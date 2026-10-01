//
//  ContentView.swift
//  Counter tca
//
//  Created by John Guerrero on 7/15/25.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    let store: StoreOf<CounterFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) {viewStore in
            Form {
                Section {
                    Text("\(viewStore.count)")
                    Button("Decrement"){
                        viewStore.send(.decrementButtonTapped)
                    }
                    Button("Increment"){
                        viewStore.send(.incrementButtonTapped)
                    }
                }

                Section {
                    Button(){
                        viewStore.send(.getFactButtonTapped)
                    } label: {
                        HStack {
                            Text("Get Fact")
                            if viewStore.isLoadingFact {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    if let fact = viewStore.fact {
                        Text(fact)
                    }
                }

                Section {
                    if viewStore.isTimerOn {
                        Button("Stop time") {
                            viewStore.send(.toggleTimerButtonTapped)
                        }
                    } else {
                        Button("Start Timer") {
                            viewStore.send(.toggleTimerButtonTapped)
                        }
                    }
                }
            }
        }
    }
}

@Reducer
struct CounterFeature {
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isTimerOn = false
        var isLoadingFact = false
    }

    enum Action: Equatable {
        case decrementButtonTapped
        case getFactButtonTapped
        case incrementButtonTapped
        case toggleTimerButtonTapped
        case factResponse(String)
        case timerTicked
    }

    private enum CancelID { case timer }

    var body: some ReducerOf<Self> {
        @Dependency(\.numberFact) var numberFact
        Reduce { state, action in
            switch action {
                case .decrementButtonTapped:
                    state.count -= 1
                    state.fact = nil
                case .incrementButtonTapped:
                    state.count += 1
                    state.fact = nil
                case .toggleTimerButtonTapped:
                    state.isTimerOn.toggle()
                    if state.isTimerOn {
                        return .run { send in
                            while true {
                                try await Task.sleep(for: .seconds(1))
                                await send(.timerTicked)
                            }
                        }.cancellable(id: CancelID.timer)
                    } else {
                        return .cancel(id: CancelID.timer)
                    }
                case .timerTicked:
                    state.count += 1
                case .getFactButtonTapped:
                    state.fact = nil
                    state.isLoadingFact = true
                    return .run { [count = state.count] send in
                        try await send(.factResponse(numberFact.fetch(count)))
                    }
                case .factResponse(let fact):
                    state.fact = fact
                    state.isLoadingFact = false
            }
            return .none
        }
    }
}

#Preview {
    ContentView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()
                ._printChanges()
        }
    )
}
