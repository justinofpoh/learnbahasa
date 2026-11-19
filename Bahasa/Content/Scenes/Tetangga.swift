import Foundation

// Place: Tetangga (neighbours). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let pakNyoman = Character(
        id: "pak-nyoman",
        name: "Pak Nyoman",
        role: "your neighbour across the lane",
        register: .neutral,
        addressAs: ["Pak"],
        moods: [.warm, .chatty],
        defaultMood: .warm,
        confused: [
            Utterance("Maaf, gimana, Kak?", gloss: "Sorry, how's that?"),
            Utterance("Hmm? Maksudnya?", gloss: "Hmm? Meaning?"),
            Utterance("Hehe, maaf, Bapak kurang ngerti.", gloss: "Heh, sorry, I don't quite follow.")
        ]
    )

    static let tetanggaMampir = RehearsalScene(
        id: "id.tetangga.mampir",
        language: "id",
        place: "Tetangga",
        title: "Tetangga mampir",
        titleEn: "Your neighbour drops by",
        setting: "Evening. A knock at the gate: your neighbour, holding a plate wrapped in banana leaf.",
        level: .connect,
        accent: .sawah,
        symbol: "leaf.fill",
        character: pakNyoman,
        goalSummary: "Thank him for the food, ask about tomorrow's temple festival, and accept his invitation.",
        goals: [
            GoalFlag(id: "thanked", label: "Thank him for the food"),
            GoalFlag(id: "asked", label: "Ask about the festival", optional: true),
            GoalFlag(id: "plans", label: "Accept the invitation")
        ],
        warmUps: [
            WarmUp(title: "Helper words · boleh, harus", lessonID: "7.1"),
            WarmUp(title: "Telling the time", lessonID: "3.3"),
            WarmUp(title: "Time words · besok, pagi", lessonID: "3.1")
        ],
        culture: [
            "After a ceremony, Balinese neighbours often share food. Accept it warmly; returning the plate with something on it is a kind touch.",
            "Even just to watch at a pura, wear a kamen (sarong) and a selendang (temple sash)."
        ],
        slots: [],
        entry: "t1",
        nodes: [
            SceneNode(
                id: "t1",
                them: Utterance("Permisi! Ini ada sedikit makanan dari upacara.", casual: "Permisi! Ini, ada makanan dari upacara.",
                                gloss: "Excuse me! Here's a little food from the ceremony.",
                                chips: "Permisi/X Ini/S ada/V sedikit/D makanan/O dari/X upacara/O"),
                replies: [
                    .natural("Wah, terima kasih banyak, Pak!", "Oh, thank you so much!",
                             accept: ["terima kasih banyak", "makasih banyak", "wah makasih banyak"],
                             sets: ["thanked"], next: "t2", chips: "Wah/X terima_kasih/X banyak/D Pak/X"),
                    .natural("Wah, kok repot-repot, Pak. Makasih, ya.", "Oh, you shouldn't have. Thanks.",
                             accept: ["kok repot repot", "repot repot", "kok repot repot makasih"],
                             sets: ["thanked"], next: "t2", chips: "Wah/X kok/X repot-repot/D Pak/X Makasih/X"),
                    .missed("Permisi, Pak.", "Excuse me.",
                            reaction: Utterance("Hehe, iya… ini buat Kakak.", gloss: "Heh, yes… this is for you."),
                            coach: "permisi is what he says at your gate. You answer with thanks: Wah, terima kasih banyak!"),
                    .off("Berapa, Pak?", "How much?",
                         reaction: Utterance("Hah? Gak usah bayar, Kak!", gloss: "Huh? You don't pay for this!"),
                         coach: "It's a gift. Asking the price sounds like you think he's selling. Just thank him warmly.")
                ]
            ),
            SceneNode(
                id: "t2",
                them: Utterance("Besok ada odalan di pura. Jalannya ditutup dari pagi, ya.", casual: "Besok odalan, jalan ditutup dari pagi.",
                                gloss: "Tomorrow there's a temple festival. The road's closed from the morning.",
                                chips: "Besok/T ada/V odalan/O di/X pura/O Jalannya/S ditutup/V dari/X pagi/T"),
                variants: [.chatty: Utterance("Oh iya, besok ada odalan di pura, lho. Jalannya ditutup dari pagi, ya.",
                                              gloss: "Oh, by the way, tomorrow there's a temple festival. The road's closed from the morning.")],
                replies: [
                    .natural("Oh, iya? Sampai jam berapa, Pak?", "Oh really? Until what time?",
                             accept: ["sampai jam berapa", "jam berapa", "sampai kapan", "sampai jam berapa pak"],
                             sets: ["asked"], next: "t3", chips: "Sampai/X jam_berapa/Q Pak/X"),
                    .natural("Oke, Pak. Makasih infonya.", "OK. Thanks for letting me know.",
                             accept: ["makasih infonya", "terima kasih infonya", "oke makasih infonya"],
                             next: "t4", chips: "Oke/X Makasih/X infonya/O"),
                    .missed("Selamat ulang tahun, Pak!", "Happy birthday!",
                            reaction: Utterance("Hehe, bukan saya, Kak. Ulang tahun pura!", gloss: "Heh, not mine. It's the temple's anniversary!"),
                            coach: "Close! An odalan is a temple's anniversary festival, every 210 days. Ask about it: Sampai jam berapa?")
                ]
            ),
            SceneNode(
                id: "t3",
                them: Utterance("Sampai sore. Gamelannya agak keras, ya.", casual: "Sampai sore. Agak berisik, ya.",
                                gloss: "Until the afternoon. The gamelan is a bit loud.",
                                chips: "Sampai/X sore/T Gamelannya/S agak/D keras/D"),
                replies: [
                    .natural("Gak apa-apa, Pak. Saya suka gamelan.", "That's fine. I like gamelan.",
                             accept: ["gak apa apa", "tidak apa apa", "saya suka gamelan", "suka gamelan"],
                             next: "t4", chips: "Gak_apa-apa/N Saya/S suka/V gamelan/O"),
                    .natural("Oh, seru! Boleh saya nonton?", "Oh, fun! Can I come and watch?",
                             accept: ["boleh saya nonton", "boleh nonton", "seru boleh nonton"],
                             next: "t4", chips: "Seru/D Boleh/H saya/S nonton/V"),
                    .missed("Gamelan itu keras, Pak?", "Is that gamelan hard?",
                            reaction: Utterance("Iya, suaranya keras, Kak. Hehe.", gloss: "Yes, the sound is loud. Heh."),
                            coach: "He already told you it's loud. Reassure him (Gak apa-apa) or ask to come (Boleh saya nonton?).")
                ]
            ),
            SceneNode(
                id: "t4",
                them: Utterance("Ikut nonton aja, Kak! Tapi pakai kamen, ya.", casual: "Ikut aja, Kak! Pakai kamen, ya.",
                                gloss: "Come and watch! But wear a kamen (sarong).",
                                chips: "Ikut/V nonton/V aja/X Tapi/L pakai/V kamen/O ya/X"),
                variants: [.chatty: Utterance("Ikut nonton aja, Kak! Seru, lho. Tapi pakai kamen, ya.",
                                              gloss: "Come and watch! It's fun. But wear a kamen.")],
                replies: [
                    .natural("Mau, Pak! Kamennya beli di mana?", "I'd love to! Where do I buy a kamen?",
                             accept: ["kamennya beli di mana", "beli kamen di mana", "mau beli kamen di mana"],
                             sets: ["plans"], next: "t5", chips: "Mau/H Kamennya/O beli/V di_mana/Q"),
                    .natural("Wah, mau banget! Makasih, Pak.", "Oh, I'd love to! Thanks.",
                             accept: ["mau banget", "wah mau banget", "mau banget makasih"],
                             sets: ["plans"], next: "t6", chips: "Mau/H banget/D Makasih/X Pak/X"),
                    .off("Kamen? Saya pakai celana pendek aja.", "A kamen? I'll just wear shorts.",
                         reaction: Utterance("Hmm… di pura harus pakai kamen, Kak.", gloss: "Hmm… at the temple you have to wear a kamen."),
                         coach: "Shorts aren't OK at a temple, even to watch. Wear a kamen and a selendang (sash).")
                ]
            ),
            SceneNode(
                id: "t5",
                them: Utterance("Gak usah beli. Pinjam punya saya aja!", casual: "Gak usah beli, pinjam aja!",
                                gloss: "No need to buy one. Just borrow mine!",
                                chips: "Gak_usah/N beli/V Pinjam/V punya_saya/O aja/X"),
                replies: [
                    .natural("Wah, makasih banyak, Pak!", "Oh, thanks so much!",
                             accept: ["makasih banyak", "terima kasih banyak", "wah makasih"],
                             next: "t6", chips: "Wah/X makasih_banyak/X Pak/X"),
                    .natural("Beneran, Pak? Makasih, ya!", "Really? Thank you!",
                             accept: ["beneran pak", "beneran makasih", "beneran"],
                             next: "t6", chips: "Beneran/D Pak/X Makasih/X ya/X"),
                    .missed("Sama-sama, Pak.", "You're welcome.",
                            reaction: Utterance("Lho, kok sama-sama? Hehe.", gloss: "Huh, why 'you're welcome'? Heh."),
                            coach: "He's doing you a favour, so thank him: Makasih banyak, Pak!")
                ]
            ),
            SceneNode(
                id: "t6",
                them: Utterance("Besok jam tujuh pagi, ya. Saya jemput.", casual: "Besok jam tujuh, ya. Saya jemput.",
                                gloss: "Tomorrow at seven in the morning. I'll come and get you.",
                                chips: "Besok/T jam_tujuh_pagi/T ya/X Saya/S jemput/V"),
                variants: [.chatty: Utterance("Besok jam tujuh pagi, ya. Saya jemput. Nanti saya kenalin sama keluarga!",
                                              gloss: "Tomorrow at seven in the morning. I'll come and get you, and introduce you to the family!")],
                replies: [
                    .natural("Siap, Pak. Sampai besok!", "Will do. See you tomorrow!",
                             accept: ["siap sampai besok", "sampai besok", "siap pak sampai besok"],
                             next: "end", chips: "Siap/D Pak/X Sampai_besok/T"),
                    .natural("Oke, jam tujuh, ya. Makasih, Pak!", "OK, seven o'clock. Thanks!",
                             accept: ["oke jam tujuh", "jam tujuh ya", "jam tujuh"],
                             next: "end", chips: "Oke/X jam_tujuh/T ya/X Makasih/X"),
                    .missed("Jam tujuh malam?", "Seven at night?",
                            reaction: Utterance("Pagi, Kak. Jam tujuh pagi.", gloss: "Morning. Seven in the morning."),
                            coach: "pagi is morning; malam is night.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Sip! Selamat istirahat, Kak.", gloss: "Great! Have a good rest.",
                                chips: "Sip/X Selamat_istirahat/X Kak/X"),
                variants: [.chatty: Utterance("Sip! Selamat makan, ya. Selamat istirahat!", gloss: "Great! Enjoy the food. Rest well!")]
            )
        ],
        listening: [
            ListeningCheck(question: "What did he bring you?",
                           options: ["Food from a ceremony", "Fruit from the market", "Coffee"], answer: "Food from a ceremony"),
            ListeningCheck(question: "What's happening tomorrow?",
                           options: ["A temple festival", "A wedding", "A football match"], answer: "A temple festival"),
            ListeningCheck(question: "When is he picking you up?",
                           options: ["7 in the morning", "7 in the evening", "At midday"], answer: "7 in the morning")
        ]
    )
}
