import SwiftUI

extension Curriculum {
    static let unit2 = Unit(
        id: "u2",
        number: 2,
        indoTitle: "Pola Dasar",
        title: "The basic pattern",
        blurb: "Subject · verb · object, pronouns, no \"to be\", and describers that follow.",
        accent: .indigo,
        symbol: "rectangle.3.group.fill",
        lessons: [lesson21, lesson22, lesson23, lesson24]
    )

    static let lesson21 = Lesson(
        id: "2.1",
        title: "Subject · verb · object",
        subtitle: "Saya makan nasi",
        symbol: "arrow.right.circle.fill",
        steps: [
            .learn(
                "Same order as English",
                "Indonesian sentences run subject, verb, object — and the verb never changes. No -s, no past tense ending, nothing to conjugate for who is doing it.",
                pattern: "Saya/S makan/V nasi/O",
                examples: [
                    Example("Saya makan nasi", "I eat rice"),
                    Example("Dia minum kopi", "He drinks coffee"),
                    Example("Kami belajar bahasa Indonesia", "We're learning Indonesian")
                ]
            ),
            .arrange(
                "I drink coffee",
                "Saya minum kopi",
                extras: ["makan", "teh"],
                why: "Subject, verb, object — minum for drinking, makan for eating."
            ),
            .learn(
                "Pronouns",
                "saya is the safe \"I\"; aku is for friends. dia covers he and she. The big one: kita includes the person you're talking to, kami does not.",
                examples: [
                    Example("saya / aku", "I", note: "formal / casual"),
                    Example("Anda / kamu", "you", note: "formal / casual"),
                    Example("dia", "he, she", note: "no gender"),
                    Example("kita / kami", "we", note: "with you / without you"),
                    Example("mereka", "they")
                ]
            ),
            .pick(
                "You're telling your friend \"we're going\" — the two of you. Pick:",
                ["Kita pergi", "Kami pergi", "Mereka pergi"],
                answer: "Kita pergi",
                why: "kita includes the listener. Saying kami here means \"us, not you\" and sounds like you're leaving them behind."
            ),
            .hear(
                "Dia minum teh",
                ["He drinks tea", "They drink tea", "I drink tea"],
                answer: "He drinks tea",
                why: "dia is he or she — context decides. She drinks tea is just as right."
            ),
            .arrange(
                "They eat fried rice",
                "Mereka makan nasi goreng",
                extras: ["kami", "minum"],
                why: "mereka = they, and nasi goreng keeps its own order: rice-fried."
            ),
            .pick(
                "Which sentence is wrong?",
                ["Dia makans nasi", "Dia makan nasi", "Saya makan nasi"],
                answer: "Dia makans nasi",
                why: "Verbs never take an ending for who is doing it."
            )
        ]
    )

    static let lesson22 = Lesson(
        id: "2.2",
        title: "No word for \"is\"",
        subtitle: "Saya lapar. Kopinya enak.",
        symbol: "equal.circle.fill",
        steps: [
            .learn(
                "Drop \"am, is, are\"",
                "Indonesian glues a subject straight onto an adjective or a place. There is no verb in between.",
                pattern: "Saya/S lapar/D",
                examples: [
                    Example("Saya lapar", "I'm hungry"),
                    Example("Kopinya enak", "The coffee is good", note: "-nya = \"the\" here"),
                    Example("Dia di kantor", "She's at the office")
                ]
            ),
            .arrange(
                "I'm tired",
                "Saya lelah",
                alt: ["Saya capek", "Aku capek", "Aku lelah"],
                extras: ["adalah", "sudah"],
                why: "Nothing stands in for \"am\". capek is the casual word for tired."
            ),
            .learn(
                "adalah is formal, and noun-to-noun only",
                "adalah exists, but it is formal and only links two nouns. Put it before an adjective and the sentence breaks.",
                examples: [
                    Example("Dia adalah dokter", "He is a doctor", note: "formal; \"Dia dokter\" is normal speech"),
                    Example("Rumah itu besar", "That house is big", note: "never \"adalah besar\"")
                ]
            ),
            .pick(
                "Which sentence is wrong?",
                ["Rumah itu adalah besar", "Rumah itu besar", "Dia adalah dokter"],
                answer: "Rumah itu adalah besar",
                why: "adalah never sits in front of an adjective — besar needs no link at all."
            ),
            .learn(
                "ini and itu come after the noun",
                "\"This coffee\" is kopi ini — literally \"coffee this\". On their own, ini and itu mean \"this\" and \"that\".",
                pattern: "Kopi/O ini/D enak/D",
                examples: [
                    Example("Kopi ini enak", "This coffee is good"),
                    Example("Rumah itu besar", "That house is big"),
                    Example("Ini teh, bukan kopi", "This is tea, not coffee")
                ]
            ),
            .arrange(
                "This coffee is good",
                "Kopi ini enak",
                extras: ["adalah", "itu"],
                why: "Noun, then ini, then the adjective. No \"is\"."
            ),
            .hear(
                "Dia di kantor",
                ["She's at the office", "She goes to the office", "She's an office worker"],
                answer: "She's at the office",
                why: "di = at or in, and the \"is\" is simply absent. Going to would be ke kantor."
            )
        ]
    )

