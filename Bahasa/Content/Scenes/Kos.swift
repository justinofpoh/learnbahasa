import Foundation

// Place: Kos (housing). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let buSari = Character(
        id: "bu-sari",
        name: "Bu Sari",
        role: "runs a kos house",
        register: .neutral,
        addressAs: ["Bu"],
        moods: [.warm, .chatty],
        defaultMood: .warm,
        confused: [
            Utterance("Maaf, maksudnya?", gloss: "Sorry, meaning?"),
            Utterance("Hmm? Gimana, Kak?", gloss: "Hmm? How's that?"),
            Utterance("Ibu kurang ngerti, Kak.", gloss: "I don't quite follow.")
        ]
    )

    static let kosKamar = RehearsalScene(
        id: "id.kos.kamar",
        language: "id",
        place: "Kos",
        title: "Sewa kamar kos",
        titleEn: "Renting a kos room",
        setting: "A kos house off the main road. Bu Sari unlocks a room and pushes the door open.",
        level: .getBy,
        accent: .sawah,
        symbol: "house.fill",
        character: buSari,
        goalSummary: "Check the room, ask the price, get a better rate for a longer stay, and agree when to move in.",
        goals: [
            GoalFlag(id: "asked_wifi", label: "Ask about wifi", optional: true),
            GoalFlag(id: "asked_price", label: "Ask the rent"),
            GoalFlag(id: "negotiated", label: "Get a better rate"),
            GoalFlag(id: "move_in", label: "Agree a move-in day")
        ],
        warmUps: [
            WarmUp(title: "Questions · ada, berapa, kapan", lessonID: "5.1"),
            WarmUp(title: "Numbers · juta", lessonID: "5.2"),
            WarmUp(title: "Places to stay", lessonID: "9.2")
        ],
        culture: [
            "Kos rent is usually paid monthly in advance. Ask what's included: listrik, air, wifi, cleaning.",
            "A longer lease (three, six or twelve months) is the normal way to get a lower monthly price."
        ],
        slots: [],
        entry: "k1",
        nodes: [
            SceneNode(
                id: "k1",
                them: Utterance("Ini kamarnya. Ada AC dan kamar mandi dalam.", casual: "Ini kamarnya, Kak. AC, kamar mandi dalam.",
                                gloss: "This is the room. It has air-con and its own bathroom.",
                                chips: "Ini/S kamarnya/O Ada/V AC/O dan/L kamar_mandi_dalam/O"),
                variants: [.chatty: Utterance("Nah, ini kamarnya, Kak. Baru dicat, lho! Ada AC dan kamar mandi dalam.",
                                              gloss: "Here's the room. Freshly painted! It has air-con and its own bathroom.")],
                replies: [
                    .natural("Bagus, Bu. Ada wifi juga?", "Nice. Is there wifi too?",
                             accept: ["ada wifi juga", "ada wifi", "bagus ada wifi"],
                             sets: ["asked_wifi"], next: "k2", chips: "Bagus/D Ada/V wifi/O juga/X"),
                    .natural("Bagus! Berapa per bulan, Bu?", "Nice! How much a month?",
                             accept: ["berapa per bulan", "berapa sebulan", "harganya berapa"],
                             sets: ["asked_price"], next: "k3", chips: "Berapa/Q per_bulan/T Bu/X"),
                    .understood("Apakah ada wifi?", "Is there wifi?", sets: ["asked_wifi"], next: "k2",
                                coach: "Correct but formal. Ada wifi? with a rising tone is how people ask."),
                    .missed("Wifi di mana ada?", "Wifi where is there?",
                            reaction: Utterance("Wifi… di mana, maksudnya?", gloss: "Wifi… where, you mean?"),
                            coach: "Keep it simple: Ada wifi? The question is in your tone.")
                ]
            ),
            SceneNode(
                id: "k2",
                them: Utterance("Ada, wifinya cepat kok.", casual: "Ada, kenceng kok.", gloss: "Yes, and it's fast.",
                                chips: "Ada/V wifinya/S cepat/D kok/X"),
                replies: [
                    .natural("Berapa per bulan, Bu?", "How much a month?", accept: ["berapa per bulan", "berapa sebulan"],
                             sets: ["asked_price"], next: "k3", chips: "Berapa/Q per_bulan/T Bu/X"),
                    .natural("Oke. Harganya berapa sebulan?", "OK. What's the price per month?",
                             accept: ["harganya berapa sebulan", "harganya berapa"],
                             sets: ["asked_price"], next: "k3", chips: "Harganya/S berapa/Q sebulan/T"),
                    .natural("Mantap. Terus, sebulan berapa, Bu?", "Great. So how much a month?",
                             accept: ["terus sebulan berapa", "sebulan berapa", "mantap sebulan berapa"],
                             sets: ["asked_price"], next: "k3", chips: "Terus/L sebulan/T berapa/Q Bu/X"),
                    .missed("Bulan berapa?", "Which month?",
                            reaction: Utterance("Bulan apa, maksudnya?", gloss: "Which month, you mean?"),
                            coach: "Word order flips the meaning: berapa per bulan asks the price."),
                    .missed("Berapa orang?", "How many people?",
                            reaction: Utterance("Satu kamar, satu orang, Kak.", gloss: "One room, one person."),
                            coach: "That asks about occupants. For rent, ask: Berapa per bulan?")
                ]
            ),
            SceneNode(
                id: "k3",
                them: Utterance("Lima juta, sudah termasuk listrik.", casual: "Lima juta, udah sama listrik.",
                                gloss: "Five million, electricity included.",
                                chips: "Lima_juta/O sudah/T termasuk/V listrik/O"),
                focus: "numbers",
                replies: [
                    .natural("Kalau sewa enam bulan, bisa lebih murah?", "If I rent for six months, can it be cheaper?",
                             accept: ["kalau enam bulan bisa lebih murah", "kalau sewa enam bulan bisa kurang", "enam bulan bisa lebih murah"],
                             sets: ["negotiated"], next: "k4", chips: "Kalau/L sewa/V enam_bulan/T bisa/H lebih_murah/D"),
                    .natural("Kalau setahun, bisa kurang, Bu?", "If it's a year, can you lower it?",
                             accept: ["kalau setahun bisa kurang", "setahun bisa lebih murah", "kalau sewa setahun"],
                             sets: ["negotiated"], next: "k4b", chips: "Kalau/L setahun/T bisa/H kurang/V"),
                    .understood("Lima juta mahal, Bu.", "Five million is a lot.", sets: ["negotiated"], next: "k4",
                                coach: "She'll often meet you anyway, but a longer stay is the real lever: Kalau sewa enam bulan, bisa lebih murah?"),
                    .missed("Lebih murah enam bulan?", "Cheaper six months?",
                            reaction: Utterance("Maksudnya, sewa enam bulan?", gloss: "You mean, rent for six months?"),
                            coach: "Lead with the condition: Kalau sewa enam bulan, bisa lebih murah?")
                ]
            ),
            SceneNode(
                id: "k4",
                them: Utterance("Kalau enam bulan, empat setengah juta.", casual: "Enam bulan, empat setengah.",
                                gloss: "For six months, four and a half million.",
                                chips: "Kalau/L enam_bulan/T empat_setengah_juta/O"),
                replies: [
                    .natural("Oke, saya ambil. Kapan saya bisa pindah?", "OK, I'll take it. When can I move in?",
                             accept: ["kapan saya bisa pindah", "oke kapan bisa pindah", "saya ambil kapan bisa pindah"],
                             sets: ["move_in"], next: "k5", chips: "Saya/S ambil/V Kapan/Q saya/S bisa/H pindah/V"),
                    .natural("Oke, deal. Bisa pindah minggu ini?", "OK, deal. Can I move in this week?",
                             accept: ["bisa pindah minggu ini", "pindah minggu ini bisa"],
                             sets: ["move_in"], next: "k5", chips: "Bisa/H pindah/V minggu_ini/T"),
                    .missed("Empat setengah ribu?", "Four and a half thousand?",
                            reaction: Utterance("Juta, Kak, bukan ribu! Hehe.", gloss: "Million, not thousand! Heh."),
                            coach: "ribu is thousand, juta is million: empat setengah juta is 4.5 million."),
                    .missed("Oke, saya ambil. Berapa saya bisa pindah?", "OK, I'll take it. How much can I move in?",
                            reaction: Utterance("Berapa…? Maksudnya kapan?", gloss: "How much…? You mean when?"),
                            coach: "kapan asks when; berapa asks how much.")
                ]
            ),
            SceneNode(
                id: "k4b",
                them: Utterance("Kalau setahun, empat juta per bulan.", casual: "Setahun, empat juta sebulan.",
                                gloss: "For a year, four million a month.", chips: "Kalau/L setahun/T empat_juta/O per_bulan/T"),
                replies: [
                    .natural("Oke, saya ambil. Kapan saya bisa pindah?", "OK, I'll take it. When can I move in?",
                             accept: ["kapan saya bisa pindah", "oke kapan bisa pindah"],
                             sets: ["move_in"], next: "k5", chips: "Saya/S ambil/V Kapan/Q saya/S bisa/H pindah/V"),
                    .natural("Hmm, enam bulan dulu, ya, Bu.", "Hmm, six months to start with.",
                             accept: ["enam bulan dulu", "enam bulan dulu ya"],
                             next: "k4", chips: "Enam_bulan/T dulu/T ya/X"),
                    .missed("Empat juta per tahun?", "Four million a year?",
                            reaction: Utterance("Bukan, per bulan, Kak.", gloss: "No, per month."),
                            coach: "per bulan is per month. She said four million a month.")
                ]
            ),
            SceneNode(
                id: "k5",
                them: Utterance("Besok juga boleh! Nanti saya siapkan kuncinya.", casual: "Besok juga bisa! Kuncinya saya siapin.",
                                gloss: "Tomorrow, even! I'll have the keys ready.",
                                chips: "Besok/T juga/X boleh/H Nanti/T saya/S siapkan/V kuncinya/O"),
                variants: [.chatty: Utterance("Besok juga boleh! Oh iya, laundry kiloan ada di sebelah, ya.",
                                              gloss: "Tomorrow, even! Oh, and there's a laundry kiloan next door.")],
                replies: [
                    .natural("Siap, Bu. Terima kasih banyak!", "Great. Thank you so much!",
                             accept: ["terima kasih banyak", "makasih banyak bu", "siap bu makasih"],
                             next: "end", chips: "Siap/D Bu/X Terima_kasih_banyak/X"),
                    .natural("Mantap! Sampai besok, Bu.", "Perfect! See you tomorrow.",
                             accept: ["sampai besok", "mantap sampai besok"],
                             next: "end", chips: "Mantap/D Sampai_besok/T Bu/X"),
                    .missed("Sama-sama, Bu.", "You're welcome.",
                            reaction: Utterance("Hehe… sama-sama.", gloss: "Heh… you're welcome."),
                            coach: "sama-sama answers thanks. She did you a favour, so thank her: Terima kasih banyak!")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Sama-sama. Selamat datang di kos, ya!", gloss: "You're welcome. Welcome to the kos!",
                                chips: "Selamat_datang/X di/X kos/O ya/X"),
                variants: [.chatty: Utterance("Sama-sama! Kalau ada apa-apa, bilang saja, ya.",
                                              gloss: "You're welcome! If you need anything, just say.")]
            )
        ],
        listening: [
            ListeningCheck(question: "What does the room have?",
                           options: ["Air-con and its own bathroom", "A kitchen and a balcony", "A desk and a TV"],
                           answer: "Air-con and its own bathroom"),
            ListeningCheck(question: "What was the first monthly price?",
                           options: ["Rp 5.000.000", "Rp 4.500.000", "Rp 500.000"], answer: "Rp 5.000.000"),
            ListeningCheck(question: "When can you move in?",
                           options: ["Tomorrow", "Next month", "Next week"], answer: "Tomorrow")
        ]
    )
}
