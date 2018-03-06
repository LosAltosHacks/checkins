//
//  ScanViewController.swift
//  Checkins
//
//  Created by Dan Appel on 1/24/18.
//  Copyright © 2018 Los Altos Hacks. All rights reserved.
//

import UIKit
import QRCodeReader
import JGProgressHUD

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

    var checkinValues: [Attendee.Checkin]!

    override func viewDidLoad() {
        super.viewDidLoad()

        checkinSelect.delegate = self
        checkinSelect.removeAllSegments()
        for checkin in checkinValues.reversed() {
            checkinSelect.insertSegment(withTitle: checkin.rawValue, at: 0, animated: false)
        }
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
        reader.dismiss(animated: true) { [weak self] in
            guard let sself = self else { return }
            guard let code = result?.value else { return }

            sself.performCheckin(code: code)
        }
    }

    func performCheckin(code: String) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view, animated: true)

        Airtable.attendee(code: code) { [weak self] attendee in
            guard let s = self else { return }

            switch attendee {
            case .none:
                hud.textLabel.text = "Error fetching attendee"
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
                hud.dismiss(afterDelay: 1, animated: true)
            case let .some(attendee):
                hud.dismiss(animated: true)
                s.found(attendee: attendee)
            }
        }
    }

    func found(attendee: Attendee) {
        switch checkinMode {
        case .general:
            self.performSegue(withIdentifier: "showAttendee", sender: attendee)
        case let .checkin(checkin):
            self.checkIn(attendee: attendee, checkin: checkin)
        }
    }

    func checkIn(attendee: Attendee, checkin: Attendee.Checkin) {
        let nameString = "\(attendee.lastName ?? "N/A"), \(attendee.firstName ?? "N/A")"

        var attendee = attendee
        guard !attendee.checkins.contains(checkin) else {
            return self.alert(message: "(\(nameString)) already checked in for meal.")
        }
        attendee.checkins.append(checkin)

        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Loading"
        hud.detailTextLabel.text = nameString
        hud.show(in: self.view, animated: true)

        Airtable.updateCheckins(attendee: attendee) { success in
            switch success {
            case true:
                hud.textLabel.text = "Checked in"
                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            case false:
                hud.textLabel.text = "Error checking in"
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
            }

            hud.dismiss(afterDelay: 1, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showAttendee":
            let attendeeVC = segue.destination as! AttendeeViewController
            attendeeVC.attendee = sender as! Attendee
            attendeeVC.checkinValues = self.checkinValues
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
            self.checkinMode = .checkin(Attendee.Checkin(rawValue: title))
        }
    }
}
