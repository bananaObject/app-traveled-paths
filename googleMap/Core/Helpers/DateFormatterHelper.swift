//
//  DateFormatterHelper.swift
//  googleMap
//
//  Created by Ke4a on 12.12.2022.
//

import Foundation

class DateFormatterHelper {
    // MARK: - Private Properties
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
        formatter.locale = Locale.current
        return formatter
    }()

    private var dateTextCache: [Double: String] = [:]

    // MARK: - Static Properties
    static var shared = DateFormatterHelper()

    private init() {}

    // MARK: - Public Methods
    func convert(_ date: Double) -> String {
        if let dateResult = dateTextCache[date] {
            return dateResult
        } else {
            let dateTime = Date(timeIntervalSince1970: date)
            let stringDate = dateFormatter.string(from: dateTime)
            dateTextCache[date] = stringDate
            return stringDate
        }
    }
}
