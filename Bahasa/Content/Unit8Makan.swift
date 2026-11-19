import SwiftUI

extension Curriculum {
    static let unit8 = Unit(
        id: "u8",
        number: 8,
        indoTitle: "Makan",
        title: "Eating out",
        blurb: "Order exactly what you want, say how you like it, and pay with a smile.",
        accent: .sambal,
        symbol: "fork.knife",
        lessons: [lesson81, lesson82, lesson83]
    )

    static let lesson81 = Lesson(
        id: "8.1",
        title: "Ordering",
        subtitle: "pakai, tanpa, tambah",
        symbol: "list.bullet.rectangle.fill",
        steps: [
            .learn(
                "Name it, then the number",
                "At a warung you can simply say the dish, then how many. Add ya to keep it friendly. Saya mau pesan… is the fuller version.",
                pattern: "Nasi_goreng/O satu/D ya/X",
                examples: [
                    Example("Nasi goreng satu, ya", "One fried rice, please"),
                    Example("Saya mau pesan mie goreng", "I'd like to order fried noodles"),
                    Example("Minta es jeruk dua", "Two iced orange juices, please"),
                    Example("Sudah, itu aja", "That's all", note: "when they ask if there's anything else")
                ]
            ),
            .pick(
                "\"Makan di sini atau dibungkus?\" You want to take it away:",
                ["Dibungkus, ya", "Makan di sini", "Bungkus di sini"],
                answer: "Dibungkus, ya",
                why: "dibungkus = wrapped (to go). Makan di sini = eating here."
            ),
            .learn(
                "pakai, tanpa, tambah",
                "pakai = with, tanpa = without, tambah = extra / add. They let you shape any order.",
                examples: [
                    Example("Pakai telur?", "With egg?"),
                    Example("Tanpa es, ya", "No ice, please"),
                    Example("Tambah nasi, ya", "Extra rice, please"),
                    Example("Nasinya sedikit aja", "Just a little rice")
                ]
            ),
            .arrange(
                "One fried rice, please",
                "Nasi goreng satu, ya",
                alt: ["Nasi goreng satu", "Minta nasi goreng satu", "Satu nasi goreng, ya"],
                extras: ["dua", "mau"],
                why: "Dish, then number. ya makes it a friendly request."
            ),
            .hear(
                "Mau minum apa?",
                ["What would you like to drink?", "Do you want to eat here?", "Is it spicy?"],
                answer: "What would you like to drink?",
                why: "minum = drink. Asked right after you order food."
            ),
            .pick(
                "You want iced tea with no sugar. Order:",
                ["Es teh tawar", "Es teh manis", "Teh panas manis"],
                answer: "Es teh tawar",
                why: "tawar = plain, unsweetened. Iced tea usually comes sweet unless you say so."
            ),
            .arrange(
                "No ice, please",
                "Tanpa es, ya",
                alt: ["Gak pakai es, ya", "Jangan pakai es", "Tanpa es"],
                extras: ["pakai", "tambah"],
                why: "tanpa = without. gak pakai es is just as common."
            ),
            .pick(
                "The cook asks \"Ada lagi?\" You're done:",
                ["Sudah, itu aja", "Belum, itu aja", "Ada, itu aja"],
                answer: "Sudah, itu aja",
                why: "ada lagi? = anything else? sudah, itu aja = that's it."
            )
        ]
    )

