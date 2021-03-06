//
//  RepeatedOperationTests.swift
//  Operations
//
//  Created by Daniel Thorpe on 30/12/2015.
//
//

import XCTest
@testable import Operations

class RandomFailGeneratorTests: XCTestCase {

    func test__failure_probability_distribution() {

        var generator = RandomFailGenerator(anyGenerator { true })

        let total = 1_000
        var failures = 0
        for _ in 0..<total {
            if let _ = generator.next() { }
            else {
                failures += 1
            }
        }

        let probabilityFailure = Double(failures) / Double(total)

        XCTAssertEqualWithAccuracy(probabilityFailure, 0.1, accuracy: 0.05)
    }
}

class FiniteGeneratorTests: XCTestCase {

    var generator: FiniteGenerator<AnyGenerator<Int>>!

    override func setUp() {
        super.setUp()
        generator = FiniteGenerator(anyGenerator(0.stride(to: 10, by: 1).generate()), limit: 2)
    }

    func test__limits_are_reached() {
        guard let _ = generator.next(), _ = generator.next() else {
            XCTFail("Should return values up to a limit.")
            return
        }

        if let _ = generator.next() {
            XCTFail("Should not return a value once the limit is reached.")
        }
    }
}

class WaitStrategyIntervalTests: XCTestCase {

    var strategy: WaitStrategy!
    var generator: IntervalGenerator!

    func getInterval(count: Int = 0) -> NSTimeInterval? {
        for _ in 0..<count {
            guard let _ = generator.next() else {
                XCTFail("IntervalGenerator never ends.")
                break
            }
        }
        return generator.next()
    }
}

class FixedWaitGeneratorTests: WaitStrategyIntervalTests {

    override func setUp() {
        super.setUp()
        strategy = .Fixed(1.0)
        generator = strategy.generator()
    }
    
