import FuzzySets

public struct TriangularFuzzyNumber {
    
    public typealias Universe = Double
    
    public let minimum: Universe
    public let peak: Universe
    public let maximum: Universe
    
    internal let function: MembershipFunction<Universe>
    
    public init(minimum: Universe, peak: Universe, maximum: Universe) {
        self.minimum = minimum
        self.peak = peak
        self.maximum = maximum
        self.function =  minimum == peak && peak == maximum
            ? .fuzzySingleton(peak)
            : .triangular(minimum: minimum, peak: peak, maximum: maximum)
    }
    
    public init(peak: Universe, leftInterval: Universe, rightInterval: Universe) {
        self.minimum = peak - leftInterval
        self.peak = peak
        self.maximum = peak + rightInterval
        self.function =  minimum == peak && peak == maximum
            ? .fuzzySingleton(peak)
            : .triangular(minimum: minimum, peak: peak, maximum: maximum)
    }
}

extension TriangularFuzzyNumber: FuzzySet {
    public func grade(forElement element: Universe) -> Grade {
        function(element)
    }
}

extension TriangularFuzzyNumber {
    public static func + (lhs: TriangularFuzzyNumber, rhs: TriangularFuzzyNumber) -> TriangularFuzzyNumber {
        .init(
            minimum: lhs.minimum + rhs.minimum,
            peak: lhs.peak + rhs.peak,
            maximum: lhs.maximum + rhs.maximum
        )
    }
    
    public static func - (lhs: TriangularFuzzyNumber, rhs: TriangularFuzzyNumber) -> TriangularFuzzyNumber {
        .init(
            minimum: lhs.minimum - rhs.maximum,
            peak: lhs.peak - rhs.peak,
            maximum: lhs.maximum - rhs.minimum
        )
    }
    
    prefix public static func - (x: TriangularFuzzyNumber) -> TriangularFuzzyNumber {
        .init(minimum: -x.maximum, peak: -x.peak, maximum: -x.minimum)
    }
    
    public func alphaCut(_ alpha: Grade) -> TriangularFuzzyNumber {
        .init(
            minimum: (peak - minimum) * alpha + minimum,
            peak: peak,
            maximum: -(maximum - peak) * alpha + maximum
        )
    }
    
    public func approximatelyMultiplied(by other: TriangularFuzzyNumber) -> TriangularFuzzyNumber {
        let selfAlpha0 = self.alphaCut(0)
        let otherAlpha0 = other.alphaCut(0)
        let newMinimum = selfAlpha0.minimum * otherAlpha0.minimum
        let newMaximum = selfAlpha0.maximum * otherAlpha0.maximum
        let newPeak = alphaCut(1).minimum * other.alphaCut(1).minimum
        return .init(minimum: newMinimum, peak: newPeak, maximum: newMaximum)
    }

    public func approximatelyDivided(by other: TriangularFuzzyNumber) -> TriangularFuzzyNumber {
        let selfAlpha0 = self.alphaCut(0)
        let otherAlpha0 = other.alphaCut(0)
        let newMinimum = selfAlpha0.minimum / otherAlpha0.maximum
        let newMaximum = selfAlpha0.maximum / otherAlpha0.minimum
        let newPeak = alphaCut(1).minimum / other.alphaCut(1).maximum
        return .init(minimum: newMinimum, peak: newPeak, maximum: newMaximum)
    }
}

extension  TriangularFuzzyNumber: AnyFuzzySetRepresentable {
    public func eraseToAnyFuzzySet() -> AnyFuzzySet<Universe> {
        .init(membershipFunction: function)
    }
}

extension TriangularFuzzyNumber: Equatable {
    public static func == (lhs: TriangularFuzzyNumber, rhs: TriangularFuzzyNumber) -> Bool {
        lhs.minimum == rhs.minimum && lhs.peak == rhs.peak && lhs.maximum == rhs.maximum
    }
}
