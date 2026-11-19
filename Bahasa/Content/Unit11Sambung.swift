import SwiftUI

extension Curriculum {
    static let unit11 = Unit(
        id: "u11",
        number: 11,
        indoTitle: "Sambung",
        title: "Longer sentences",
        blurb: "Join ideas with tapi, karena and kalau, and compare things with lebih and paling.",
        accent: .laut,
        symbol: "link",
        lessons: [lesson111, lesson112, lesson113]
    )

    static let lesson111 = Lesson(
        id: "11.1",
        title: "And, but, because, so",
        subtitle: "dan, tapi, karena, jadi",
        symbol: "point.3.connected.trianglepath.dotted",
        steps: [
            .learn(
                "Four joining words",
                "dan (and), tapi (but), karena (because), jadi (so). They sit between two ideas exactly as in English, and neither half changes.",
                pattern: "Saya/S suka/V pedas/O tapi/L sedikit/D aja/X",
                examples: [
                    Example("Saya suka pedas, tapi sedikit aja", "I like it spicy, but just a little"),
                    Example("Saya capek karena macet", "I'm tired because of the traffic"),
                    Example("Hujan, jadi kami di rumah", "It's raining, so we're staying in"),
                    Example("Nasi goreng dan es teh", "Fried rice and iced tea")
                ]
            ),
            .pick(
                "\"I want to go, but it's raining.\" Pick the joining word:",
                ["Saya mau pergi, tapi hujan", "Saya mau pergi, karena hujan", "Saya mau pergi, jadi hujan"],
                answer: "Saya mau pergi, tapi hujan",
                why: "tapi = but. It joins two ideas that pull in different directions."
            ),
            .arrange(
                "I'm late because of the traffic",
                "Saya terlambat karena macet",
                alt: ["Saya telat karena macet"],
                extras: ["jadi", "tapi"],
                why: "karena = because. macet (traffic jam) needs no \"of the\"."
            ),
            .hear(
                "Sudah malam, jadi saya pulang",
                ["It's late, so I'm going home", "It's late, but I'm staying", "I'm going home because I'm tired"],
                answer: "It's late, so I'm going home",
                why: "jadi = so, therefore. sudah malam = it's already night."
            ),
            .learn(
                "terus: and then",
                "When telling a story or giving directions, terus links each step: this, then that. In speech it's everywhere.",
                examples: [
                    Example("Saya makan, terus tidur", "I ate, then slept"),
                    Example("Lurus, terus belok kiri", "Straight on, then turn left"),
                    Example("Terus?", "And then? / So?", note: "to encourage someone to keep talking"),
                    Example("Habis itu kita ke pantai", "After that we go to the beach")
                ]
            ),
            .pick(
                "Your friend pauses mid-story. Encourage them to continue:",
                ["Terus?", "Karena?", "Dan tidak?"],
                answer: "Terus?",
                why: "terus? = and then? The friendliest way to keep a story going."
            ),
            .arrange(
                "Fried rice and iced tea",
                "Nasi goreng dan es teh",
                alt: ["Nasi goreng sama es teh"],
                extras: ["tapi", "atau"],
                why: "dan = and. In speech, sama often means \"and\" too."
            ),
            .pick(
                "\"I'm not hungry because I've already eaten.\" Say:",
                ["Saya gak lapar karena sudah makan", "Saya gak lapar jadi sudah makan", "Saya gak lapar tapi sudah makan"],
                answer: "Saya gak lapar karena sudah makan",
                why: "karena gives the reason. jadi would make eating the result of not being hungry."
            ),
            .hear(
                "Enak, tapi agak mahal",
                ["It's good, but a bit pricey", "It's good and cheap", "It's pricey, so I'll skip it"],
                answer: "It's good, but a bit pricey",
                why: "tapi = but. agak = a bit."
            ),
            .arrange(
                "It's raining, so we're staying home",
                "Hujan, jadi kami di rumah",
                alt: ["Hujan, jadi kita di rumah", "Hujan jadi kami di rumah"],
                extras: ["karena", "tapi"],
                why: "jadi = so. The result comes after it."
            )
        ]
    )

