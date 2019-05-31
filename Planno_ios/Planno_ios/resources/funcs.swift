//
//  funcs.swift
//  Planno_ios
//
//  Created by Сергей Петров on 08/05/2019.
//  Copyright © 2019 SergioPetrovx. All rights reserved.
//

import Foundation
import UIKit

func showError(controller : UIViewController, message : String) {
    let alertController = UIAlertController(
        title: "Ошибка",
        message: message,
        preferredStyle: UIAlertController.Style.alert)
    alertController.addAction(UIAlertAction (
        title: "OK",
        style: UIAlertAction.Style.default,
        handler: nil))
    controller.present(alertController, animated: true, completion: nil)
}

func showMessage(controller: UIViewController, message : String) {
    let messageController = UIAlertController (
        title: "Успешно!", message: message, preferredStyle: UIAlertController.Style.alert)
    messageController.addAction(UIAlertAction (
        title: "OK",
        style: UIAlertAction.Style.default,
        handler: nil))
    controller.present(messageController, animated: true, completion: nil)
}
