//
//  ScanViewController.swift
//  Checkins
//
//  Created by Dan Appel on 1/24/18.
//  Copyright © 2018 Los Altos Hacks. All rights reserved.
//

import UIKit
import QRCodeReader

enum CheckinMode {
    case checkin(Attendee.Checkin)
    case general
}

class ScanViewController: UIViewController {
    @IBOutlet weak var checkinSelect: MultiSelectSegmentedControl!

    let reader: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }

        return QRCodeReaderViewController(builder: builder)
    }()

    var checkinMode = CheckinMode.general {
        didSet {
            print(checkinMode)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        checkinSelect.delegate = self
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
        switch checkinMode {
        case .general:
            self.performSegue(withIdentifier: "showAttendee", sender: attendee)
        case let .checkin(checkin):
            //TODO: implement
            print(checkin)
        }
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

extension ScanViewController: MultiSelectSegmentedControlDelegate {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChangeValue value: Bool, at index: UInt) {
        switch value {
        case false:
            self.checkinMode = .general
        case true:
            // deselect all except this one
            multiSelectSegmentedControl.selectedSegmentIndexes = [numericCast(index)]
            let title = multiSelectSegmentedControl.titleForSegment(at: numericCast(index))!
            self.checkinMode = .checkin(Attendee.Checkin(rawValue: title)!)
        }
    }
}
