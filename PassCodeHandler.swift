//
//  PassCodeHandler.swift
//  passcode_test
//
//  Created by Florian Pfeffer on 13.04.17.
//  Copyright © 2017 Florian Pfeffer. All rights reserved.
//

import Foundation
import SAPFoundation
import SAPCommon
import SAPFiori

class PassCodeHandler {
    
    // logger
    fileprivate static let logger = Logger.shared(named: "passCodeHandlerLogger")
    
    // secure value store
    private var store: SecureKeyValueStore!
    private static let encryptionKey = "1234abcd"
    
    // passcode
    private static let passcodeKey = "passcode"
    private var passcode: String? = nil
    
    // further constants
    private static let bundleSAPFiori = "com.sap.cp.sdk.ios.SAPFiori"
    
    fileprivate enum errorConsts: Error {
        case passcodeNotValid
    }
    
    init() {
        initPassCodeHandler()
    }
    
    deinit {
        closeStore()
    }
    
    // init the Passcode Handler (e.g. open key value store)
    private func initPassCodeHandler(){
        do{
            // open store
            self.store = SecureKeyValueStore(databaseFileName: "passcodeKeystore.db", name: "passcodeKeystore")
            try self.store.open(with: PassCodeHandler.encryptionKey)
            
            // get passcode from store (if available)
            passcode = try self.store.getString(PassCodeHandler.passcodeKey)
        }catch let error{
            PassCodeHandler.logger.error(error.localizedDescription)
        }
    }
    
    // close key value store
    private func closeStore(){
        if self.store.isOpen(){
            self.store.close()
        }
    }
    
    /// check for passcode on resume if one exists
    func passcodeActionOnResume(_ viewController: UIViewController, animated: Bool = true){
        if self.isPasscodeSet(){
            self.checkExistingPasscode(viewController, animated: animated)
        }
    }
    
    /// check if passcode is set
    func isPasscodeSet() -> Bool {
        return ( self.passcode == nil) ? false : true
    }
    
    /// create a new passcode
    func createNewPasscode(_ viewController: UIViewController){
        PassCodeHandler.logger.info("createNewPasscode entered")
        
        let storyboard = UIStoryboard(name: "FUIPasscodeCreateController", bundle: Bundle(identifier: PassCodeHandler.bundleSAPFiori))
        let vc = storyboard.instantiateViewController(withIdentifier: "PasscodeCreateFirstViewController")
        let passcodeVC = vc as! FUIPasscodeCreateController
        passcodeVC.delegate = self
        let navC = UINavigationController(rootViewController: passcodeVC)
        viewController.present(navC, animated: true, completion: {})
    }
    
    /// check existing passcode
    func checkExistingPasscode(_ viewController: UIViewController, animated: Bool = true){
        PassCodeHandler.logger.info("checkExistingPasscode entered")
        
        let storyboard = UIStoryboard(name: "FUIPasscodeInputController", bundle: Bundle(identifier: PassCodeHandler.bundleSAPFiori))
        let vc = storyboard.instantiateViewController(withIdentifier: "PasscodeInputViewController")
        let passcodeVC = vc as! FUIPasscodeInputController
        passcodeVC.delegate = self
        passcodeVC.isToShowCancelBarItem = false
        let navC = UINavigationController(rootViewController: passcodeVC)
        viewController.present(navC, animated: animated, completion: {})
    }
    
    /// change passcode
    func changePasscode(_ viewController: UIViewController){
        PassCodeHandler.logger.info("changePasscode entered")
        
        if let changeController = FUIPasscodeChangeController.createInstanceFromStoryboard() {
            changeController.passcodeControllerDelegate = self
            //changeController.validationDelegate = validationDelegate
            viewController.present(changeController, animated: true, completion: {})
        }
    }
    
    /// reset passcode
    func resetPasscode() throws {
        PassCodeHandler.logger.info("resetPasscode entered")
        
        do{
            _ = try self.store.remove(PassCodeHandler.passcodeKey)
            self.passcode = nil
            
            FUIToastMessage.show(message: NSLocalizedString("Passcode successfully reset.", comment: "Success message when passcode was reset."), withDuration: 1)
        }catch let error{
            PassCodeHandler.logger.error(error.localizedDescription)
            throw error
        }
    }
    
    // save passcode in key value store
    fileprivate func savePasscode(_ passcode: String) throws{
        do{
            try self.store.put(passcode, forKey: PassCodeHandler.passcodeKey)
            self.passcode = passcode
        }catch let error{
            PassCodeHandler.logger.error(error.localizedDescription)
            throw error
        }
    }
    
    // check if passcode is valid
    fileprivate func isPasscodeValid(_ passcode: String) -> Bool{
        return (passcode == self.passcode)
    }
}

extension PassCodeHandler: FUIPasscodeControllerDelegate{
    public func shouldTryPasscode(_ passcode: String, forInputMode inputMode: FUIPasscodeInputMode, fromController passcodeController: FUIPasscodeController) throws {
        PassCodeHandler.logger.info("shouldTryPasscode entered with inputMode \(inputMode)")
        
        switch inputMode {
        case .create:
            try self.savePasscode(passcode)
            passcodeController.dismiss(animated: true, completion: {})
            FUIToastMessage.show(message: NSLocalizedString("Passcode successfully created.", comment: "Success message when passcode was created."), withDuration: 1)
        case .change:
            try self.savePasscode(passcode)
            passcodeController.dismiss(animated: true, completion: {})
            FUIToastMessage.show(message: NSLocalizedString("Passcode successfully changed.", comment: "Success message when passcode was changed."), withDuration: 1)
        case .match:
            if self.isPasscodeValid(passcode){
                passcodeController.dismiss(animated: true, completion: {})
                FUIToastMessage.show(message: NSLocalizedString("Passcode successfully validated.", comment: "Success message when passcode was validated."), withDuration: 1)
            }else{
                throw PassCodeHandler.errorConsts.passcodeNotValid
            }
        case .matchForChange:
            if !self.isPasscodeValid(passcode){
                throw PassCodeHandler.errorConsts.passcodeNotValid
            }
        }
    }
    
    public func didCancelPasscodeEntry(fromController passcodeController: FUIPasscodeController) {
        passcodeController.dismiss(animated: true, completion: {})
    }
    
    public func didSkipPasscodeSetup(fromController passcodeController: FUIPasscodeController) {
        passcodeController.dismiss(animated: true, completion: {})
    }
    
    public func shouldResetPasscode(fromController passcodeController: FUIPasscodeController) {
        do{
            try self.resetPasscode()
            passcodeController.dismiss(animated: true, completion: {})
        }catch let error{
            PassCodeHandler.logger.error(error.localizedDescription)
        }
    }
    
    func passcodePolicy() -> FUIPasscodePolicy {
        var policy = FUIPasscodePolicy()
        //policy.hasDigit = true
        //policy.hasLower = true
        //policy.hasUpper = true
        //policy.hasSpecial = true
        //policy.minLength = 8
        policy.minCharGroups = 3
        return policy
    }
    
}

