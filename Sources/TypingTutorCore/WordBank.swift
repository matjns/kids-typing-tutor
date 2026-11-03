import Foundation

/// Original word lists. Every word is lowercase letters only.
public enum WordBank {
    public static let words: [String] = {
        let raw = """
        add all apple ask away back bag ball band barn bath bean bed bell best
        big bike bird bit blue boat book box brown bus cab cake call camp can
        cap car cat coat cold cook corn dance dark day den desk dig dish dock
        dog door dot down duck eat egg end fall farm fast feed feel fill find
        fish flag flash flask flat flow food foot fork fox free frog fruit fun
        gall game gate gift glad glass gold good green grew grow had half hall
        hand happy hard has hat help hen hill hold home hop hot ice jam jar jet
        job jog joy jump just keep key kind kite lake lamp land lap last late
        leaf left leg let lid like line lion list little lock log long look
        lost lot love make map mat milk mix moon mop more most mouse move much
        mud music must nap near nest net next night nose now off old open out
        over pack page pan park part path pen pet pie pig pin pink play please
        pond pool pop power pup purple quiet quiz rain read red rest ride ring
        river road rock room row rug run sad safe sail salad salt same sand sat
        see seed set ship shop sit sky slow small snow sock soft song soon soup
        star stay step stop sun swim take talk tall tap tea team tell ten the
        them then this time top toy tree trip try turn van very walk warm water
        wave way well went west wet what when will wind wish with wolf wood
        word work yard year yellow yes yet you zoo zoom alfalfa asks falls flags
        halls lass shall toad trail tower later quiet write story party type
        sight right light sail owl low row tire flower white hello today
        """
        let parts = raw.split(whereSeparator: \.isWhitespace).map(String.init)
        return Array(Set(parts)).sorted()
    }()

    public static func randomWord(
        allowed: Set<Character>,
        minimumLength: Int,
        maximumLength: Int,
        rng: inout SplitMix64
    ) -> String? {
        let pool = words.filter { word in
            word.count >= minimumLength
                && word.count <= maximumLength
                && word.allSatisfy { allowed.contains($0) }
        }
        guard !pool.isEmpty else { return nil }
        let index = Int.random(in: 0..<pool.count, using: &rng)
        return pool[index]
    }
}
