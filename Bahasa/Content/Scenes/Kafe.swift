import Foundation

// Place: Kafe (coffee shop). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let masDimas = Character(
        id: "mas-dimas",
        name: "Mas Dimas",
        role: "barista at a café in Canggu",
        register: .casual,
        addressAs: ["Mas"],
        moods: [.chatty, .busy],
        defaultMood: .chatty,
        confused: [
            Utterance("Sori, gimana, Kak?", gloss: "Sorry, how's that?"),
            Utterance("Hmm? Mau pesan apa, Kak?", gloss: "Hmm? What would you like?"),
            Utterance("Maaf, gak dengar, Kak. Rame.", gloss: "Sorry, didn't catch that. It's noisy.")
        ]
    )

    static let kafeKopi = RehearsalScene(
        id: "id.kafe.kopi",
        language: "id",
        place: "Kafe",
        title: "Pesan kopi",
        titleEn: "Ordering coffee",
        setting: "A busy café. The grinder whirs, and the barista looks up from the espresso machine.",
        level: .getBy,
        accent: .kopi,
        symbol: "mug.fill",
        character: masDimas,
        goalSummary: "Order your coffee the way you like it, give a name for the order, and pay.",
        goals: [
            GoalFlag(id: "ordered", label: "Order a coffee"),
            GoalFlag(id: "sugar", label: "Say how sweet"),
            GoalFlag(id: "name", label: "Give your name"),
            GoalFlag(id: "wifi", label: "Ask about wifi", optional: true),
            GoalFlag(id: "paid", label: "Pay")
        ],
        warmUps: [
            WarmUp(title: "Ordering · pakai, tanpa", lessonID: "8.1"),
            WarmUp(title: "Taste · manis, kurang", lessonID: "8.2"),
            WarmUp(title: "Paying", lessonID: "5.4")
        ],
        culture: [
            "Es kopi susu (iced milk coffee, often with palm sugar) is the everyday favourite. Cafés usually ask how sweet you want it.",
            "Call a young man serving you Mas. Cafés often take your name and call it out when the drink is ready."
        ],
        slots: [.name],
        entry: "f1",
        nodes: [
            SceneNode(
                id: "f1",
                them: Utterance("Halo, Kak! Mau pesan apa?", casual: "Pesan apa, Kak?",
                                gloss: "Hi! What can I get you?", chips: "Mau/H pesan/V apa/Q"),
                variants: [.busy: Utterance("Ya, Kak? Pesan apa?", gloss: "Yes? What'll it be?")],
                replies: [
                    .natural("Es kopi susu satu, Mas.", "One iced milk coffee, please.",
                             accept: ["es kopi susu satu", "es kopi susu", "satu es kopi susu"],
                             sets: ["ordered"], next: "f2", chips: "Es_kopi_susu/O satu/X Mas/X"),
                    .natural("Kopi susu panas satu, ya.", "One hot milk coffee, please.",
                             accept: ["kopi susu panas satu", "kopi susu panas", "kopi panas satu"],
                             sets: ["ordered"], next: "f2", chips: "Kopi_susu/O panas/D satu/X ya/X"),
                    .natural("Mas, americano dingin satu.", "An iced americano, please.",
                             accept: ["americano dingin satu", "americano dingin", "americano satu"],
                             sets: ["ordered"], next: "f2", chips: "Mas/X americano/O dingin/D satu/X"),
                    .understood("Saya mau satu kopi.", "I want one coffee.", sets: ["ordered"], next: "f2",
                                coach: "He'll ask which one. Name the drink, and put the number after it: Es kopi susu satu."),
                    .missed("Saya kopi, Mas.", "I am coffee.",
                            reaction: Utterance("Hehe, kopinya apa, Kak?", gloss: "Heh, which coffee?"),
                            coach: "Without mau, it sounds like \"I am coffee\". Name the drink: Es kopi susu satu, Mas.")
                ]
            ),
            SceneNode(
                id: "f2",
                them: Utterance("Manisnya normal atau kurang manis?", casual: "Gulanya normal?",
                                gloss: "Regular sweetness or less sweet?",
                                chips: "Manisnya/S normal/D atau/L kurang/D manis/D"),
                variants: [.busy: Utterance("Gula normal?", gloss: "Regular sugar?")],
                replies: [
                    .natural("Kurang manis, ya.", "Less sweet, please.",
                             accept: ["kurang manis", "kurang manis mas", "agak kurang manis"],
                             sets: ["sugar"], next: "f3", chips: "Kurang/D manis/D ya/X"),
                    .natural("Gak pakai gula, Mas.", "No sugar, please.",
                             accept: ["gak pakai gula", "tanpa gula", "tidak pakai gula"],
                             sets: ["sugar"], next: "f3", chips: "Gak/N pakai/V gula/O Mas/X"),
                    .natural("Normal aja, Mas.", "Regular is fine.",
                             accept: ["normal aja", "normal saja", "normal"],
                             sets: ["sugar"], next: "f3", chips: "Normal/D aja/X Mas/X"),
                    .missed("Manis tidak.", "Sweet no.",
                            reaction: Utterance("Manis… atau gak?", gloss: "Sweet… or not?"),
                            coach: "tidak goes before the word: tidak manis. Or: Gak pakai gula."),
                    .missed("Lebih kurang manis.", "More less sweet.",
                            reaction: Utterance("Hmm? Kurang manis, ya?", gloss: "Hmm? Less sweet, you mean?"),
                            coach: "kurang already means less. Just: Kurang manis.")
                ]
            ),
            SceneNode(
                id: "f3",
                them: Utterance("Atas nama siapa, Kak?", casual: "Namanya, Kak?",
                                gloss: "What name is it under?", chips: "Atas_nama/X siapa/Q"),
                replies: [
                    .natural("{name}, Mas.", "{name}.", accept: ["{name}"],
                             sets: ["name"], next: "f4", chips: "{name}/O Mas/X"),
                    .natural("Atas nama {name}.", "Under {name}.", accept: ["atas nama {name}", "nama {name}"],
                             sets: ["name"], next: "f4", chips: "Atas_nama/X {name}/O"),
                    .understood("Nama saya adalah {name}.", "My name is {name}.", sets: ["name"], next: "f4",
                                coach: "He's got it. For an order, just the name is enough: {name}, Mas. And adalah is never needed here."),
                    .missed("Siapa nama Mas?", "What's your name?",
                            reaction: Utterance("Hehe, Dimas. Kalau Kakak?", gloss: "Heh, Dimas. And you?"),
                            coach: "atas nama siapa asks for YOUR name for the order. Answer: {name}, Mas.")
                ]
            ),
            SceneNode(
                id: "f4",
                them: Utterance("Minum di sini atau dibawa?", casual: "Sini atau take away?",
                                gloss: "For here or to take away?", chips: "Minum/V di_sini/X atau/L dibawa/V"),
                replies: [
                    .natural("Minum sini, Mas.", "For here.",
                             accept: ["minum sini", "minum di sini", "di sini"],
                             next: "f4b", moodNext: [.busy: "f5"], chips: "Minum/V sini/X Mas/X"),
                    .natural("Dibawa, ya.", "To take away, please.",
                             accept: ["dibawa", "dibawa aja", "bawa pulang"],
                             next: "f5", chips: "Dibawa/V ya/X"),
                    .natural("Take away aja, Mas.", "Takeaway's fine.",
                             accept: ["take away aja", "take away", "takeaway"],
                             next: "f5", chips: "Take_away/V aja/X Mas/X"),
                    .missed("Minum di mana?", "Drink where?",
                            reaction: Utterance("Hehe, terserah Kakak. Di sini atau dibawa?", gloss: "Heh, up to you. Here or to go?"),
                            coach: "He's offering two choices. Pick one: Minum sini, or Dibawa.")
                ]
            ),
            SceneNode(
                id: "f4b",
                them: Utterance("Silakan duduk, nanti kami antar.", casual: "Duduk aja, nanti diantar.",
                                gloss: "Have a seat, we'll bring it over.",
                                chips: "Silakan/X duduk/V nanti/T kami/S antar/V"),
                replies: [
                    .natural("Oke, makasih, Mas.", "OK, thanks.",
                             accept: ["oke makasih", "makasih mas"],
                             next: "f5", chips: "Oke/X makasih/X Mas/X"),
                    .natural("Sip. Ada wifi, Mas?", "Great. Is there wifi?",
                             accept: ["ada wifi", "sip ada wifi", "wifinya ada"],
                             sets: ["wifi"], next: "f4c", chips: "Sip/X Ada/V wifi/O Mas/X"),
                    .natural("Oke. Password wifinya apa, Mas?", "OK. What's the wifi password?",
                             accept: ["password wifinya apa", "password wifi apa", "passwordnya apa"],
                             sets: ["wifi"], next: "f4c", chips: "Password/O wifinya/O apa/Q"),
                    .missed("Saya antar, ya.", "I'll deliver it.",
                            reaction: Utterance("Hehe, gak usah, Kak. Kami yang antar.", gloss: "Heh, no need. We'll bring it."),
                            coach: "antar is the café bringing it to you. Just say thanks: Oke, makasih, Mas.")
                ]
            ),
            SceneNode(
                id: "f4c",
                them: Utterance("Ada. Password-nya di meja, ya.", casual: "Ada, di meja, Kak.",
                                gloss: "Yes. The password's on the table.", chips: "Ada/V Password-nya/O di/X meja/O"),
                replies: [
                    .natural("Oke, makasih!", "OK, thanks!", accept: ["oke makasih", "makasih"],
                             next: "f5", chips: "Oke/X makasih/X"),
                    .natural("Sip, makasih, Mas.", "Great, thanks.", accept: ["sip makasih", "sip makasih mas"],
                             next: "f5", chips: "Sip/X makasih/X Mas/X"),
                    .missed("Meja berapa?", "Which table number?",
                            reaction: Utterance("Di semua meja, Kak, hehe.", gloss: "On every table, heh."),
                            coach: "He means it's written on the tables. Just thank him.")
                ]
            ),
            SceneNode(
                id: "f5",
                them: Utterance("Semuanya tiga puluh dua ribu. Cash atau QRIS?", casual: "Tiga dua, Kak. Cash atau QRIS?",
                                gloss: "That's thirty-two thousand. Cash or QRIS?",
                                chips: "Semuanya/S tiga_puluh_dua_ribu/O Cash/O atau/L QRIS/O"),
                focus: "numbers",
                replies: [
                    .natural("QRIS aja, Mas.", "QRIS, please.",
                             accept: ["qris aja", "qris", "pakai qris"],
                             sets: ["paid"], next: "end", chips: "QRIS/O aja/X Mas/X"),
                    .natural("Cash, ya. Ini uangnya.", "Cash. Here's the money.",
                             accept: ["cash ini uangnya", "ini uangnya", "cash aja"],
                             sets: ["paid"], next: "end", chips: "Cash/O ya/X Ini/S uangnya/O"),
                    .missed("Dua puluh tiga ribu, ya?", "Twenty-three thousand?",
                            reaction: Utterance("Tiga puluh dua, Kak.", gloss: "Thirty-two."),
                            coach: "The tens come first: tiga puluh dua is 32; dua puluh tiga is 23."),
                    .off("Mahal, ya. Bisa kurang?", "Pricey. Can you go lower?",
                         reaction: Utterance("Hehe, maaf, harga menu, Kak.", gloss: "Heh, sorry, it's the menu price."),
                         coach: "Café prices are on the menu. Bargaining here comes across as odd.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Makasih, Kak {name}! Ditunggu, ya.", gloss: "Thanks! It'll be ready shortly.",
                                chips: "Makasih/X Kak/X {name}/O Ditunggu/V ya/X"),
                variants: [.busy: Utterance("Oke, ditunggu, Kak.", gloss: "OK, won't be long.")]
            )
        ],
        listening: [
            ListeningCheck(question: "What did he ask about the coffee?",
                           options: ["How sweet you want it", "How big you want it", "If you want ice cream"],
                           answer: "How sweet you want it"),
            ListeningCheck(question: "Why did he ask for a name?",
                           options: ["To call out the order", "To sign you up", "To add you on WhatsApp"],
                           answer: "To call out the order"),
            ListeningCheck(question: "How much was it?",
                           options: ["Rp 32.000", "Rp 23.000", "Rp 320.000"], answer: "Rp 32.000")
        ]
    )
}
