import SwiftUI

extension Curriculum {
    static let phrasebook: [PhraseCategory] = [
        PhraseCategory(
            id: "basics",
            title: "Basics",
            indoTitle: "Dasar",
            symbol: "star.fill",
            accent: .sambal,
            phrases: [
                Phrase("Apa kabar?", "How are you?", note: "Reply: Baik, terima kasih"),
                Phrase("Saya tidak mengerti", "I don't understand", note: "casual: Saya nggak ngerti"),
                Phrase("Bisa ulangi?", "Could you repeat that?"),
                Phrase("Pelan-pelan, ya", "Slowly, please"),
                Phrase("Apa artinya…?", "What does … mean?"),
                Phrase("Bahasa Indonesianya apa?", "What's that in Indonesian?"),
                Phrase("Saya baru belajar", "I've only just started learning"),
                Phrase("Tidak apa-apa", "It's fine / no worries", note: "casual: gak papa")
            ]
        ),
        PhraseCategory(
            id: "food",
            title: "Food",
            indoTitle: "Makanan",
            symbol: "fork.knife",
            accent: .kunyit,
            phrases: [
                Phrase("Saya mau pesan", "I'd like to order"),
                Phrase("Tidak pedas, ya", "Not spicy, please", note: "or jangan pedas"),
                Phrase("Sedikit pedas aja", "Just a little spicy"),
                Phrase("Saya tidak makan daging", "I don't eat meat"),
                Phrase("Minta bon, ya", "The bill, please"),
                Phrase("Bungkus, ya", "To take away, please"),
                Phrase("Air putih satu", "One still water", note: "air putih = plain water"),
                Phrase("Tanpa gula, ya", "No sugar, please"),
                Phrase("Enak banget!", "Really delicious!"),
                Phrase("Es teh tawar", "Unsweetened iced tea", note: "tawar = plain"),
                Phrase("Saya alergi kacang", "I'm allergic to peanuts"),
                Phrase("Tambah nasi, ya", "Extra rice, please"),
                Phrase("Sudah kenyang", "I'm full")
            ]
        ),
        PhraseCategory(
            id: "around",
            title: "Getting around",
            indoTitle: "Di jalan",
            symbol: "scooter",
            accent: .laut,
            phrases: [
                Phrase("Kiri, ya", "Stop here, please", note: "literally \"left\" — how you stop a driver"),
                Phrase("Lurus saja", "Straight on"),
                Phrase("Belok kanan", "Turn right"),
                Phrase("Belok kiri", "Turn left"),
                Phrase("Jauh?", "Is it far?"),
                Phrase("Macet banget", "The traffic's awful"),
                Phrase("Pom bensin di mana?", "Where's a petrol station?"),
                Phrase("Turun di depan, ya", "Drop me up ahead, please"),
                Phrase("Pelan-pelan, Pak", "Slowly, please")
            ]
        ),
        PhraseCategory(
            id: "shopping",
            title: "Shopping",
            indoTitle: "Belanja",
            symbol: "bag.fill",
            accent: .jambu,
            phrases: [
                Phrase("Ini berapa?", "How much is this?"),
                Phrase("Bisa kurang?", "Can you come down?"),
                Phrase("Harga pas?", "Is the price fixed?"),
                Phrase("Ada ukuran lain?", "Do you have another size?"),
                Phrase("Ada warna lain?", "Any other colours?"),
                Phrase("Bisa bayar pakai QRIS?", "Can I pay by QRIS?", note: "the national QR payment system"),
                Phrase("Saya lihat-lihat dulu", "I'm just looking for now"),
                Phrase("Mahal sekali!", "That's very expensive!")
            ]
        ),
        PhraseCategory(
            id: "home",
            title: "Home & living",
            indoTitle: "Rumah",
            symbol: "house.fill",
            accent: .sawah,
            phrases: [
                Phrase("Saya mau sewa kamar", "I'd like to rent a room"),
                Phrase("Sudah termasuk listrik?", "Is electricity included?"),
                Phrase("AC-nya rusak", "The air-con is broken"),
                Phrase("Wifinya mati", "The wifi is down"),
                Phrase("Tidak ada air panas", "There's no hot water"),
                Phrase("Laundry kiloan di mana?", "Where's a laundry by the kilo?"),
                Phrase("Bisa diperbaiki hari ini?", "Can it be fixed today?"),
                Phrase("Berapa per bulan?", "How much per month?")
            ]
        ),
        PhraseCategory(
            id: "social",
            title: "Social",
            indoTitle: "Pergaulan",
            symbol: "person.2.fill",
            accent: .kopi,
            phrases: [
                Phrase("Salam kenal", "Nice to meet you"),
                Phrase("Asalnya dari mana?", "Where are you from?"),
                Phrase("Sudah lama di sini?", "Have you been here long?"),
                Phrase("Ayo ngopi!", "Let's get a coffee!"),
                Phrase("Boleh minta nomornya?", "Could I have your number?"),
                Phrase("Sampai jumpa", "See you", note: "casual: sampai nanti"),
                Phrase("Hati-hati di jalan", "Take care on the road", note: "said as someone leaves"),
                Phrase("Titip salam, ya", "Say hello to them for me")
            ]
        ),
        PhraseCategory(
            id: "travel",
            title: "Travel & stays",
            indoTitle: "Perjalanan",
            symbol: "airplane",
            accent: .laut,
            phrases: [
                Phrase("Ke bandara, ya", "To the airport, please"),
                Phrase("Berapa lama ke sana?", "How long does it take to get there?"),
                Phrase("Saya sudah pesan kamar", "I've booked a room"),
                Phrase("Atas nama…", "Under the name…", note: "for bookings and bills"),
                Phrase("Check-out jam berapa?", "What time is check-out?"),
                Phrase("Bisa titip tas?", "Can I leave my bag here?"),
                Phrase("Kapalnya berangkat jam berapa?", "What time does the boat leave?"),
                Phrase("Bisa minta handuk lagi?", "Could I have another towel?")
            ]
        ),
        PhraseCategory(
            id: "time",
            title: "Time & days",
            indoTitle: "Waktu",
            symbol: "clock.fill",
            accent: .kunyit,
            phrases: [
                Phrase("Jam berapa?", "What time is it?"),
                Phrase("Jam tiga sore", "Three in the afternoon"),
                Phrase("Setengah tujuh", "Half past six", note: "literally \"half seven\""),
                Phrase("Hari ini", "Today"),
                Phrase("Besok pagi", "Tomorrow morning"),
                Phrase("Minggu depan", "Next week"),
                Phrase("Tiga hari yang lalu", "Three days ago"),
                Phrase("Sebentar, ya", "Just a moment")
            ]
        ),
        PhraseCategory(
            id: "culture",
            title: "Culture",
            indoTitle: "Budaya",
            symbol: "leaf.fill",
            accent: .sawah,
            phrases: [
                Phrase("Om Swastiastu", "Hello", note: "Balinese Hindu greeting; reply the same"),
                Phrase("Suksma", "Thank you", note: "Balinese"),
                Phrase("Boleh masuk?", "May I come in?"),
                Phrase("Boleh foto?", "May I take a photo?"),
                Phrase("Sedang ada upacara?", "Is there a ceremony on?"),
                Phrase("Harus pakai sarung?", "Do I need to wear a sarong?"),
                Phrase("Sedikit-sedikit", "Just a little", note: "the modest reply when people praise your Indonesian"),
                Phrase("Masih belajar", "I'm still learning")
            ]
        ),
        PhraseCategory(
            id: "emergency",
            title: "Emergency",
            indoTitle: "Darurat",
            symbol: "cross.case.fill",
            accent: .indigo,
            phrases: [
                Phrase("Tolong!", "Help!"),
                Phrase("Saya sakit", "I'm ill"),
                Phrase("Di mana rumah sakit?", "Where is the hospital?"),
                Phrase("Apotek di mana?", "Where's a pharmacy?"),
                Phrase("Saya kecelakaan motor", "I've had a motorbike accident"),
                Phrase("Dompet saya hilang", "I've lost my wallet"),
                Phrase("Tolong panggil polisi", "Please call the police"),
                Phrase("Saya butuh dokter", "I need a doctor")
            ]
        )
    ]
}
