import Foundation

// Place: Pasar. Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let buKetut = Character(
        id: "bu-ketut",
        name: "Bu Ketut",
        role: "sells sarongs at the pasar",
        register: .neutral,
        addressAs: ["Bu"],
        moods: [.warm, .busy],
        defaultMood: .warm,
        confused: [
            Utterance("Hah? Gimana, Kak?", gloss: "Huh? How's that?"),
            Utterance("Maaf, apa, Kak?", gloss: "Sorry, what?"),
            Utterance("Yang mana, Kak?", gloss: "Which one?")
        ]
    )

    static let pasarSarong = RehearsalScene(
        id: "id.pasar.sarong",
        language: "id",
        place: "Pasar",
        title: "Menawar sarung",
        titleEn: "Haggling for a sarong",
        setting: "Morning at the pasar. Sarongs hang in rows, and one is the deep blue you've been after.",
        level: .getBy,
        accent: .kunyit,
        symbol: "bag.fill",
        character: buKetut,
        goalSummary: "Point out the blue sarong, bargain the price down, and buy it.",
        goals: [
            GoalFlag(id: "asked_price", label: "Ask the price"),
            GoalFlag(id: "countered", label: "Make an offer"),
            GoalFlag(id: "deal", label: "Close the deal")
        ],
        warmUps: [
            WarmUp(title: "Numbers & prices", lessonID: "5.2"),
            WarmUp(title: "yang = the one that", lessonID: "6.1"),
            WarmUp(title: "-nya · harganya", lessonID: "6.3")
        ],
        culture: [
            "At the pasar the first price is an opening. Smile, offer about half, and meet in the middle.",
            "Saying you'll look around first (lihat-lihat dulu) is a normal, polite move, and often brings the price down."
        ],
        slots: [],
        entry: "p1",
        nodes: [
            SceneNode(
                id: "p1",
                them: Utterance("Silakan, Kak, lihat-lihat dulu!", casual: "Mari, Kak, lihat-lihat!",
                                gloss: "Go ahead, have a look around!", chips: "Silakan/X lihat-lihat/V dulu/T"),
                variants: [.busy: Utterance("Cari apa, Kak?", gloss: "Looking for something?", chips: "Cari/V apa/Q")],
                replies: [
                    .natural("Yang biru itu berapa, Bu?", "How much is that blue one?",
                             accept: ["yang biru itu berapa", "yang biru berapa", "berapa yang biru itu"],
                             sets: ["asked_price"], next: "p2", chips: "Yang_biru_itu/S berapa/Q Bu/X"),
                    .natural("Bu, sarung yang biru itu berapa?", "How much is the blue sarong there?",
                             accept: ["sarung yang biru berapa", "sarung biru itu berapa"],
                             sets: ["asked_price"], next: "p2", chips: "Sarung/S yang_biru_itu/D berapa/Q"),
                    .understood("Berapa harganya?", "How much is it?", next: "p1b",
                                coach: "Fine, but she can't tell which one you mean. Point it out with yang: yang biru itu."),
                    .missed("Biru itu yang berapa?", "Blue that one how much?",
                            reaction: Utterance("Yang… mana?", gloss: "Which… one?"),
                            coach: "yang comes first: yang biru itu means 'the blue one there'."),
                    .missed("Apa itu biru?", "What is that blue?",
                            reaction: Utterance("Biru, Kak. Warna biru.", gloss: "Blue. The colour blue."),
                            coach: "That asks what 'blue' is. To ask the price: yang biru itu berapa?")
                ]
            ),
            SceneNode(
                id: "p1b",
                them: Utterance("Yang mana, Kak?", gloss: "Which one?", chips: "Yang_mana/Q"),
                replies: [
                    .natural("Yang biru itu, Bu.", "The blue one there.", accept: ["yang biru itu", "yang biru"],
                             sets: ["asked_price"], next: "p2", chips: "Yang_biru_itu/S Bu/X"),
                    .natural("Itu, yang biru.", "That one, the blue one.", accept: ["itu yang biru"],
                             sets: ["asked_price"], next: "p2", chips: "Itu/S yang_biru/D"),
                    .missed("Biru yang itu.", "Blue the one there.",
                            reaction: Utterance("Hmm? Yang mana?", gloss: "Hmm? Which one?"),
                            coach: "yang leads the describer: yang biru.")
                ]
            ),
            SceneNode(
                id: "p2",
                them: Utterance("Yang biru dua ratus ribu.", casual: "Dua ratus, Kak.",
                                gloss: "The blue one is two hundred thousand.", chips: "Yang_biru/S dua_ratus_ribu/O"),
                variants: [.busy: Utterance("Dua ratus.", gloss: "Two hundred.")],
                focus: "numbers",
                replies: [
                    .natural("Wah, mahal sekali! Bisa kurang?", "Wow, that's a lot! Can you go lower?",
                             accept: ["mahal sekali bisa kurang", "mahal banget bisa kurang", "wah mahal bisa kurang"],
                             next: "p3", chips: "Mahal/D sekali/D Bisa/H kurang/V"),
                    .natural("Bisa kurang, Bu?", "Can you go lower?", accept: ["bisa kurang", "kurang bisa bu"],
                             next: "p3", chips: "Bisa/H kurang/V Bu/X"),
                    .natural("Aduh, mahal. Kurangin, dong, Bu.", "Oof, that's a lot. Come down a bit.",
                             accept: ["kurangin dong", "kurangin dong bu", "mahal kurangin dong"],
                             next: "p3", chips: "Mahal/D Kurangin/V dong/X Bu/X"),
                    .missed("Oke, saya ambil.", "OK, I'll take it.",
                            reaction: Utterance("Langsung? Hehe… boleh, boleh.", gloss: "Just like that? Heh… sure, sure."),
                            coach: "She'd love that, but you'd overpay. The first price is an opening: Bisa kurang?"),
                    .missed("Dua ratus ribu bukan?", "Not two hundred thousand?",
                            reaction: Utterance("Iya, dua ratus ribu.", gloss: "Yes, two hundred thousand."),
                            coach: "That just checks the price. To bargain, ask: Bisa kurang?")
                ]
            ),
            SceneNode(
                id: "p3",
                them: Utterance("Untuk Kakak, seratus delapan puluh ribu.", casual: "Buat Kakak, seratus delapan puluh.",
                                gloss: "For you, one hundred and eighty thousand.",
                                chips: "Untuk/L Kakak/O seratus_delapan_puluh_ribu/O"),
                variants: [.busy: Utterance("Seratus delapan puluh, ya.", gloss: "One-eighty, then.")],
                replies: [
                    .natural("Seratus ribu, ya?", "A hundred thousand?", accept: ["seratus ribu ya", "seratus ribu bisa", "bisa seratus ribu"],
                             sets: ["countered"], next: "p4", chips: "Seratus_ribu/O ya/X"),
                    .natural("Kalau seratus ribu, bisa?", "If it's a hundred thousand, can you?",
                             accept: ["kalau seratus ribu bisa", "seratus ribu boleh"],
                             sets: ["countered"], next: "p4", chips: "Kalau/L seratus_ribu/O bisa/H"),
                    .natural("Seratus aja, ya, Bu?", "Just a hundred?",
                             accept: ["seratus aja", "seratus aja ya", "seratus saja ya bu"],
                             sets: ["countered"], next: "p4", chips: "Seratus/O aja/X ya/X Bu/X"),
                    .off("Seribu, ya?", "A thousand?",
                         reaction: Utterance("Seribu? Hahaha… gak bisa, Kak!", gloss: "A thousand? Ha! No way!"),
                         coach: "seribu is 1,000, cheeky enough to end the conversation. You meant seratus ribu."),
                    .missed("Dua ratus ribu, ya?", "Two hundred thousand?",
                            reaction: Utterance("Lho, itu lebih mahal, Kak!", gloss: "Hey, that's more!"),
                            coach: "That's above her own price. Counter lower: seratus ribu.")
                ]
            ),
            SceneNode(
                id: "p4",
                them: Utterance("Aduh, tidak bisa. Harga pas seratus lima puluh.", casual: "Aduh, gak bisa, Kak. Pas seratus lima puluh.",
                                gloss: "Oh, I can't. Best price, one hundred and fifty.",
                                chips: "Tidak/N bisa/H Harga_pas/S seratus_lima_puluh/O"),
                variants: [.busy: Utterance("Gak bisa, Kak. Seratus lima puluh, pas.", gloss: "Can't do it. One-fifty, final.")],
                replies: [
                    .natural("Seratus dua puluh. Terakhir, Bu.", "One-twenty. Final offer.",
                             accept: ["seratus dua puluh terakhir", "seratus dua puluh ya bu", "seratus dua puluh"],
                             sets: ["countered"], next: "p5", chips: "Seratus_dua_puluh/O Terakhir/D Bu/X"),
                    .natural("Saya lihat-lihat dulu, ya, Bu.", "I'll have a look around first.",
                             accept: ["lihat-lihat dulu", "saya lihat lihat dulu", "lihat lihat dulu ya"],
                             next: "p4b", chips: "Saya/S lihat-lihat/V dulu/T ya/X"),
                    .understood("Seratus lima puluh mahal, Bu.", "One-fifty is expensive.", next: "p5",
                                coach: "True, but a number moves the deal; a complaint doesn't. Try: Seratus dua puluh. Terakhir, Bu."),
                    .missed("Harga pas apa?", "What fixed price?",
                            reaction: Utterance("Harga pas, Kak. Sudah murah itu.", gloss: "Best price. That's already cheap."),
                            coach: "harga pas means 'my best price'. She's near her limit: make one last offer, or walk away politely.")
                ]
            ),
            SceneNode(
                id: "p4b",
                narration: "You turn to go.",
                them: Utterance("Eh, Kak! Ya sudah, seratus dua puluh lima.", casual: "Kak, Kak! Seratus dua lima, deh.",
                                gloss: "Hey! All right, one twenty-five.", chips: "Ya_sudah/X seratus_dua_puluh_lima/O"),
                replies: [
                    .natural("Oke, saya ambil.", "OK, I'll take it.", accept: ["oke ambil", "saya ambil"],
                             sets: ["deal"], next: "end", chips: "Oke/X saya/S ambil/V"),
                    .natural("Boleh, Bu. Makasih!", "Deal. Thanks!", accept: ["boleh bu", "boleh makasih"],
                             sets: ["deal"], next: "end", chips: "Boleh/H Bu/X Makasih/X"),
                    .missed("Belum.", "Not yet.",
                            reaction: Utterance("Belum…? Jadi gimana, Kak?", gloss: "Not yet…? So what'll it be?"),
                            coach: "belum answers 'have you … yet?'. It isn't yes or no to an offer.")
                ]
            ),
            SceneNode(
                id: "p5",
                them: Utterance("Seratus dua puluh lima. Boleh?", casual: "Seratus dua lima, ya?",
                                gloss: "One twenty-five. OK?", chips: "Seratus_dua_puluh_lima/O Boleh/H"),
                replies: [
                    .natural("Oke, saya ambil.", "OK, I'll take it.", accept: ["oke ambil", "saya ambil"],
                             sets: ["deal"], next: "end", chips: "Oke/X saya/S ambil/V"),
                    .natural("Boleh, Bu.", "Deal.", accept: ["boleh"],
                             sets: ["deal"], next: "end", chips: "Boleh/H Bu/X"),
                    .missed("Belum.", "Not yet.",
                            reaction: Utterance("Belum…? Jadi gimana?", gloss: "Not yet…? So?"),
                            coach: "belum answers 'have you … yet?'. It isn't yes or no to an offer."),
                    .natural("Ya udah, Bu. Saya ambil.", "All right. I'll take it.",
                             accept: ["ya udah saya ambil", "ya sudah saya ambil"],
                             sets: ["deal"], next: "end", chips: "Ya_udah/X Bu/X Saya/S ambil/V"),
                    .missed("Bukan, terima kasih.", "No (not a noun), thanks.",
                            reaction: Utterance("Bukan apa, Kak?", gloss: "Not what?"),
                            coach: "bukan denies nouns. To decline politely: Tidak, terima kasih.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Makasih, Kak! Awet, ya.", gloss: "Thank you! May it last you well.",
                                chips: "Makasih/X Awet/D ya/X"),
                variants: [.busy: Utterance("Ya, makasih, Kak!", gloss: "Yep, thanks!")]
            )
        ],
        listening: [
            ListeningCheck(question: "Which sarong did you want?",
                           options: ["The blue one", "The red one", "The green one"], answer: "The blue one"),
            ListeningCheck(question: "What was her first price?",
                           options: ["Rp 200.000", "Rp 120.000", "Rp 2.000.000"], answer: "Rp 200.000"),
            ListeningCheck(question: "What did you pay in the end?",
                           options: ["Rp 125.000", "Rp 150.000", "Rp 180.000"], answer: "Rp 125.000")
        ]
    )
}
