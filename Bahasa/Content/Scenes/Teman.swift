import Foundation

// Place: Teman (social). Indonesian still needs the native-speaker check (spec §12.1).

extension SceneLibrary {
    static let putu = Character(
        id: "putu",
        name: "Putu",
        role: "graphic designer at the next table",
        register: .casual,
        addressAs: ["Putu"],
        moods: [.chatty, .tired],
        defaultMood: .chatty,
        confused: [
            Utterance("Hah? Gimana?", gloss: "Huh? How's that?"),
            Utterance("Sori, maksudnya?", gloss: "Sorry, meaning?"),
            Utterance("Hehe, apa tadi?", gloss: "Heh, what was that?")
        ]
    )

    static let temanNgopi = RehearsalScene(
        id: "id.teman.ngopi",
        language: "id",
        place: "Teman",
        title: "Ngopi sama teman baru",
        titleEn: "Coffee with a new friend",
        setting: "A busy café. Every table is taken except one seat, across from someone with a sketchbook.",
        level: .connect,
        accent: .kopi,
        symbol: "cup.and.saucer.fill",
        character: putu,
        goalSummary: "Ask to sit, introduce yourself, chat about life here, and make plans to meet again.",
        goals: [
            GoalFlag(id: "seat", label: "Ask to sit"),
            GoalFlag(id: "intro", label: "Introduce yourself"),
            GoalFlag(id: "chat", label: "Small talk", optional: true),
            GoalFlag(id: "plans", label: "Make plans")
        ],
        warmUps: [
            WarmUp(title: "Helper words · boleh", lessonID: "7.1"),
            WarmUp(title: "Particles & short forms", lessonID: "7.2"),
            WarmUp(title: "Reactions · wah, masa", lessonID: "7.3")
        ],
        culture: [
            "Putu is a Balinese name for a firstborn (like Wayan and Gede). It tells you birth order, not gender.",
            "Between people your age, aku/kamu, gak and banget are normal. Save saya/Anda for formal settings."
        ],
        slots: [.name],
        entry: "c1",
        nodes: [
            SceneNode(
                id: "c1",
                them: Utterance("Rame banget, ya, hari ini.", casual: "Rame banget, ya.",
                                gloss: "So busy today, huh.", chips: "Rame/D banget/D ya/X hari_ini/T"),
                variants: [.tired: Utterance("Hmm, rame, ya.", gloss: "Hmm, busy, huh.")],
                replies: [
                    .natural("Iya. Boleh duduk di sini?", "Yeah. Can I sit here?",
                             accept: ["boleh duduk di sini", "boleh saya duduk di sini", "iya boleh duduk sini"],
                             sets: ["seat"], next: "c2", chips: "Boleh/H duduk/V di_sini/X"),
                    .natural("Iya, ya. Kursinya kosong?", "Yeah. Is this seat free?",
                             accept: ["kursinya kosong", "kursi ini kosong", "kosong kursinya"],
                             sets: ["seat"], next: "c2", chips: "Kursinya/S kosong/D"),
                    .understood("Iya. Saya duduk di sini.", "Yes. I'm sitting here.", sets: ["seat"], next: "c2",
                                coach: "Not wrong, but asking with boleh is what makes it polite: Boleh duduk di sini?"),
                    .missed("Iya. Harus duduk di sini?", "Yes. Must I sit here?",
                            reaction: Utterance("Harus? Hehe, gak harus kok.", gloss: "Must? Heh, you don't have to."),
                            coach: "harus means must. To ask permission, use boleh.")
                ]
            ),
            SceneNode(
                id: "c2",
                them: Utterance("Boleh, silakan! Aku Putu.", gloss: "Sure, go ahead! I'm Putu.",
                                chips: "Boleh/H silakan/X Aku/S Putu/O"),
                replies: [
                    .natural("Salam kenal, aku {name}.", "Nice to meet you, I'm {name}.",
                             accept: ["salam kenal saya {name}", "aku {name}", "saya {name}", "salam kenal"],
                             sets: ["intro"], next: "c3", chips: "Salam_kenal/X aku/S {name}/O"),
                    .natural("Makasih! Aku {name}. Salam kenal.", "Thanks! I'm {name}. Nice to meet you.",
                             accept: ["makasih aku {name}", "makasih saya {name}"],
                             sets: ["intro"], next: "c3", chips: "Makasih/X Aku/S {name}/O Salam_kenal/X"),
                    .missed("Sama-sama, nama saya adalah {name}.", "You're welcome, my name is {name}.",
                            reaction: Utterance("Hehe… sama-sama?", gloss: "Heh… you're welcome?"),
                            coach: "sama-sama answers thanks, and adalah doesn't belong before a name. Try: Salam kenal, aku {name}."),
                    .missed("Siapa namamu?", "What's your name?",
                            reaction: Utterance("Putu, hehe. Kamu?", gloss: "Putu, heh. You?"),
                            coach: "Putu just told you. Give yours back: Aku {name}.")
                ]
            ),
            SceneNode(
                id: "c3",
                them: Utterance("Kerja apa, {name}?", casual: "Kerja apa di sini?", gloss: "What do you do?",
                                chips: "Kerja/V apa/Q"),
                replies: [
                    .natural("Aku kerja online.", "I work online.",
                             accept: ["kerja online", "saya kerja online", "aku kerja remote"],
                             sets: ["chat"], next: "c4", moodNext: [.tired: "c6"], chips: "Aku/S kerja/V online/D"),
                    .natural("Aku bikin aplikasi iPhone.", "I make iPhone apps.",
                             accept: ["bikin aplikasi", "saya bikin aplikasi iphone", "aku bikin aplikasi"],
                             sets: ["chat"], next: "c4", moodNext: [.tired: "c6"], chips: "Aku/S bikin/V aplikasi_iPhone/O"),
                    .natural("Aku lagi liburan aja, hehe.", "I'm just on holiday, heh.",
                             accept: ["lagi liburan", "aku lagi liburan", "liburan aja"],
                             sets: ["chat"], next: "c4", moodNext: [.tired: "c6"], chips: "Aku/S lagi/T liburan/V aja/X"),
                    .missed("Aku kerja apa.", "I work what.",
                            reaction: Utterance("Hehe, iya, kerja apa?", gloss: "Heh, yeah, what do you do?"),
                            coach: "That's the question repeated. Answer with what you do, e.g. Aku kerja online.")
                ]
            ),
            SceneNode(
                id: "c4",
                them: Utterance("Wah, keren! Udah lama di Bali?", gloss: "Oh, cool! Been in Bali long?",
                                chips: "Udah/T lama/D di/X Bali/O"),
                replies: [
                    .natural("Udah delapan bulan.", "Eight months now.",
                             accept: ["sudah delapan bulan", "delapan bulan"],
                             next: "c4b", chips: "Udah/T delapan_bulan/T"),
                    .natural("Baru dua minggu.", "Only two weeks.", accept: ["baru dua minggu", "dua minggu"],
                             next: "c4b", chips: "Baru/T dua_minggu/T"),
                    .missed("Delapan bulan lagi.", "In eight more months.",
                            reaction: Utterance("Oh, mau pergi delapan bulan lagi?", gloss: "Oh, you're leaving in eight months?"),
                            coach: "lagi points to the future. For time already spent, use udah: Udah delapan bulan."),
                    .missed("Belum delapan bulan ada.", "Not yet eight months there is.",
                            reaction: Utterance("Hmm? Berapa lama?", gloss: "Hmm? How long?"),
                            coach: "No ada needed. udah + the time: Udah delapan bulan.")
                ]
            ),
            SceneNode(
                id: "c4b",
                them: Utterance("Tinggal di mana sekarang?", casual: "Tinggal di mana?", gloss: "Where are you living now?",
                                chips: "Tinggal/V di_mana/Q sekarang/T"),
                replies: [
                    .natural("Di kos dekat sini.", "In a kos near here.",
                             accept: ["di kos dekat sini", "kos dekat sini", "aku di kos dekat sini"],
                             next: "c5", chips: "Di/X kos/O dekat/D sini/X"),
                    .natural("Aku ngekos di {city}.", "I rent a kos room in {city}.",
                             accept: ["ngekos di {city}", "aku ngekos", "di {city}"],
                             next: "c5", chips: "Aku/S ngekos/V di/X {city}/O"),
                    .natural("Di {city}, dekat pantai.", "In {city}, near the beach.",
                             accept: ["di {city} dekat pantai", "dekat pantai"],
                             next: "c5", chips: "Di/X {city}/O dekat/D pantai/O"),
                    .missed("Aku tinggal ke {city}.", "I live to {city}.",
                            reaction: Utterance("Ke {city}? Maksudnya di {city}?", gloss: "To {city}? You mean in {city}?"),
                            coach: "tinggal takes di (at), not ke (to): Aku tinggal di {city}.")
                ]
            ),
            SceneNode(
                id: "c5",
                them: Utterance("Suka di sini?", casual: "Betah?", gloss: "Do you like it here?",
                                chips: "Suka/V di_sini/X"),
                replies: [
                    .natural("Suka banget! Tapi macetnya parah.", "Love it! But the traffic is terrible.",
                             accept: ["suka banget", "suka banget tapi macet"],
                             next: "c6", chips: "Suka/V banget/D Tapi/L macetnya/S parah/D"),
                    .natural("Suka, tapi panas banget, hehe.", "I do, but it's so hot, heh.",
                             accept: ["suka tapi panas banget", "suka tapi panas"],
                             next: "c6", chips: "Suka/V tapi/L panas/D banget/D"),
                    .understood("Suka sekali banget!", "Very very much!", next: "c6",
                                coach: "One intensifier is enough: suka banget or suka sekali."),
                    .missed("Banget suka!", "Very like!",
                            reaction: Utterance("Hehe, suka banget, ya?", gloss: "Heh, love it, huh?"),
                            coach: "banget goes after the word it strengthens: suka banget.")
                ]
            ),
            SceneNode(
                id: "c6",
                them: Utterance("Nanti sore main voli di pantai. Mau ikut?", casual: "Sore ini voli di pantai, ikut yuk?",
                                gloss: "We're playing volleyball at the beach this afternoon. Want to come?",
                                chips: "Nanti_sore/T main/V voli/O di_pantai/X Mau/H ikut/V"),
                variants: [.tired: Utterance("Eh, sore ini ada voli di pantai. Ikut?", gloss: "Hey, there's volleyball at the beach this afternoon. Coming?")],
                replies: [
                    .natural("Mau! Kirim lokasinya, ya.", "I'd love to! Send me the location.",
                             accept: ["kirim lokasinya", "mau kirim lokasinya", "mau ikut kirim lokasinya"],
                             sets: ["plans"], next: "end", chips: "Mau/H Kirim/V lokasinya/O ya/X"),
                    .natural("Boleh! Minta nomor WA-mu, ya.", "Sure! Give me your WhatsApp number.",
                             accept: ["minta nomor wa", "minta nomormu", "boleh minta nomor"],
                             sets: ["plans"], next: "end", chips: "Boleh/H Minta/V nomor_WA-mu/O"),
                    .missed("Mau! Kirim lokasi saya, ya.", "I'd love to! Send my location.",
                            reaction: Utterance("Lokasi kamu? Hehe, lokasi pantainya, ya?", gloss: "Your location? Heh, you mean the beach's?"),
                            coach: "-nya points at the place you're both talking about. lokasi saya is your own location."),
                    .missed("Boleh! Jangan kirim lokasinya.", "Sure! Don't send the location.",
                            reaction: Utterance("Lho, terus gimana?", gloss: "Huh, then how?"),
                            coach: "jangan makes it a don't, the opposite of what you want.")
                ]
            ),
            SceneNode(
                id: "end",
                them: Utterance("Sip, nanti aku kirim. Sampai nanti!", gloss: "Cool, I'll send it. See you later!",
                                chips: "Sip/X nanti/T aku/S kirim/V Sampai_nanti/T"),
                variants: [.tired: Utterance("Oke, nanti aku kirim, ya.", gloss: "OK, I'll send it.")]
            )
        ],
        listening: [
            ListeningCheck(question: "What did Putu say about the café?",
                           options: ["It's busy today", "It's closing soon", "It's new"], answer: "It's busy today"),
            ListeningCheck(question: "What did Putu ask after your name?",
                           options: ["What you do", "How old you are", "Where you're staying"], answer: "What you do"),
            ListeningCheck(question: "What were you invited to?",
                           options: ["Volleyball at the beach", "Dinner", "A concert"], answer: "Volleyball at the beach")
        ]
    )
}
