Implementation Guide for iOS App Publishers


* `Copy  Project from the InAppCMPReference/Mobile In-App Reference Implementation/iOS/CMPReference library to your project.`
* `Open Your Xcode Project`
* `Right Click on Your Project  and Add file to your Project`
* `Select  CMPReference.xcodeproj Uncheck 'Copy Items if needed`
* `Go to Project -> General ->  Embedded Binaried`
* `Select-> CMPReference.fremework`

* Configure the CMP Reference by providing a set of properties encapsulated in the CMPSettings object. Where:

* `SubjectToGdpr`: NSString that indicates
* `CMPGDPRDisabled` - value @"0", not subject to GDPR
* `CMPGDPREnabled` - value @"1", subject to GDPR
* `CMPGDPRUnknown` - value Nil, unset
* `cmpURL`: `String url` that is used to create and load the request into the WebView – it is the request for the consent webpage. This property is mandatory.
* `consentString`: If this property is given, it enforces reinitialization with the given string, configured based on the consentToolURL. This property is optional.
* `cmpPresent`:  Boolean that indicates if a CMP implementing the iAB specification is present in the application


```
CMPSettings *cmpSettings = [[CMPSettings alloc] init];
cmpSettings.subjectToGDPR = @"1";
cmpSettings.consentString = NULL;
cmpSettings.cmpURL = https://consentWebPage;
cmpSettings.cmpPresent = true
```

* In order to start the `CMPConsentViewController`, you can call the following method: `CMPConsentViewController`
```*consentToolVC = [[CMPConsentViewController alloc] init];
consentToolVC.consentToolAPI.cmpURL = @"https://acdn.adnxs.com/mobile/democmp/docs/mobilecomplete.html";
consentToolVC.consentToolAPI.subjectToGDPR = @"1";
consentToolVC.consentToolAPI.cmpPresent = YES;
consentToolVC.delegate = self;
[self presentViewController:consentToolVC animated:YES completion:nil];
```

* In order to receive a callback when close or done button is tapped, you may use implement `CMPConsentViewControllerDelegate` that is `didReceiveConsentString` listener, otherwise pass null as the third parameter to `openCMPConsentToolView()`.
* `SubjectToGdpr`, `consentString` and `cmpPresent` will be stored in UserDefaults
