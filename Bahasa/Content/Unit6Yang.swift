import SwiftUI

extension Curriculum {
    static let unit6 = Unit(
        id: "u6",
        number: 6,
        indoTitle: "Yang & Imbuhan",
        title: "Yang and prefixes",
        blurb: "The one word that builds long sentences, plus the prefixes on signs and menus.",
        accent: .laut,
        symbol: "link.circle.fill",
        lessons: [lesson61, lesson62, lesson63, lesson64]
    )

    static let lesson61 = Lesson(
        id: "6.1",
        title: "yang",
        subtitle: "\"the one that\"",
        symbol: "arrow.triangle.merge",
        steps: [
            .learn(
                "yang = the one that",
                "yang hooks a description onto a noun. It covers English who, which, that — and on its own it means \"the one\".",
                pattern: "orang/O yang/L tinggal/V di_sini/O",
                examples: [
                    Example("orang yang tinggal di sini", "the person who lives here"),
                    Example("Yang merah", "The red one"),
                    Example("Yang ini", "This one"),
                    Example("Yang mana?", "Which one?")
                ]
            ),
            .pick(
                "A seller asks which sarong you mean. Point and say:",
                ["Yang biru itu", "Biru yang itu", "Itu biru yang"],
                answer: "Yang biru itu",
                why: "yang + colour + itu: \"the blue one, that one there\"."
            ),
            .arrange(
                "I want the sweet one",
                "Saya mau yang manis",
                alt: ["Mau yang manis", "Saya mau yang manis saja"],
                extras: ["adalah", "ini"],
                why: "yang stands in for the noun you've both already got in mind."
            ),
            .learn(
                "Stretching sentences with yang",
                "Once yang is comfortable, you can describe anything without learning new grammar.",
                examples: [
                    Example("Warung yang di depan", "The warung up ahead"),
                    Example("Kamar yang ada AC", "A room that has air-con"),
                    Example("Yang tidak pedas, ya", "The one that isn't spicy, please")
                ]
            ),
            .hear(
                "Yang mana?",
                ["Which one?", "How many?", "Whose is it?"],
                answer: "Which one?",
                why: "mana = which or where; with yang it picks one out of several."
            ),
            .arrange(
                "A room that has air-con",
                "Kamar yang ada AC",
                alt: ["Kamar yang ada AC-nya"],
                extras: ["adalah", "punya"],
                why: "ada = there is / has, and yang links it to kamar."
            )
        ]
    )

    static let lesson62 = Lesson(
        id: "6.2",
        title: "Prefixes",
        subtitle: "me-, ber-, di-",
        symbol: "text.append",
        steps: [
            .learn(
                "Bare roots in speech, me- in writing",
                "Conversation uses the bare root: beli, baca, tulis. Menus, news and formal speech dress the same verbs in me-.",
                examples: [
                    Example("beli / membeli", "buy", note: "casual / formal"),
                    Example("baca / membaca", "read"),
                    Example("Saya mau beli ini", "I want to buy this", note: "what you'd actually say"),
                    Example("Dia membaca buku", "He is reading a book", note: "written style")
                ]
            ),
            .learn(
                "ber- verbs",
                "ber- builds verbs that are about doing something in itself — working, swimming, travelling. They are learned as whole words.",
                examples: [
                    Example("bekerja", "to work", note: "kerja in speech"),
                    Example("berenang", "to swim"),
                    Example("berbicara", "to speak", note: "ngobrol is the casual chat word"),
                    Example("berapa lama?", "how long?")
                ]
            ),
            .pick(
                "Which one would you actually say to a shopkeeper?",
                ["Saya mau beli ini", "Saya ingin membeli ini", "Saya pembelian ini"],
                answer: "Saya mau beli ini",
                why: "mau + bare root is normal speech. The me- form isn't wrong, just stiff."
            ),
            .learn(
                "di- on signs",
                "di- in front of a verb makes it passive — it's done to something. Signs are full of it.",
                pattern: "Dilarang/V parkir/V",
                examples: [
                    Example("Dilarang parkir", "No parking", note: "literally \"parking is forbidden\""),
                    Example("Dilarang merokok", "No smoking"),
                    Example("Rumah ini disewakan", "This house is for rent"),
                    Example("Dibungkus", "Wrapped to take away")
                ]
            ),
            .hear(
                "Dilarang parkir",
                ["No parking", "Parking here", "Paid parking"],
                answer: "No parking",
                why: "dilarang = forbidden. Spot it on every second wall in Bali."
            ),
            .arrange(
                "Can I take it away?",
                "Bisa dibungkus?",
                alt: ["Bisa dibungkus ya", "Dibungkus bisa?"],
                extras: ["makan", "jangan"],
                why: "bungkus = to wrap; di- makes it \"be wrapped\". The takeaway question."
            ),
            .pick(
                "A sign says \"Rumah ini disewakan\". It means:",
                ["This house is for rent", "This house is sold out", "Don't enter this house"],
                answer: "This house is for rent",
                why: "sewa = rent, di- …-kan = is being rented out."
            )
        ]
    )