    func test__next_interval() {
        guard let interval = getInterval() else {
            XCTFail("FixedWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 1)
    }
}

class RandomWaitGeneratorTests: WaitStrategyIntervalTests {

    override func setUp() {
        super.setUp()
        strategy = .Random((minimum: 1.0, maximum: 2.0))
        generator = strategy.generator()
    }

    func test__next_interval() {
        for _ in 0..<100 {
            guard let interval = generator.next() else {
                XCTFail("RandomWaitGenerator never ends.")
                return
            }
            XCTAssertGreaterThanOrEqual(interval, 1.0)
            XCTAssertLessThanOrEqual(interval, 2.0)
        }
    }
}

class IncrementingWaitGeneratorTests: WaitStrategyIntervalTests {

    override func setUp() {
        super.setUp()
        strategy = .Incrementing((initial: 1.0, increment: 1.0))
        generator = strategy.generator()
    }

    func test__next_interval() {
        for i in 0..<100 {
            guard let interval = generator.next() else {
                XCTFail("IncrementingWaitGenerator never ends.")
                return
            }
            XCTAssertEqual(interval, NSTimeInterval(i + 1))
        }
    }
}

class ExponentialWaitGeneratorTests: WaitStrategyIntervalTests {

    override func setUp() {
        super.setUp()
        strategy = .Exponential((period: 1, maximum: 20))
        generator = strategy.generator()
    }

    func test__next_0() {
        guard let interval = getInterval(0) else {
            XCTFail("ExponentialWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 1)
    }

    func test__next_1() {
        guard let interval = getInterval(1) else {
            XCTFail("ExponentialWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 2)
    }

    func test__next_2() {
        guard let interval = getInterval(2) else {
            XCTFail("ExponentialWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 4)
    }

    func test__next_3() {
        guard let interval = getInterval(3) else {
            XCTFail("ExponentialWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 8)
    }

    func test__next_4() {
        guard let interval = getInterval(4) else {
            XCTFail("ExponentialWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 16)
    }

    func test__next_5() {
        guard let interval = getInterval(5) else {
            XCTFail("ExponentialWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 20)
    }
}

class FibonacciWaitGeneratorTests: WaitStrategyIntervalTests {

    override func setUp() {
        super.setUp()
        strategy = .Fibonacci((period: 1, maximum: 10))
        generator = strategy.generator()
    }
    
    func test__next_0() {
        guard let interval = getInterval(0) else {
            XCTFail("FibonacciWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 0)
    }

    func test__next_1() {
        guard let interval = getInterval(1) else {
            XCTFail("FibonacciWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 1)
    }

    func test__next_2() {
        guard let interval = getInterval(2) else {
            XCTFail("FibonacciWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 1)
    }

    func test__next_3() {
        guard let interval = getInterval(3) else {
            XCTFail("FibonacciWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 2)
    }

    func test__next_4() {
        guard let interval = getInterval(4) else {
            XCTFail("FibonacciWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 3)
    }

    func test__next_5() {
        guard let interval = getInterval(5) else {
            XCTFail("FibonacciWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 5)
    }

    func test__next_6() {
        guard let interval = getInterval(6) else {
            XCTFail("FibonacciWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 8)
    }

    func test__next_7() {
        guard let interval = getInterval(7) else {
            XCTFail("FibonacciWaitGenerator never ends.")
            return
        }
        XCTAssertEqual(interval, 10) // max reached
    }
}

class RepeatedOperationTests: OperationTests {

    var operation: RepeatedOperation<TestOperation>!

    func test__custom_generator_with_delay() {
        operation = RepeatedOperation(maxCount: 2, generator: anyGenerator { (Delay.By(0.1), TestOperation() )})

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
        XCTAssertEqual(operation.count, 2)
        XCTAssertEqual(operation.aggregateErrors.count, 0)
    }

    func test__custom_generator_without_delay() {
        operation = RepeatedOperation(maxCount: 2, generator: anyGenerator { (.None, TestOperation() )})

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertTrue(operation.finished)
        XCTAssertEqual(operation.count, 2)
        XCTAssertEqual(operation.aggregateErrors.count, 0)
    }
}

class NonRepeatableRepeatedOperationTests: OperationTests {

    func createGenerator(succeedsAfterCount target: Int = 1) -> AnyGenerator<TestOperation> {
        var count = 0
        return anyGenerator { () -> TestOperation? in
            guard count < target else { return nil }
            defer { count += 1 }
            if count < target - 1 {
                return TestOperation(error: TestOperation.Error.SimulatedError)
            }
            else {
                return TestOperation()
            }
        }
    }

    func test__repeated_operation_repeats() {
        let operation = RepeatedOperation(generator: createGenerator(succeedsAfterCount: 5))

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertEqual(operation.count, 5)
        XCTAssertEqual(operation.aggregateErrors.count, 4)
    }

    func test__repeated_with_max_number_of_attempts() {
        let operation = RepeatedOperation(maxCount: 2, generator: createGenerator(succeedsAfterCount: 5))

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertEqual(operation.count, 2)
    }
}

class RepeatingTestOperation: TestOperation, Repeatable {

    func shouldRepeat(count: Int) -> Bool {
        return count < 5
    }
}

class RepeatableRepeatedOperationTests: OperationTests {

    func test__repeated_operation_repeats() {
        let operation = RepeatedOperation { return RepeatingTestOperation() }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertEqual(operation.count, 5)
    }

    func test__repeated_with_max_number_of_attempts() {
        let operation = RepeatedOperation(maxCount: 2) { return RepeatingTestOperation() }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertEqual(operation.count, 2)
    }

    func test__repeatable_operation() {

        var errors: [ErrorType] = []
        let operation = RepeatedOperation(maxCount: 10) {() -> RepeatableOperation<TestOperation> in

            let op = TestOperation(error: TestOperation.Error.SimulatedError)
            op.addObserver(FinishedObserver { _, e in
                errors.appendContentsOf(e)
            })

            return RepeatableOperation(op) { _ in errors.count < 3 }
        }

        addCompletionBlockToTestOperation(operation, withExpectation: expectationWithDescription("Test: \(__FUNCTION__)"))
        runOperation(operation)
        waitForExpectationsWithTimeout(3, handler: nil)

        XCTAssertEqual(operation.count, 3)
    }

    func test__repeatable_operation_cancels() {
        let op = TestOperation()
        let operation = RepeatableOperation(op) { _ in true }
        operation.cancel()
        XCTAssertTrue(operation.cancelled)
        XCTAssertTrue(op.cancelled)
    }
}
















