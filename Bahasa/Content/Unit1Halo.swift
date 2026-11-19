import SwiftUI

extension Curriculum {
    static let unit1 = Unit(
        id: "u1",
        number: 1,
        indoTitle: "Halo!",
        title: "First words",
        blurb: "Greet people by the hour, say thank you, and introduce yourself.",
        accent: .sambal,
        symbol: "hand.wave.fill",
        lessons: [lesson11, lesson12, lesson13, lesson14]
    )

    static let lesson11 = Lesson(
        id: "1.1",
        title: "Greetings",
        subtitle: "Selamat pagi, siang, sore, malam",
        symbol: "sun.max.fill",
        steps: [
            .learn(
                "Selamat + time of day",
                "Indonesian greetings are built from selamat (\"safe, well\") plus the part of the day. There is no single \"hello\" you use all day — people pick the one that matches the clock.",
                pattern: "Selamat/X pagi/T",
                examples: [
                    Example("Selamat pagi", "Good morning", note: "until about 11am"),
                    Example("Selamat siang", "Good day", note: "about 11am–3pm"),
                    Example("Selamat sore", "Good afternoon", note: "about 3pm until dark"),
                    Example("Selamat malam", "Good evening", note: "after dark")
                ]
            ),
            .pick(
                "It is 4pm. Which greeting?",
                ["Selamat pagi", "Selamat siang", "Selamat sore"],
                answer: "Selamat sore",
                why: "Sore runs from roughly 3pm until it gets dark."
            ),
            .learn(
                "Thank you",
                "Terima kasih is the full form; makasih is the everyday short one. The standard reply is sama-sama — literally \"same-same\".",
                examples: [
                    Example("Terima kasih", "Thank you"),
                    Example("Makasih, ya", "Thanks!", note: "casual"),
                    Example("Sama-sama", "You're welcome"),
                    Example("Terima kasih banyak", "Thank you very much")
                ]
            ),
            .arrange(
                "Thank you very much",
                "Terima kasih banyak",
                extras: ["sama-sama", "sekali"],
                why: "banyak (\"a lot\") goes after the thing it strengthens."
            ),
            .pick(
                "Someone says \"Terima kasih!\" — reply:",
                say: "Terima kasih!",
                ["Sama-sama", "Permisi", "Maaf"],
                answer: "Sama-sama",
                why: "Sama-sama is the standard \"you're welcome\"."
            ),
            .learn(
                "Permisi and maaf",
                "Permisi is \"excuse me\" when you pass someone, enter a room or get a seller's attention. Maaf is \"sorry\" — for apologies, and for softening bad news.",
                examples: [
                    Example("Permisi, Pak", "Excuse me, sir"),
                    Example("Maaf, saya terlambat", "Sorry, I'm late"),
                    Example("Maaf, tidak bisa", "Sorry, I can't")
                ]
            ),
            .hear(
                "Selamat malam",
                ["Good evening", "Good morning", "Good afternoon"],
                answer: "Good evening",
                why: "Malam is night — used once it's dark."
            ),
            .arrange(
                "Good morning, Ma'am",
                "Selamat pagi, Bu",
                alt: ["Selamat pagi Bu"],
                extras: ["Pak", "sore"],
                why: "Bu (for women) and Pak (for men) are added constantly — leaving them out sounds blunt."
            )
        ]
    )

    static let lesson12 = Lesson(
        id: "1.2",
        title: "Introduce yourself",
        subtitle: "Nama saya, saya dari, saya tinggal di",
        symbol: "person.fill",
        steps: [
            .learn(
                "Nama saya…",
                "\"My name\" is nama saya — noun first, owner second. Indonesian puts the owner after the thing owned, the opposite of English.",
                pattern: "Nama/O saya/S Rina/X",
                examples: [
                    Example("Nama saya Rina", "My name is Rina"),
                    Example("Siapa nama Anda?", "What is your name?", note: "formal — literally \"who\""),
                    Example("Siapa namamu?", "What's your name?", note: "casual"),
                    Example("Salam kenal", "Nice to meet you", note: "said when you first meet")
                ]
            ),
            .arrange(
                "My name is Rina",
                "Nama saya Rina",
                extras: ["adalah", "punya"],
                why: "No word for \"is\", and the owner follows the noun: name–my–Rina."
            ),
            .pick(
                "Ask a new friend their name, casually:",
                ["Siapa namamu?", "Siapa nama Anda?", "Apa kamu nama?"],
                answer: "Siapa namamu?",
                why: "Indonesian asks siapa (\"who\"), not apa. -mu is the casual \"your\" and sticks to the noun."
            ),
            .learn(
                "Where you're from, where you live",
                "Saya dari… means \"I'm from…\" with no verb at all. For where you live, use tinggal di (\"live at\").",
                pattern: "Saya/S dari/L Australia/O",
                examples: [
                    Example("Saya dari Australia", "I'm from Australia"),
                    Example("Saya tinggal di Canggu", "I live in Canggu"),
                    Example("Asalnya dari mana?", "Where are you from?", note: "literally \"origin from where\"")
                ]
            ),
            .arrange(
                "I live in Bali",
                "Saya tinggal di Bali",
                extras: ["adalah", "ke"],
                why: "tinggal di = live in. The verb stays as it is."
            ),
            .hear(
                "Senang bertemu dengan Anda",
                ["Pleased to meet you", "See you tomorrow", "Where do you live?"],
                answer: "Pleased to meet you",
                why: "senang = glad, bertemu = to meet. Formal; with friends, salam kenal is enough."
            ),
            .pick(
                "Someone says \"Salam kenal.\" — reply:",
                say: "Salam kenal.",
                ["Salam kenal juga", "Sama-sama", "Permisi"],
                answer: "Salam kenal juga",
                why: "juga = \"too\", and it goes at the end."
            ),
            .arrange(
                "I'm from Canada, but I live in Bali",
                "Saya dari Kanada, tapi saya tinggal di Bali",
                alt: ["Saya dari Kanada tapi tinggal di Bali"],
                extras: ["adalah", "dan"],
                why: "tapi = but. The second saya can be dropped once it's obvious."
            )
        ]
    )

