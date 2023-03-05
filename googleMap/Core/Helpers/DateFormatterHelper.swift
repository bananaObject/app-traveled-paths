//
//  DateFormatterHelper.swift
//  googleMap
//
//  Created by Ke4a on 12.12.2022.
//

import Foundation

final class DateFormatterHelper {
    // MARK: - Private Properties

    /// A formatter that converts between dates and their textual representations.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
        formatter.locale = Locale.current
        return formatter
    }()

    /// Dates cache.
    private var datesTextCache: [Double: String] = [:]

    // MARK: - Static Properties

    static var shared = DateFormatterHelper()

    private init() {}

    // MARK: - Public Methods

    /// Converts timeIntervalSince1970 to string.
    /// - Parameter date: timeIntervalSince1970
    /// - Returns: String like ""HH:mm:ss dd/MM/yyyyy"".
    func convertToString(_ date: Double) -> String {
        if let dateResult = datesTextCache[date] {
            return dateResult
        } else {
            let dateTime = Date(timeIntervalSince1970: date)
            let stringDate = dateFormatter.string(from: dateTime)
            datesTextCache[date] = stringDate
            return stringDate
        }
    }
}
