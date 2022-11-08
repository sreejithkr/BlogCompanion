//
//  RemoteViewController.swift
//  BLESwitchSimulator
//
//  Created by skr on 07/11/22.
//

import UIKit

class RemoteViewController: UIViewController {
    @IBOutlet var blubSwitch: UISwitch!
    
    var centralManager = CentralManager()

    override func viewDidLoad() {
        super.viewDidLoad()
       // centralManager.scanPeripherals()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func scanAndConnect() {
        centralManager.scanPeripherals()
        // create the alert
               let alert = UIAlertController(title: "Connected", message: "Connection Establised with Switch", preferredStyle: UIAlertController.Style.alert)

               // add an action (button)
               alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

               // show the alert
               self.present(alert, animated: true, completion: nil)

        
    }
    
    @IBAction func sendCommand() {
        if blubSwitch.isOn {
            centralManager.wirte(data: "ON")
        } else {
            centralManager.wirte(data: "OFF")
        }
        
    }
}
