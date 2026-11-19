import SwiftUI

extension Curriculum {
    static let unit10 = Unit(
        id: "u10",
        number: 10,
        indoTitle: "Budaya",
        title: "Manners and warmth",
        blurb: "Temple manners, a few words of Balinese, and taking a compliment gracefully.",
        accent: .sawah,
        symbol: "leaf.circle.fill",
        lessons: [lesson101, lesson102]
    )

    static let lesson101 = Lesson(
        id: "10.1",
        title: "Bali manners",
        subtitle: "Om Swastiastu, upacara, sarung",
        symbol: "building.columns.fill",
        steps: [
            .learn(
                "A little Balinese",
                "Most Balinese speak Indonesian with visitors, but a word of their own language earns a big smile. These are Balinese, not Indonesian.",
                examples: [
                    Example("Om Swastiastu", "Hello", note: "Balinese Hindu greeting; reply the same"),
                    Example("Suksma", "Thank you", note: "Balinese"),
                    Example("Bli", "Older brother, for a man", note: "how you address a Balinese man"),
                    Example("Mbok", "Older sister, for a woman")
                ]
            ),
            .pick(
                "Someone greets you with \"Om Swastiastu\". Reply:",
                ["Om Swastiastu", "Sama-sama", "Selamat jalan"],
                answer: "Om Swastiastu",
                why: "The greeting is returned as it is, often with hands pressed together."
            ),
            .learn(
                "At a temple",
                "Temples ask visitors to wear a sarong and sash. Ceremonies close roads and fill the streets; it's polite to wait, and to ask before taking photos.",
                pattern: "Harus/H pakai/V sarung/O",
                examples: [
                    Example("Boleh masuk?", "May I come in?"),
                    Example("Harus pakai sarung", "You have to wear a sarong"),
                    Example("Sedang ada upacara", "There's a ceremony on"),
                    Example("Boleh foto di sini?", "May I take photos here?")
                ]
            ),
            .arrange(
                "May I come in?",
                "Boleh masuk?",
                alt: ["Boleh saya masuk?"],
                extras: ["harus", "mau"],
                why: "boleh = may, allowed. Ask before stepping into any temple courtyard."
            ),
            .hear(
                "Jalannya ditutup, ada upacara",
                ["The road's closed, there's a ceremony", "The temple is open today", "The road is busy with traffic"],
                answer: "The road's closed, there's a ceremony",
                why: "ditutup = closed (di- passive). upacara = ceremony."
            ),
            .pick(
                "Handing money to a seller, use:",
                ["Your right hand", "Your left hand", "Either hand"],
                answer: "Your right hand",
                why: "The left hand is considered unclean. Give and receive with the right."
            ),
            .arrange(
                "You have to wear a sarong",
                "Harus pakai sarung",
                alt: ["Harus pakai kain", "Kamu harus pakai sarung"],
                extras: ["boleh", "bukan"],
                why: "harus = must. pakai = wear, use."
            ),
            .pick(
                "Leaving a Balinese friend's home, thank them in Balinese:",
                ["Suksma", "Om Swastiastu", "Permisi"],
                answer: "Suksma",
                why: "suksma = thank you in Balinese. Om Swastiastu is the greeting."
            ),
            .learn(
                "Ceremony days",
                "Processions and ceremonies are part of daily life. Ask before you join, step aside for them, and say permisi when you pass people.",
                pattern: "Permisi/X numpang/V lewat/V",
                examples: [
                    Example("Ada upacara apa?", "What's the ceremony for?"),
                    Example("Boleh nonton?", "May I watch?"),
                    Example("Permisi, numpang lewat", "Excuse me, may I get past?", note: "the polite way to squeeze by"),
                    Example("Pakai selendang juga", "Wear a temple sash too")
                ]
            ),
            .hear(
                "Boleh nonton, tapi pakai sarung, ya",
                ["You can watch, but wear a sarong", "You can't watch today", "Buy a sarong over there"],
                answer: "You can watch, but wear a sarong",
                why: "boleh = allowed. tapi = but. pakai = wear."
            ),
            .arrange(
                "Excuse me, may I get past?",
                "Permisi, numpang lewat",
                alt: ["Permisi numpang lewat", "Numpang lewat"],
                extras: ["masuk", "harus"],
                why: "numpang = to ride along with, lewat = pass. Together: may I pass through?"
            ),
            .pick(
                "A procession fills the road ahead. The polite thing to do:",
                ["Stop and let it pass", "Honk so they make room", "Ride through the gap"],
                answer: "Stop and let it pass",
                why: "Ceremonies come first. Turn off the engine, wait, and enjoy it."
            )
        ]
    )

