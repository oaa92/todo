//
//  PeriodType.swift
//  todo
//
//  Created by Анатолий on 29/02/2020.
//  Copyright © 2020 Anatoliy Odinetskiy. All rights reserved.
//

import Foundation

enum PeriodType: Equatable {
    case none
    case daily
    case weekly(weekdays: [Int]?)
    case monthly
    case annually

    var name: String {
        switch self {
        case .none:
            return "none"
        case .daily:
            return "daily"
        case .weekly:
            return "weekly"
        case .monthly:
            return "monthly"
        case .annually:
            return "annually"
        }
    }

    var rawValue: Int {
        switch self {
        case .none:
            return 0
        case .daily:
            return 1
        case .weekly:
            return 2
        case .monthly:
            return 3
        case .annually:
            return 4
        }
    }
}

extension PeriodType: Codable {
    enum CodingKeys: CodingKey {
        case rawValue
        case associatedValue
    }

    enum CodingError: Error {
        case unknownValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .none
        case 1:
            self = .daily
        case 2:
            let weekdays = try container.decodeIfPresent([Int].self, forKey: .associatedValue)
            self = .weekly(weekdays: weekdays)
        case 3:
            self = .monthly
        case 4:
            self = .annually
        default:
            throw CodingError.unknownValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rawValue, forKey: .rawValue)
        if case let .weekly(weekdays) = self {
            try container.encode(weekdays, forKey: .associatedValue)
        }
    }
}
