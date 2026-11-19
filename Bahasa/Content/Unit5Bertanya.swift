import SwiftUI

extension Curriculum {
    static let unit5 = Unit(
        id: "u5",
        number: 5,
        indoTitle: "Bertanya",
        title: "Asking things",
        blurb: "Questions by intonation, the question words, and prices in thousands.",
        accent: .sawah,
        symbol: "questionmark.circle.fill",
        lessons: [lesson51, lesson52, lesson53, lesson54]
    )

    static let lesson51 = Lesson(
        id: "5.1",
        title: "Questions",
        subtitle: "apa, siapa, di mana, berapa",
        symbol: "text.bubble.fill",
        steps: [
            .learn(
                "Just raise your voice",
                "A statement becomes a question with intonation alone — nothing is reordered. apakah exists but belongs in writing and formal speech.",
                pattern: "Ada/V wifi/O",
                examples: [
                    Example("Ada wifi?", "Is there wifi?"),
                    Example("Bisa?", "Can you? / Is that possible?"),
                    Example("Sudah makan?", "Have you eaten?"),
                    Example("Apakah Anda sudah makan?", "Have you eaten?", note: "formal, written")
                ]
            ),
            .learn(
                "The question words",
                "apa (what), siapa (who), mana (which / where, with di/ke/dari), kapan (when), berapa (how much), kenapa (why), bagaimana or casual gimana (how).",
                examples: [
                    Example("Kamu tinggal di mana?", "Where do you live?", note: "question word last"),
                    Example("Ini berapa?", "How much is this?"),
                    Example("Kapan kamu pulang?", "When are you going home?"),
                    Example("Kenapa macet?", "Why is there traffic?")
                ]
            ),
            .pick(
                "Ask a driver where he's from, casually:",
                ["Dari mana, Kak?", "Mana dari, Kak?", "Di mana kamu dari?"],
                answer: "Dari mana, Kak?",
                why: "The preposition leads: dari mana. Kak is what drivers and staff are called."
            ),
            .arrange(
                "Where do you live?",
                "Kamu tinggal di mana?",
                alt: ["Tinggal di mana?", "Kamu tinggal di mana"],
                extras: ["apa", "siapa"],
                why: "Indonesian usually leaves the question word at the end."
            ),
            .hear(
                "Ada wifi?",
                ["Is there wifi?", "Where is the wifi?", "The wifi is broken"],
                answer: "Is there wifi?",
                why: "ada = there is / to have. One of the most useful words you'll own."
            ),
            .pick(
                "Which asks \"what does that mean?\"",
                ["Apa artinya?", "Siapa artinya?", "Berapa artinya?"],
                answer: "Apa artinya?",
                why: "arti = meaning, -nya points to the word you just heard."
            ),
            .arrange(
                "How much is this?",
                "Ini berapa?",
                alt: ["Berapa ini?", "Ini berapa"],
                extras: ["apa", "harganya"],
                why: "berapa covers how much and how many. Berapa harganya? is the fuller version."
            )
        ]
    )

    static let lesson52 = Lesson(
        id: "5.2",
        title: "Numbers & prices",
        subtitle: "tiga puluh lima ribu",
        symbol: "number.circle.fill",
        steps: [
            .learn(
                "One to ten",
                "satu, dua, tiga, empat, lima, enam, tujuh, delapan, sembilan, sepuluh. Notice se- at the start of sepuluh: se- means \"one\".",
                examples: [
                    Example("satu, dua, tiga", "one, two, three"),
                    Example("empat, lima, enam", "four, five, six"),
                    Example("tujuh, delapan, sembilan", "seven, eight, nine"),
                    Example("sepuluh", "ten", note: "se- = one")
                ]
            ),
            .learn(
                "Building bigger numbers",
                "belas = teens, puluh = tens, ratus = hundred, ribu = thousand, juta = million. Stack them left to right, with se- for a single one.",
                pattern: "tiga/X puluh/X lima/X ribu/X",
                examples: [
                    Example("dua belas", "twelve"),
                    Example("tiga puluh lima", "thirty-five"),
                    Example("seratus", "one hundred"),
                    Example("tiga puluh lima ribu", "35,000", note: "Rp 35k — a typical warung meal")
                ]
            ),
            .pick(
                "\"Lima belas ribu\" is:",
                ["15,000", "50,000", "5,000"],
                answer: "15,000",
                why: "belas makes teens; lima puluh ribu would be 50,000. Listen for that one syllable."
            ),
            .arrange(
                "How much does it cost?",
                "Berapa harganya?",
                alt: ["Harganya berapa?", "Berapa harganya"],
                extras: ["apa", "mahal"],
                why: "harga = price, -nya = its. Both word orders are normal."
            ),
            .hear(
                "Dua puluh lima ribu",
                ["25,000", "20,500", "250,000"],
                answer: "25,000",
                why: "dua puluh (20) + lima (5) + ribu (thousand)."
            ),
            .pick(
                "The price feels steep. Say:",
                ["Mahal sekali!", "Murah sekali!", "Besar sekali!"],
                answer: "Mahal sekali!",
                why: "mahal = expensive, sekali = very. murah is cheap — the opposite complaint."
            ),
            .arrange(
                "Can you come down a bit?",
                "Bisa kurang?",
                alt: ["Bisa kurang sedikit?", "Bisa kurang"],
                extras: ["mahal", "tambah"],
                why: "kurang = less. The standard, polite opening move when haggling."
            )
        ]
    )

