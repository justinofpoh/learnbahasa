import SwiftUI

extension Curriculum {
    static let unit7 = Unit(
        id: "u7",
        number: 7,
        indoTitle: "Ngobrol",
        title: "Sounding natural",
        blurb: "Helper verbs, who to call Pak or Mbak, and the little particles that soften everything.",
        accent: .kopi,
        symbol: "bubble.left.and.text.bubble.right.fill",
        lessons: [lesson71, lesson72, lesson73, lesson74]
    )

    static let lesson71 = Lesson(
        id: "7.1",
        title: "Helper words",
        subtitle: "mau, bisa, boleh, harus",
        symbol: "wand.and.stars",
        steps: [
            .learn(
                "Helpers sit before the verb",
                "mau (want / going to), bisa (can, able), boleh (may, allowed), harus (must), perlu (need). The verb after them never changes.",
                pattern: "Saya/S mau/H pesan/V kopi/O",
                examples: [
                    Example("Saya mau pesan kopi", "I'd like to order a coffee"),
                    Example("Bisa pelan-pelan?", "Could you go slowly?"),
                    Example("Boleh saya duduk di sini?", "May I sit here?"),
                    Example("Saya harus pergi", "I have to go")
                ]
            ),
            .pick(
                "Someone is speaking too fast. Ask them to slow down:",
                ["Bisa pelan-pelan?", "Harus pelan-pelan?", "Mau pelan-pelan?"],
                answer: "Bisa pelan-pelan?",
                why: "bisa asks whether they can. harus would be ordering them to."
            ),
            .arrange(
                "May I sit here?",
                "Boleh saya duduk di sini?",
                alt: ["Boleh duduk di sini?", "Boleh saya duduk di sini"],
                extras: ["harus", "tidak"],
                why: "boleh asks permission and opens the sentence."
            ),
            .learn(
                "Register: saya or aku",
                "saya and Anda are the safe pair for strangers and anyone older. aku and kamu are for friends, and using them too early feels forward.",
                examples: [
                    Example("Saya mau pesan", "I'd like to order", note: "safe anywhere"),
                    Example("Aku mau pesan", "I wanna order", note: "friends only"),
                    Example("Anda", "you", note: "formal, a little distant"),
                    Example("kamu", "you", note: "friends, children")
                ]
            ),
            .learn(
                "What to call people",
                "Pak and Bu for adults you're being respectful to; Mas and Mbak for younger men and women, especially staff; in Bali, Bli and Mbok; Kak is what drivers and shop staff will call you.",
                examples: [
                    Example("Pak / Bu", "sir / ma'am"),
                    Example("Mas / Mbak", "young man / young woman", note: "Javanese, used nationwide"),
                    Example("Bli / Mbok", "brother / sister", note: "Balinese"),
                    Example("Terima kasih, Pak", "Thank you, sir")
                ]
            ),
            .hear(
                "Boleh saya lihat?",
                ["May I have a look?", "Do you want to see?", "I have to look"],
                answer: "May I have a look?",
                why: "boleh = may, lihat = to look. Perfect in any shop."
            ),
            .arrange(
                "I need help",
                "Saya perlu bantuan",
                alt: ["Saya butuh bantuan", "Perlu bantuan"],
                extras: ["mau", "boleh"],
                why: "perlu or butuh = need; bantuan = help."
            )
        ]
    )

    static let lesson72 = Lesson(
        id: "7.2",
        title: "Particles & short forms",
        subtitle: "ya, dong, banget, aja",
        symbol: "sparkles",
        steps: [
            .learn(
                "The little words at the end",
                "Particles carry the tone. ya softens into a please, dong nudges, kok questions gently, sih asks \"but why\", deh gives in.",
                examples: [
                    Example("Satu aja, ya", "Just one, please"),
                    Example("Pelan-pelan dong", "Come on, slow down"),
                    Example("Kok mahal?", "Why so expensive?"),
                    Example("Kenapa sih?", "What's the matter?"),
                    Example("Oke deh", "Fine then")
                ]
            ),
            .learn(
                "Everyday short forms",
                "udah (sudah), gak (tidak), aja (saja — just), banget (very), gimana (bagaimana). These are what you'll hear all day.",
                examples: [
                    Example("Udah, makasih", "Already done, thanks"),
                    Example("Enak banget!", "So good!"),
                    Example("Satu aja", "Just one"),
                    Example("Gimana?", "How is it? / What do you think?")
                ]
            ),
            .pick(
                "The food is delicious. Say it the way a local would:",
                ["Enak banget!", "Enak sekali sangat!", "Banget enak!"],
                answer: "Enak banget!",
                why: "banget follows the adjective. sekali also works but sounds more careful."
            ),
            .arrange(
                "Just one, please",
                "Satu aja, ya",
                alt: ["Satu saja ya", "Satu aja ya"],
                extras: ["banget", "dong"],
                why: "aja = just, and ya turns it into a request rather than an order."
            ),
            .hear(
                "Gimana?",
                ["How is it?", "How many?", "Who is it?"],
                answer: "How is it?",
                why: "Casual bagaimana. Asked about food, plans, anything."
            ),
            .pick(
                "Which sounds friendliest when asking for the bill?",
                ["Minta bon, ya", "Bon!", "Saya harus bon"],
                answer: "Minta bon, ya",
                why: "minta = may I have, and ya softens it. Bare commands sound sharp."
            ),
            .arrange(
                "The traffic is really bad",
                "Macetnya parah banget",
                alt: ["Macet banget", "Macetnya parah"],
                extras: ["enak", "aja"],
                why: "macet = traffic jam, parah = severe, banget = really. A daily complaint."
            )
        ]
    )

