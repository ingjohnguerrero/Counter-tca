//
//  NumberFactClient.swift
//  Counter tca
//
//  Created by John Guerrero on 7/17/25.
//

import Dependencies
import Foundation

struct NumberFactClient {
    var fetch: @Sendable (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    static let liveValue = Self(
        fetch: { number in
            let (data, _) = try await URLSession.shared.data(
                from: URL(string: "http://www.numbersapi.com/\(number)")!
            )

            return String(decoding: data, as: UTF8.self)
        }
    )
}

extension DependencyValues {
    var numberFact: NumberFactClient {
        get {
            self[NumberFactClient.self]
        }
        set {
            self[NumberFactClient.self] = newValue
        }
    }
}
