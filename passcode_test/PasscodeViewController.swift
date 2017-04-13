//
//  PasscodeViewController.swift
//  passcode_test
//
//  Created by Florian Pfeffer on 13.04.17.
//  Copyright © 2017 Florian Pfeffer. All rights reserved.
//

import UIKit
import SAPFiori

class PasscodeViewController: UIViewController {
    @IBOutlet weak var createNewPasscodeBtn: UIButton!
    @IBOutlet weak var checkPasscodeBtn: UIButton!
    @IBOutlet weak var changePasscodeBtn: UIButton!
    @IBOutlet weak var resetPasscodeBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setButtonStates()
    }
    
    // set button states
    private func setButtonStates(){
        let passcodeHandler = (UIApplication.shared.delegate as! AppDelegate).passcodeHandler!
        
        DispatchQueue.main.async{
            if passcodeHandler.isPasscodeSet() {
                self.createNewPasscodeBtn.isEnabled = false
                self.checkPasscodeBtn.isEnabled = true
                self.changePasscodeBtn.isEnabled = true
                self.resetPasscodeBtn.isEnabled = true
            }else{
                self.createNewPasscodeBtn.isEnabled = true
                self.checkPasscodeBtn.isEnabled = false
                self.changePasscodeBtn.isEnabled = false
                self.resetPasscodeBtn.isEnabled = false
            }
        }
    }

    @IBAction func createNewPasscode(_ sender: UIButton) {
        let passcodeHandler = (UIApplication.shared.delegate as! AppDelegate).passcodeHandler!
        passcodeHandler.createNewPasscode(self)
        self.setButtonStates()
    }
    
    @IBAction func checkPasscode(_ sender: UIButton) {
        let passcodeHandler = (UIApplication.shared.delegate as! AppDelegate).passcodeHandler!
        passcodeHandler.checkExistingPasscode(self)
    }
    
    @IBAction func changePasscode(_ sender: Any) {
        let passcodeHandler = (UIApplication.shared.delegate as! AppDelegate).passcodeHandler!
        passcodeHandler.changePasscode(self)
    }
    
    @IBAction func resetPasscode(_ sender: UIButton) {
        let passcodeHandler = (UIApplication.shared.delegate as! AppDelegate).passcodeHandler!
        
        do{
            try passcodeHandler.resetPasscode()
            self.setButtonStates()
        }catch let error{
            FUIToastMessage.show(message: error.localizedDescription, withDuration: 3)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
