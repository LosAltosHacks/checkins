//
//  LoadingViewController.swift
//  Checkins
//
//  Created by Dan Appel on 3/5/18.
//  Copyright © 2018 Los Altos Hacks. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    static let showScanSegue = "showScan"

    override func viewDidLoad() {
        super.viewDidLoad()

        Airtable.attendee(code: Secrets.global.developerAttendeeCode) { [weak self] attendee in
            guard let sself = self else { return }
            guard let attendee = attendee else { return sself.alert(message: "Failed to load checkin values") }

            sself.performSegue(withIdentifier: LoadingViewController.showScanSegue, sender: attendee)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case LoadingViewController.showScanSegue:
            let scanViewController = segue.destination as! ScanViewController
            let attendee = sender as! Attendee
            // inject the possible checkin values
            scanViewController.checkinValues = attendee.checkins
        default:
            return
        }
    }
}
