import SwiftUI

extension Curriculum {
    static let unit4 = Unit(
        id: "u4",
        number: 4,
        indoTitle: "Tidak & Bukan",
        title: "Saying no",
        blurb: "Two words for \"not\" — one for verbs and adjectives, one for nouns.",
        accent: .jambu,
        symbol: "xmark.circle.fill",
        lessons: [lesson41, lesson42, lesson43]
    )

    static let lesson41 = Lesson(
        id: "4.1",
        title: "tidak or bukan",
        subtitle: "Ini bukan kopi, ini teh",
        symbol: "arrow.triangle.branch",
        steps: [
            .learn(
                "tidak for verbs and adjectives",
                "tidak goes in front of what you are denying — an action or a quality.",
                pattern: "Saya/S tidak/N makan/V daging/O",
                examples: [
                    Example("Saya tidak makan daging", "I don't eat meat"),
                    Example("Tidak pedas, ya", "Not spicy, please"),
                    Example("Saya tidak mengerti", "I don't understand"),
                    Example("Tidak apa-apa", "It's fine / no worries")
                ]
            ),
            .learn(
                "bukan for nouns",
                "If you're denying a thing — a noun — it must be bukan. Swapping the two is the most common beginner slip.",
                pattern: "Ini/S bukan/N kopi/O",
                examples: [
                    Example("Ini bukan kopi, ini teh", "This isn't coffee, it's tea"),
                    Example("Saya bukan turis", "I'm not a tourist"),
                    Example("Bukan saya", "It wasn't me"),
                    Example("Bukan begitu", "That's not how it is")
                ]
            ),
            .pick(
                "\"I'm not a tourist.\" Pick the right one:",
                ["Saya bukan turis", "Saya tidak turis", "Saya tidak ada turis"],
                answer: "Saya bukan turis",
                why: "turis is a noun, so it takes bukan."
            ),
            .arrange(
                "I don't eat pork",
                "Saya tidak makan babi",
                alt: ["Saya nggak makan babi"],
                extras: ["bukan", "belum"],
                why: "makan is a verb, so tidak. Worth memorising for any warung."
            ),
            .hear(
                "Ini bukan punya saya",
                ["This isn't mine", "I don't want this", "This isn't ready"],
                answer: "This isn't mine",
                why: "punya saya (\"my possession\") is a noun phrase, so bukan."
            ),
            .pick(
                "Which sentence is wrong?",
                ["Kopinya bukan enak", "Kopinya tidak enak", "Ini bukan kopi"],
                answer: "Kopinya bukan enak",
                why: "enak is an adjective — it needs tidak."
            ),
            .arrange(
                "This isn't spicy",
                "Ini tidak pedas",
                alt: ["Ini nggak pedas", "Ini gak pedas"],
                extras: ["bukan", "sudah"],
                why: "pedas describes, so tidak. Only nouns get bukan."
            )
        ]
    )

    static let lesson42 = Lesson(
        id: "4.2",
        title: "Everyday no",
        subtitle: "gak, nggak, jangan",
        symbol: "hand.raised.fill",
        steps: [
            .learn(
                "gak and nggak",
                "In speech, tidak becomes nggak or gak. You will hear these far more often than tidak, which sounds careful or written.",
                examples: [
                    Example("Gak pedas, ya", "Not spicy, OK?"),
                    Example("Gak apa-apa", "No worries", note: "also heard as nggak papa"),
                    Example("Gak usah", "No need, don't bother"),
                    Example("Gak tahu", "Don't know", note: "often gak tau")
                ]
            ),
            .pick(
                "A driver offers to carry your bag and you'd rather he didn't. Say:",
                ["Gak usah, terima kasih", "Gak apa-apa, terima kasih", "Bukan, terima kasih"],
                answer: "Gak usah, terima kasih",
                why: "gak usah = no need. gak apa-apa means \"it's fine\", which sounds like a yes."
            ),
            .learn(
                "jangan = don't",
                "For telling someone not to do something, use jangan, never tidak.",
                pattern: "Jangan/N pedas/D ya/X",
                examples: [
                    Example("Jangan pedas, ya", "No chilli, please"),
                    Example("Jangan lupa", "Don't forget"),
                    Example("Jangan khawatir", "Don't worry"),
                    Example("Jangan di sini", "Not here")
                ]
            ),
            .arrange(
                "Don't forget your helmet",
                "Jangan lupa helmnya",
                alt: ["Jangan lupa helm"],
                extras: ["tidak", "bukan"],
                why: "jangan for a command. -nya points at the helmet you both know about."
            ),
            .hear(
                "Gak apa-apa",
                ["It's fine", "There isn't any", "Don't do that"],
                answer: "It's fine",
                why: "Literally \"not what-what\". The all-purpose reassurance."
            ),
            .pick(
                "Which one tells a cook to leave the chilli out?",
                ["Jangan pakai sambal", "Tidak sambal", "Bukan sambal"],
                answer: "Jangan pakai sambal",
                why: "A request not to do something takes jangan; pakai = use."
            )
        ]
    )

    static let lesson43 = Lesson(
        id: "4.3",
        title: "Saying yes",
        subtitle: "Ada? Ada. Bisa? Bisa.",
        symbol: "checkmark.bubble.fill",
        steps: [
            .learn(
                "Echo the verb",
                "Indonesians rarely answer a question with a bare \"yes\". They repeat the key word: Ada? Ada. Bisa? Bisa. It sounds natural and clear.",
                examples: [
                    Example("Ada wifi? · Ada.", "Is there wifi? · There is."),
                    Example("Bisa bayar pakai kartu? · Bisa.", "Can I pay by card? · You can."),
                    Example("Boleh foto? · Boleh.", "May I take a photo? · Sure."),
                    Example("Sudah? · Sudah.", "Done? · Done.")
                ]
            ),
            .pick(
                "The waiter asks \"Mau es?\" (Want ice?). Answer yes like a local:",
                ["Mau", "Ada", "Bukan"],
                answer: "Mau",
                why: "Echo the question's key word: mau → mau."
            ),
            .learn(
                "ya, iya, and the soft no",
                "ya is a plain yes; iya is warmer and more casual. For no, echo with the negation: Ada? Gak ada. Bisa? Gak bisa. Belum is the hopeful no for things that may still happen.",
                examples: [
                    Example("Iya, betul", "Yes, that's right"),
                    Example("Gak ada", "There isn't any"),
                    Example("Gak bisa, maaf", "Sorry, I can't"),
                    Example("Mungkin", "Maybe")
                ]
            ),
            .pick(
                "\"Ada kamar kosong?\" (Any free rooms?) There aren't. The owner says:",
                ["Gak ada", "Bukan ada", "Tidak mau"],
                answer: "Gak ada",
                why: "Echo ada with the everyday no in front."
            ),
            .hear(
                "Bisa, bisa",
                ["Sure, no problem", "Maybe later", "I don't know"],
                answer: "Sure, no problem",
                why: "Doubling the echo makes it cheerful and certain."
            ),
            .arrange(
                "Sorry, I can't",
                "Maaf, gak bisa",
                alt: ["Maaf, tidak bisa", "Maaf gak bisa", "Maaf, nggak bisa"],
                extras: ["bukan", "ada"],
                why: "Echo bisa with the negation. maaf softens it."
            ),
            .pick(
                "\"Sudah menikah?\" You're not married (yet). The friendly answer:",
                ["Belum", "Tidak", "Bukan"],
                answer: "Belum",
                why: "belum keeps the door open and is the polite, expected answer."
            )
        ]
    )
}
