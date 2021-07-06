# onyx-ios-swift-example
Swift example using Onyx Cocoapod for iOS

Clone the repository
```
git clone https://github.com/DFTinc/onyx-ios-swift-example.git
```

Change directories to the project and install the CocoaPod dependencies
```
cd onyx-ios-swift-example
```
```
pod install
```

* Open the new workspace that was created `onyx-ios-swift-example.xcworkspace`

***NOTE***

OnyxCamera cocoapod 7.0.1 now implements the latest ONYX four finger simultaneous capture process you will see a breaking change from the previous single finger capture cocoapods. ONYX no longer returns a single OnyxResult file it returns an array of files representing each individual fingerprint and is now denoted as
```
onyxResults
```

## Requirements
- Minimum iOS Deployment Target 9.0
- xCode 11 & 12

## Known issues
### Archiving app with iOS Deployment Target 9.x OR 10.x will fail. 
Reason: OnyxCamera fails to archive app with "armv7" architecture included.

Solution A:
Set Minimum Deployment Target to >= 11.0

Solution B: 
STEP 1: xCode -> App Target -> Build Settings -> set "YES" to "Build Active Architectures Only [Release]"
STEP 2: plug in your iOS device -> select "Your iOS device" as build target (instead of "Any iOS Device (arm64, armv7))
STEP 3: Archive app

### 3 files must be added manually into your project project:

1. Select your xcodeproj file from the naviagtion pane on the left
2. Select "Build Phases"
3. Expaned "Copy Bunde Resources"
4. Click the "+"
5. Click "Add Other..."
6. A Finder window will launch
7. Navigate to Pods/OnyxCamera/OnyxCamera/Assets/ source the resource files from here

```
onyx_4f_logo_v2.png
onyx_4f_logo_v2@2x.png
capture_unet_nn_quant.tflite
```

## How to integrate OnyxCamera CocoaPod

* Open Xcode and create a new project
    * File > New > Project...
    * Single View App > Next
        * Product Name: `onyx-ios-swift-example`
        * Language: `Swift`
        * Next
            * Select location of new project
            * Create

* Open `Terminal` and navigate to the root directory of the new project

```
cd path/to/onyx-ios-swift-example
```

* Create a Podfile

```
pod init
```

* Open the new workspace that was created `onyx-ios-swift-example.xcworkspace`

* Add the Podfile to the project
    * Right-click on the root project `onyx-ios-swift-example`
    * Add files to "onyx-ios-swift-example"...
    * Select the Podfile

* Add the `OnyxCamera` cocoapod to the Podfile

```
pod 'OnyxCamera', '~> 7.0.1'
```

```
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'onyx-ios-swift-example' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for onyx-ios-swift-example
    pod 'OnyxCamera', '~> 7.0.1'
end
```

* Add 3 files to your project. 

1. Select your xcodeproj file from the naviagtion pane on the left
2. Select "Build Phases"
3. Expand "Copy Bunde Resources"
4. Click the "+"
5. Click "Add Other..."
6. A Finder window will launch
7. Navigate to Pods/OnyxCamera/OnyxCamera/Assets/ source the resource files from here

```
onyx_4f_logo_v2.png
onyx_4f_logo_v2@2x.png
capturenet.tflite
qualitynet.tflite
```

Otherwise the OnyxCamera will crash!

## How to implement Onyx

### Add usage descriptions for requested permissions to `Info.plist`
* Right-click on `Info.plist` > Open As > Source Code
* Paste the following lines at the bottom of the `<dict>` element

```
<key>NSCameraUsageDescription</key>
<string>Capture fingerprint image</string>
```

### Create a bridging header to use Objective C classes in Swift
Create a bridging header yourself by choosing File > New > File > [operating system] > Source > Header File.

Edit the bridging header to expose your Objective-C code to your Swift code:

In your Objective-C bridging header, import every Objective-C header you want to expose to Swift.

In Build Settings, in Swift Compiler - General, make sure the Objective-C Bridging Header build setting has a path to the bridging header file. The path should be relative to your project, similar to the way your Info.plist path is specified in Build Settings. In most cases, you won't need to modify this setting.

The bridging header should have these imports
```
// These are the base imports needed to bridge Onyx Objective C headers to Swift
#import <OnyxCamera/Onyx.h>
#import <OnyxCamera/OnyxConfigurationBuilder.h>
#import <OnyxCamera/OnyxConfiguration.h>
#import <OnyxCamera/CaptureNetController.h>
#import <OnyxCamera/OnyxViewController.h>
#import <OnyxCamera/OnyxEnums.h>
#import <TFLTensorFlowLite.h>
```

### Modify the ViewController.swift created for you by the project
*Currently Onyx has to have a Navigation Controller as the entry point, so have to do the following*
* Go to Editor -> Embed In -> Navigation Controller
* This sets the Navigation Controller as the Storyboard Entry Point

This simple configuration would create a scene that loads Onyx by putting this example code in the ViewController.swift file
```
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
```

### Notes on OnyxConfiguration and OnyxResult
* The OnyxConfiguration is highly customizable for options that are desired.  You must put your valid Onyx license key in the configuration
* There is a ReticleOrientation enum that has the various layouts for the UI desired (Currently they are LEFT, RIGHT, and THUMB_CAPTURE)
* The `onyxCallback` is triggered when Onyx is successfully configured and starts the capture
* The `onyxSuccessCallback` is triggered on successful capture and returns an OnyxResult that has images and CaptureMetrics such as NFIQ score
* The `onyxErrorCallback` is triggered when there is an error along with the error message to let you know what happened
* The error messages are in the `Error` enum in `OnyxEnums.h` and they are listed below
```
typedef enum Error {
    /**
     * This error occurs when the camera fails to auto-focus.
     */
    AUTOFOCUS_FAILURE,
    
    /**
     * This error occurs whenever the camera sub-system fails.
     */
    CAMERA_FAILURE,
    
    /**
     * This error occurs when the license validation fails.
     */
    LICENSING_FAILURE,
    
    /**
     * This error occurs when permissions have not been granted.
     */
    PERMISSIONS_FAILURE,
    
    /**
     * This error occurs when there is an error encountered during capture.
     */
    FINGERPRINT_CAPTURE_FAILURE,
    
    /**
     * This error occurs when there is a successful capture, but the resulting image is
     * of too low quality (NFIQ Score = 5)
     */
    FINGERPRINT_TOO_LOW_QUALITY,
    /**
     * This error occurs if there is an error communicating with the liveness detection
     * server.  Check if there is an internet connection, and if not, advise client to
     * connect to the internet, or to try a different internet connection.
     */
    LIVENESS_FAILURE
} Error;
```
