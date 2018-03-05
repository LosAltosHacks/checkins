//
//  Secrets.swift
//  Checkins
//
//  Created by Dan Appel on 1/24/18.
//  Copyright © 2018 Los Altos Hacks. All rights reserved.
//

import Foundation

struct Secrets: Codable {
    static let global: Secrets! = {
        guard
            let url = Bundle.main.url(forResource: "secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let secrets = try? PropertyListDecoder().decode(Secrets.self, from: data)
        else { return nil }

        return secrets
    }()

    let airtableApiKey: String
    let airtableAppId: String
    let developerAttendeeCode: String
}