    static let lesson63 = Lesson(
        id: "6.3",
        title: "The handy -nya",
        subtitle: "harganya, kamarnya, namanya",
        symbol: "pin.fill",
        steps: [
            .learn(
                "-nya = his, her, its",
                "Stuck onto a noun, -nya means his, her or its: namanya is \"her name\". It never shows if the owner is a man or a woman.",
                pattern: "Namanya/O siapa/Q",
                examples: [
                    Example("Namanya siapa?", "What's his / her name?"),
                    Example("Rumahnya di Ubud", "Her house is in Ubud"),
                    Example("Motornya baru", "His motorbike is new"),
                    Example("Anjingnya lucu", "Their dog is cute")
                ]
            ),
            .learn(
                "-nya = the one we both know",
                "Even more often, -nya works like \"the\": the thing that's already in the conversation. That's why prices, rooms and food all get it.",
                examples: [
                    Example("Berapa harganya?", "How much is it?", note: "the price of this thing"),
                    Example("Kamarnya bersih", "The room is clean"),
                    Example("Kopinya enak", "The coffee's good"),
                    Example("Wifinya mati", "The wifi's down")
                ]
            ),
            .pick(
                "You're holding a sarong. Ask its price:",
                ["Berapa harganya?", "Berapa harga?", "Harga berapa saya?"],
                answer: "Berapa harganya?",
                why: "-nya points at the price of this sarong. Plain harga sounds like a dictionary entry."
            ),
            .arrange(
                "The room is clean",
                "Kamarnya bersih",
                extras: ["adalah", "kamar"],
                why: "-nya for \"the room\", and no \"is\" before an adjective."
            ),
            .hear(
                "AC-nya rusak",
                ["The air-con is broken", "The air-con is cold", "There's no air-con"],
                answer: "The air-con is broken",
                why: "rusak = broken. Written with a hyphen after abbreviations: AC-nya."
            ),
            .pick(
                "Which sentence says \"the wifi is down\"?",
                ["Wifinya mati", "Wifi saya mati", "Mati wifi"],
                answer: "Wifinya mati",
                why: "mati = dead, off. -nya = the wifi here."
            ),
            .arrange(
                "What's her name?",
                "Namanya siapa?",
                alt: ["Siapa namanya?"],
                extras: ["apa", "nama"],
                why: "siapa, not apa, for names, because a name belongs to a person."
            )
        ]
    )

    static let lesson64 = Lesson(
        id: "6.4",
        title: "-an makes things",
        subtitle: "makanan, minuman, pakaian",
        symbol: "takeoutbag.and.cup.and.straw.fill",
        steps: [
            .learn(
                "Verb + -an = the thing",
                "Add -an to a verb and you get the thing that's done: makan (eat) → makanan (food), minum (drink) → minuman (drinks). Menus and signs use these constantly.",
                examples: [
                    Example("makan → makanan", "eat → food"),
                    Example("minum → minuman", "drink → drinks"),
                    Example("pakai → pakaian", "wear → clothes"),
                    Example("tulis → tulisan", "write → writing")
                ]
            ),
            .pick(
                "On a menu, which heading is \"Drinks\"?",
                ["Minuman", "Minum", "Peminum"],
                answer: "Minuman",
                why: "minum + -an = what you drink."
            ),
            .learn(
                "Doubled + -an: all sorts",
                "Doubling with -an means a variety: sayur-sayuran (all kinds of vegetables), buah-buahan (all kinds of fruit). You'll see them on market signs.",
                examples: [
                    Example("Sayur-sayuran segar", "Fresh vegetables"),
                    Example("Buah-buahan", "Fruit of all kinds"),
                    Example("Makanan khas Bali", "Food typical of Bali"),
                    Example("Minuman dingin", "Cold drinks")
                ]
            ),
            .arrange(
                "Balinese food",
                "Makanan khas Bali",
                alt: ["Makanan Bali"],
                extras: ["makan", "minuman"],
                why: "khas = typical of, special to. Describers follow the noun."
            ),
            .hear(
                "Minumannya apa?",
                ["What would you like to drink?", "Is the drink cold?", "Where are the drinks?"],
                answer: "What would you like to drink?",
                why: "The waiter's question after you order food."
            ),
            .pick(
                "\"Pakaian\" is:",
                ["Clothes", "A wardrobe", "Wearing"],
                answer: "Clothes",
                why: "pakai (wear, use) + -an = the things you wear."
            )
        ]
    )
}
