import Foundation

/// The progress document stored per account (Supabase table `progress`, column `data`).
/// The website reads and writes `lessons`, `xp`, `chats` and `profile`; the app also keeps a full
/// backup under `app`. Merging never loses anything: sets are unioned, numbers take the higher value.
struct SyncDocument: Codable, Equatable {
    var v = 1
    var lessons: [String] = []
    var xp = 0
    var chats: [String: ChatMark] = [:]
    var profile: SyncProfile?
    var app: AppBackup?

    struct ChatMark: Codable, Equatable {
        var stars = 0
        var lived = false
    }

    struct SyncProfile: Codable, Equatable {
        var name: String?
        var country: String?
        var city: String?
        var avatar: String?
        var level: Int?
    }

    /// Everything the iPhone app keeps, so a new phone gets saved lines and the review queue back too.
    struct AppBackup: Codable, Equatable {
        var progress: ProgressStore.State
        var rehearsal: RehearsalState
        var updatedAt: Date

        static func == (a: AppBackup, b: AppBackup) -> Bool { a.updatedAt == b.updatedAt }
    }

    init() {}

    // Tolerant decoding: the website writes only some fields, and older documents may lack new ones.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        v = (try? c.decodeIfPresent(Int.self, forKey: .v)) ?? 1
        lessons = (try? c.decodeIfPresent([String].self, forKey: .lessons)) ?? []
        xp = (try? c.decodeIfPresent(Int.self, forKey: .xp)) ?? 0
        chats = (try? c.decodeIfPresent([String: ChatMark].self, forKey: .chats)) ?? [:]
        profile = try? c.decodeIfPresent(SyncProfile.self, forKey: .profile)
        app = try? c.decodeIfPresent(AppBackup.self, forKey: .app)
    }

    private enum CodingKeys: String, CodingKey { case v, lessons, xp, chats, profile, app }
}

// MARK: - Merging

enum SyncMerge {
    /// Builds the document that describes this device.
    static func document(progress: ProgressStore.State, rehearsal: RehearsalState) -> SyncDocument {
        var doc = SyncDocument()
        doc.lessons = progress.lessonsDone.sorted()
        doc.xp = progress.xp
        for (id, record) in rehearsal.scenes where record.stars > 0 || record.lived || record.watched {
            doc.chats[id] = .init(stars: max(record.stars, record.watched ? 1 : 0), lived: record.lived)
        }
        let p = rehearsal.profile
        doc.profile = .init(name: p.name.nilIfEmpty, country: p.country.nilIfEmpty, city: p.city.nilIfEmpty,
                            avatar: p.avatar.nilIfEmpty, level: p.level >= 0 ? p.level : nil)
        doc.app = .init(progress: progress, rehearsal: rehearsal, updatedAt: Date())
        return doc
    }

    /// Combines what's on this device with what's in the account.
    static func merge(local: (ProgressStore.State, RehearsalState), remote: SyncDocument)
        -> (ProgressStore.State, RehearsalState) {
        var progress = local.0
        var rehearsal = local.1

        // Full backup from another iPhone first, so its saved lines and review items come along.
        if let backup = remote.app {
            progress = mergeProgress(progress, backup.progress)
            rehearsal = mergeRehearsal(rehearsal, backup.rehearsal)
        }

        // Then what the website (or any device) recorded.
        progress.lessonsDone.formUnion(remote.lessons)
        progress.xp = max(progress.xp, remote.xp)
        for (id, mark) in remote.chats where SceneLibrary.scene(id) != nil {
            rehearsal.update(id) { record in
                if mark.stars > record.stars { record.stars = mark.stars }
                if mark.stars > 0 { record.watched = true }
                if mark.lived { record.lived = true }
            }
        }
        if let p = remote.profile {
            if rehearsal.profile.name.isEmpty, let v = p.name { rehearsal.profile.name = v }
            if rehearsal.profile.country.isEmpty, let v = p.country { rehearsal.profile.country = v }
            if rehearsal.profile.city.isEmpty, let v = p.city { rehearsal.profile.city = v }
            if rehearsal.profile.avatar.isEmpty, let v = p.avatar { rehearsal.profile.avatar = v }
            if rehearsal.profile.level < 0, let v = p.level { rehearsal.profile.level = v }
        }
        return (progress, rehearsal)
    }

    static func mergeProgress(_ a: ProgressStore.State, _ b: ProgressStore.State) -> ProgressStore.State {
        var out = a
        out.lessonsDone.formUnion(b.lessonsDone)
        out.scenariosDone.formUnion(b.scenariosDone)
        out.xp = max(a.xp, b.xp)
        // The streak belongs to whichever device was used most recently.
        if b.lastActiveDay > a.lastActiveDay {
            out.lastActiveDay = b.lastActiveDay
            out.streak = b.streak
            out.todayXP = b.todayXP
        } else if b.lastActiveDay == a.lastActiveDay {
            out.streak = max(a.streak, b.streak)
            out.todayXP = max(a.todayXP, b.todayXP)
        }
        return out
    }

    static func mergeRehearsal(_ a: RehearsalState, _ b: RehearsalState) -> RehearsalState {
        var out = a
        for (id, theirs) in b.scenes {
            out.update(id) { mine in
                mine.watched = mine.watched || theirs.watched
                mine.stars = max(mine.stars, theirs.stars)
                mine.performPassed = mine.performPassed || theirs.performPassed
                mine.clearedMoods.formUnion(theirs.clearedMoods)
                mine.lived = mine.lived || theirs.lived
                mine.rehearsals = max(mine.rehearsals, theirs.rehearsals)
                if mine.liveIssuedAt == nil { mine.liveIssuedAt = theirs.liveIssuedAt }
                let known = Set(mine.checkins.map(\.id))
                mine.checkins += theirs.checkins.filter { !known.contains($0.id) }
            }
        }
        let lineIDs = Set(out.lines.map(\.id))
        out.lines += b.lines.filter { !lineIDs.contains($0.id) }
        let recallIDs = Set(out.recall.map(\.id))
        out.recall += b.recall.filter { !recallIDs.contains($0.id) && SceneLibrary.scene($0.sceneID)?.node($0.nodeID) != nil }
        if out.profile.name.isEmpty { out.profile.name = b.profile.name }
        if out.profile.country.isEmpty { out.profile.country = b.profile.country }
        if out.profile.city.isEmpty { out.profile.city = b.profile.city }
        if out.profile.avatar.isEmpty { out.profile.avatar = b.profile.avatar }
        if out.profile.level < 0 { out.profile.level = b.profile.level }
        return out
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
