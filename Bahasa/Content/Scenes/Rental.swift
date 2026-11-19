import Foundation

// Place: Rental (scooter hire). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let pakGede = Character(
        id: "pak-gede",
        name: "Pak Gede",
        role: "rents out scooters by the week",
        register: .neutral,
        addressAs: ["Pak"],
        moods: [.chatty, .busy],
        defaultMood: .chatty,
        confused: [
            Utterance("Maaf, gimana, Kak?", gloss: "Sorry, how's that?"),
            Utterance("Hmm? Mau sewa berapa hari?", gloss: "Hmm? How many days do you want it?"),
            Utterance("Maaf, kurang jelas, Kak.", gloss: "Sorry, that wasn't clear.")
        ]
    )

    static let rentalMotor = RehearsalScene(
        id: "id.rental.motor",
        language: "id",
        place: "Rental",
        title: "Sewa motor",
        titleEn: "Renting a scooter",
        setting: "A row of scooters by the road, helmets on a rack, and a hand-written price board.",
        level: .getBy,
        accent: .laut,
        symbol: "key.fill",
        character: pakGede,
        goalSummary: "Ask the price, pick how long, show your licence, and ride off with a helmet.",
        goals: [
            GoalFlag(id: "asked_price", label: "Ask the price"),
            GoalFlag(id: "chose", label: "Pick how long"),
            GoalFlag(id: "licence", label: "Show your licence"),
            GoalFlag(id: "contact", label: "Get his number", optional: true)
        ],
        warmUps: [
            WarmUp(title: "Rides", lessonID: "9.1"),
            WarmUp(title: "Numbers & prices", lessonID: "5.2"),
            WarmUp(title: "Comparing · lebih murah", lessonID: "11.3")
        ],
        culture: [
            "Weekly and monthly rentals cost much less per day than daily ones. You fill up the petrol yourself.",
            "Police check for helmets and an international driving permit (SIM internasional). Always wear the helmet."
        ],
        slots: [],
        entry: "m1",
        nodes: [
            SceneNode(
                id: "m1",
                them: Utterance("Mau sewa motor, Kak?", casual: "Sewa motor, Kak?",
                                gloss: "Want to rent a scooter?", chips: "Mau/H sewa/V motor/O"),
                variants: [.busy: Utterance("Sewa, Kak?", gloss: "Renting?")],
                replies: [
                    .natural("Iya, Pak. Berapa sehari?", "Yes. How much per day?",
                             accept: ["berapa sehari", "iya berapa sehari", "sehari berapa"],
                             sets: ["asked_price"], next: "m2", chips: "Iya/X Pak/X Berapa/Q sehari/T"),
                    .natural("Iya, Pak. Kalau seminggu, berapa?", "Yes. How much for a week?",
                             accept: ["kalau seminggu berapa", "seminggu berapa", "berapa seminggu"],
                             sets: ["asked_price"], next: "m2b", chips: "Kalau/L seminggu/T berapa/Q"),
                    .natural("Iya. Ada yang matic, Pak?", "Yes. Do you have an automatic?",
                             accept: ["ada yang matic", "ada matic", "yang matic ada"],
                             next: "m1b", chips: "Ada/V yang/L matic/D Pak/X"),
                    .missed("Iya, saya mau beli motor.", "Yes, I want to buy a scooter.",
                            reaction: Utterance("Beli? Di sini sewa aja, Kak.", gloss: "Buy? We only rent here."),
                            coach: "beli is buy; sewa is rent: Saya mau sewa motor.")
                ]
            ),
            SceneNode(
                id: "m1b",
                them: Utterance("Ada, semua matic. Mau berapa hari?", casual: "Matic semua. Berapa hari?",
                                gloss: "Yes, they're all automatic. For how many days?",
                                chips: "Ada/V semua/X matic/D Mau/H berapa/Q hari/T"),
                replies: [
                    .natural("Seminggu. Berapa, Pak?", "A week. How much?",
                             accept: ["seminggu berapa", "seminggu"],
                             sets: ["asked_price"], next: "m2b", chips: "Seminggu/T Berapa/Q Pak/X"),
                    .natural("Sehari dulu. Berapa, Pak?", "One day for now. How much?",
                             accept: ["sehari dulu berapa", "sehari dulu", "sehari berapa"],
                             sets: ["asked_price"], next: "m2", chips: "Sehari/T dulu/T Berapa/Q"),
                    .missed("Tujuh hari lagi.", "In seven more days.",
                            reaction: Utterance("Tujuh hari lagi? Jadi sewanya minggu depan?", gloss: "In seven days? So you want it next week?"),
                            coach: "lagi points ahead. For a week-long rental: Seminggu.")
                ]
            ),
            SceneNode(
                id: "m2",
                them: Utterance("Sehari tujuh puluh ribu. Kalau seminggu, lebih murah.", casual: "Sehari tujuh puluh. Seminggu lebih murah.",
                                gloss: "Seventy thousand a day. By the week it's cheaper.",
                                chips: "Sehari/T tujuh_puluh_ribu/O Kalau/L seminggu/T lebih_murah/D"),
                focus: "numbers",
                replies: [
                    .natural("Seminggu berapa, Pak?", "How much for a week?",
                             accept: ["seminggu berapa", "kalau seminggu berapa"],
                             next: "m2b", chips: "Seminggu/T berapa/Q Pak/X"),
                    .natural("Oke, sehari aja, Pak.", "OK, just one day.",
                             accept: ["sehari aja", "sehari saja", "oke sehari"],
                             sets: ["chose"], next: "m3", chips: "Oke/X sehari/T aja/X"),
                    .missed("Tujuh belas ribu? Murah!", "Seventeen thousand? Cheap!",
                            reaction: Utterance("Tujuh puluh, Kak. Bukan tujuh belas.", gloss: "Seventy, not seventeen."),
                            coach: "tujuh belas is 17; tujuh puluh is 70.")
                ]
            ),
            SceneNode(
                id: "m2b",
                them: Utterance("Seminggu empat ratus ribu.", casual: "Seminggu empat ratus.",
                                gloss: "Four hundred thousand a week.", chips: "Seminggu/T empat_ratus_ribu/O"),
                variants: [.busy: Utterance("Empat ratus seminggu.", gloss: "Four hundred a week.")],
                replies: [
                    .natural("Oke, seminggu, ya.", "OK, a week then.",
                             accept: ["seminggu ya", "oke seminggu", "seminggu aja"],
                             sets: ["chose"], next: "m3", chips: "Oke/X seminggu/T ya/X"),
                    .natural("Bisa tiga ratus lima puluh, Pak?", "Could you do three hundred and fifty?",
                             accept: ["bisa tiga ratus lima puluh", "tiga ratus lima puluh bisa", "tiga ratus lima puluh"],
                             sets: ["chose"], next: "m2c", moodNext: [.busy: "m3"], chips: "Bisa/H tiga_ratus_lima_puluh/O Pak/X"),
                    .missed("Empat ratus ribu sehari?", "Four hundred thousand a day?",
                            reaction: Utterance("Bukan, seminggu, Kak.", gloss: "No, a week."),
                            coach: "seminggu is a week; sehari is a day.")
                ]
            ),
            SceneNode(
                id: "m2c",
                them: Utterance("Ya udah, boleh. Tapi bensin isi sendiri, ya.", casual: "Oke deh. Bensin sendiri, ya.",
                                gloss: "All right, fine. But you fill up the petrol yourself.",
                                chips: "Ya_udah/X boleh/H Tapi/L bensin/O isi/V sendiri/X"),
                replies: [
                    .natural("Siap, Pak. Makasih!", "Sure. Thanks!", accept: ["siap makasih", "siap pak makasih"],
                             next: "m3", chips: "Siap/D Pak/X Makasih/X"),
                    .natural("Oke, gak apa-apa.", "OK, that's fine.", accept: ["gak apa apa", "oke gak apa apa", "tidak apa apa"],
                             next: "m3", chips: "Oke/X gak_apa-apa/N"),
                    .missed("Bensinnya gratis?", "The petrol's free?",
                            reaction: Utterance("Hehe, gak, Kak. Isi sendiri.", gloss: "Heh, no. You fill it yourself."),
                            coach: "isi sendiri means fill it yourself. Just agree: Siap, Pak.")
                ]
            ),
            SceneNode(
                id: "m3",
                them: Utterance("Ada SIM internasional, Kak?", casual: "SIM-nya ada, Kak?",
                                gloss: "Do you have an international driving permit?",
                                chips: "Ada/V SIM_internasional/O"),
                replies: [
                    .natural("Ada, Pak. Ini.", "Yes. Here.", accept: ["ada ini", "ada pak ini", "ini pak"],
                             sets: ["licence"], next: "m4", chips: "Ada/V Pak/X Ini/S"),
                    .natural("Ada. Mau lihat sekarang?", "Yes. Want to see it now?",
                             accept: ["mau lihat sekarang", "ada mau lihat"],
                             sets: ["licence"], next: "m4", chips: "Ada/V Mau/H lihat/V sekarang/T"),
                    .understood("Ya, saya punya SIM.", "Yes, I have a licence.", sets: ["licence"], next: "m4",
                                coach: "Clear. Shorter is more natural: Ada, Pak. Ini."),
                    .missed("Kartu SIM? Belum beli, Pak.", "A SIM card? Haven't bought one.",
                            reaction: Utterance("Hehe, bukan kartu SIM, Kak. SIM buat nyetir!", gloss: "Heh, not a phone SIM. A licence for driving!"),
                            coach: "SIM is a driving licence (Surat Izin Mengemudi). A phone SIM is kartu SIM.")
                ]
            ),
            SceneNode(
                id: "m4",
                narration: "He hands you the key and two helmets.",
                them: Utterance("Ini kuncinya. Helmnya dua, ya. Hati-hati, jalannya rame.",
                                casual: "Kuncinya, Kak. Helm dua. Hati-hati, ya.",
                                gloss: "Here's the key. Two helmets. Careful, the roads are busy.",
                                chips: "Ini/S kuncinya/O Helmnya/O dua/X Hati-hati/D jalannya/S rame/D"),
                variants: [.busy: Utterance("Kuncinya, Kak. Hati-hati.", gloss: "The key. Take care.")],
                replies: [
                    .natural("Makasih, Pak. Nomor WA Bapak berapa?", "Thanks. What's your WhatsApp number?",
                             accept: ["nomor wa bapak berapa", "nomor wa berapa", "minta nomor wa"],
                             sets: ["contact"], next: "m5", moodNext: [.busy: "end"], chips: "Nomor_WA/O Bapak/S berapa/Q"),
                    .natural("Siap, Pak. Makasih!", "Will do. Thanks!",
                             accept: ["siap makasih", "siap pak"],
                             next: "end", chips: "Siap/D Pak/X Makasih/X"),
                    .off("Helm gak usah, Pak.", "No need for a helmet.",
                         reaction: Utterance("Wah, harus pakai helm, Kak. Nanti ditilang!", gloss: "Oh, you have to. You'll get a ticket!"),
                         coach: "Helmets are the law, and police do stop riders without one. Always wear it.")
                ]
            ),
            SceneNode(
                id: "m5",
                them: Utterance("Ini nomor saya. Kalau ada apa-apa, telepon aja.", casual: "Nomor saya, Kak. Ada apa-apa, telepon.",
                                gloss: "Here's my number. If anything comes up, just call.",
                                chips: "Ini/S nomor_saya/O Kalau/L ada_apa-apa/V telepon/V aja/X"),
                replies: [
                    .natural("Sip, makasih, Pak!", "Great, thanks!", accept: ["sip makasih", "makasih pak"],
                             next: "end", chips: "Sip/X makasih/X Pak/X"),
                    .natural("Oke, Pak. Saya simpan.", "OK. I'll save it.", accept: ["saya simpan", "oke saya simpan"],
                             next: "end", chips: "Oke/X Saya/S simpan/V"),
                    .missed("Ada apa-apa, Pak?", "Is something wrong?",
                            reaction: Utterance("Gak ada, Kak. Maksudnya kalau ada masalah.", gloss: "Nothing. I mean if there's a problem."),
                            coach: "Kalau ada apa-apa means \"if anything comes up\". Just thank him.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Sama-sama. Selamat jalan-jalan, Kak!", gloss: "You're welcome. Enjoy exploring!",
                                chips: "Sama-sama/X Selamat/X jalan-jalan/V"),
                variants: [.busy: Utterance("Oke, Kak. Hati-hati!", gloss: "OK. Take care!")]
            )
        ],
        listening: [
            ListeningCheck(question: "How much was it per day?",
                           options: ["Rp 70.000", "Rp 17.000", "Rp 700.000"], answer: "Rp 70.000"),
            ListeningCheck(question: "What did he ask to see?",
                           options: ["Your international driving permit", "Your passport", "Your phone"],
                           answer: "Your international driving permit"),
            ListeningCheck(question: "What did he give you with the key?",
                           options: ["Two helmets", "A raincoat", "A map"], answer: "Two helmets")
        ]
    )
}
