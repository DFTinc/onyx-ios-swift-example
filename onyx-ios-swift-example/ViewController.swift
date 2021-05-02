//
//  ViewController.swift
//  onyx-ios-swift-example
//
//  Created by Christopher Wheatley on 5/2/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configOnyx()
    }

    func configOnyx(){
        let onyxConfig: OnyxConfiguration = OnyxConfiguration();
        onyxConfig.viewController = self
        onyxConfig.licenseKey = "Your license key here"
        onyxConfig.returnRawFingerprintImage = false
        onyxConfig.returnProcessedFingerprintImage = true
        onyxConfig.returnGrayRawFingerprintImage = false
        onyxConfig.returnGrayRawWsq = false
        onyxConfig.returnWsq = false
        onyxConfig.reticleOrientation = ReticleOrientation(rawValue: 0)
        onyxConfig.showSpinner = true
        onyxConfig.useLiveness = false
        onyxConfig.onyxCallback = onyxCallback
        onyxConfig.successCallback = onyxSuccessCallback
        onyxConfig.errorCallback = onyxErrorCallback
        
        let onyx: Onyx = Onyx()
        onyx.doSetup(onyxConfig)
    }
    
    func onyxCallback(configuredOnyx: Onyx?) -> Void {
        NSLog("Onyx Callback");
        DispatchQueue.main.async {
            configuredOnyx?.capture(self);
        }
    }
    
    func onyxSuccessCallback(onyxResult: OnyxResult?) -> Void {
        NSLog("Onyx Success Callback");
    }
    
    func onyxErrorCallback(onyxError: OnyxError?) -> Void {
        NSLog("Onyx Error Callback");
        NSLog(onyxError?.errorMessage ?? "Onyx returned an error");
    }
}

