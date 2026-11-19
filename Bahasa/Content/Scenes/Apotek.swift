import Foundation

// Place: Apotek (pharmacy). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let mbakRina = Character(
        id: "mbak-rina",
        name: "Mbak Rina",
        role: "pharmacist at the apotek",
        register: .neutral,
        addressAs: ["Mbak"],
        moods: [.warm, .busy],
        defaultMood: .warm,
        confused: [
            Utterance("Maaf, maksudnya?", gloss: "Sorry, meaning?"),
            Utterance("Maaf, bisa diulang, Kak?", gloss: "Sorry, could you say that again?"),
            Utterance("Hmm? Sakit apa, Kak?", gloss: "Hmm? What's wrong?")
        ]
    )

    static let apotekObat = RehearsalScene(
        id: "id.apotek.obat",
        language: "id",
        place: "Apotek",
        title: "Beli obat di apotek",
        titleEn: "At the pharmacy",
        setting: "A bright little apotek on the main road. Shelves of boxes, a cool fan, a pharmacist in a white coat.",
        level: .getBy,
        accent: .jambu,
        symbol: "cross.case.fill",
        character: mbakRina,
        goalSummary: "Say what's wrong, answer her questions, check how to take the medicine, and pay.",
        goals: [
            GoalFlag(id: "symptom", label: "Say what's wrong"),
            GoalFlag(id: "fever", label: "Answer about fever", optional: true),
            GoalFlag(id: "dosage", label: "Check how to take it"),
            GoalFlag(id: "paid", label: "Pay")
        ],
        warmUps: [
            WarmUp(title: "Saying what's wrong", lessonID: "9.3"),
            WarmUp(title: "Numbers · puluh & ribu", lessonID: "5.2"),
            WarmUp(title: "tidak & bukan", lessonID: "4.1")
        ],
        culture: [
            "An apotek can suggest medicine for everyday problems. Antibiotics need a doctor's prescription (resep).",
            "Semoga cepat sembuh (get well soon) is what people say when you're unwell."
        ],
        slots: [],
        entry: "a1",
        nodes: [
            SceneNode(
                id: "a1",
                them: Utterance("Selamat siang. Ada yang bisa dibantu?", casual: "Cari apa, Kak?",
                                gloss: "Good afternoon. How can I help?",
                                chips: "Selamat_siang/X Ada/V yang/L bisa/H dibantu/V"),
                variants: [.busy: Utterance("Ya, Kak? Cari apa?", gloss: "Yes? What are you looking for?")],
                replies: [
                    .natural("Saya sakit perut, Mbak.", "I have a stomach ache.",
                             accept: ["sakit perut", "perut saya sakit", "saya sakit perut"],
                             sets: ["symptom"], next: "a2", chips: "Saya/S sakit/D perut/O Mbak/X"),
                    .natural("Ada obat sakit perut, Mbak?", "Do you have something for a stomach ache?",
                             accept: ["ada obat sakit perut", "obat sakit perut", "ada obat diare"],
                             sets: ["symptom"], next: "a2", chips: "Ada/V obat/O sakit_perut/O Mbak/X"),
                    .natural("Mbak, ada obat diare?", "Do you have something for diarrhoea?",
                             accept: ["ada obat diare", "obat diare ada", "obat diare"],
                             sets: ["symptom"], next: "a2", chips: "Mbak/X ada/V obat/O diare/O"),
                    .understood("Saya perut sakit.", "I stomach sick.", sets: ["symptom"], next: "a2",
                                coach: "She got it. The usual order is sakit perut (ache + where) or perut saya sakit."),
                    .missed("Saya sakit hati, Mbak.", "I'm heartbroken.",
                            reaction: Utterance("Aduh… sakit hati kenapa, Kak?", gloss: "Oh dear… why are you hurt?"),
                            coach: "sakit hati means hurt feelings! Your stomach is perut: sakit perut.")
                ]
            ),
            SceneNode(
                id: "a2",
                them: Utterance("Sudah berapa hari?", casual: "Udah berapa hari?", gloss: "For how many days?",
                                chips: "Sudah/T berapa/Q hari/T"),
                variants: [.busy: Utterance("Berapa hari?", gloss: "How many days?")],
                replies: [
                    .natural("Dari kemarin, Mbak.", "Since yesterday.",
                             accept: ["dari kemarin", "sejak kemarin"],
                             next: "a3", moodNext: [.busy: "a4"], chips: "Dari/X kemarin/T Mbak/X"),
                    .natural("Udah dua hari.", "Two days now.",
                             accept: ["sudah dua hari", "dua hari", "udah dua hari mbak"],
                             next: "a3", moodNext: [.busy: "a4"], chips: "Udah/T dua_hari/T"),
                    .missed("Dua hari lagi.", "In two more days.",
                            reaction: Utterance("Lho, dua hari lagi? Maksudnya sudah dua hari?",
                                                gloss: "Huh, in two days? You mean for two days now?"),
                            coach: "lagi points ahead. For time already passed, use sudah: Sudah dua hari.")
                ]
            ),
            SceneNode(
                id: "a3",
                them: Utterance("Ada demam juga?", casual: "Demam gak?", gloss: "Any fever too?",
                                chips: "Ada/V demam/O juga/X"),
                replies: [
                    .natural("Gak ada, Mbak. Cuma perut aja.", "No. Just my stomach.",
                             accept: ["gak ada", "tidak ada", "cuma perut", "gak ada demam", "cuma perut saja"],
                             sets: ["fever"], next: "a4", chips: "Gak/N ada/V Cuma/X perut/O aja/X"),
                    .natural("Sedikit, Mbak. Badan agak panas.", "A little. I feel a bit hot.",
                             accept: ["sedikit", "agak panas", "badan agak panas", "iya sedikit"],
                             sets: ["fever"], next: "a3b", chips: "Sedikit/D Badan/S agak/D panas/D"),
                    .missed("Demam tidak.", "Fever no.",
                            reaction: Utterance("Demam… atau tidak?", gloss: "Fever… or not?"),
                            coach: "tidak goes before the word it cancels: tidak demam. Or just: Gak ada.")
                ]
            ),
            SceneNode(
                id: "a3b",
                them: Utterance("Oke. Kalau demamnya tinggi, ke dokter, ya.", casual: "Kalau panas tinggi, ke dokter, ya.",
                                gloss: "OK. If the fever gets high, see a doctor.",
                                chips: "Kalau/L demamnya/S tinggi/D ke/X dokter/O ya/X"),
                replies: [
                    .natural("Iya, Mbak. Makasih.", "Yes. Thanks.",
                             accept: ["iya makasih", "oke makasih", "makasih mbak"],
                             next: "a4", chips: "Iya/X Mbak/X Makasih/X"),
                    .natural("Oke, Mbak. Nanti saya ke dokter.", "OK. I'll go to the doctor if so.",
                             accept: ["nanti saya ke dokter", "oke ke dokter", "nanti ke dokter"],
                             next: "a4", chips: "Nanti/T saya/S ke/X dokter/O"),
                    .missed("Sama-sama, Mbak.", "You're welcome.",
                            reaction: Utterance("Hehe… iya.", gloss: "Heh… right."),
                            coach: "sama-sama answers thanks. She gave you advice, so say Iya, makasih.")
                ]
            ),
            SceneNode(
                id: "a4",
                narration: "She puts a small box on the counter.",
                them: Utterance("Ini obatnya. Diminum tiga kali sehari, sesudah makan.", casual: "Ini, tiga kali sehari, habis makan.",
                                gloss: "Here's the medicine. Take it three times a day, after meals.",
                                chips: "Ini/S obatnya/O Diminum/V tiga_kali_sehari/T sesudah/T makan/V"),
                replies: [
                    .natural("Tiga kali sehari, ya. Makasih, Mbak.", "Three times a day. Thanks.",
                             accept: ["tiga kali sehari", "tiga kali sehari ya", "oke tiga kali sehari"],
                             sets: ["dosage"], next: "a5", chips: "Tiga_kali_sehari/T ya/X Makasih/X"),
                    .natural("Sesudah makan, ya, Mbak?", "After meals, right?",
                             accept: ["sesudah makan ya", "habis makan ya", "sesudah makan"],
                             sets: ["dosage"], next: "a5", chips: "Sesudah/T makan/V ya/X Mbak/X"),
                    .missed("Tiga hari sekali?", "Once every three days?",
                            reaction: Utterance("Bukan, Kak. Tiga kali sehari.", gloss: "No. Three times a day."),
                            coach: "tiga kali sehari is three times a day; tiga hari sekali is once every three days."),
                    .missed("Sebelum makan, ya?", "Before meals, right?",
                            reaction: Utterance("Sesudah makan, Kak.", gloss: "After meals."),
                            coach: "sebelum is before; sesudah (or habis) is after.")
                ]
            ),
            SceneNode(
                id: "a5",
                them: Utterance("Semuanya dua puluh delapan ribu.", casual: "Dua puluh delapan, Kak.",
                                gloss: "That's twenty-eight thousand altogether.",
                                chips: "Semuanya/S dua_puluh_delapan_ribu/O"),
                focus: "numbers",
                replies: [
                    .natural("Bisa pakai QRIS, Mbak?", "Can I pay by QRIS?",
                             accept: ["bisa qris", "pakai qris bisa", "bisa bayar pakai qris"],
                             sets: ["paid"], next: "end", chips: "Bisa/H pakai/V QRIS/O Mbak/X"),
                    .natural("Ini uangnya, Mbak.", "Here's the money.",
                             accept: ["ini uangnya", "ini uang"],
                             sets: ["paid"], next: "end", chips: "Ini/S uangnya/O Mbak/X"),
                    .missed("Delapan puluh dua ribu?", "Eighty-two thousand?",
                            reaction: Utterance("Dua puluh delapan, Kak.", gloss: "Twenty-eight."),
                            coach: "The tens come first: dua puluh delapan is 28; delapan puluh dua is 82."),
                    .off("Mahal! Bisa kurang?", "Expensive! Can you go lower?",
                         reaction: Utterance("Maaf, harga apotek pas, Kak.", gloss: "Sorry, pharmacy prices are fixed."),
                         coach: "Pharmacy prices are fixed. Save haggling for the pasar.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Terima kasih. Semoga cepat sembuh, ya!", gloss: "Thank you. Get well soon!",
                                chips: "Terima_kasih/X Semoga/H cepat/D sembuh/V ya/X"),
                variants: [.busy: Utterance("Makasih, Kak. Cepat sembuh!", gloss: "Thanks. Get well soon!")]
            )
        ],
        listening: [
            ListeningCheck(question: "What did she ask you?",
                           options: ["How long you'd been ill", "Where you live", "How old you are"],
                           answer: "How long you'd been ill"),
            ListeningCheck(question: "How often should you take the medicine?",
                           options: ["Three times a day", "Once a day", "Every three days"], answer: "Three times a day"),
            ListeningCheck(question: "How much was it?",
                           options: ["Rp 28.000", "Rp 82.000", "Rp 8.000"], answer: "Rp 28.000")
        ]
    )
}
