import Foundation

// Place: Laundry (laundry kiloan). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let mbokKadek = Character(
        id: "mbok-kadek",
        name: "Mbok Kadek",
        role: "runs the laundry next door",
        register: .neutral,
        addressAs: ["Mbok"],
        moods: [.warm, .busy],
        defaultMood: .warm,
        confused: [
            Utterance("Maaf, gimana, Kak?", gloss: "Sorry, how's that?"),
            Utterance("Hmm? Mau apa, Kak?", gloss: "Hmm? What would you like?"),
            Utterance("Maaf, kurang ngerti, Kak.", gloss: "Sorry, I don't quite follow.")
        ]
    )

    static let laundryKiloan = RehearsalScene(
        id: "id.laundry.kiloan",
        language: "id",
        place: "Laundry",
        title: "Laundry kiloan",
        titleEn: "Dropping off your laundry",
        setting: "A tiny shopfront that smells of soap. Folded stacks on the shelves, a scale on the counter.",
        level: .survive,
        accent: .indigo,
        symbol: "washer.fill",
        character: mbokKadek,
        goalSummary: "Hand in your clothes, pick the service, and find out when to collect them.",
        goals: [
            GoalFlag(id: "dropped", label: "Hand in your laundry"),
            GoalFlag(id: "when", label: "Ask when it's ready"),
            GoalFlag(id: "express", label: "Ask for express", optional: true)
        ],
        warmUps: [
            WarmUp(title: "Numbers · puluh & belas", lessonID: "5.2"),
            WarmUp(title: "Questions · kapan", lessonID: "5.1"),
            WarmUp(title: "Days and plans · besok", lessonID: "3.4")
        ],
        culture: [
            "Laundry kiloan charges by weight at a posted rate. Cuci kering is wash and dry; cuci setrika adds ironing.",
            "Keep the nota (receipt): you show it to collect. In Bali, Mbok is a friendly way to address a woman."
        ],
        slots: [],
        entry: "l1",
        nodes: [
            SceneNode(
                id: "l1",
                them: Utterance("Halo, Kak. Mau laundry?", casual: "Laundry, Kak?",
                                gloss: "Hi. Laundry?", chips: "Halo/X Kak/X Mau/H laundry/O"),
                variants: [.busy: Utterance("Ya, Kak? Laundry?", gloss: "Yes? Laundry?")],
                replies: [
                    .natural("Iya, Mbok. Cuci setrika, ya.", "Yes. Wash and iron, please.",
                             accept: ["cuci setrika", "iya cuci setrika", "cuci setrika ya"],
                             sets: ["dropped"], next: "l2", chips: "Iya/X Mbok/X Cuci/V setrika/V ya/X"),
                    .natural("Iya, Mbok. Cuci kering aja.", "Yes. Just wash and dry.",
                             accept: ["cuci kering aja", "cuci kering saja", "cuci kering"],
                             sets: ["dropped"], next: "l2", chips: "Iya/X Mbok/X Cuci/V kering/D aja/X"),
                    .natural("Iya, Mbok. Setrika aja, ya.", "Yes. Just ironing, please.",
                             accept: ["setrika aja", "setrika saja", "setrika aja ya"],
                             sets: ["dropped"], next: "l2", chips: "Iya/X Mbok/X Setrika/V aja/X ya/X"),
                    .understood("Saya ingin mencuci pakaian saya.", "I would like to wash my clothes.",
                                sets: ["dropped"], next: "l2",
                                coach: "Clear, but bookish. At a laundry, just name the service: Cuci setrika, ya."),
                    .missed("Iya, saya mau mandi.", "Yes, I want to shower.",
                            reaction: Utterance("Hah? Mandi di sini, Kak?", gloss: "Huh? Shower here?"),
                            coach: "mandi is washing yourself. For clothes it's cuci: cuci setrika, cuci kering.")
                ]
            ),
            SceneNode(
                id: "l2",
                narration: "She weighs your bag.",
                them: Utterance("Tiga kilo, ya. Jadi tiga puluh ribu.", casual: "Tiga kilo, tiga puluh ribu.",
                                gloss: "Three kilos. That's thirty thousand.",
                                chips: "Tiga_kilo/O ya/X Jadi/L tiga_puluh_ribu/O"),
                focus: "numbers",
                replies: [
                    .natural("Oke. Kapan selesai, Mbok?", "OK. When will it be ready?",
                             accept: ["kapan selesai", "oke kapan selesai", "kapan jadi", "selesai kapan"],
                             sets: ["when"], next: "l3", chips: "Oke/X Kapan/Q selesai/V Mbok/X"),
                    .natural("Ada yang kilat, Mbok?", "Do you have express?",
                             accept: ["ada yang kilat", "ada kilat", "bisa kilat"],
                             sets: ["when"], next: "l3b", chips: "Ada/V yang/L kilat/D Mbok/X"),
                    .missed("Tiga belas ribu?", "Thirteen thousand?",
                            reaction: Utterance("Tiga puluh, Kak. Tiga puluh ribu.", gloss: "Thirty. Thirty thousand."),
                            coach: "belas is the teens (tiga belas, 13); puluh is the tens (tiga puluh, 30)."),
                    .off("Mahal, ya. Bisa kurang?", "That's a lot. Can you go lower?",
                         reaction: Utterance("Harganya per kilo, Kak.", gloss: "The price is per kilo."),
                         coach: "Laundry kiloan has a posted rate per kilo. Haggling here sounds odd.")
                ]
            ),
            SceneNode(
                id: "l3",
                them: Utterance("Besok sore udah bisa diambil.", casual: "Besok sore, Kak.",
                                gloss: "You can pick it up tomorrow afternoon.",
                                chips: "Besok/T sore/T udah/T bisa/H diambil/V"),
                variants: [.busy: Utterance("Besok sore, ya.", gloss: "Tomorrow afternoon.")],
                replies: [
                    .natural("Oke, makasih, Mbok. Sampai besok.", "OK, thanks. See you tomorrow.",
                             accept: ["makasih sampai besok", "oke makasih", "sampai besok"],
                             next: "end", chips: "Oke/X makasih/X Mbok/X Sampai_besok/T"),
                    .natural("Sip, besok sore saya ambil.", "Great, I'll collect it tomorrow afternoon.",
                             accept: ["besok sore saya ambil", "sip besok saya ambil", "besok saya ambil"],
                             next: "end", chips: "Sip/X besok_sore/T saya/S ambil/V"),
                    .missed("Besok pagi, ya?", "Tomorrow morning?",
                            reaction: Utterance("Sore, Kak. Besok sore.", gloss: "Afternoon. Tomorrow afternoon."),
                            coach: "pagi is morning; sore is late afternoon."),
                    .missed("Kemarin sore, ya?", "Yesterday afternoon?",
                            reaction: Utterance("Kemarin? Besok, Kak!", gloss: "Yesterday? Tomorrow!"),
                            coach: "kemarin is yesterday; besok is tomorrow.")
                ]
            ),
            SceneNode(
                id: "l3b",
                them: Utterance("Ada. Kilat enam jam, tapi tambah lima belas ribu.", casual: "Ada, enam jam. Tambah lima belas.",
                                gloss: "Yes. Express is six hours, but fifteen thousand extra.",
                                chips: "Ada/V Kilat/D enam_jam/T tapi/L tambah/V lima_belas_ribu/O"),
                replies: [
                    .natural("Oke, kilat aja, Mbok.", "OK, express then.",
                             accept: ["kilat aja", "yang kilat", "oke kilat", "kilat saja"],
                             sets: ["express"], next: "endKilat", chips: "Oke/X kilat/D aja/X"),
                    .natural("Gak usah, yang biasa aja.", "No need, the regular one's fine.",
                             accept: ["yang biasa aja", "biasa aja", "gak usah", "yang biasa saja"],
                             next: "l3", chips: "Gak_usah/N yang/L biasa/D aja/X"),
                    .missed("Tambah lima puluh ribu?", "Fifty thousand extra?",
                            reaction: Utterance("Lima belas, Kak, bukan lima puluh.", gloss: "Fifteen, not fifty."),
                            coach: "lima belas is 15; lima puluh is 50.")
                ]
            ),
            SceneNode(
                id: "endKilat",
                them: Utterance("Siap, Kak! Jam enam sore udah jadi. Jangan lupa notanya, ya.",
                                gloss: "Sure! Ready by six this evening. Don't forget your receipt.",
                                chips: "Jam_enam_sore/T udah/T jadi/V Jangan/N lupa/V notanya/O")
            ),
            SceneNode(
                id: "end",
                them: Utterance("Sama-sama, Kak. Jangan lupa notanya, ya!", gloss: "You're welcome. Don't forget your receipt!",
                                chips: "Sama-sama/X Jangan/N lupa/V notanya/O ya/X"),
                variants: [.busy: Utterance("Iya, Kak. Ini notanya.", gloss: "Sure. Here's your receipt.")]
            )
        ],
        listening: [
            ListeningCheck(question: "How heavy was your laundry?",
                           options: ["Three kilos", "Thirteen kilos", "Thirty kilos"], answer: "Three kilos"),
            ListeningCheck(question: "How much did it cost?",
                           options: ["Rp 30.000", "Rp 13.000", "Rp 3.000"], answer: "Rp 30.000"),
            ListeningCheck(question: "When can you collect it?",
                           options: ["Tomorrow afternoon", "Tonight", "Next week"], answer: "Tomorrow afternoon")
        ]
    )
}
