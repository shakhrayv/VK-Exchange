# VK Exchange (App Store)

In this repository I store the source code (both the client and the server) for the iOS app "VK Exchange", previously available on App Store (2015 - 2017). The app was removed from the App Store in 2017 by me due to the lack of time to support the project.

### About
"VK Exchange" was an app that let people exchange social value in VK social network. In order to start sharing the social value, the user had to:
* download the app from the App Store
* log in to the existing VK account (or create a new one!)
* grant the app access to the user's photos and feed
* use in-app currency to request other people to like your content

#### Screenshots

<img src="/Screenshots/1.PNG" width="220"/> <img src="/Screenshots/2.PNG" width="220"/> <img src="/Screenshots/3.PNG" width="220"/>

### Architecture - iOS

**Authorization**
The iOS app was built in Objective-C using powerful tools and 3-rd party libraries and SDKs. In order to log in to the VK social network I used `VK SDK for iOS` Cocoapod, which has a wide variaty of functions to synchronise the state with that of the social network account. Please look at `VKAuthorizationViewController.m`, where I handle authorization-specific actions (such as checking whether the SDK token has expired or not).

In case the required method was not available by `VK SDK`, I had to implement one by my own, primarily using the `AFNetworking` Cocoapod.

**Analytics**
When dealing with a user base of that size, it was important for me to ensure that proper analytics tools are embedded in the app. For that, I've successfully relied on `Flurry-iOS-SDK` pod.

**Ads**
As a way of monetization, I've used *Vungle* framework as a main ads provider.

**Other**
As you can see from the `Podfile` file, I've also used many other utilities to further sharpen the user experience and to make the app more beautiful and reliable. The list of such frameworks is listed below:

* `MFSideMenu` for implementing beautiful side menu
* `SLCAlertView-ObjC` for handling alerts in a stylish way
* `SVProgressHud` to show progress during the loading of heavy items (e.g. photos)
* `GBStorage` for easy and reliable persistent storage accross the user session
* `MaterialControls`
* `SpinKit`
* `NYXImagesKit`
* `Colours`
* `RMStore`




