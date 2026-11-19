import SwiftUI

extension Curriculum {
    static let unit9 = Unit(
        id: "u9",
        number: 9,
        indoTitle: "Jalan-jalan",
        title: "Getting around",
        blurb: "Rides, places to stay, and what to say when something goes wrong.",
        accent: .indigo,
        symbol: "map.fill",
        lessons: [lesson91, lesson92, lesson93]
    )

    static let lesson91 = Lesson(
        id: "9.1",
        title: "Rides",
        subtitle: "naik ojek, ke bandara",
        symbol: "scooter",
        steps: [
            .learn(
                "naik + the ride",
                "naik (to get on, go up) is how you say you take any transport: naik ojek, naik taksi, naik kapal. The verb doesn't change for past or future.",
                pattern: "Saya/S naik/V ojek/O",
                examples: [
                    Example("Saya naik ojek", "I'll take a motorbike taxi"),
                    Example("Kami naik kapal ke Nusa Penida", "We're taking the boat to Nusa Penida"),
                    Example("Naik pesawat jam berapa?", "What time is your flight?"),
                    Example("Turun di sini", "Get off here")
                ]
            ),
            .pick(
                "Say you'll take a taxi:",
                ["Saya naik taksi", "Saya pakai taksi naik", "Saya taksi naik"],
                answer: "Saya naik taksi",
                why: "naik + vehicle, in the usual subject-verb-object order."
            ),
            .learn(
                "Talking to the driver",
                "Name the place with ke, ask the price before you go, and use kiri (left) to stop: drivers pull over to the left.",
                examples: [
                    Example("Ke bandara, ya", "To the airport, please"),
                    Example("Berapa ke Ubud?", "How much to Ubud?"),
                    Example("Kiri, ya, Pak", "Stop here, please"),
                    Example("Di sini aja", "Right here is fine")
                ]
            ),
            .arrange(
                "To the airport, please",
                "Ke bandara, ya",
                alt: ["Ke bandara", "Ke bandara, Pak"],
                extras: ["di", "dari"],
                why: "ke = to. bandara = airport."
            ),
            .hear(
                "Sudah sampai",
                ["We've arrived", "Not there yet", "We're leaving"],
                answer: "We've arrived",
                why: "sampai = arrive. sudah = already."
            ),
            .pick(
                "You want the driver to stop right here:",
                ["Di sini aja, Pak", "Dari sini, Pak", "Sampai jumpa, Pak"],
                answer: "Di sini aja, Pak",
                why: "di sini = here. aja makes it light: here's fine."
            ),
            .arrange(
                "How long to Ubud?",
                "Berapa lama ke Ubud?",
                alt: ["Ke Ubud berapa lama?"],
                extras: ["harga", "jam"],
                why: "berapa lama = how long. ke = to."
            )
        ]
    )

