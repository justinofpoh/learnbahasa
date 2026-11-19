import Foundation

// Place: Bengkel (motorbike repair). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let bliMade = Character(
        id: "bli-made",
        name: "Bli Made",
        role: "fixes bikes at the bengkel",
        register: .casual,
        addressAs: ["Bli"],
        moods: [.chatty, .busy],
        defaultMood: .chatty,
        confused: [
            Utterance("Hah? Gimana, Kak?", gloss: "Huh? How's that?"),
            Utterance("Apa, Kak? Gak dengar.", gloss: "What? Didn't catch that."),
            Utterance("Maksudnya gimana?", gloss: "Meaning what?")
        ]
    )

    static let bengkelBan = RehearsalScene(
        id: "id.bengkel.ban",
        language: "id",
        place: "Bengkel",
        title: "Ban bocor",
        titleEn: "A flat tyre at the bengkel",
        setting: "You push your scooter into a roadside bengkel. Tyres hang on the wall; a compressor hums.",
        level: .getBy,
        accent: .kunyit,
        symbol: "wrench.and.screwdriver.fill",
        character: bliMade,
        goalSummary: "Say what's wrong, choose the repair, wait, and pay.",
        goals: [
            GoalFlag(id: "problem", label: "Say what's wrong"),
            GoalFlag(id: "decided", label: "Choose the repair"),
            GoalFlag(id: "coffee", label: "Answer his offer", optional: true),
            GoalFlag(id: "paid", label: "Pay")
        ],
        warmUps: [
            WarmUp(title: "Describers go after", lessonID: "2.3"),
            WarmUp(title: "Numbers · belas & puluh", lessonID: "5.2"),
            WarmUp(title: "Particles & short forms", lessonID: "7.2")
        ],
        culture: [
            "Look for a hand-painted Tambal Ban sign. A patch usually costs Rp 10.000–20.000.",
            "In Bali, Bli (older brother) is a friendly way to address a man about your age or older."
        ],
        slots: [],
        entry: "b1",
        nodes: [
            SceneNode(
                id: "b1",
                them: Utterance("Kenapa motornya, Kak?", casual: "Kenapa, Kak?", gloss: "What's wrong with the bike?",
                                chips: "Kenapa/Q motornya/S Kak/X"),
                variants: [.busy: Utterance("Kenapa, Kak?", gloss: "What's up?")],
                replies: [
                    .natural("Bannya bocor, Bli.", "The tyre's punctured.",
                             accept: ["ban bocor", "bannya bocor", "ban saya bocor", "bannya kempes"],
                             sets: ["problem"], next: "b2", chips: "Bannya/S bocor/D Bli/X"),
                    .natural("Ban belakang bocor, Bli.", "The back tyre's punctured.",
                             accept: ["ban belakang bocor", "belakang bocor", "ban belakang kempes"],
                             sets: ["problem"], next: "b2", chips: "Ban_belakang/S bocor/D Bli/X"),
                    .natural("Bli, bisa tambal ban?", "Can you patch a tyre?",
                             accept: ["bisa tambal ban", "tambal ban bisa", "bisa tambal"],
                             sets: ["problem"], next: "b2", chips: "Bli/X bisa/H tambal/V ban/O"),
                    .understood("Ban saya tidak ada angin.", "My tyre has no air.", sets: ["problem"], next: "b2",
                                coach: "He got it! Locals say bannya bocor (punctured) or bannya kempes (flat)."),
                    .missed("Motornya bocor, Bli.", "The bike is leaking.",
                            reaction: Utterance("Bocor? Bensinnya, Kak?", gloss: "Leaking? The petrol?"),
                            coach: "bocor alone sounds like a leak. Say which part: bannya bocor.")
                ]
            ),
            SceneNode(
                id: "b2",
                narration: "He squeezes the back tyre and spins it slowly.",
                them: Utterance("Wah, ada paku. Mau ditambal atau ganti ban dalam?", casual: "Ada paku, nih. Tambal atau ganti?",
                                gloss: "Oh, there's a nail. Patch it, or a new inner tube?",
                                chips: "ada/V paku/O Mau/H ditambal/V atau/L ganti/V ban_dalam/O"),
                replies: [
                    .natural("Ditambal aja, Bli.", "Just patch it.",
                             accept: ["tambal aja", "ditambal saja", "tambal saja", "ditambal"],
                             sets: ["decided"], next: "b3", chips: "Ditambal/V aja/X Bli/X"),
                    .natural("Kalau ganti, berapa, Bli?", "How much to replace it?",
                             accept: ["kalau ganti berapa", "ganti berapa", "berapa kalau ganti"],
                             next: "b2b", chips: "Kalau/L ganti/V berapa/Q Bli/X"),
                    .missed("Saya mau paku.", "I want a nail.",
                            reaction: Utterance("Hah? Pakunya buat apa, Kak?", gloss: "Huh? What do you want the nail for?"),
                            coach: "paku is the nail that caused it. Choose: ditambal (patched) or ganti (replaced).")
                ]
            ),
            SceneNode(
                id: "b2b",
                them: Utterance("Ganti enam puluh ribu. Tapi tambal aja cukup, kok.", casual: "Ganti enam puluh. Tambal aja cukup.",
                                gloss: "A new one is sixty thousand. But a patch is enough, really.",
                                chips: "Ganti/V enam_puluh_ribu/O Tapi/L tambal/V aja/X cukup/D kok/X"),
                replies: [
                    .natural("Oke, tambal aja, Bli.", "OK, just patch it.",
                             accept: ["tambal aja", "oke tambal", "ditambal aja", "tambal saja"],
                             sets: ["decided"], next: "b3", chips: "Oke/X tambal/V aja/X"),
                    .natural("Terserah Bli aja.", "Whatever you think.",
                             accept: ["terserah bli", "terserah", "terserah aja"],
                             sets: ["decided"], next: "b3", chips: "Terserah/X Bli/S aja/X"),
                    .missed("Saya mau ganti motor.", "I want to change my motorbike.",
                            reaction: Utterance("Hahaha, ganti motor? Ban aja, Kak!", gloss: "Haha, a new bike? Just the tyre!"),
                            coach: "ganti motor is a whole new bike! He means ban dalam, the inner tube.")
                ]
            ),
            SceneNode(
                id: "b3",
                them: Utterance("Oke. Tunggu sebentar, ya. Lima belas menit.", casual: "Tunggu bentar, ya. Lima belas menit.",
                                gloss: "OK. Wait a moment. Fifteen minutes.",
                                chips: "Tunggu/V sebentar/T ya/X Lima_belas_menit/T"),
                variants: [.busy: Utterance("Tunggu, ya. Ada dua motor dulu.", gloss: "Wait, there are two bikes ahead of you.")],
                replies: [
                    .natural("Oke, saya tunggu di sini.", "OK, I'll wait here.",
                             accept: ["saya tunggu di sini", "tunggu di sini", "oke saya tunggu"],
                             next: "b3c", moodNext: [.busy: "b4"], chips: "Saya/S tunggu/V di_sini/X"),
                    .natural("Saya titip dulu, ya. Nanti balik lagi.", "I'll leave it with you. I'll be back.",
                             accept: ["saya titip dulu", "titip dulu", "nanti balik lagi", "titip dulu ya"],
                             next: "b4", chips: "Saya/S titip/V dulu/T Nanti/T balik/V lagi/T"),
                    .missed("Lima puluh menit?", "Fifty minutes?",
                            reaction: Utterance("Lima belas, Kak. Sebentar aja.", gloss: "Fifteen. Just a moment."),
                            coach: "belas is the teens: lima belas is 15, lima puluh is 50.")
                ]
            ),
            SceneNode(
                id: "b3c",
                them: Utterance("Sambil nunggu, mau kopi?", casual: "Ngopi dulu, Kak?",
                                gloss: "Want a coffee while you wait?", chips: "Sambil/L nunggu/V mau/H kopi/O"),
                replies: [
                    .natural("Boleh, makasih, Bli!", "Sure, thanks!",
                             accept: ["boleh makasih", "boleh", "mau makasih"],
                             sets: ["coffee"], next: "b4", chips: "Boleh/H makasih/X Bli/X"),
                    .natural("Gak usah, makasih, Bli.", "No need, thanks.",
                             accept: ["gak usah makasih", "gak usah", "tidak usah terima kasih"],
                             sets: ["coffee"], next: "b4", chips: "Gak_usah/N makasih/X Bli/X"),
                    .missed("Kopinya berapa?", "How much is the coffee?",
                            reaction: Utterance("Hehe, gratis, Kak!", gloss: "Heh, it's free!"),
                            coach: "He's offering, not selling. Accept with Boleh, makasih, or decline with Gak usah, makasih.")
                ]
            ),
            SceneNode(
                id: "b4",
                narration: "A little later.",
                them: Utterance("Udah beres, Kak. Lima belas ribu.", casual: "Beres, Kak. Lima belas.",
                                gloss: "All done. Fifteen thousand.", chips: "Udah/T beres/D Lima_belas_ribu/O"),
                replies: [
                    .natural("Ini, Bli. Makasih banyak!", "Here you go. Thanks a lot!",
                             accept: ["ini makasih", "makasih banyak", "ini bli makasih banyak"],
                             sets: ["paid"], next: "end", chips: "Ini/S Bli/X Makasih_banyak/X"),
                    .natural("Mantap. Ini uangnya, Bli.", "Great. Here's the money.",
                             accept: ["ini uangnya", "mantap ini uangnya"],
                             sets: ["paid"], next: "end", chips: "Mantap/D Ini/S uangnya/O"),
                    .off("Wah, mahal. Sepuluh ribu, ya?", "That's a lot. Ten thousand?",
                         reaction: Utterance("Tambal di mana-mana segitu, Kak.", gloss: "A patch costs that everywhere."),
                         coach: "Fifteen thousand is the going rate. Haggling over a small repair comes across as stingy.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Sip! Hati-hati di jalan, Kak.", gloss: "Great! Ride safe.",
                                chips: "Sip/X Hati-hati/D di/X jalan/O"),
                variants: [.busy: Utterance("Oke, makasih, Kak.", gloss: "OK, thanks.")]
            )
        ],
        listening: [
            ListeningCheck(question: "What was in the tyre?",
                           options: ["A nail", "Broken glass", "A stone"], answer: "A nail"),
            ListeningCheck(question: "How long did he say it would take?",
                           options: ["Fifteen minutes", "Fifty minutes", "An hour"], answer: "Fifteen minutes"),
            ListeningCheck(question: "How much was the repair?",
                           options: ["Rp 15.000", "Rp 50.000", "Rp 60.000"], answer: "Rp 15.000")
        ]
    )
}
