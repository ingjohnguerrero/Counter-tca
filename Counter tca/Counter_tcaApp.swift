//
//  Counter_tcaApp.swift
//  Counter tca
//
//  Created by John Guerrero on 7/15/25.
//

import ComposableArchitecture
import SwiftUI

@main
struct Counter_tcaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: CounterFeature.State(), reducer: {
                    CounterFeature()
                })
            )
        }
    }
}