    static let lesson82 = Lesson(
        id: "8.2",
        title: "Taste and diet",
        subtitle: "asin, manis, alergi",
        symbol: "leaf.fill",
        steps: [
            .learn(
                "Six tastes",
                "pedas (spicy), manis (sweet), asin (salty), asam (sour), pahit (bitter), gurih (savoury, rich). terlalu means too, agak means a bit.",
                pattern: "Supnya/O terlalu/D asin/D",
                examples: [
                    Example("Supnya terlalu asin", "The soup is too salty"),
                    Example("Agak pedas", "A bit spicy"),
                    Example("Kopinya pahit", "The coffee is bitter"),
                    Example("Gurih banget!", "So savoury!")
                ]
            ),
            .pick(
                "Your juice is far too sweet. Say:",
                ["Terlalu manis", "Agak asam", "Kurang manis"],
                answer: "Terlalu manis",
                why: "terlalu = too. kurang manis would mean \"not sweet enough\"."
            ),
            .learn(
                "Telling them what you can't eat",
                "Say it plainly and early. Shrimp paste (terasi) and peanuts hide in a lot of sauces, so it's worth asking.",
                examples: [
                    Example("Saya vegetarian", "I'm vegetarian"),
                    Example("Saya alergi kacang", "I'm allergic to peanuts"),
                    Example("Saya tidak makan babi", "I don't eat pork"),
                    Example("Pakai terasi?", "Does it have shrimp paste?")
                ]
            ),
            .arrange(
                "I'm allergic to peanuts",
                "Saya alergi kacang",
                alt: ["Saya alergi kacang tanah"],
                extras: ["makan", "tidak"],
                why: "No \"am\" needed: subject + alergi + the food."
            ),
            .hear(
                "Ini pakai daging babi?",
                ["Does this have pork in it?", "Is this pork satay?", "Do you sell pork?"],
                answer: "Does this have pork in it?",
                why: "pakai = contains, comes with. daging babi = pork."
            ),
            .pick(
                "Ask if the dish has shrimp:",
                ["Pakai udang?", "Udang di mana?", "Mau udang?"],
                answer: "Pakai udang?",
                why: "pakai asks what goes into a dish."
            ),
            .arrange(
                "A bit spicy, please",
                "Agak pedas, ya",
                alt: ["Sedikit pedas, ya", "Agak pedas"],
                extras: ["terlalu", "manis"],
                why: "agak = somewhat. The safe level for most warungs."
            )
        ]
    )

    static let lesson83 = Lesson(
        id: "8.3",
        title: "Table talk",
        subtitle: "Mbak! Minta bon. Kenyang!",
        symbol: "fork.knife.circle.fill",
        steps: [
            .learn(
                "Calling staff",
                "Call staff by Mas or Mbak, softened with permisi. Raise a hand slightly; waving or hissing is rude.",
                examples: [
                    Example("Permisi, Mbak", "Excuse me (to a young woman)"),
                    Example("Minta menunya, ya", "The menu, please"),
                    Example("Minta bon, ya", "The bill, please"),
                    Example("Bisa dibungkus sisanya?", "Can I take the rest away?")
                ]
            ),
            .pick(
                "Get the waitress's attention politely:",
                ["Permisi, Mbak", "Hei, Mbak!", "Halo, Ibu-ibu"],
                answer: "Permisi, Mbak",
                why: "permisi + the right title is always polite."
            ),
            .arrange(
                "The menu, please",
                "Minta menunya, ya",
                alt: ["Minta menu, ya", "Boleh lihat menunya?", "Minta menunya"],
                extras: ["bon", "tolong"],
                why: "minta for a thing. -nya = the menu here."
            ),
            .hear(
                "Semuanya delapan puluh lima ribu",
                ["It's 85,000 altogether", "Each one is 85,000", "It's 58,000 altogether"],
                answer: "It's 85,000 altogether",
                why: "semuanya = all of it. delapan puluh lima ribu = eighty-five thousand."
            ),
            .learn(
                "After the meal",
                "Praise the food; it's the nicest thing you can say to a cook. kenyang means full, the happy kind.",
                examples: [
                    Example("Enak sekali, Bu!", "Delicious, ma'am!"),
                    Example("Saya sudah kenyang", "I'm full"),
                    Example("Makasih, enak banget", "Thanks, it was really good"),
                    Example("Lain kali saya ke sini lagi", "I'll come back another time")
                ]
            ),
            .pick(
                "Your host offers more food, but you're full:",
                ["Sudah kenyang, makasih", "Sudah lapar, makasih", "Sudah haus, makasih"],
                answer: "Sudah kenyang, makasih",
                why: "kenyang = full. lapar = hungry, haus = thirsty."
            ),
            .arrange(
                "The bill, please",
                "Minta bon, ya",
                alt: ["Minta bonnya, ya", "Minta bon"],
                extras: ["bayar", "menu"],
                why: "bon = bill. You'll also hear minta nota."
            )
        ]
    )
}
