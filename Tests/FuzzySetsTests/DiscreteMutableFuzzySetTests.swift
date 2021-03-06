import XCTest
import FuzzySets

final class DiscreteMutableFuzzySetTests: XCTestCase {
    func test_defaultInit_allGradesAreZero() throws {
        let sut = DiscreteMutableFuzzySet<String>()
        
        let expected = [
            "a": 0.0,
            "b": 0.0,
            "c": 0.0,
        ]
        
        for (element, grade) in expected {
            assertExpectedGrade(element: element, expectedGrade: grade, sut: sut)
        }
    }
    
    func test_initWithParams_gradesAreCorrect() throws {
        let parameters = [
            "a": 0.69,
            "c": 1.0,
        ]
        
        let sut = DiscreteMutableFuzzySet(parameters)
        
        let expected = [
            "a": 0.69,
            "b": 0.0,
            "c": 1.0,
        ]
        
        for (element, grade) in expected {
            assertExpectedGrade(element: element, expectedGrade: grade, sut: sut)
        }
    }
    
    func test_stringRepr_noZeroes() {
        let parameters = [
            "a": 0.69,
            "b": 1,
        ]
        let sut = DiscreteMutableFuzzySet(parameters)
        let expected1 = "<FuzzySet: {0.69/a + 1.0/b}, other values == 0.0>"
        let expected2 = "<FuzzySet: {1.0/b + 0.69/a}, other values == 0.0>"
        
        let result = String(describing: sut)
        
        XCTAssert([expected1, expected2].contains(result))
    }
    
    func test_setGrade_gradesAreCorrect() throws {
        var sut1 = DiscreteMutableFuzzySet<String>()
        var sut2 = DiscreteMutableFuzzySet<String>()
        
        let expected = [
            "a": 0.69,
            "b": 0.0,
            "c": 1.0,
        ]
        
        for (element, grade) in expected {
            if grade == 0 { continue }
            sut1.setGrade(grade, forElement: element)
        }
        
        for (element, grade) in expected {
            if grade == 0 { continue }
            sut2[element] = grade
        }
        
        for (element, grade) in expected {
            assertExpectedGrade(element: element, expectedGrade: grade, sut: sut1)
            assertExpectedGrade(element: element, expectedGrade: grade, sut: sut2)
        }
    }
    
    func test_fuzzify_gradesAreCorrect() throws {
        let cs: Set<String> = ["a", "b", "c"]
        let expected = [
            "a": 1.0,
            "b": 1.0,
            "c": 1.0,
            "d": 0.0,
            " ": 0.0,
            "": 0.0,
        ]
        
        let sut = DiscreteMutableFuzzySet.fromCrispSet(cs)
        
        for (element, grade) in expected {
            assertExpectedGrade(element: element, expectedGrade: grade, sut: sut)
        }
    }
    
    func test_alphaCut_gradesAreCorrect() {
        let alpha = 0.5
        let initial = [
            "a": 1.0,
            "b": 0.88,
            "c": 0.69,
            "d": 0.42,
            "e": 0.001,
            "f": 0.0,
        ]
        let expected = [
            "a": 1.0,
            "b": 0.88,
            "c": 0.69,
            "d": 0.5,
            "e": 0.5,
            "f": 0.5,
        ]
        
        let set = DiscreteMutableFuzzySet(initial)
        var sut2 = DiscreteMutableFuzzySet(initial)
        
        let sut1 = set.alphaCut(alpha)
        sut2.applyAlphaCut(alpha)
        
        for (element, grade) in expected {
            assertExpectedGrade(element: element, expectedGrade: grade, sut: sut1)
            assertExpectedGrade(element: element, expectedGrade: grade, sut: sut2)
        }
    }
    
    func test_complement_gradesAreCorrect() {
        let initial = [
            "a": 1.0,
            "b": 0.88,
            "c": 0.69,
            "d": 0.42,
            "e": 0.001,
            "f": 0.0,
        ]
        let expected = [
            "a": 0.0,
            "b": 0.12,
            "c": 0.31,
            "d": 0.58,
            "e": 0.999,
            "f": 1.0,
        ]
        let set = DiscreteMutableFuzzySet(initial)
        
        let sut = set.complement()
        
        for (element, grade) in expected {
            assertExpectedGrade(element: element, expectedGrade: grade, sut: sut)
        }
    }
}
