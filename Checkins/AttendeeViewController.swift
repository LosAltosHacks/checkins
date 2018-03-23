//
//  AttendeeViewController.swift
//  Checkins
//
//  Created by Dan Appel on 1/26/18.
//  Copyright © 2018 Los Altos Hacks. All rights reserved.
//

import UIKit

class AttendeeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        print("Refreshing!!")
        Airtable.attendee(code: attendee.code.text) { [weak self] attendee in
            guard let s = self else { return }
            guard let attendee = attendee else { return s.alert(message: "Failed to refresh.") }
            s.attendee = attendee
            s.tableView.reloadData()
        }
    }

    var attendee: Attendee!
    var checkinValues: [Attendee.Checkin]!

    var titlesAndValues: [(String,String)] {
        func shorthand(closure: (Attendee) -> (Attendee.CodingKeys, String?)) -> (String, String) {
            let result = closure(attendee)
            return (result.0.stringValue, result.1 ?? "")
        }

        return [
            shorthand { (.type, $0.type?.rawValue) },
            shorthand { (.checkedIn, $0.checkedIn.description.capitalized) },
            shorthand { (.firstName, $0.firstName) },
            shorthand { (.lastName, $0.lastName) },
            shorthand { (.email, $0.email) },
            shorthand { (.age, $0.age?.description) },
            shorthand { (.highSchool, $0.highSchool) },
            shorthand { (.guardianName, $0.guardianName) },
            shorthand { (.guardianEmail, $0.guardianEmail) },
            shorthand { (.phoneNumber, $0.phoneNumber) },
            shorthand { (.grade, $0.grade) },
            shorthand { (.gender, $0.gender) },
            shorthand { (.dietaryRestrictions, $0.dietaryRestrictions) },
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func update() {
        Airtable.updateCheckins(attendee: attendee) { [weak self] success in
            guard let s = self else { return }
            guard success else { return s.alert(message: "Failed to update attendee") }
        }
    }

    @objc func switched(sender: UISwitch) {
        let checkin = checkinValues[sender.tag]

        switch sender.isOn {
        case true:
            guard !attendee.checkins.contains(checkin) else { return }
            attendee.checkins.append(checkin)
            update()
        case false:
            guard attendee.checkins.contains(checkin) else { return }
            attendee.checkins.remove(at: attendee.checkins.index(of: checkin)!)
            update()
        }
    }
}

extension AttendeeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        print(attendee)
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Checkins"
        case 1:
            return "Information"
        default:
            fatalError("Unknown section")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return checkinValues.count
        case 1:
            return titlesAndValues.count
        default:
            fatalError("Unknown section")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {

        case 0:
            let checkin = checkinValues[indexPath.row]
            let checkedIn = attendee.checkins.contains(checkin)

            let checkinSwitch = UISwitch()
            checkinSwitch.tag = indexPath.row
            checkinSwitch.setOn(checkedIn, animated: false)
            checkinSwitch.addTarget(self, action: #selector(self.switched(sender:)), for: .valueChanged)

            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckinCell")!
            cell.textLabel!.text = checkin.rawValue
            cell.accessoryView = checkinSwitch

            return cell

        case 1:
            let (title, value) = titlesAndValues[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell")!
            cell.textLabel!.text = title
            cell.detailTextLabel!.text = value

            return cell

        default:
            fatalError("Unknown section")
        }
    }
}
