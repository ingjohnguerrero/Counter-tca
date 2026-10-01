//
//  CounterFeatureTests.swift
//  Counter tca
//
//  Created by John Guerrero on 7/16/25.
//

import XCTest
import ComposableArchitecture
@testable import Counter_tca

@MainActor
final class CounterFeatureTests: XCTestCase {

    var store: TestStore<CounterFeature.State, CounterFeature.Action>!
    override func setUp() async throws {
        store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }
    }

    func testCounter() async {
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
    }

    func testTimerToggle() async throws {
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerOn = true
        }
    }

    func testTimerUpdatesCounterwhenTapped() async {
        let clock = TestClock()
        store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerOn = true
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.count = 1
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.count = 2
        }
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerOn = false
        }
    }

    func testGetFact() async {
        store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: { store in
            store.continuousClock = ImmediateClock()
            store.numberFact.fetch = { "\($0) is a great number!" }
        }
        await store.send(.getFactButtonTapped) {
            $0.isLoadingFact = true
        }
        await store.receive(
            .factResponse("0 is a great number!")
        ) {
            $0.isLoadingFact = false
            $0.fact = "0 is a great number!"
        }
    }

    func testGetFact_Failure() async {
        let store = TestStore(
            initialState: CounterFeature.State()
        ) {
            CounterFeature()
        } withDependencies: {
            $0.numberFact.fetch = { _ in
                struct SomeError: Error {}
                throw SomeError()
            }
        }
    }
}
