import Foundation

// Place: Warung. One file per Place (spec §12.7).
// All Indonesian here still needs the native-speaker check required by §12.1.

extension SceneLibrary {
    static let ibuWayan = Character(
        id: "ibu-wayan",
        name: "Ibu Wayan",
        role: "runs a warung in Canggu",
        register: .neutral,
        addressAs: ["Bu", "Ibu"],
        moods: [.warm, .busy],
        defaultMood: .warm,
        confused: [
            Utterance("Maaf, apa?", gloss: "Sorry, what?"),
            Utterance("Hmm? Gimana?", gloss: "Hmm? How's that?"),
            Utterance("Maaf, Ibu kurang ngerti.", gloss: "Sorry, I don't quite get it.")
        ]
    )

    static let warungLunch = RehearsalScene(
        id: "id.warung.lunch",
        language: "id",
        place: "Warung",
        title: "Makan siang di warung",
        titleEn: "Lunch at the warung",
        setting: "Midday. Plastic stools, a glass case of dishes. Ibu Wayan looks up from the rice.",
        level: .getBy,
        accent: .sambal,
        symbol: "fork.knife",
        character: ibuWayan,
        goalSummary: "Order a nasi campur that isn't too spicy, and pay.",
        goals: [
            GoalFlag(id: "ordered_food", label: "Order food"),
            GoalFlag(id: "set_spice", label: "Set the spice"),
            GoalFlag(id: "ordered_drink", label: "Get a drink", optional: true),
            GoalFlag(id: "paid", label: "Pay")
        ],
        warmUps: [
            WarmUp(title: "Ordering · pakai, tanpa", lessonID: "8.1"),
            WarmUp(title: "Everyday no · gak", lessonID: "4.2"),
            WarmUp(title: "Numbers & prices", lessonID: "5.2")
        ],
        culture: [
            "Call a woman running a warung Bu (short for Ibu). It's polite without being stiff.",
            "Warung prices are fixed, and you usually pay after you've eaten."
        ],
        slots: [.country],
        entry: "n1",
        nodes: [
            SceneNode(
                id: "n1",
                them: Utterance("Selamat siang! Mau makan apa?", casual: "Siang! Makan apa?",
                                gloss: "Good afternoon! What would you like to eat?",
                                chips: "Mau/H makan/V apa/Q"),
                variants: [.busy: Utterance("Ya, makan apa?", gloss: "Yes, what'll it be?", chips: "Makan/V apa/Q")],
                replies: [
                    .natural("Nasi campur satu, Bu.", "One nasi campur, please.",
                             accept: ["satu nasi campur", "nasi campur satu ya"],
                             sets: ["ordered_food"], next: "n2",
                             chips: "Nasi_campur/O satu/X Bu/X"),
                    .natural("Saya mau nasi campur, Bu.", "I'd like a nasi campur, please.",
                             accept: ["mau nasi campur", "saya mau nasi campur satu"],
                             sets: ["ordered_food"], next: "n2",
                             chips: "Saya/S mau/H nasi_campur/O Bu/X"),
                    .natural("Bu, nasi campurnya satu, ya.", "A nasi campur for me, please.",
                             accept: ["nasi campurnya satu", "nasi campurnya satu ya"],
                             sets: ["ordered_food"], next: "n2", chips: "Bu/X nasi_campurnya/O satu/X ya/X"),
                    .understood("Saya ingin memesan nasi campur.", "I wish to order a nasi campur.",
                                sets: ["ordered_food"], next: "n2",
                                coach: "Correct, but very formal for a warung, like reading a menu aloud. Locals say: Nasi campur satu, Bu."),
                    .missed("Saya makan nasi campur.", "I eat nasi campur.",
                            reaction: Utterance("Hmm? Mau pesan nasi campur?", gloss: "Hmm? You want to order a nasi campur?"),
                            coach: "makan on its own says you're eating it. Add mau (want) to order: Saya mau nasi campur."),
                    .off("Nasi campur!", "(just the dish name)",
                         reaction: Utterance("…Iya.", gloss: "…Right."),
                         coach: "Just the dish sounds abrupt. Add satu and Bu: Nasi campur satu, Bu.")
                ]
            ),
            SceneNode(
                id: "n2",
                them: Utterance("Mau pedas atau tidak?", casual: "Pedas gak?",
                                gloss: "Do you want it spicy or not?",
                                chips: "Mau/H pedas/D atau/L tidak/N"),
                variants: [.busy: Utterance("Pedas?", gloss: "Spicy?", chips: "Pedas/D")],
                focus: "tidak-before",
                extras: ["tidak", "sekali"],
                replies: [
                    .natural("Sedikit aja, Bu.", "Just a little, please.",
                             accept: ["sedikit pedas aja", "sedikit pedas", "sedikit aja"],
                             sets: ["set_spice"], next: "n3",
                             chips: "Sedikit/D aja/X Bu/X"),
                    .natural("Gak pedas, ya.", "Not spicy, please.",
                             accept: ["tidak pedas", "gak pedas bu", "jangan pedas"],
                             sets: ["set_spice"], next: "n2b",
                             chips: "Gak/N pedas/D ya/X"),
                    .understood("Saya tidak suka pedas.", "I don't like spicy food.",
                                sets: ["set_spice"], next: "n2b",
                                coach: "Clear and polite. Shorter is more natural here: Gak pedas, ya."),
                    .missed("Pedas tidak.", "Spicy not.",
                            reaction: Utterance("Pedas… atau tidak?", gloss: "Spicy… or not?"),
                            coach: "tidak goes before the word it cancels: tidak pedas.")
                ]
            ),
            SceneNode(
                id: "n2b",
                them: Utterance("Sama sekali gak pedas?", gloss: "Not spicy at all?",
                                chips: "Sama_sekali/D gak/N pedas/D"),
                replies: [
                    .natural("Iya, gak pedas sama sekali.", "Yes, not spicy at all.",
                             accept: ["iya sama sekali", "iya tidak pedas sama sekali"],
                             next: "n3", chips: "Iya/X gak/N pedas/D sama_sekali/D"),
                    .natural("Iya, Bu.", "That's right.", accept: ["iya"], next: "n3", chips: "Iya/X Bu/X"),
                    .natural("Sedikit aja, gak apa-apa.", "A little is fine.",
                             accept: ["sedikit gak apa apa", "sedikit saja tidak apa apa"],
                             next: "n3", chips: "Sedikit/D aja/X gak_apa-apa/N"),
                    .missed("Tidak.", "No.",
                            reaction: Utterance("Tidak… jadi mau pedas?", gloss: "No… so you do want it spicy?"),
                            coach: "To agree with a negative question, say Iya: \"yes, that's right, not spicy\". Tidak here sounds like you want spice.")
                ]
            ),
            SceneNode(
                id: "n3",
                them: Utterance("Minumnya apa?", casual: "Minumnya?",
                                gloss: "And to drink?", chips: "Minumnya/O apa/Q"),
                variants: [.busy: Utterance("Minum?", gloss: "Drink?", chips: "Minum/V")],
                replies: [
                    .natural("Es teh manis satu.", "One sweet iced tea.",
                             accept: ["satu es teh manis", "es teh manis", "es teh satu"],
                             sets: ["ordered_drink"], next: "n4",
                             chips: "Es_teh/O manis/D satu/X"),
                    .natural("Air putih aja, Bu.", "Just water, please.",
                             accept: ["air putih", "air putih satu"],
                             sets: ["ordered_drink"], next: "n4",
                             chips: "Air_putih/O aja/X Bu/X"),
                    .natural("Gak usah, Bu. Makasih.", "No need, thanks.",
                             accept: ["gak usah", "tidak usah terima kasih"],
                             next: "n4", chips: "Gak/N usah/H Bu/X Makasih/X"),
                    .missed("Saya minum es teh manis berapa?", "How much do I drink sweet iced tea?",
                            reaction: Utterance("Mau es teh manis?", gloss: "You want a sweet iced tea?"),
                            coach: "berapa asks a price or a number, so it doesn't belong in an order. Just name it: Es teh manis satu.")
                ]
            ),
            SceneNode(
                id: "n4",
                them: Utterance("Makan di sini atau dibungkus?", casual: "Makan sini apa bungkus?",
                                gloss: "Eating here or taking it away?",
                                chips: "Makan/V di_sini/X atau/L dibungkus/V"),
                variants: [.busy: Utterance("Sini atau bungkus?", gloss: "Here or to go?", chips: "Sini/X atau/L bungkus/V")],
                extras: ["atau"],
                replies: [
                    .natural("Makan sini, Bu.", "Eating here.",
                             accept: ["makan di sini", "di sini"],
                             next: "n4b", moodNext: [.busy: "n5"],
                             chips: "Makan/V sini/X Bu/X"),
                    .natural("Dibungkus, ya.", "To take away, please.",
                             accept: ["bungkus", "bungkus aja", "dibungkus aja"],
                             next: "n4b", moodNext: [.busy: "n5"],
                             chips: "Dibungkus/V ya/X"),
                    .missed("Di sini atau dibungkus.", "Here or takeaway.",
                            reaction: Utterance("Hehe, yang mana?", gloss: "Heh, which one?"),
                            coach: "That hands her question back. Pick one: Makan sini or Dibungkus."),
                    .missed("Dibungkus di sini.", "Wrapped here.",
                            reaction: Utterance("Dibungkus… atau makan di sini?", gloss: "Takeaway… or eating here?"),
                            coach: "Those are the two choices, not one. Pick di sini or dibungkus.")
                ]
            ),
            SceneNode(
                id: "n4b",
                them: Utterance("Asalnya dari mana?", casual: "Dari mana?",
                                gloss: "Where are you from?", chips: "Asalnya/S dari/X mana/Q"),
                replies: [
                    .natural("Saya dari {country}, Bu.", "I'm from {country}.",
                             accept: ["dari {country}", "saya dari {country}"],
                             next: "n5", chips: "Saya/S dari/X {country}/O Bu/X"),
                    .natural("Saya orang {country}.", "I'm from {country} (lit. a {country} person).",
                             accept: ["orang {country}"],
                             next: "n5", chips: "Saya/S orang/X {country}/D"),
                    .understood("Saya adalah dari {country}.", "I am from {country}.", next: "n5",
                                coach: "She understood, but there's no 'to be' before dari. Drop adalah: Saya dari {country}."),
                    .missed("Saya {country}.", "I am {country}.",
                            reaction: Utterance("Oh… dari {country}?", gloss: "Oh… from {country}?"),
                            coach: "Without dari it reads \"I am {country}\". Say: Saya dari {country}.")
                ]
            ),
            SceneNode(
                id: "n5",
                narration: "A bit later, at the counter.",
                them: Utterance("Semuanya tiga puluh lima ribu.", casual: "Tiga lima, ya.",
                                gloss: "That's 35,000 altogether.",
                                chips: "Semuanya/S tiga_puluh_lima_ribu/O"),
                variants: [.busy: Utterance("Tiga puluh lima ribu.", casual: "Tiga lima.", gloss: "Thirty-five thousand.")],
                replies: [
                    .natural("Ini, Bu. Makasih.", "Here you go. Thanks.",
                             accept: ["ini bu", "ini terima kasih", "ini ya bu"],
                             sets: ["paid"], next: "end", chips: "Ini/S Bu/X Makasih/X"),
                    .natural("Bisa pakai QRIS?", "Can I pay with QRIS?",
                             accept: ["bisa qris", "pakai qris bisa", "bisa bayar pakai qris"],
                             next: "n5b", chips: "Bisa/H pakai/V QRIS/O"),
                    .natural("Ini uangnya, Bu.", "Here's the money.",
                             accept: ["ini uangnya", "ini uangnya bu"],
                             sets: ["paid"], next: "end", chips: "Ini/S uangnya/O Bu/X"),
                    .missed("Lima belas ribu?", "Fifteen thousand?",
                            reaction: Utterance("Tiga puluh lima ribu, ya.", gloss: "Thirty-five thousand."),
                            coach: "belas is the teens, puluh is the tens. 35 = tiga puluh lima."),
                    .off("Mahal! Bisa kurang?", "Expensive! Can you go lower?",
                         reaction: Utterance("Harga pas, ya.", gloss: "Fixed price."),
                         coach: "Warung prices are fixed. Haggle at the pasar, not over lunch.")
                ]
            ),
            SceneNode(
                id: "n5b",
                them: Utterance("Bisa. Scan di sini, ya.", gloss: "Sure. Scan here.",
                                chips: "Bisa/H scan/V di_sini/X"),
                replies: [
                    .natural("Sudah, Bu. Makasih.", "Done. Thanks.",
                             accept: ["sudah", "sudah terima kasih"],
                             sets: ["paid"], next: "end", chips: "Sudah/T Bu/X Makasih/X"),
                    .natural("Oke, sudah, ya.", "Okay, done.",
                             accept: ["oke sudah"],
                             sets: ["paid"], next: "end", chips: "Oke/X sudah/T ya/X"),
                    .missed("Sudah bayar besok.", "Already paid tomorrow.",
                            reaction: Utterance("Hah? Besok?", gloss: "Huh? Tomorrow?"),
                            coach: "sudah means done; besok means tomorrow. They clash. Just say: Sudah, Bu.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Makasih! Datang lagi, ya.", gloss: "Thanks! Come again.",
                                chips: "Makasih/X Datang/V lagi/T ya/X"),
                variants: [.busy: Utterance("Ya, makasih.", gloss: "Yep, thanks.")]
            )
        ],
        listening: [
            ListeningCheck(question: "What did Ibu Wayan ask first?",
                           options: ["What you'd like to eat", "Where you're from", "If you're hungry"],
                           answer: "What you'd like to eat"),
            ListeningCheck(question: "What did she ask about the food?",
                           options: ["Whether you want it spicy", "Whether you want it hot or cold", "Whether you want extra rice"],
                           answer: "Whether you want it spicy"),
            ListeningCheck(question: "How much was it?",
                           options: ["Rp 35.000", "Rp 15.000", "Rp 53.000"],
                           answer: "Rp 35.000")
        ]
    )
}