    static let lesson13 = Lesson(
        id: "1.3",
        title: "How are you?",
        subtitle: "Apa kabar? Baik!",
        symbol: "face.smiling.fill",
        steps: [
            .learn(
                "Apa kabar?",
                "Literally \"what news?\". It's the friendly how-are-you for someone you haven't seen for a while. The usual answer is baik (well), then you ask back.",
                pattern: "Apa/Q kabar/O",
                examples: [
                    Example("Apa kabar?", "How are you?"),
                    Example("Baik, terima kasih", "Fine, thanks"),
                    Example("Kabar baik. Kamu?", "I'm good. You?"),
                    Example("Lumayan", "Not bad", note: "honest and very common")
                ]
            ),
            .pick(
                "A friend asks \"Apa kabar?\". Answer and ask back:",
                ["Baik. Kamu?", "Sama-sama. Kamu?", "Selamat. Kamu?"],
                answer: "Baik. Kamu?",
                why: "baik = well. sama-sama answers a thank-you, not a how-are-you."
            ),
            .learn(
                "Saying goodbye",
                "Goodbyes in Indonesian often wish the other person well on the road, because so much of life happens on a scooter.",
                examples: [
                    Example("Sampai jumpa", "See you"),
                    Example("Sampai besok", "See you tomorrow"),
                    Example("Hati-hati di jalan", "Take care on the road"),
                    Example("Duluan, ya", "I'll head off first", note: "what you say when you leave before others")
                ]
            ),
            .arrange(
                "See you tomorrow",
                "Sampai besok",
                extras: ["kemarin", "jumpa"],
                why: "sampai = until. besok = tomorrow. Literally \"until tomorrow\"."
            ),
            .hear(
                "Hati-hati di jalan",
                ["Take care on the road", "The road is closed", "Go straight ahead"],
                answer: "Take care on the road",
                why: "hati-hati = careful, di jalan = on the road. Said to anyone leaving."
            ),
            .pick(
                "You're leaving a café before your friends. Say:",
                ["Duluan, ya", "Sampai jumpa lagi besok pagi", "Selamat datang"],
                answer: "Duluan, ya",
                why: "duluan = first, ahead. The polite little line for leaving a group."
            ),
            .arrange(
                "Fine, thanks",
                "Baik, terima kasih",
                alt: ["Baik, makasih", "Baik terima kasih"],
                extras: ["sama-sama", "apa"],
                why: "Short and polite. makasih works with friends."
            )
        ]
    )

    static let lesson14 = Lesson(
        id: "1.4",
        title: "Please and go ahead",
        subtitle: "tolong, minta, silakan",
        symbol: "hands.sparkles.fill",
        steps: [
            .learn(
                "Three kinds of \"please\"",
                "English has one please; Indonesian splits it by what you're doing. tolong when you ask someone to do something for you, minta when you ask for a thing, silakan when you invite someone to go ahead.",
                pattern: "Tolong/H tutup/V pintunya/O",
                examples: [
                    Example("Tolong tutup pintunya", "Please close the door"),
                    Example("Minta air putih", "Some water, please"),
                    Example("Silakan duduk", "Please, have a seat"),
                    Example("Silakan masuk", "Come in")
                ]
            ),
            .pick(
                "You want a glass of water. Say:",
                ["Minta air putih", "Tolong air putih", "Silakan air putih"],
                answer: "Minta air putih",
                why: "You're asking for a thing, so minta."
            ),
            .pick(
                "You want the driver to wait a moment. Say:",
                ["Tolong tunggu sebentar", "Minta tunggu sebentar", "Silakan tunggu sebentar"],
                answer: "Tolong tunggu sebentar",
                why: "You're asking him to do something for you, so tolong. sebentar = a moment."
            ),
            .learn(
                "Making space",
                "permisi is \"excuse me\" for getting past, getting attention or entering. maaf is \"sorry\". Both are used constantly, and a little bow of the head goes with permisi.",
                examples: [
                    Example("Permisi, Bu", "Excuse me, ma'am", note: "to get past or to call someone"),
                    Example("Maaf, saya terlambat", "Sorry, I'm late"),
                    Example("Maaf, tidak bisa", "Sorry, I can't"),
                    Example("Sebentar, ya", "Just a moment")
                ]
            ),
            .arrange(
                "Please, have a seat",
                "Silakan duduk",
                extras: ["minta", "tolong"],
                why: "silakan invites someone to do something for their own benefit."
            ),
            .hear(
                "Tolong tunggu sebentar",
                ["Please wait a moment", "Please come in", "Sorry, I'm late"],
                answer: "Please wait a moment",
                why: "tolong = please (do this for me), tunggu = wait, sebentar = a moment."
            ),
            .arrange(
                "Sorry, I'm late",
                "Maaf, saya terlambat",
                alt: ["Maaf saya terlambat", "Maaf, saya telat"],
                extras: ["permisi", "sudah"],
                why: "maaf = sorry. telat is the casual word for late."
            )
        ]
    )
}