    static let lesson102 = Lesson(
        id: "10.2",
        title: "Compliments",
        subtitle: "Bagus! Sedikit-sedikit.",
        symbol: "heart.fill",
        steps: [
            .learn(
                "Taking a compliment",
                "When someone praises your Indonesian, the gracious answer is modest. Saying you know \"a little\" is expected and charming.",
                examples: [
                    Example("Bahasa Indonesianya bagus!", "Your Indonesian is good!"),
                    Example("Ah, masih belajar", "Oh, I'm still learning"),
                    Example("Sedikit-sedikit", "Just a little"),
                    Example("Makasih, Bu", "Thank you, ma'am")
                ]
            ),
            .pick(
                "\"Wah, bisa bahasa Indonesia!\" Answer modestly:",
                ["Sedikit-sedikit", "Sama-sama", "Bagus sekali"],
                answer: "Sedikit-sedikit",
                why: "\"A little bit\" is the warm, modest reply."
            ),
            .learn(
                "Giving one",
                "Compliments are about people's homes, children, food and views. lucu (cute) is for kids and pets, cantik for women, ganteng for men, indah for scenery.",
                pattern: "Pemandangannya/O indah/D sekali/D",
                examples: [
                    Example("Pemandangannya indah sekali", "The view is so beautiful"),
                    Example("Anaknya lucu", "Your child is cute"),
                    Example("Rumahnya bagus", "Your house is lovely"),
                    Example("Masakan Ibu enak sekali", "Your cooking is delicious, ma'am")
                ]
            ),
            .arrange(
                "The view is beautiful",
                "Pemandangannya indah",
                alt: ["Pemandangannya bagus", "Pemandangannya indah sekali", "Pemandangannya cantik"],
                extras: ["adalah", "lucu"],
                why: "No \"is\" before an adjective. indah suits scenery."
            ),
            .hear(
                "Anaknya lucu sekali",
                ["Your child is so cute", "The child is very funny", "Your child is very tall"],
                answer: "Your child is so cute",
                why: "lucu = cute (and also funny). The compliment every parent loves."
            ),
            .pick(
                "Thank your host warmly after dinner:",
                ["Makasih banyak, Bu, enak sekali", "Sama-sama, Bu, enak sekali", "Permisi, Bu, enak sekali"],
                answer: "Makasih banyak, Bu, enak sekali",
                why: "Thanks plus praise for the food. sama-sama is the reply to thanks, not the thanks itself."
            ),
            .arrange(
                "I speak a little",
                "Saya bisa sedikit-sedikit",
                alt: ["Bisa sedikit-sedikit", "Sedikit-sedikit"],
                extras: ["banyak", "tidak"],
                why: "bisa = can. sedikit-sedikit = a little bit."
            ),
            .pick(
                "Your host's baby smiles at you. Say:",
                ["Lucu sekali!", "Indah sekali!", "Enak sekali!"],
                answer: "Lucu sekali!",
                why: "lucu = cute, for babies and pets. indah is for views, enak for food."
            ),
            .hear(
                "Masakan Ibu enak sekali",
                ["Your cooking is delicious, ma'am", "The food is too spicy, ma'am", "This food is expensive"],
                answer: "Your cooking is delicious, ma'am",
                why: "masakan = cooking (masak + -an). Ibu here means \"you\", politely."
            ),
            .learn(
                "When they offer more",
                "Hosts offer more food again and again. Praise it, then say you're full. A little more is a kind compromise.",
                pattern: "Sudah/T kenyang/D makasih/X",
                examples: [
                    Example("Tambah lagi?", "Some more?"),
                    Example("Sudah kenyang, makasih", "I'm full, thanks"),
                    Example("Enak, tapi sudah kenyang", "It's delicious, but I'm full"),
                    Example("Sedikit aja, ya", "Just a little, then")
                ]
            ),
            .arrange(
                "I'm full, thanks",
                "Sudah kenyang, makasih",
                alt: ["Udah kenyang, makasih", "Saya sudah kenyang, makasih", "Sudah kenyang, terima kasih"],
                extras: ["lapar", "belum"],
                why: "sudah = already. kenyang = full. No \"am\" needed."
            ),
            .pick(
                "\"Tambah lagi?\" You're full. Answer:",
                ["Sudah kenyang, makasih", "Belum makan, makasih", "Sama-sama, makasih"],
                answer: "Sudah kenyang, makasih",
                why: "Say you're full and thank them. belum makan would mean you haven't eaten yet."
            ),
            .arrange(
                "Your house is lovely",
                "Rumahnya bagus",
                alt: ["Rumahnya bagus sekali", "Rumahnya indah", "Rumah Ibu bagus"],
                extras: ["adalah", "lucu"],
                why: "-nya = your (the one we both see). bagus = nice, lovely."
            )
        ]
    )
}
