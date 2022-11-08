//
//  SwitchViewController.swift
//  BLESwitchSimulator
//
//  Created by skr on 07/11/22.
//

import UIKit

class SwitchViewController: UIViewController, PeripheralDataDelegate  {
   
    
    @IBOutlet var blub: UIImageView!
    @IBOutlet var advertisingSwitch: UISwitch!
    var peripheralManager = SwitchPeripheralManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        if advertisingSwitch.isOn {
            peripheralManager.startAdvertising()
        } else {
            peripheralManager.stopAdvertising()
        }
    }
    
    func dataRecieved(switch toggle: Bool) {
        print(toggle)
        blub.image = UIImage(named: toggle ? "blublit" : "bulboff")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

