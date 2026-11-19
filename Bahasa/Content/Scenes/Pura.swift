import Foundation

// Place: Pura (temple visit). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let bliKomang = Character(
        id: "bli-komang",
        name: "Bli Komang",
        role: "looks after visitors at the temple gate",
        register: .neutral,
        addressAs: ["Bli"],
        moods: [.warm, .chatty],
        defaultMood: .warm,
        confused: [
            Utterance("Maaf, gimana, Kak?", gloss: "Sorry, how's that?"),
            Utterance("Hmm? Mau masuk, Kak?", gloss: "Hmm? Want to come in?"),
            Utterance("Maaf, kurang ngerti, Kak.", gloss: "Sorry, I don't quite follow.")
        ]
    )

    static let puraKamen = RehearsalScene(
        id: "id.pura.kamen",
        language: "id",
        place: "Pura",
        title: "Masuk pura",
        titleEn: "Visiting a temple",
        setting: "Stone steps up to a split gate. Yellow umbrellas, offerings, and a man with a pile of folded kamen.",
        level: .getBy,
        accent: .kunyit,
        symbol: "building.columns.fill",
        character: bliKomang,
        goalSummary: "Greet him, ask to go in, borrow a kamen, make a donation, and check the rules.",
        goals: [
            GoalFlag(id: "asked", label: "Ask to go in"),
            GoalFlag(id: "kamen", label: "Borrow a kamen"),
            GoalFlag(id: "donated", label: "Make a donation"),
            GoalFlag(id: "photo", label: "Ask about photos", optional: true)
        ],
        warmUps: [
            WarmUp(title: "Bali manners", lessonID: "10.1"),
            WarmUp(title: "Helper words · boleh, harus", lessonID: "7.1"),
            WarmUp(title: "Everyday no · jangan", lessonID: "4.2")
        ],
        culture: [
            "Every visitor wears a kamen (sarong) and selendang (sash). Most temples lend them for a small donation.",
            "Don't walk in front of people who are praying, and don't climb on shrines or walls."
        ],
        slots: [],
        entry: "r1",
        nodes: [
            SceneNode(
                id: "r1",
                them: Utterance("Om Swastiastu. Mau masuk, Kak?", casual: "Om Swastiastu. Masuk, Kak?",
                                gloss: "Hello (Balinese). Want to come in?", chips: "Om_Swastiastu/X Mau/H masuk/V"),
                variants: [.chatty: Utterance("Om Swastiastu! Dari mana, Kak? Mau masuk?",
                                              gloss: "Hello! Where are you from? Want to come in?")],
                replies: [
                    .natural("Om Swastiastu, Bli. Boleh masuk?", "Hello. May I come in?",
                             accept: ["om swastiastu boleh masuk", "boleh masuk", "om swastiastu"],
                             sets: ["asked"], next: "r2", chips: "Om_Swastiastu/X Bli/X Boleh/H masuk/V"),
                    .natural("Iya, Bli. Boleh masuk?", "Yes. May I come in?",
                             accept: ["iya boleh masuk", "boleh saya masuk"],
                             sets: ["asked"], next: "r2", chips: "Iya/X Bli/X Boleh/H masuk/V"),
                    .understood("Halo. Saya mau masuk.", "Hi. I want to go in.", sets: ["asked"], next: "r2",
                                coach: "He'll let you in. Returning his Om Swastiastu, and asking with boleh, earns a big smile."),
                    .missed("Selamat tinggal, Bli.", "Goodbye.",
                            reaction: Utterance("Lho, sudah mau pulang?", gloss: "Oh, leaving already?"),
                            coach: "selamat tinggal is goodbye. Reply to the greeting with the greeting: Om Swastiastu.")
                ]
            ),
            SceneNode(
                id: "r2",
                them: Utterance("Boleh. Tapi harus pakai kamen dan selendang, ya.", casual: "Boleh, tapi pakai kamen, ya.",
                                gloss: "Sure. But you have to wear a kamen and a sash.",
                                chips: "Boleh/H Tapi/L harus/H pakai/V kamen/O dan/L selendang/O"),
                replies: [
                    .natural("Saya gak punya. Bisa pinjam di sini?", "I don't have one. Can I borrow one here?",
                             accept: ["bisa pinjam di sini", "saya gak punya bisa pinjam", "bisa pinjam"],
                             sets: ["kamen"], next: "r3", chips: "Saya/S gak/N punya/V Bisa/H pinjam/V di_sini/X"),
                    .natural("Oh, pinjam di mana, Bli?", "Oh, where can I borrow one?",
                             accept: ["pinjam di mana", "kamennya pinjam di mana"],
                             sets: ["kamen"], next: "r3", chips: "Pinjam/V di_mana/Q Bli/X"),
                    .natural("Ada, Bli. Saya bawa sendiri.", "I've got one. I brought my own.",
                             accept: ["saya bawa sendiri", "bawa sendiri", "ada saya bawa"],
                             sets: ["kamen"], next: "r3b", chips: "Ada/V Saya/S bawa/V sendiri/X"),
                    .off("Gak usah, Bli. Saya cuma foto-foto.", "No need. I'm only taking photos.",
                         reaction: Utterance("Maaf, Kak. Tetap harus pakai.", gloss: "Sorry. You still have to wear one."),
                         coach: "Everyone wears a kamen inside, even just to look. Ask to borrow one: Bisa pinjam di sini?")
                ]
            ),
            SceneNode(
                id: "r3",
                them: Utterance("Bisa. Pinjam di sini, donasi seikhlasnya.", casual: "Bisa, Kak. Donasinya seikhlasnya.",
                                gloss: "Sure. Borrow one here, for whatever donation you like.",
                                chips: "Bisa/H Pinjam/V di_sini/X donasi/O seikhlasnya/D"),
                replies: [
                    .natural("Biasanya berapa, Bli?", "How much do people usually give?",
                             accept: ["biasanya berapa", "berapa biasanya"],
                             next: "r3b", chips: "Biasanya/T berapa/Q Bli/X"),
                    .natural("Oke, ini donasinya, Bli.", "OK, here's my donation.",
                             accept: ["ini donasinya", "oke ini donasinya"],
                             sets: ["donated"], next: "r4", chips: "Oke/X ini/S donasinya/O Bli/X"),
                    .off("Gak usah donasi, ya.", "I'll skip the donation.",
                         reaction: Utterance("Hmm… seikhlasnya aja, Kak.", gloss: "Hmm… whatever you like, really."),
                         coach: "Pay-what-you-like still means paying something. Rp 10.000–20.000 is usual.")
                ]
            ),
            SceneNode(
                id: "r3b",
                them: Utterance("Donasinya biasanya dua puluh ribu, Kak.", casual: "Biasanya dua puluh ribu.",
                                gloss: "People usually give twenty thousand.",
                                chips: "Donasinya/S biasanya/T dua_puluh_ribu/O"),
                replies: [
                    .natural("Oke, ini, Bli.", "OK, here you go.", accept: ["oke ini", "ini bli"],
                             sets: ["donated"], next: "r4", chips: "Oke/X ini/S Bli/X"),
                    .natural("Sip. Ini dua puluh ribu.", "Great. Here's twenty thousand.",
                             accept: ["ini dua puluh ribu", "dua puluh ribu"],
                             sets: ["donated"], next: "r4", chips: "Sip/X Ini/S dua_puluh_ribu/O"),
                    .missed("Dua belas ribu?", "Twelve thousand?",
                            reaction: Utterance("Dua puluh, Kak. Tapi seikhlasnya, kok.", gloss: "Twenty. But really, whatever you like."),
                            coach: "dua belas is 12; dua puluh is 20.")
                ]
            ),
            SceneNode(
                id: "r4",
                narration: "He ties the sash around your waist.",
                them: Utterance("Nah, sudah rapi. Jangan lewat di depan orang sembahyang, ya.",
                                casual: "Udah rapi. Jangan lewat depan orang sembahyang, ya.",
                                gloss: "There, all neat. Don't walk in front of people praying.",
                                chips: "Sudah/T rapi/D Jangan/N lewat/V di_depan/X orang/S sembahyang/V"),
                variants: [.chatty: Utterance("Nah, cocok! Jangan lewat di depan orang sembahyang, ya.",
                                              gloss: "There, it suits you! Don't walk in front of people praying.")],
                replies: [
                    .natural("Siap, Bli. Boleh foto di dalam?", "Will do. May I take photos inside?",
                             accept: ["boleh foto di dalam", "boleh foto", "siap boleh foto"],
                             sets: ["photo"], next: "r5", chips: "Siap/D Bli/X Boleh/H foto/V di_dalam/X"),
                    .natural("Baik, Bli. Terima kasih banyak!", "Of course. Thank you so much!",
                             accept: ["baik terima kasih banyak", "terima kasih banyak", "baik bli"],
                             next: "end", chips: "Baik/D Bli/X Terima_kasih/X banyak/D"),
                    .natural("Oke, Bli. Suksma!", "OK. Thank you! (Balinese)",
                             accept: ["oke suksma", "suksma bli", "suksma"],
                             next: "end", chips: "Oke/X Bli/X Suksma/X"),
                    .missed("Jangan masuk?", "Don't go in?",
                            reaction: Utterance("Boleh masuk, Kak. Cuma jangan lewat di depan orang sembahyang.",
                                                gloss: "You can go in. Just don't walk in front of people praying."),
                            coach: "jangan covers only what follows it: don't walk in front of people praying.")
                ]
            ),
            SceneNode(
                id: "r5",
                them: Utterance("Boleh, tapi jangan foto orang sembahyang, ya.", casual: "Boleh, asal jangan foto orang sembahyang.",
                                gloss: "Yes, but don't photograph people praying.",
                                chips: "Boleh/H tapi/L jangan/N foto/V orang/S sembahyang/V"),
                replies: [
                    .natural("Oke, Bli. Suksma!", "OK. Thank you! (Balinese)",
                             accept: ["oke suksma", "suksma bli", "suksma"],
                             next: "end", chips: "Oke/X Bli/X Suksma/X"),
                    .natural("Siap, makasih, Bli.", "Will do, thanks.",
                             accept: ["siap makasih", "makasih bli"],
                             next: "end", chips: "Siap/D makasih/X Bli/X"),
                    .missed("Om Swastiastu!", "Hello!",
                            reaction: Utterance("Hehe, itu salam, Kak. Kalau terima kasih, suksma.", gloss: "Heh, that's hello. Thank you is suksma."),
                            coach: "Om Swastiastu is the greeting. Thank you in Balinese is suksma.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Sama-sama. Selamat jalan-jalan, Kak!", gloss: "You're welcome. Enjoy your visit!",
                                chips: "Sama-sama/X Selamat/X jalan-jalan/V"),
                variants: [.chatty: Utterance("Suksma, Kak! Pakai kamen cocok, lho!", gloss: "Thank you! The kamen really suits you!")]
            )
        ],
        listening: [
            ListeningCheck(question: "What do you have to wear?",
                           options: ["A kamen and a sash", "A hat", "Long sleeves and shoes"], answer: "A kamen and a sash"),
            ListeningCheck(question: "How much do people usually donate?",
                           options: ["Rp 20.000", "Rp 12.000", "Rp 200.000"], answer: "Rp 20.000"),
            ListeningCheck(question: "What shouldn't you do inside?",
                           options: ["Walk in front of people praying", "Speak Indonesian", "Take off your shoes"],
                           answer: "Walk in front of people praying")
        ]
    )
}
