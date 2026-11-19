import SwiftUI

extension Curriculum {
    static let unit3 = Unit(
        id: "u3",
        number: 3,
        indoTitle: "Waktu",
        title: "Time without tenses",
        blurb: "One little word in front of the verb does the work of every English tense.",
        accent: .kunyit,
        symbol: "clock.fill",
        lessons: [lesson31, lesson32, lesson33, lesson34]
    )

    static let lesson31 = Lesson(
        id: "3.1",
        title: "Time markers",
        subtitle: "sudah, sedang, akan, belum",
        symbol: "timeline.selection",
        steps: [
            .learn(
                "Markers, not tenses",
                "Verbs never change shape. You put a small marker in front instead: sudah (already / did), sedang (in the middle of), akan (will), belum (not yet).",
                pattern: "Saya/S sudah/T makan/V",
                examples: [
                    Example("Saya sudah makan", "I've eaten"),
                    Example("Saya sedang makan", "I'm eating right now", note: "sedang is often shortened to lagi in speech"),
                    Example("Saya akan makan", "I'm going to eat"),
                    Example("Saya belum makan", "I haven't eaten yet")
                ]
            ),
            .pick(
                "You're halfway through lunch. Say:",
                ["Saya sedang makan", "Saya sudah makan", "Saya akan makan"],
                answer: "Saya sedang makan",
                why: "sedang marks something going on right now. In conversation most people say lagi makan."
            ),
            .learn(
                "Time words carry the rest",
                "Add a time word and the verb still doesn't move: kemarin (yesterday), tadi (earlier today), nanti (later today), besok (tomorrow).",
                pattern: "Besok/T saya/S pergi/V",
                examples: [
                    Example("Besok saya pergi ke Ubud", "Tomorrow I'm going to Ubud"),
                    Example("Kemarin saya ke pasar", "Yesterday I went to the market", note: "no verb needed at all"),
                    Example("Nanti saja", "Later", note: "a very useful brush-off"),
                    Example("Tadi dia telepon", "He called earlier")
                ]
            ),
            .arrange(
                "Tomorrow I'm going to Ubud",
                "Besok saya pergi ke Ubud",
                alt: ["Saya pergi ke Ubud besok"],
                extras: ["kemarin", "sudah"],
                why: "The time word can open the sentence or close it. pergi stays as it is."
            ),
            .learn(
                "\"Sudah makan?\" as a greeting",
                "Asking whether someone has eaten is small talk, not an invitation. Answer sudah or belum and everyone is happy.",
                examples: [
                    Example("Sudah makan?", "Have you eaten?"),
                    Example("Sudah, terima kasih", "Yes, I have, thanks"),
                    Example("Belum", "Not yet"),
                    Example("Mau ke mana?", "Where are you off to?", note: "the other standard opener")
                ]
            ),
            .hear(
                "Saya belum makan",
                ["I haven't eaten yet", "I've already eaten", "I'm eating now"],
                answer: "I haven't eaten yet",
                why: "belum = not yet, and it leaves the door open."
            ),
            .arrange(
                "I've already paid",
                "Saya sudah bayar",
                alt: ["Sudah bayar"],
                extras: ["belum", "akan"],
                why: "sudah + bayar. Nothing marks the past on the verb itself."
            ),
            .pick(
                "\"Sudah menikah?\" — you aren't married. Reply:",
                say: "Sudah menikah?",
                ["Belum", "Tidak", "Bukan"],
                answer: "Belum",
                why: "belum is the polite, optimistic \"not yet\". Tidak sounds like a refusal."
            )
        ]
    )

