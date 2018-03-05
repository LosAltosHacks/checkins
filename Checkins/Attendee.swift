//
//  Attendee.swift
//  Checkins
//
//  Created by Dan Appel on 1/26/18.
//  Copyright © 2018 Los Altos Hacks. All rights reserved.
//

struct Attendee: Codable {
    enum ResponseCodingKeys: String, CodingKey {
        case id
        case createdTime
        case attendee = "fields"
    }
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case firstName = "First Name"
        case lastName = "Last Name"
        case email = "Email"
        case age = "Age"
        case highSchool = "High School"
        case guardianName = "Guardian/Parent Name"
        case guardianEmail = "Guardian/Parent Email"
        case phoneNumber = "Phone Number"
        case grade = "Grade"
        case gender = "Gender"
        case tshirtSize = "T-shirt Size"
        case dietaryRestrictions = "Dietary Restrictions"
        case checkedIn = "Checked In"
        case checkins = "Check-Ins"
    }

    struct Barcode: Codable {
        let text: String
    }

    struct Checkin: Codable, RawRepresentable, Hashable {
        var rawValue: String

        var hashValue: Int {
            return rawValue.hashValue
        }
        static func ==(lhs: Checkin, rhs: Checkin) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }

    let id: String
    let createdTime: String
    let code: Barcode
    var firstName: String?
    var lastName: String?
    var email: String?
    var age: Int?
    var highSchool: String?
    var guardianName: String?
    var guardianEmail: String?
    var phoneNumber: String?
    var grade: String?
    var gender: String?
    var tshirtSize: String?
    var dietaryRestrictions: String?
    var checkedIn: Bool
    var checkins: [Checkin] = []
}

extension Attendee {
    init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: ResponseCodingKeys.self)
        let attendee = try response.nestedContainer(keyedBy: CodingKeys.self, forKey: .attendee)
        try self.init(
            id: response.decode(String.self, forKey: .id),
            createdTime: response.decode(String.self, forKey: .createdTime),
            code: attendee.decode(Barcode.self, forKey: .code),
            firstName: attendee.decodeIfPresent(String.self, forKey: .firstName),
            lastName: attendee.decodeIfPresent(String.self, forKey: .lastName),
            email: attendee.decodeIfPresent(String.self, forKey: .email),
            age: attendee.decodeIfPresent(Int.self, forKey: .age),
            highSchool: attendee.decodeIfPresent(String.self, forKey: .highSchool),
            guardianName: attendee.decodeIfPresent(String.self, forKey: .guardianName),
            guardianEmail: attendee.decodeIfPresent(String.self, forKey: .guardianEmail),
            phoneNumber: attendee.decodeIfPresent(String.self, forKey: .phoneNumber),
            grade: attendee.decodeIfPresent(String.self, forKey: .grade),
            gender: attendee.decodeIfPresent(String.self, forKey: .gender),
            tshirtSize: attendee.decodeIfPresent(String.self, forKey: .tshirtSize),
            dietaryRestrictions: attendee.decodeIfPresent(String.self, forKey: .dietaryRestrictions),
            checkedIn: attendee.decodeIfPresent(Bool.self, forKey: .checkedIn) ?? false,
            checkins: attendee.decodeIfPresent([Checkin].self, forKey: .checkins) ?? []
        )
    }
}

extension Attendee.Checkin {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    init(from decoder: Decoder) throws {
        self.rawValue = try decoder.singleValueContainer().decode(String.self)
    }
}
