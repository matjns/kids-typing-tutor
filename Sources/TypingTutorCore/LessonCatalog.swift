import Foundation

public enum LessonCatalog {
    public static let all: [Lesson] = makeAll()

    public static func lesson(id: String) -> Lesson? {
        all.first { $0.id == id }
    }

    public static func lessons(in stage: Stage) -> [Lesson] {
        all.filter { $0.stage == stage }
    }

    public static func next(after id: String) -> Lesson? {
        guard let index = all.firstIndex(where: { $0.id == id }), index + 1 < all.count else {
            return nil
        }
        return all[index + 1]
    }

    public static func previous(before id: String) -> Lesson? {
        guard let index = all.firstIndex(where: { $0.id == id }), index > 0 else {
            return nil
        }
        return all[index - 1]
    }

    private static func makeAll() -> [Lesson] {
        let homeFJ = "fj"
        let homeDK = "fjdk"
        let homeSL = "fjdksl"
        let homeA = "fjdksla;"
        let home = "asdfghjkl;"
        let topRU = home + "ru"
        let topEI = topRU + "ei"
        let topWO = topEI + "wo"
        let topTY = topWO + "ty"
        let top = topTY + "qp"
        let botVN = top + "vn"
        let botCM = botVN + "cm"
        let botBX = botCM + "bx"
        let letters = botBX + "z"
        let homeCaps = "ASDFGHJKL"
        let otherCaps = "QWERTYUIOPZXCVBNM"
        let capitals = homeCaps + otherCaps
        let shiftHome = home + homeCaps
        let shiftAll = letters + capitals
        let numLeft = shiftAll + "12345"
        let numAll = numLeft + "67890"
        let commaPeriod = numAll + ".,"
        let question = commaPeriod + "?"
        let exclaim = question + "!"
        let quotes = exclaim + "'\""

        return [
            make(
                "home-fj", .homeRow, "F and J bumps",
                "F and J have a little bump. Rest your index fingers on them.",
                new: homeFJ, allowed: homeFJ, mode: .drill, seconds: 60
            ),
            make(
                "home-dk", .homeRow, "D and K",
                "D is the next finger to the left. K is the next finger to the right.",
                new: "dk", allowed: homeDK, mode: .drill, seconds: 60
            ),
            make(
                "home-sl", .homeRow, "S and L",
                "S uses the left ring finger. L uses the right ring finger.",
                new: "sl", allowed: homeSL, mode: .drill, seconds: 60
            ),
            make(
                "home-a", .homeRow, "A and semicolon",
                "A is the left pinky. Semicolon is the right pinky.",
                new: "a;", allowed: homeA, mode: .drill, seconds: 60
            ),
            make(
                "home-gh", .homeRow, "G and H",
                "G and H sit in the middle. Reach in with your index fingers, then come home.",
                new: "gh", allowed: home, mode: .drill, seconds: 90
            ),
            make(
                "home-words", .homeRow, "Home row words",
                "Real words made only from the home row.",
                new: "", allowed: home, mode: .words, seconds: 120
            ),
            make(
                "top-ru", .topRow, "R and U",
                "Reach up from F to R, and from J to U.",
                new: "ru", allowed: topRU, mode: .drill, seconds: 60
            ),
            make(
                "top-ei", .topRow, "E and I",
                "E is above D. I is above K.",
                new: "ei", allowed: topEI, mode: .drill, seconds: 60
            ),
            make(
                "top-wo", .topRow, "W and O",
                "W is above S. O is above L.",
                new: "wo", allowed: topWO, mode: .drill, seconds: 60
            ),
            make(
                "top-ty", .topRow, "T and Y",
                "T and Y are a small reach from the index fingers.",
                new: "ty", allowed: topTY, mode: .drill, seconds: 60
            ),
            make(
                "top-qp", .topRow, "Q and P",
                "Q is the left pinky. P is the right pinky.",
                new: "qp", allowed: top, mode: .drill, seconds: 60
            ),
            make(
                "top-words", .topRow, "Top row words",
                "Words that mix the home row and the top row.",
                new: "", allowed: top, mode: .words, seconds: 120
            ),
            make(
                "bot-vn", .bottomRow, "V and N",
                "V is below F. N is below J.",
                new: "vn", allowed: botVN, mode: .drill, seconds: 60
            ),
            make(
                "bot-cm", .bottomRow, "C and M",
                "C is below D. M is beside N.",
                new: "cm", allowed: botCM, mode: .drill, seconds: 60
            ),
            make(
                "bot-bx", .bottomRow, "B and X",
                "B is a reach from the left index finger. X is below S.",
                new: "bx", allowed: botBX, mode: .drill, seconds: 60
            ),
            make(
                "bot-z", .bottomRow, "Z",
                "Z is the left pinky, down in the corner.",
                new: "z", allowed: letters, mode: .drill, seconds: 60
            ),
            make(
                "bot-words", .bottomRow, "Bottom row words",
                "Words that use the whole alphabet.",
                new: "", allowed: letters, mode: .words, seconds: 120
            ),
            make(
                "shift-home", .shift, "Capital letters",
                "Hold shift with the other pinky, then press the letter.",
                new: homeCaps, allowed: shiftHome, mode: .lines, seconds: 120,
                samples: [
                    "A sad lad had a flag",
                    "A glad lad had a salad",
                    "Ask a glad lad",
                    "Fall adds a glass",
                    "A lass had a flask"
                ]
            ),
            make(
                "shift-all", .shift, "Capitals everywhere",
                "Start each line with a capital. Keep the shift hand opposite the letter.",
                new: otherCaps, allowed: shiftAll, mode: .lines, seconds: 120,
                samples: [
                    "The red kite flew fast",
                    "A quiet dog sat by the water",
                    "Yellow flowers grow tall",
                    "The small fox dug a den",
                    "Please feed the fish"
                ]
            ),
            make(
                "num-left", .numbers, "Numbers 1 to 5",
                "The left hand covers 1 through 5. 1 is the pinky.",
                new: "12345", allowed: numLeft, mode: .lines, seconds: 90,
                samples: [
                    "1 2 3 4 5",
                    "2 red kites and 4 dogs",
                    "5 tall trees",
                    "1 star and 3 fish",
                    "4 flags"
                ]
            ),
            make(
                "num-right", .numbers, "Numbers 6 to 0",
                "The right hand covers 6 through 0.",
                new: "67890", allowed: numAll, mode: .lines, seconds: 90,
                samples: [
                    "6 7 8 9 0",
                    "8 ducks and 6 frogs",
                    "10 red boats",
                    "7 hats and 9 maps",
                    "6 big frogs"
                ]
            ),
            make(
                "num-mix", .numbers, "Numbers in a line",
                "Letters and numbers together. Stay slow and steady.",
                new: "", allowed: numAll, mode: .lines, seconds: 120,
                samples: [
                    "I see 4 red kites and 2 blue boats",
                    "Count 10 stars and 8 ducks",
                    "We saw 6 frogs and 7 fish",
                    "3 cakes and 0 soup left"
                ]
            ),
            make(
                "punct-stop", .punctuation, "Commas and periods",
                "Comma is beside M. Period is the next key. Both use the right hand.",
                new: ".,", allowed: commaPeriod, mode: .lines, seconds: 90,
                samples: [
                    "The cat sat, and the dog ran.",
                    "A small bird sang.",
                    "Feed the fish, then rest.",
                    "A glad lad had a salad, and a glass of water."
                ]
            ),
            make(
                "punct-question", .punctuation, "Question marks",
                "A question mark is shift and the slash key.",
                new: "?", allowed: question, mode: .lines, seconds: 90,
                samples: [
                    "Can you see the star?",
                    "Is the soup hot?",
                    "Where is the map?",
                    "Did the fox dig a den?"
                ]
            ),
            make(
                "punct-exclaim", .punctuation, "Exclamation marks",
                "An exclamation mark is shift and the 1 key.",
                new: "!", allowed: exclaim, mode: .lines, seconds: 90,
                samples: [
                    "Wow, the cake is ready!",
                    "Look at that kite!",
                    "Yes, the race is on!",
                    "The yellow flower grew so fast!"
                ]
            ),
            make(
                "punct-quotes", .punctuation, "Apostrophes and quotes",
                "Apostrophe is the key beside semicolon. Quote is shift and that same key.",
                new: "'\"", allowed: quotes, mode: .lines, seconds: 120,
                samples: [
                    "Don't drop the jar.",
                    "The sign says \"Slow\".",
                    "I can't wait to play.",
                    "It's a good day."
                ]
            ),
            make(
                "sentences-short", .sentences, "Short stories",
                "A few sentences in a row. Take your time.",
                new: "", allowed: quotes, mode: .lines, seconds: 120,
                samples: [
                    "The red kite flew past a tall tree.",
                    "A glad dog sat by the water.",
                    "Pack a snack and a map.",
                    "Seven ducks swim at the dock.",
                    "Stars glow after the sun goes down."
                ]
            ),
            make(
                "sentences-long", .sentences, "A longer note",
                "The longest practice. About three minutes if you go gently.",
                new: "", allowed: quotes, mode: .lines, seconds: 180,
                samples: [
                    "The brave mouse found a big piece of cheese. What a day!",
                    "Please hold the door. The bus stops at the corner.",
                    "Can the fox see the moon? Yes, the night is clear.",
                    "Don't drop the jar. Set it on the flat rock.",
                    "Count the boats. 1, 2, 3. The yellow one is last."
                ]
            )
        ]
    }

    private static func make(
        _ id: String,
        _ stage: Stage,
        _ title: String,
        _ blurb: String,
        new: String,
        allowed: String,
        mode: ExerciseMode,
        seconds: Int,
        samples: [String] = []
    ) -> Lesson {
        Lesson(
            id: id,
            stage: stage,
            title: title,
            blurb: blurb,
            newKeys: Array(new),
            allowedKeys: Array(allowed),
            mode: mode,
            suggestedSeconds: seconds,
            samples: samples
        )
    }
}
