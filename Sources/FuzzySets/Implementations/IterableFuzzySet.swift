public struct IterableFuzzySet<Universe, S: Sequence> where S.Element == Universe {
    
    public struct Element {
        public let element: Universe
        public let grade: Grade
        
        public init(element: Universe, grade: Grade) {
            self.element = element
            self.grade = grade
        }
    }
    
    public typealias Iterator = Array<Element>.Iterator
    
    public let sequence: S
    internal let function: MembershipFunction<Universe>
    
    public init(_ sequence: S, membershipFunction: MembershipFunction<Universe>) {
        self.sequence = sequence
        self.function = membershipFunction
    }
    
    public init(_ sequence: S, membershipFunction: @escaping MembershipFunction<Universe>.FunctionType) {
        self.sequence = sequence
        self.function = .init(membershipFunction)
    }
}

public extension IterableFuzzySet where Universe: CaseIterable, S == Universe.AllCases {
    init(membershipFunction: MembershipFunction<Universe>) {
        self.sequence = Universe.allCases
        self.function = membershipFunction
    }
    
    init(membershipFunction: @escaping MembershipFunction<Universe>.FunctionType) {
        self.sequence = Universe.allCases
        self.function = .init(membershipFunction)
    }
}

// MARK: - Fuzzy set

extension IterableFuzzySet: FuzzySet {
    public func grade(forElement element: Universe) -> Grade {
        function(element)
    }
}

// MARK: - Fuzzy set operations

extension IterableFuzzySet: FuzzySetOperations {
    
    public func alphaCut(_ alpha: Grade) -> Self {
        .init(sequence) {
            Swift.max(function($0), alpha)
        }
    }
    
    public func complement(method: ComplementFunction = .standard) -> Self {
        .init(sequence) {
            method.function(function($0))
        }
    }
    
    public func intersection(_ other: Self, method: TNormFunction = .minimum) -> Self {
        .init(sequence) {
            method.function(function($0), other.function($0))
        }
    }
    
    public func union(_ other: Self, method: SNormFunction = .maximum) -> Self {
        .init(sequence) {
            method.function(function($0), other.function($0))
        }
    }
    
    public func difference(_ other: Self, method: DifferenceFunction = .tNormAndComplement(.minimum, .standard)) -> Self {
        .init(sequence) {
            method.function(function($0), other.function($0))
        }
    }
    
    public func symmetricDifference(_ other: Self, method: SymmetricDifferenceFunction = .absoluteValue) -> Self {
        .init(sequence) {
            method.function(function($0), other.function($0))
        }
    }
    
    public func power(_ n: Double) -> Self {
        .init(sequence) {
            Double.pow(function($0), n)
        }
    }
    
    public func appliedCustomFunction(_ function: @escaping (Grade) -> Grade) -> IterableFuzzySet<Universe, S> {
        .init(sequence) {
            function(self.function($0))
        }
    }
}

// MARK: - Sequence

extension IterableFuzzySet: Sequence {
    public func makeIterator() -> Iterator {
        sequence
            .map { .init(
                element: $0,
                grade: grade(forElement: $0)
            )}
            .makeIterator()
    }
}

// MARK: - Convertions

public extension AnyFuzzySet {
    func makeIterable<S: Sequence>(over sequence: S) -> IterableFuzzySet<Universe, S> {
        .init(sequence, membershipFunction: membershipFunction)
    }
}

public extension AnyFuzzySet where Universe: CaseIterable {
    func makeIterable() -> IterableFuzzySet<Universe, Universe.AllCases> {
        .init(Universe.allCases, membershipFunction: membershipFunction)
    }
}

public extension DiscreteMutableFuzzySet {
    func makeIterable() -> IterableFuzzySet<Universe, Dictionary<Universe, Grade>.Keys> {
        .init(grades.keys, membershipFunction: .fromDictionary(grades))
    }
    
    func makeIterable<S: Sequence>(over sequence: S) -> IterableFuzzySet<Universe, S> {
        .init(sequence, membershipFunction: .init { self[$0] })
    }
}

public extension DiscreteMutableFuzzySet where Universe: CaseIterable {
    func makeIterable() -> IterableFuzzySet<Universe, Universe.AllCases> {
        .init(Universe.allCases, membershipFunction: .fromDictionary(grades))
    }
}

// MARK: - Properties

public extension IterableFuzzySet {
    var height: Grade {
        sequence.map(grade(forElement:)).max() ?? 0
    }
    
    var isNormal: Bool {
        sequence.map(grade(forElement:)).contains { $0 == 1 }
    }
}

public extension IterableFuzzySet where Universe: Hashable {
    var support: Set<Universe> {
        let elements = self
            .filter { $0.grade > 0 }
            .map { $0.element }
        return Set(elements)
    }
    
    var core: Set<Universe> {
        let elements = self
            .filter { $0.grade == 1 }
            .map { $0.element }
        return Set(elements)
    }
}

// MARK: - From crisp set

public extension IterableFuzzySet where S == Set<Universe> {
    static func fromCrispSet(_ set: S) -> Self {
        .init(set, membershipFunction: .fromCrispSet(set))
    }
}

// MARK: - Utility

public extension IterableFuzzySet where Universe: Equatable, S == Array<Universe> {
    static func singleton(_ u: Universe) -> Self {
        .init([u], membershipFunction: .fuzzySingleton(u))
    }
}

// Some workaround for https://forums.swift.org/t/tuples-conform-to-equatable/32559/74
public extension IterableFuzzySet {
    static func singleton<A: Equatable, B: Equatable>(_ u: (A, B)) -> Self where S == Array<(A, B)> {
        .init([u]) {
            $0.0 == u.0 && $0.1 == u.1 ? 1 : 0
        }
    }
}

extension IterableFuzzySet.Element: Equatable where Universe: Equatable {}
extension IterableFuzzySet.Element: Hashable where Universe: Hashable {}
extension IterableFuzzySet.Element: Encodable where Universe: Encodable {}
extension IterableFuzzySet.Element: Decodable where Universe: Decodable {}