    static let lesson112 = Lesson(
        id: "11.2",
        title: "If and when",
        subtitle: "kalau, waktu, sebelum, setelah",
        symbol: "arrow.triangle.branch",
        steps: [
            .learn(
                "kalau = if",
                "kalau opens a condition. The rest of the sentence follows as normal. In casual speech it also means \"as for\": Kalau kamu? (And you?)",
                pattern: "Kalau/L hujan/V kita/S di_rumah/O",
                examples: [
                    Example("Kalau hujan, kita di rumah", "If it rains, we'll stay home"),
                    Example("Kalau bisa, besok pagi", "Tomorrow morning, if possible"),
                    Example("Kalau mahal, gak usah", "If it's expensive, don't bother"),
                    Example("Kalau kamu?", "What about you?")
                ]
            ),
            .pick(
                "\"Tomorrow morning, if possible.\" Say:",
                ["Kalau bisa, besok pagi", "Karena bisa, besok pagi", "Kapan bisa, besok pagi"],
                answer: "Kalau bisa, besok pagi",
                why: "kalau bisa = if possible. A very polite way to ask for something."
            ),
            .learn(
                "Before, after, while",
                "sebelum (before), setelah or habis (after), waktu (when, at the time). Put them in front of the action, just like English.",
                examples: [
                    Example("Sebelum makan, cuci tangan", "Wash your hands before eating"),
                    Example("Setelah kerja, saya ke pantai", "After work I go to the beach"),
                    Example("Waktu saya di Jawa…", "When I was in Java…"),
                    Example("Habis makan, ngopi", "After eating, coffee")
                ]
            ),
            .arrange(
                "If it rains, we'll stay home",
                "Kalau hujan, kita di rumah",
                alt: ["Kalau hujan kita di rumah", "Kalau hujan, kami di rumah"],
                extras: ["karena", "waktu"],
                why: "kalau + condition, then the result. No \"will\" needed."
            ),
            .hear(
                "Setelah kerja, saya ke pantai",
                ["After work, I go to the beach", "Before work, I go to the beach", "I work at the beach"],
                answer: "After work, I go to the beach",
                why: "setelah = after. ke pantai = to the beach; no verb for \"go\" needed."
            ),
            .pick(
                "Which one means \"before eating\"?",
                ["Sebelum makan", "Setelah makan", "Waktu makan"],
                answer: "Sebelum makan",
                why: "sebelum = before. setelah = after, waktu = while, when."
            ),
            .pick(
                "You've answered a question. Ask \"What about you?\":",
                ["Kalau kamu?", "Karena kamu?", "Waktu kamu?"],
                answer: "Kalau kamu?",
                why: "kalau kamu? = and you? The easiest way to keep a chat going."
            ),
            .arrange(
                "Wash your hands before eating",
                "Sebelum makan, cuci tangan",
                alt: ["Sebelum makan cuci tangan", "Cuci tangan sebelum makan"],
                extras: ["setelah", "kalau"],
                why: "sebelum = before. It can open the sentence or follow the action."
            ),
            .hear(
                "Kalau mahal, gak usah",
                ["If it's expensive, don't bother", "It's expensive, so I'll take it", "When it's cheap, buy two"],
                answer: "If it's expensive, don't bother",
                why: "kalau = if. gak usah = no need, don't bother."
            ),
            .pick(
                "\"When I was in Java…\" Start the story:",
                ["Waktu saya di Jawa…", "Kalau saya di Jawa…", "Sebelum saya di Jawa…"],
                answer: "Waktu saya di Jawa…",
                why: "waktu = when, for a time that really happened. kalau is for if or whenever."
            )
        ]
    )

    static let lesson113 = Lesson(
        id: "11.3",
        title: "Comparing",
        subtitle: "lebih, paling, sama",
        symbol: "chart.bar.fill",
        steps: [
            .learn(
                "lebih … dari",
                "lebih (more) goes before the describer, then dari (than). There are no -er endings; one pattern does it all.",
                pattern: "Ini/S lebih/D murah/D dari/L itu/O",
                examples: [
                    Example("Ini lebih murah", "This one's cheaper"),
                    Example("Ubud lebih dingin dari Kuta", "Ubud is cooler than Kuta"),
                    Example("Lebih besar, ada?", "Do you have a bigger one?"),
                    Example("Kurang manis", "Not sweet enough", note: "kurang = less")
                ]
            ),
            .pick(
                "Ask for a cheaper one:",
                ["Ada yang lebih murah?", "Ada yang murah lebih?", "Ada lebih yang murah?"],
                answer: "Ada yang lebih murah?",
                why: "yang lebih murah = the one that's cheaper. lebih always comes before the describer."
            ),
            .learn(
                "paling = most",
                "paling before a describer gives the top of the scale: paling enak (the most delicious, the best). sama … dengan means \"as … as\".",
                examples: [
                    Example("Yang paling enak yang mana?", "Which is the best one?"),
                    Example("Paling dekat", "The closest"),
                    Example("Sama enaknya", "Just as good"),
                    Example("Harganya sama", "Same price")
                ]
            ),
            .arrange(
                "This one's cheaper",
                "Ini lebih murah",
                alt: ["Yang ini lebih murah"],
                extras: ["paling", "dari"],
                why: "lebih before the describer. No \"is\"."
            ),
            .hear(
                "Yang paling enak yang mana?",
                ["Which one is the best?", "Which one is cheaper?", "Is this one good?"],
                answer: "Which one is the best?",
                why: "paling enak = the tastiest. Great to ask at any warung."
            ),
            .pick(
                "Ubud is cooler than Kuta. Say:",
                ["Ubud lebih dingin dari Kuta", "Ubud paling dingin dari Kuta", "Ubud dingin lebih Kuta"],
                answer: "Ubud lebih dingin dari Kuta",
                why: "lebih + describer + dari + what you compare with."
            ),
            .arrange(
                "Do you have a bigger one?",
                "Ada yang lebih besar?",
                alt: ["Lebih besar, ada?", "Ada yang besar?"],
                extras: ["kecil", "paling"],
                why: "ada yang … ? = is there one that … ? The shopping question."
            ),
            .pick(
                "Ask which one is the closest:",
                ["Yang paling dekat yang mana?", "Yang lebih dekat paling mana?", "Paling yang dekat mana?"],
                answer: "Yang paling dekat yang mana?",
                why: "paling + describer = the most. yang mana? = which one?"
            ),
            .hear(
                "Harganya sama",
                ["It's the same price", "The price is lower", "What's the price?"],
                answer: "It's the same price",
                why: "sama = the same. harganya = the price (of it)."
            ),
            .arrange(
                "This one's the best",
                "Ini paling enak",
                alt: ["Yang ini paling enak", "Ini yang paling enak"],
                extras: ["lebih", "dari"],
                why: "paling before the describer: the most delicious, the best."
            ),
            .pick(
                "Your coffee isn't sweet enough. Say:",
                ["Kurang manis", "Lebih manis", "Paling manis"],
                answer: "Kurang manis",
                why: "kurang = not enough, less. lebih manis would describe a sweeter one."
            )
        ]
    )
}
