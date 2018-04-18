//
//  EmailSender.swift
//  PedestrianARNavigation
//
//  Created by Dmitry Trimonov on 18/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import UIKit
import MessageUI

class EmailSender: NSObject, MFMailComposeViewControllerDelegate {

    func sendEmail(controller: UIViewController, message: String) {
        let mailComposeViewController = configuredMailComposeViewController(withMessage: message)
        if MFMailComposeViewController.canSendMail() {
            controller.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }

    func configuredMailComposeViewController(withMessage message: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property

        mailComposerVC.setToRecipients(["trimonovds@yandex-team.ru"])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody(message, isHTML: false)

        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
