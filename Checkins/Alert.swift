//
//  Alert.swift
//  Checkins
//
//  Created by Dan Appel on 1/28/18.
//  Copyright © 2018 Los Altos Hacks. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(message: String) {
        let controller = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        ))
        present(controller, animated: true, completion: nil)
    }
}
