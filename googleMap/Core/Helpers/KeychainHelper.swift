//
//  KeychainHelper.swift
//  googleMap
//
//  Created by Ke4a on 13.12.2022.
//

import Foundation
import KeychainSwift
import RealmSwift

enum KeychainKey: String {
    case logins
    case passwords
}

final class KeychainHelper {
    private lazy var keychain = KeychainSwift()

    /// Get data by key.
    /// - Parameter key: The data to be obtained.
    /// - Returns: Json of data.
    func get(key: KeychainKey) -> [String: String]? {
        do {
            guard let data = keychain.get(key.rawValue)?.data(using: .utf8),
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: String] else { return nil }
            return json
        } catch {
            print(error)
            return nil
        }
    }

    /// Writing data into the keychain by key.
    /// - Parameters:
    ///   - value: Json of data.
    ///   - key: The data to be recorded.
    func set(_ value: [String: String], key: KeychainKey) {
        do {
            let theJSONData = try JSONSerialization.data(withJSONObject: value)
            guard let theJSONText = String(data: theJSONData, encoding: .utf8) else { return }
            keychain.set(theJSONText, forKey: key.rawValue)
        } catch {
            print(error)
        }
    }
}