    static let lesson32 = Lesson(
        id: "3.2",
        title: "belum, pernah, lagi",
        subtitle: "The optimistic \"not yet\"",
        symbol: "hourglass",
        steps: [
            .learn(
                "belum keeps it open",
                "Where English says a flat \"no\", Indonesian often says belum — not yet. It is the normal answer to anything that could still happen one day.",
                examples: [
                    Example("Sudah punya anak?", "Do you have kids?"),
                    Example("Belum", "Not yet"),
                    Example("Belum pernah", "I never have — so far"),
                    Example("Belum siap", "Not ready yet")
                ]
            ),
            .learn(
                "pernah = have ever",
                "pernah marks experience: have you ever. With belum in front, it is \"not yet ever\".",
                pattern: "Kamu/S pernah/T ke/V Jawa/O",
                examples: [
                    Example("Pernah ke Jawa?", "Have you been to Java?"),
                    Example("Pernah, dua kali", "Yes, twice"),
                    Example("Belum pernah", "Never, not yet"),
                    Example("Saya pernah coba", "I've tried it before")
                ]
            ),
            .pick(
                "\"Pernah makan durian?\" — you never have. Reply:",
                say: "Pernah makan durian?",
                ["Belum pernah", "Tidak pernah ada", "Bukan pernah"],
                answer: "Belum pernah",
                why: "belum pernah is what people actually say. bukan never touches a verb."
            ),
            .learn(
                "lagi does three jobs",
                "lagi means \"again\", \"more\", and — in casual speech — \"in the middle of\" instead of sedang.",
                examples: [
                    Example("Satu lagi, ya", "One more, please"),
                    Example("Lagi apa?", "What are you up to?", note: "casual for sedang apa"),
                    Example("Coba lagi", "Try again"),
                    Example("Lagi macet", "The traffic's bad right now")
                ]
            ),
            .arrange(
                "One more coffee, please",
                "Satu kopi lagi, ya",
                alt: ["Kopi satu lagi ya", "Satu kopi lagi"],
                extras: ["sudah", "banyak"],
                why: "lagi sits at the end for \"more\", and ya softens the request into a please."
            ),
            .hear(
                "Lagi apa?",
                ["What are you doing?", "What again?", "How many more?"],
                answer: "What are you doing?",
                why: "Casual lagi = sedang. A friend texting you this means \"what are you up to\"."
            ),
            .arrange(
                "I've never been to Lombok",
                "Saya belum pernah ke Lombok",
                alt: ["Belum pernah ke Lombok"],
                extras: ["tidak", "sudah"],
                why: "belum pernah + ke. No verb for \"been\" is needed."
            )
        ]
    )

    static let lesson33 = Lesson(
        id: "3.3",
        title: "Telling the time",
        subtitle: "Jam berapa? Jam tiga.",
        symbol: "clock.badge.checkmark.fill",
        steps: [
            .learn(
                "jam + number",
                "jam means both \"hour\" and \"o'clock\". Put the number after it. Add pagi, siang, sore or malam to show which part of the day.",
                pattern: "Jam/T tiga/T sore/T",
                examples: [
                    Example("Jam berapa?", "What time is it?"),
                    Example("Jam tujuh pagi", "Seven in the morning"),
                    Example("Jam tiga sore", "Three in the afternoon"),
                    Example("Jam delapan malam", "Eight in the evening")
                ]
            ),
            .pick(
                "Your boat leaves at 9am. Which one?",
                ["Jam sembilan pagi", "Jam sembilan malam", "Sembilan jam"],
                answer: "Jam sembilan pagi",
                why: "jam comes first for clock time. Sembilan jam means \"nine hours\", a length of time."
            ),
            .learn(
                "Half past is half to",
                "setengah means half, and it counts towards the next hour: setengah empat is 3:30, not 4:30. Quarters use seperempat with lewat (past) or kurang (to).",
                examples: [
                    Example("Setengah empat", "Half past three", note: "literally \"half four\""),
                    Example("Jam tiga lewat sepuluh", "Ten past three"),
                    Example("Jam tiga lewat seperempat", "Quarter past three"),
                    Example("Jam empat kurang seperempat", "Quarter to four")
                ]
            ),
            .pick(
                "Someone says \"setengah tujuh\". What time is it?",
                ["6:30", "7:30", "7:00"],
                answer: "6:30",
                why: "setengah counts towards the next hour: half (of the way to) seven."
            ),
            .arrange(
                "What time is it?",
                "Jam berapa?",
                alt: ["Jam berapa sekarang?", "Sekarang jam berapa?"],
                extras: ["menit", "apa"],
                why: "jam + berapa (how many). Literally \"hour how-many?\"."
            ),
            .hear(
                "Kita ketemu jam lima sore",
                ["We'll meet at five in the afternoon", "We met five days ago", "It takes five hours"],
                answer: "We'll meet at five in the afternoon",
                why: "ketemu = meet (casual for bertemu). No future marker needed; the time says it."
            ),
            .learn(
                "How long",
                "For a length of time, the number goes before the unit: dua jam (two hours), sepuluh menit (ten minutes). Ask with berapa lama.",
                examples: [
                    Example("Berapa lama?", "How long?"),
                    Example("Kira-kira dua jam", "About two hours"),
                    Example("Sepuluh menit lagi", "Ten more minutes"),
                    Example("Sebentar saja", "Only a moment")
                ]
            ),
            .arrange(
                "About two hours",
                "Kira-kira dua jam",
                alt: ["Sekitar dua jam"],
                extras: ["menit", "berapa"],
                why: "kira-kira = roughly. Number before jam for a duration."
            )
        ]
    )