    static let lesson73 = Lesson(
        id: "7.3",
        title: "Reactions",
        subtitle: "Wah! Aduh! Masa? Mantap!",
        symbol: "exclamationmark.bubble.fill",
        steps: [
            .learn(
                "Little words that do a lot",
                "These short reactions make you sound like you're really listening. They're casual, so use them with friends, drivers and sellers rather than in a bank.",
                examples: [
                    Example("Wah!", "Wow!", note: "surprise or admiration"),
                    Example("Aduh!", "Ouch! / Oh no!"),
                    Example("Masa?", "Really? No way!"),
                    Example("Mantap!", "Great! Nice one!")
                ]
            ),
            .pick(
                "You stub your toe on a step. You say:",
                ["Aduh!", "Mantap!", "Masa?"],
                answer: "Aduh!",
                why: "aduh is pain, dismay or mild frustration."
            ),
            .pick(
                "A friend says the beach is empty today. You can't believe it:",
                ["Masa?", "Aduh!", "Sama-sama"],
                answer: "Masa?",
                why: "masa? = really? as in \"I find that hard to believe\"."
            ),
            .learn(
                "Sympathy and agreement",
                "kasihan is the go-to for sympathy. betul and bener agree. Asyik is \"fun, cool\".",
                examples: [
                    Example("Kasihan!", "Oh, poor thing!"),
                    Example("Betul, betul", "True, so true"),
                    Example("Asyik!", "Fun! Cool!"),
                    Example("Serius?", "Seriously?")
                ]
            ),
            .hear(
                "Wah, mantap!",
                ["Wow, great!", "Oh no, that hurts!", "Really? No way!"],
                answer: "Wow, great!",
                why: "wah (wow) + mantap (great). The perfect reply to good news."
            ),
            .arrange(
                "Wow, delicious!",
                "Wah, enak!",
                alt: ["Wah enak!", "Wah, enak banget!"],
                extras: ["aduh", "masa"],
                why: "wah for happy surprise. Every cook loves hearing it."
            ),
            .pick(
                "Your driver tells you his scooter broke down yesterday:",
                ["Kasihan, Pak", "Mantap, Pak", "Asyik, Pak"],
                answer: "Kasihan, Pak",
                why: "kasihan shows sympathy. The others celebrate."
            )
        ]
    )

    static let lesson74 = Lesson(
        id: "7.4",
        title: "Small talk",
        subtitle: "Sudah lama di Bali?",
        symbol: "person.2.wave.2.fill",
        steps: [
            .learn(
                "The questions you'll be asked",
                "Indonesians are warmly curious. Expect the same few questions from every driver and neighbour. Having your answers ready makes these chats easy.",
                examples: [
                    Example("Sudah lama di Bali?", "Have you been in Bali long?"),
                    Example("Kerja apa?", "What do you do?"),
                    Example("Sudah menikah?", "Are you married?"),
                    Example("Sudah punya anak?", "Do you have kids?")
                ]
            ),
            .pick(
                "\"Sudah lama di Bali?\" You arrived two weeks ago:",
                ["Baru dua minggu", "Dua minggu lalu", "Sudah dua minggu lagi"],
                answer: "Baru dua minggu",
                why: "baru = only just. \"Only two weeks\" answers \"long?\"."
            ),
            .learn(
                "Answering about yourself",
                "Keep answers short and ask one back. Personal questions are friendly here, not nosy, and a smile with belum always works.",
                pattern: "Saya/S kerja/V di_kantor/O",
                examples: [
                    Example("Saya kerja online", "I work online"),
                    Example("Saya guru", "I'm a teacher"),
                    Example("Belum, masih single", "Not yet, still single"),
                    Example("Sudah, anak saya dua", "Yes, I have two kids")
                ]
            ),
            .arrange(
                "I'm a teacher",
                "Saya guru",
                alt: ["Saya seorang guru"],
                extras: ["adalah", "kerja"],
                why: "No \"am\" needed. adalah would sound like a form."
            ),
            .hear(
                "Sudah berapa lama di sini?",
                ["How long have you been here?", "How long will you stay?", "When did you leave?"],
                answer: "How long have you been here?",
                why: "sudah + berapa lama = how long so far."
            ),
            .arrange(
                "I work online",
                "Saya kerja online",
                alt: ["Saya bekerja online"],
                extras: ["di", "apa"],
                why: "kerja is the everyday verb; bekerja is more formal."
            ),
            .pick(
                "Turn the question back to them, casually:",
                ["Kalau kamu?", "Untuk kamu?", "Dari kamu?"],
                answer: "Kalau kamu?",
                why: "kalau kamu? = and you? The easiest way to keep a chat going."
            )
        ]
    )
}
