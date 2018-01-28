//
//  Airtable.swift
//  Checkins
//
//  Created by Dan Appel on 1/24/18.
//  Copyright © 2018 Los Altos Hacks. All rights reserved.
//

import Alamofire

class Airtable {
    static let appId = Secrets.global.airtableAppId
    static let apiKey = Secrets.global.airtableApiKey
    static let root = URL(string: "https://api.airtable.com/v0/\(appId)/Attendees")!

    class func attendee(code: String, completion: @escaping (Attendee?) -> ()) {
        var components = URLComponents(url: root, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "filterByFormula", value: "(CODE = '\(code)')"),
            .init(name: "api_key", value: apiKey)
        ]

        Alamofire.request(components.url!).responseJSON { data in
            print(data.result.value!)
            guard let jsonData = data.data else { return completion(nil) }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode([String:[Attendee]].self, from: jsonData)
                completion(response["records"]?.first)
            } catch let error {
                print(error)
                completion(nil)
            }
        }
    }

    class func updateCheckins(attendee: Attendee) {
        var request = try! URLRequest(
            url: root.appendingPathComponent(attendee.id),
            method: .patch,
            headers: [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(apiKey)"
            ]
        )
        let payload: [String:[String:[Attendee.Checkin]]] = [
            "fields": [
                "Check-Ins": attendee.checkins
            ]
        ]
        request.httpBody = try! JSONEncoder().encode(payload)

        Alamofire.request(request).responseJSON { data in
            print(data.result.value!)
        }
    }
}