    static let lesson34 = Lesson(
        id: "3.4",
        title: "Days and plans",
        subtitle: "hari ini, minggu depan",
        symbol: "calendar",
        steps: [
            .learn(
                "Today, this week, next month",
                "Time words are built from hari (day), minggu (week), bulan (month) and tahun (year), plus ini (this), depan (next, literally \"front\") and lalu (last).",
                pattern: "Minggu/T depan/T saya/S pulang/V",
                examples: [
                    Example("Hari ini", "Today"),
                    Example("Minggu depan", "Next week"),
                    Example("Bulan lalu", "Last month"),
                    Example("Tahun depan saya ke Jawa", "Next year I'm going to Java")
                ]
            ),
            .pick(
                "Which one means \"last week\"?",
                ["Minggu lalu", "Minggu depan", "Minggu ini"],
                answer: "Minggu lalu",
                why: "lalu = past, gone by. depan points forward."
            ),
            .learn(
                "Days of the week",
                "Days take hari in front: hari Senin, hari Selasa… In speech hari is often dropped. Minggu is also Sunday, so context tells you if it's a week or the day.",
                examples: [
                    Example("Senin, Selasa, Rabu", "Monday, Tuesday, Wednesday"),
                    Example("Kamis, Jumat, Sabtu", "Thursday, Friday, Saturday"),
                    Example("Hari Minggu", "Sunday"),
                    Example("Sampai hari Jumat", "See you Friday")
                ]
            ),
            .arrange(
                "Next week I'm going home",
                "Minggu depan saya pulang",
                alt: ["Saya pulang minggu depan"],
                extras: ["lalu", "sudah"],
                why: "Time words can open or close the sentence. pulang = go home."
            ),
            .hear(
                "Hari Sabtu saya libur",
                ["I'm off on Saturday", "I work on Sunday", "Saturday is busy"],
                answer: "I'm off on Saturday",
                why: "libur = day off, holiday."
            ),
            .pick(
                "A friend asks when you arrived. You came three days ago:",
                ["Tiga hari yang lalu", "Tiga hari lagi", "Hari ketiga"],
                answer: "Tiga hari yang lalu",
                why: "yang lalu after a length of time = ago. … lagi = in … time."
            ),
            .arrange(
                "In two weeks",
                "Dua minggu lagi",
                extras: ["lalu", "depan"],
                why: "lagi after a length of time points forward: two more weeks."
            )
        ]
    )
}
