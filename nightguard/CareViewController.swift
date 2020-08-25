//
//  AlarmViewController.swift
//  nightguard
//
//  Created by Florian Preknya on 2/2/19.
//  Copyright © 2019 private. All rights reserved.
//

import UIKit
import Eureka
import Foundation

class CareViewController: CustomFormViewController {
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var reconstructFormOnViewWillAppear: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func constructForm() {
        
        form +++ Section(header: NSLocalizedString("Set a new Temporary Target", comment: "Label for Temporary Target Section"), footer: nil)
                
                <<< PickerInlineRow<String>() { row in
                    row.title = NSLocalizedString("Reason", comment: "Label for the Temporary Target Reason")
                    row.options = [
                        NSLocalizedString("Activity", comment: "TT Reason Picker Activity"),
                        NSLocalizedString("Too High", comment: "TT Reason Picker Too High"),
                        NSLocalizedString("Too Low", comment: "TT Reason Picker Too Low"),
                        NSLocalizedString("Meal Soon", comment: "TT Reason Picker Meal Soon")]
                    row.value = UserDefaultsRepository.temporaryTargetReason.value
                }.onChange { row in
                    UserDefaultsRepository.temporaryTargetReason.value = row.value!
                    
                    if row.value == NSLocalizedString("Activity", comment: "TT Reason Picker Activity") {
                        let targetValueRow : PickerInlineRow<Int> = self.form.rowBy(tag: "Value") as! PickerInlineRow<Int>
                        UserDefaultsRepository.temporaryTarget.value = 130
                        targetValueRow.value = UserDefaultsRepository.temporaryTarget.value
                        targetValueRow.reload()
                    }
                    if row.value == NSLocalizedString("Too High", comment: "TT Reason Picker Too High") {
                        let targetValueRow : PickerInlineRow<Int> = self.form.rowBy(tag: "Value") as! PickerInlineRow<Int>
                        UserDefaultsRepository.temporaryTarget.value = 70
                        targetValueRow.value = UserDefaultsRepository.temporaryTarget.value
                        targetValueRow.reload()
                    }
                    if row.value == NSLocalizedString("Too Low", comment: "TT Reason Picker Too Low") {
                        let targetValueRow : PickerInlineRow<Int> = self.form.rowBy(tag: "Value") as! PickerInlineRow<Int>
                        UserDefaultsRepository.temporaryTarget.value = 120
                        targetValueRow.value = UserDefaultsRepository.temporaryTarget.value
                        targetValueRow.reload()
                    }
                    if row.value == NSLocalizedString("Meal Soon", comment: "TT Reason Picker Meal Soon") {
                        let targetValueRow : PickerInlineRow<Int> = self.form.rowBy(tag: "Value") as! PickerInlineRow<Int>
                        UserDefaultsRepository.temporaryTarget.value = 80
                        targetValueRow.value = UserDefaultsRepository.temporaryTarget.value
                        targetValueRow.reload()
                    }
                }
            
                <<< PickerInlineRow<Int>() { row in
                    row.tag = "Duration"
                    row.title = NSLocalizedString("Duration", comment: "Label for Temporary Target Duration")
                    row.displayValueFor = { value in
                        guard let value = value else { return nil }
                        if value < 60 {
                            return "\(value) " + NSLocalizedString("minutes", comment: "Minutes TT Unit")
                        } else if value == 60 {
                            return "1 " + NSLocalizedString("hour", comment: "Hour TT Unit")
                        } else if value == 90 {
                            return "1.5 " + NSLocalizedString("hours", comment: "Hour TT Unit")
                        } else {
                            return "\(value / 60) " + NSLocalizedString("hours", comment: "Hour TT Unit")
                        }
                    }
                    row.options = [30, 60, 90, 120, 180]
                    row.value = UserDefaultsRepository.temporaryTargetDuration.value
                }.onChange { row in
                    UserDefaultsRepository.temporaryTargetDuration.value = row.value!
                }
        
                <<< PickerInlineRow<Int>() { row in
                    row.tag = "Value"
                    row.title = NSLocalizedString("Target Value", comment: "Label for Temporary Target Value")
                    row.options = [70, 80, 100, 120]
                    row.value = UserDefaultsRepository.temporaryTarget.value
                    row.displayValueFor = { value in
                        guard let value = value else { return nil }
                        return UnitsConverter.toDisplayUnits(value)
                    }
                }.onChange { row in
                    UserDefaultsRepository.temporaryTarget.value = row.value!
                }
        
                <<< ButtonRow() { row in
                    row.title = NSLocalizedString("Set Target", comment: "Button to activate the Temporary Target")
                }.onCellSelection { _, _ in
                    
                    self.displayActivateTemporaryTargetPopup()
                }
            
                +++ Section(header: NSLocalizedString("Delete an active Temporary Target", comment: "Section to delete a temporary Target"), footer: nil)
                <<< ButtonRow() { row in
                        row.title = NSLocalizedString("Delete Temporary Target", comment: "Button to delete a current Temporary Target")
                    }.onCellSelection { _, _ in
                        
                        self.displayCancelTargetPopup()
                }
    }
    
