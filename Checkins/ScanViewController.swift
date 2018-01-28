//
//  ScanViewController.swift
//  Checkins
//
//  Created by Dan Appel on 1/24/18.
//  Copyright © 2018 Los Altos Hacks. All rights reserved.
//

import UIKit
import QRCodeReader

class ScanViewController: UIViewController {
    let reader: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }

        return QRCodeReaderViewController(builder: builder)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        reader.completionBlock = self.finishedScanning(result:)
        reader.modalPresentationStyle = .formSheet
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func startScan(_ sender: UIButton) {
        present(reader, animated: true, completion: nil)
    }

    func finishedScanning(result: QRCodeReaderResult?) {
        reader.dismiss(animated: true, completion: nil)

        guard let code = result?.value else {
            return
        }

        Airtable.attendee(code: code) { [weak self] attendee in
            guard let s = self else { return }
            guard let attendee = attendee else { return s.alert(message: "Error fetching attendee.") }
            s.found(attendee: attendee)
        }
    }

    func found(attendee: Attendee) {
        self.performSegue(withIdentifier: "showAttendee", sender: attendee)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showAttendee":
            let attendeeVC = segue.destination as! AttendeeViewController
            attendeeVC.attendee = sender as! Attendee
        default:
            break
        }
    }
}