    static let lesson23 = Lesson(
        id: "2.3",
        title: "Describers go after",
        subtitle: "kopi panas, motor saya",
        symbol: "textformat.size",
        steps: [
            .learn(
                "Noun first, describer second",
                "Every describing word follows its noun. Read them backwards into English and they click.",
                pattern: "kopi/O panas/D",
                examples: [
                    Example("kopi panas", "hot coffee"),
                    Example("nasi goreng", "fried rice", note: "rice–fried"),
                    Example("air dingin", "cold water"),
                    Example("es teh manis", "sweet iced tea")
                ]
            ),
            .arrange(
                "cold water",
                "air dingin",
                extras: ["panas", "manis"],
                why: "air = water, dingin = cold, and cold comes second."
            ),
            .pick(
                "\"Fried rice\" is:",
                ["nasi goreng", "goreng nasi", "nasi yang goreng"],
                answer: "nasi goreng",
                why: "The describer follows: rice-fried."
            ),
            .learn(
                "Possession follows too",
                "Owners sit after the thing owned, and you can stack them. For friends and family, -ku and -mu attach straight to the noun.",
                pattern: "motor/O saya/S",
                examples: [
                    Example("motor saya", "my motorbike"),
                    Example("motor teman saya", "my friend's motorbike", note: "bike–friend–my"),
                    Example("namaku", "my name", note: "casual"),
                    Example("namamu", "your name", note: "casual")
                ]
            ),
            .arrange(
                "my friend's motorbike",
                "motor teman saya",
                extras: ["punya", "nya"],
                why: "Stack the owners after the noun: motor – teman – saya."
            ),
            .hear(
                "es teh manis",
                ["sweet iced tea", "hot sweet tea", "iced coffee"],
                answer: "sweet iced tea",
                why: "es = ice, teh = tea, manis = sweet. The warung default, and it is very sweet."
            ),
            .pick(
                "Say \"your name\" casually:",
                ["namamu", "kamu nama", "mu nama"],
                answer: "namamu",
                why: "-mu attaches to the end of the noun. nama kamu works too."
            )
        ]
    )

    static let lesson24 = Lesson(
        id: "2.4",
        title: "One, many, all",
        subtitle: "anak-anak, banyak, semua",
        symbol: "square.stack.3d.up.fill",
        steps: [
            .learn(
                "No plural ending",
                "Nouns don't change for plural. Context usually does the job: dua kopi is simply \"two coffee\". Add a number or a quantity word and you're done.",
                pattern: "Dua/D kopi/O ya/X",
                examples: [
                    Example("Dua kopi, ya", "Two coffees, please"),
                    Example("Banyak turis di sini", "There are lots of tourists here"),
                    Example("Beberapa hari", "A few days"),
                    Example("Semua orang", "Everyone")
                ]
            ),
            .pick(
                "Order three coffees:",
                ["Tiga kopi", "Tiga kopi-kopi", "Kopi-kopi tiga"],
                answer: "Tiga kopi",
                why: "With a number, the noun stays single. Doubling is never added on top of a number."
            ),
            .learn(
                "Doubling means \"a variety of\"",
                "Doubling a noun makes it plural with a sense of many or all sorts: anak-anak (children), buah-buahan (all kinds of fruit). Some doubled words simply have their own meaning, like kupu-kupu (butterfly) and jalan-jalan (going out for fun).",
                examples: [
                    Example("Anak-anak main di pantai", "The kids are playing on the beach"),
                    Example("Buah-buahan segar", "Fresh fruit of all kinds"),
                    Example("Kami mau jalan-jalan", "We want to go out and wander", note: "jalan-jalan = to go out for fun"),
                    Example("Hati-hati", "Careful!", note: "a doubled word with its own meaning")
                ]
            ),
            .arrange(
                "Lots of people",
                "Banyak orang",
                extras: ["orang-orang", "semua"],
                why: "banyak already says \"many\", so orang stays single."
            ),
            .hear(
                "Semua orang suka nasi goreng",
                ["Everyone likes fried rice", "Many people sell fried rice", "Some people eat fried rice"],
                answer: "Everyone likes fried rice",
                why: "semua orang = all people, everyone. suka = like."
            ),
            .pick(
                "Which one means \"a few days\"?",
                ["Beberapa hari", "Banyak hari", "Semua hari"],
                answer: "Beberapa hari",
                why: "beberapa = several, a few. Useful for \"how long are you staying?\"."
            ),
            .arrange(
                "The kids are on the beach",
                "Anak-anak di pantai",
                alt: ["Anak-anak ada di pantai"],
                extras: ["dua", "semua"],
                why: "No verb needed for a location, and doubling gives \"the kids\"."
            )
        ]
    )
}