    static let lesson92 = Lesson(
        id: "9.2",
        title: "Places to stay",
        subtitle: "atas nama, handuk, kunci",
        symbol: "bed.double.fill",
        steps: [
            .learn(
                "Checking in",
                "Bookings are \"atas nama\" (in the name of). Nights are malam.",
                pattern: "Saya/S sudah/T pesan/V kamar/O",
                examples: [
                    Example("Saya sudah pesan kamar", "I've booked a room"),
                    Example("Atas nama Sam", "Under the name Sam"),
                    Example("Untuk tiga malam", "For three nights"),
                    Example("Check-out jam berapa?", "What time is check-out?")
                ]
            ),
            .pick(
                "The receptionist asks whose name the booking is in:",
                ["Atas nama Alex", "Nama saya atas Alex", "Untuk nama Alex"],
                answer: "Atas nama Alex",
                why: "atas nama = in the name of. The set phrase for bookings and bills."
            ),
            .learn(
                "When something's not right",
                "Point at the thing with -nya and add how it is. Staff are used to this and will usually fix it fast.",
                examples: [
                    Example("AC-nya tidak dingin", "The air-con isn't cold"),
                    Example("Air panasnya gak keluar", "There's no hot water"),
                    Example("Kuncinya hilang", "I've lost the key"),
                    Example("Bisa minta handuk lagi?", "Could I have another towel?")
                ]
            ),
            .arrange(
                "I've booked a room",
                "Saya sudah pesan kamar",
                alt: ["Saya sudah booking kamar", "Saya sudah pesan kamarnya"],
                extras: ["akan", "belum"],
                why: "sudah + pesan (order, book). The verb stays the same."
            ),
            .hear(
                "Sarapan jam tujuh sampai jam sepuluh",
                ["Breakfast is from seven to ten", "Breakfast is at ten past seven", "Breakfast is ten thousand"],
                answer: "Breakfast is from seven to ten",
                why: "sampai = until. jam tujuh = seven o'clock."
            ),
            .arrange(
                "Could I have another towel?",
                "Bisa minta handuk lagi?",
                alt: ["Boleh minta handuk lagi?", "Minta handuk lagi, ya"],
                extras: ["tolong", "kunci"],
                why: "bisa + minta for a polite request. lagi = another, more."
            ),
            .pick(
                "Your room key has gone missing:",
                ["Kuncinya hilang", "Kuncinya rusak", "Kuncinya mati"],
                answer: "Kuncinya hilang",
                why: "hilang = lost, gone. rusak = broken, mati = dead or off."
            )
        ]
    )

    static let lesson93 = Lesson(
        id: "9.3",
        title: "Help!",
        subtitle: "tolong, sakit, hilang",
        symbol: "cross.case.fill",
        steps: [
            .learn(
                "In an emergency",
                "tolong on its own means \"help!\". Keep these short; people will understand and come.",
                pattern: "Tolong/H panggil/V dokter/O",
                examples: [
                    Example("Tolong!", "Help!"),
                    Example("Tolong panggil dokter", "Please call a doctor"),
                    Example("Panggil ambulans!", "Call an ambulance!"),
                    Example("Rumah sakit terdekat di mana?", "Where's the nearest hospital?")
                ]
            ),
            .pick(
                "Ask where the nearest hospital is:",
                ["Rumah sakit terdekat di mana?", "Di mana sakit rumah?", "Rumah sakit dekat apa?"],
                answer: "Rumah sakit terdekat di mana?",
                why: "rumah sakit = hospital (literally \"sick house\"). terdekat = nearest."
            ),
            .learn(
                "Saying what's wrong",
                "sakit means sick and also hurts. Put the body part first, then sakit. pusing covers dizzy and a headache.",
                examples: [
                    Example("Perut saya sakit", "My stomach hurts"),
                    Example("Kepala saya pusing", "I've got a headache / I'm dizzy"),
                    Example("Saya demam", "I have a fever"),
                    Example("Saya jatuh dari motor", "I fell off my scooter")
                ]
            ),
            .arrange(
                "My stomach hurts",
                "Perut saya sakit",
                alt: ["Saya sakit perut", "Perutku sakit"],
                extras: ["kepala", "tidak"],
                why: "Body part + owner + sakit. Saya sakit perut also works."
            ),
            .hear(
                "Dompet saya hilang",
                ["I've lost my wallet", "My phone is broken", "My bag is here"],
                answer: "I've lost my wallet",
                why: "dompet = wallet, hilang = lost, gone."
            ),
            .pick(
                "Tell someone you fell off your scooter:",
                ["Saya jatuh dari motor", "Saya jatuh ke motor", "Motor saya jatuh dari saya"],
                answer: "Saya jatuh dari motor",
                why: "jatuh = fall, dari = from."
            ),
            .arrange(
                "Please call a doctor",
                "Tolong panggil dokter",
                alt: ["Tolong panggilkan dokter"],
                extras: ["minta", "rumah"],
                why: "tolong + verb when you ask someone to do something."
            )
        ]
    )
}
