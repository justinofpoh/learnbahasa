import Foundation

// Place: Jalan (getting around). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let pakAgus = Character(
        id: "pak-agus",
        name: "Pak Agus",
        role: "your ojek driver",
        register: .casual,
        addressAs: ["Pak"],
        moods: [.chatty, .busy],
        defaultMood: .chatty,
        confused: [
            Utterance("Hah? Apa, Kak?", gloss: "Huh? What?"),
            Utterance("Maaf, gak dengar, Kak.", gloss: "Sorry, didn't catch that."),
            Utterance("Gimana, Kak?", gloss: "How's that?")
        ]
    )

    static let jalanOjek = RehearsalScene(
        id: "id.jalan.ojek",
        language: "id",
        place: "Jalan",
        title: "Naik ojek",
        titleEn: "Riding with an ojek driver",
        setting: "Roadside. Your driver pulls up, phone clipped to the handlebars, a spare helmet in hand.",
        level: .getBy,
        accent: .laut,
        symbol: "scooter",
        character: pakAgus,
        goalSummary: "Confirm where you're going, chat on the way, and get dropped at the right spot.",
        goals: [
            GoalFlag(id: "confirmed", label: "Confirm the destination"),
            GoalFlag(id: "ready", label: "Get on"),
            GoalFlag(id: "small_talk", label: "Chat a little", optional: true),
            GoalFlag(id: "dropoff", label: "Say where to stop")
        ],
        warmUps: [
            WarmUp(title: "Questions · di/ke/dari mana", lessonID: "5.1"),
            WarmUp(title: "Rides · ke, kiri, sampai", lessonID: "9.1"),
            WarmUp(title: "Small talk", lessonID: "7.4")
        ],
        culture: [
            "Drivers often call passengers Kak (short for Kakak, older sibling), whatever your age. Call him Pak.",
            "To stop, say Kiri, ya or Di sini aja. Tipping isn't expected, but a five-star rating is appreciated."
        ],
        slots: [.country, .city],
        entry: "g1",
        nodes: [
            SceneNode(
                id: "g1",
                them: Utterance("Sesuai aplikasi, ke {city}, ya?", casual: "Ke {city}, Kak?",
                                gloss: "As in the app, to {city}, right?", chips: "Sesuai/L aplikasi/O ke/X {city}/O ya/X"),
                replies: [
                    .natural("Iya, betul, Pak.", "Yes, that's right.", accept: ["iya betul", "betul pak", "iya pak", "betul"],
                             sets: ["confirmed"], next: "g2", chips: "Iya/X betul/D Pak/X"),
                    .natural("Iya, ke {city}, Pak.", "Yes, to {city}.", accept: ["ke {city}", "iya ke {city}"],
                             sets: ["confirmed"], next: "g2", chips: "Iya/X ke/X {city}/O Pak/X"),
                    .missed("Tidak apa-apa, Pak.", "It's fine.",
                            reaction: Utterance("Jadi… ke {city} atau bukan?", gloss: "So… to {city} or not?"),
                            coach: "Tidak apa-apa means 'it's fine', not yes. Iya or betul confirms."),
                    .missed("Belum, Pak.", "Not yet.",
                            reaction: Utterance("Belum? Mau ke mana, Kak?", gloss: "Not yet? Where do you want to go?"),
                            coach: "belum means 'not yet'. To say yes, use iya or betul.")
                ]
            ),
            SceneNode(
                id: "g2",
                them: Utterance("Ini helmnya. Sudah siap?", casual: "Helmnya, Kak. Siap?",
                                gloss: "Here's the helmet. Ready?", chips: "Ini/S helmnya/O Sudah/T siap/D"),
                replies: [
                    .natural("Sudah, Pak.", "Ready.", accept: ["sudah", "udah pak", "sudah siap"],
                             sets: ["ready"], next: "g3", moodNext: [.busy: "g4"], chips: "Sudah/T Pak/X"),
                    .natural("Siap, Pak! Makasih.", "Ready! Thanks.", accept: ["siap pak", "siap makasih", "siap"],
                             sets: ["ready"], next: "g3", moodNext: [.busy: "g4"], chips: "Siap/D Pak/X Makasih/X"),
                    .missed("Sudah makan, Pak.", "I've already eaten.",
                            reaction: Utterance("Hehe, saya tanya siap, Kak.", gloss: "Heh, I asked if you're ready."),
                            coach: "sudah on its own answers his question. Adding makan answers a different one."),
                    .missed("Belum pernah.", "Never have.",
                            reaction: Utterance("Belum pernah naik motor?", gloss: "Never ridden a motorbike?"),
                            coach: "pernah is about experience. He only wants to know if you're ready: Sudah.")
                ]
            ),
            SceneNode(
                id: "g3",
                narration: "You pull out into traffic.",
                them: Utterance("Dari mana, Kak?", casual: "Asli mana, Kak?", gloss: "Where are you from?",
                                chips: "Dari/X mana/Q"),
                replies: [
                    .natural("Saya dari {country}, tapi tinggal di {city}.", "I'm from {country}, but I live in {city}.",
                             accept: ["dari {country} tapi tinggal di {city}", "saya dari {country}"],
                             sets: ["small_talk"], next: "g3b", chips: "Saya/S dari/X {country}/O tapi/L tinggal/V di/X {city}/O"),
                    .natural("Dari {country}, Pak.", "From {country}.", accept: ["dari {country}"],
                             sets: ["small_talk"], next: "g3b", chips: "Dari/X {country}/O Pak/X"),
                    .understood("Saya adalah dari {country}.", "I am from {country}.", sets: ["small_talk"], next: "g3b",
                                coach: "He understood, but there's no 'to be' before dari. Drop adalah: Saya dari {country}."),
                    .missed("Saya ke {country}.", "I'm going to {country}.",
                            reaction: Utterance("Oh, mau pulang ke {country}?", gloss: "Oh, going home to {country}?"),
                            coach: "ke means to, dari means from.")
                ]
            ),
            SceneNode(
                id: "g3b",
                them: Utterance("Bahasa Indonesianya bagus!", casual: "Wah, lancar bahasanya!",
                                gloss: "Your Indonesian is good!", chips: "Bahasa_Indonesianya/S bagus/D"),
                replies: [
                    .natural("Makasih, saya masih belajar.", "Thanks, I'm still learning.",
                             accept: ["terima kasih saya masih belajar", "masih belajar pak", "makasih masih belajar"],
                             next: "g3c", chips: "Makasih/X saya/S masih/T belajar/V"),
                    .natural("Ah, belum lancar, Pak. Masih belajar.", "Oh, not fluent yet. Still learning.",
                             accept: ["belum lancar masih belajar", "belum lancar"],
                             next: "g3c", chips: "Belum/N lancar/D Masih/T belajar/V"),
                    .missed("Sama-sama, Pak.", "You're welcome.",
                            reaction: Utterance("Hehe… sama-sama?", gloss: "Heh… you're welcome?"),
                            coach: "sama-sama answers thanks, not a compliment. Say makasih."),
                    .missed("Tidak, bahasa saya bukan bagus.", "No, my language is not (a) good.",
                            reaction: Utterance("Bagus kok, Kak!", gloss: "It really is good!"),
                            coach: "bagus is a describer, so it's tidak bagus, not bukan bagus. And a modest thank-you lands better.")
                ]
            ),
            SceneNode(
                id: "g3c",
                narration: "You pass a warung with a crowd outside.",
                them: Utterance("Udah makan, Kak?", casual: "Udah makan?", gloss: "Have you eaten yet?",
                                chips: "Udah/T makan/V Kak/X"),
                replies: [
                    .natural("Udah, Pak. Tadi di warung.", "Yes. At a warung earlier.",
                             accept: ["sudah tadi di warung", "udah tadi di warung", "sudah pak"],
                             sets: ["small_talk"], next: "g4", chips: "Udah/T Pak/X Tadi/T di/X warung/O"),
                    .natural("Belum, Pak. Nanti aja.", "Not yet. Later.",
                             accept: ["belum nanti aja", "belum pak", "belum nanti saja"],
                             sets: ["small_talk"], next: "g4", chips: "Belum/N Pak/X Nanti/T aja/X"),
                    .natural("Udah, Pak. Bapak udah?", "Yes. Have you?",
                             accept: ["sudah bapak sudah", "udah bapak udah", "bapak sudah makan"],
                             sets: ["small_talk"], next: "g4", chips: "Udah/T Pak/X Bapak/S udah/T"),
                    .understood("Tidak, Pak.", "No.", sets: ["small_talk"], next: "g4",
                                coach: "He understood, but belum (not yet) is the natural answer. Tidak sounds like you don't eat at all."),
                    .missed("Saya mau makan nasi campur.", "I want to eat nasi campur.",
                            reaction: Utterance("Hehe, mau mampir ke warung?", gloss: "Heh, want to stop at a warung?"),
                            coach: "He isn't taking your order. Udah makan? is a friendly how-are-you. Answer udah or belum.")
                ]
            ),
            SceneNode(
                id: "g4",
                narration: "Nearly there.",
                them: Utterance("Turun di mana, Kak?", casual: "Berhenti di mana?", gloss: "Where do you want to get off?",
                                chips: "Turun/V di_mana/Q"),
                variants: [.busy: Utterance("Di mana, Kak?", gloss: "Where?")],
                replies: [
                    .natural("Di depan kafe itu, ya.", "In front of that café, please.",
                             accept: ["depan kafe itu", "di depan kafe itu pak"],
                             sets: ["dropoff"], next: "g5", chips: "Di_depan/X kafe_itu/O ya/X"),
                    .natural("Kiri, Pak. Di sini aja.", "On the left, here's fine.",
                             accept: ["di sini aja", "di sini saja", "kiri pak", "kiri ya"],
                             sets: ["dropoff"], next: "g5", chips: "Kiri/X Pak/X Di_sini/X aja/X"),
                    .natural("Di pertigaan depan, ya, Pak.", "At the T-junction ahead, please.",
                             accept: ["pertigaan depan", "di pertigaan depan", "pertigaan depan ya"],
                             sets: ["dropoff"], next: "g5", chips: "Di/X pertigaan/O depan/X ya/X"),
                    .understood("Ke depan kafe itu.", "To the front of that café.", sets: ["dropoff"], next: "g5",
                                coach: "He got it. For the spot you stop at, use di: Di depan kafe itu."),
                    .missed("Di mana kafe itu?", "Where is that café?",
                            reaction: Utterance("Lho, saya yang tanya, Kak.", gloss: "Hey, I'm the one asking."),
                            coach: "That hands his question back. Tell him: Di depan kafe itu.")
                ]
            ),
            SceneNode(
                id: "g5",
                them: Utterance("Oke, sudah sampai, Kak.", casual: "Udah sampai, Kak.", gloss: "OK, we're here.",
                                chips: "Sudah/T sampai/V"),
                variants: [.busy: Utterance("Sampai, Kak.", gloss: "Here we are.")],
                replies: [
                    .natural("Makasih, Pak! Bintang lima.", "Thanks! Five stars.", accept: ["makasih bintang lima", "terima kasih pak"],
                             next: "end", chips: "Makasih/X Pak/X Bintang_lima/O"),
                    .natural("Terima kasih, Pak. Hati-hati, ya.", "Thank you. Ride safe.",
                             accept: ["makasih hati hati", "terima kasih hati hati"],
                             next: "end", chips: "Terima_kasih/X Hati-hati/D ya/X"),
                    .missed("Permisi, Pak.", "Excuse me.",
                            reaction: Utterance("Ya, Kak? Ada apa?", gloss: "Yes? What is it?"),
                            coach: "permisi is for getting past or getting attention, not for thanks."),
                    .missed("Selamat makan, Pak.", "Enjoy your meal.",
                            reaction: Utterance("Hah? Makan?", gloss: "Huh? Eat?"),
                            coach: "Lovely, but that's for someone about to eat. Say makasih.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Sama-sama, Kak. Hati-hati!", gloss: "You're welcome. Take care!",
                                chips: "Sama-sama/X Hati-hati/D"),
                variants: [.busy: Utterance("Oke, makasih, Kak.", gloss: "OK, thanks.")]
            )
        ],
        listening: [
            ListeningCheck(question: "Where was he taking you?",
                           options: ["Where you booked in the app", "To the airport", "To the beach"],
                           answer: "Where you booked in the app"),
            ListeningCheck(question: "What did he hand you?",
                           options: ["A helmet", "A raincoat", "His phone"], answer: "A helmet"),
            ListeningCheck(question: "Where did you get off?",
                           options: ["In front of a café", "At the market", "At a petrol station"], answer: "In front of a café")
        ]
    )
}