    static let lesson53 = Lesson(
        id: "5.3",
        title: "Directions",
        subtitle: "lurus, belok kiri, di depan",
        symbol: "arrow.triangle.turn.up.right.diamond.fill",
        steps: [
            .learn(
                "Asking the way",
                "Start with permisi, name the place, then di mana. Locals often answer with a gesture and a few words, so learn the words first.",
                pattern: "Permisi/X ATM/O di_mana/Q",
                examples: [
                    Example("Permisi, ATM di mana?", "Excuse me, where's an ATM?"),
                    Example("Pantainya ke arah mana?", "Which way to the beach?"),
                    Example("Jauh dari sini?", "Is it far from here?"),
                    Example("Bisa jalan kaki?", "Can I walk there?")
                ]
            ),
            .learn(
                "The answers you'll hear",
                "lurus (straight), belok kiri / kanan (turn left / right), terus (keep going), sampai (until). Places sit with di: di depan (in front), di belakang (behind), di sebelah (next to), di seberang (across).",
                examples: [
                    Example("Lurus aja, terus belok kiri", "Just go straight, then turn left"),
                    Example("Di sebelah minimarket", "Next to the minimarket"),
                    Example("Di seberang jalan", "Across the road"),
                    Example("Sampai lampu merah", "Up to the traffic lights")
                ]
            ),
            .pick(
                "\"Lurus aja, terus belok kanan.\" What do you do?",
                ["Go straight, then turn right", "Turn left, then go straight", "Turn right, then go back"],
                answer: "Go straight, then turn right",
                why: "lurus = straight, terus = then / keep going, belok kanan = turn right."
            ),
            .arrange(
                "Excuse me, where's the beach?",
                "Permisi, pantainya di mana?",
                alt: ["Permisi, pantai di mana?", "Permisi pantainya di mana?"],
                extras: ["ke", "apa"],
                why: "-nya makes it \"the beach\" you both have in mind. di mana closes the question."
            ),
            .hear(
                "Di seberang jalan",
                ["Across the road", "At the end of the road", "Next to the road"],
                answer: "Across the road",
                why: "seberang = the other side. Handy for spotting a warung across a busy street."
            ),
            .pick(
                "The shop is next to the bank. Say:",
                ["Di sebelah bank", "Di belakang bank", "Di depan bank"],
                answer: "Di sebelah bank",
                why: "sebelah = beside. belakang = behind, depan = in front."
            ),
            .arrange(
                "Is it far from here?",
                "Jauh dari sini?",
                alt: ["Jauh gak dari sini?", "Apakah jauh dari sini?"],
                extras: ["dekat", "ke"],
                why: "Rising voice turns the statement into a question. dekat = near."
            )
        ]
    )

    static let lesson54 = Lesson(
        id: "5.4",
        title: "Paying",
        subtitle: "kembalian, uang pas, QRIS",
        symbol: "creditcard.fill",
        steps: [
            .learn(
                "At the counter",
                "Most small places want cash or QRIS (the national QR payment). Big notes can be a problem at a warung, so ask before you pay.",
                pattern: "Bisa/H bayar/V pakai_QRIS/O",
                examples: [
                    Example("Bisa bayar pakai kartu?", "Can I pay by card?"),
                    Example("Bisa pakai QRIS?", "Can I pay with QRIS?"),
                    Example("Ada kembalian?", "Do you have change?"),
                    Example("Maaf, uangnya besar", "Sorry, it's a big note")
                ]
            ),
            .pick(
                "You only have a 100,000 note for a 15,000 lunch. Ask first:",
                ["Ada kembalian?", "Ada uang pas?", "Berapa kembalian?"],
                answer: "Ada kembalian?",
                why: "kembalian = change. Asking first is polite at small warungs."
            ),
            .learn(
                "Exact money and keeping the change",
                "uang pas is exact money. Sellers may ask Ada uang kecil? (got small notes?). To let them keep the change: ambil aja kembaliannya.",
                examples: [
                    Example("Ada uang kecil?", "Do you have small notes?"),
                    Example("Pas, ya", "That's exact"),
                    Example("Ambil aja kembaliannya", "Keep the change"),
                    Example("Bayar di kasir", "Pay at the cashier")
                ]
            ),
            .hear(
                "Ada uang kecil?",
                ["Do you have small notes?", "Is it a small price?", "Is there a small size?"],
                answer: "Do you have small notes?",
                why: "uang = money, kecil = small. A very common question at markets."
            ),
            .arrange(
                "Keep the change",
                "Ambil aja kembaliannya",
                alt: ["Ambil saja kembaliannya", "Kembaliannya ambil aja"],
                extras: ["bayar", "pas"],
                why: "ambil = take, aja = just. A kind gesture for drivers and small sellers."
            ),
            .pick(
                "Ask if you can pay by card:",
                ["Bisa bayar pakai kartu?", "Bisa kartu bayar?", "Kartu bisa pakai?"],
                answer: "Bisa bayar pakai kartu?",
                why: "helper + verb + pakai (with, using) + thing."
            )
        ]
    )
}