    fileprivate func displayCancelTargetPopup() {
        let alertController = UIAlertController(
            title: NSLocalizedString("Cancel Target", comment: "Cancel Target Popup Title"),
            message: NSLocalizedString("Do you want to cancel an active temporary target?", comment: "Cancel Target Popup Text"),
            preferredStyle: .alert)
        let actionAccept = UIAlertAction(title: NSLocalizedString("Accept", comment: "Popup Accept-Button"), style: .default, handler: { (alert: UIAlertAction!) in
            
            NightscoutService.singleton.deleteTemporaryTarget(
                resultHandler: {(error: String?) in
                    
                    if (error != nil) {
                        self.displayErrorMessagePopup(message: error!)
                    } else {
                        UIApplication.shared.showMain()
                    }
            })
        })
        let actionDecline = UIAlertAction(title: NSLocalizedString("Decline", comment: "Popup Decline-Button"), style: .default, handler: { (alert: UIAlertAction!) in
        })
        alertController.addAction(actionAccept)
        alertController.addAction(actionDecline)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func displayActivateTemporaryTargetPopup() {
        let alertController = UIAlertController(
            title: String(format: NSLocalizedString("Set Target '%@'?", comment: "Set Target Message Title"), UserDefaultsRepository.temporaryTargetReason.value),
            message: String(format: NSLocalizedString("Do you want to set a temporary target for %d minutes?", comment: "Set Target Message Text"), UserDefaultsRepository.temporaryTargetDuration.value), preferredStyle: .alert)
        let actionAccept = UIAlertAction(title: NSLocalizedString("Accept", comment: "Popup Accept-Button"), style: .default, handler: { (alert: UIAlertAction!) in
            
            NightscoutService.singleton.createTemporaryTarget(
                reason: UserDefaultsRepository.temporaryTargetReason.value,
                target: UserDefaultsRepository.temporaryTarget.value,
                durationInMinutes: UserDefaultsRepository.temporaryTargetDuration.value,
                resultHandler: {(error: String?) in
                    
                    if (error != nil) {
                        self.displayErrorMessagePopup(message: error!)
                        return
                    }
                    UIApplication.shared.showMain()
            })
        })
        let actionDecline = UIAlertAction(title: NSLocalizedString("Decline", comment: "Popup Decline-Button"), style: .default, handler: { (alert: UIAlertAction!) in
        })
        alertController.addAction(actionAccept)
        alertController.addAction(actionDecline)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func displayErrorMessagePopup(message : String) {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Popup Error Message Title"), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Popup Error-Ok-Button"), style: .default, handler: { (alert: UIAlertAction!) in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
