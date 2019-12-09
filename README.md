# VK Exchange (App Store)

In this repository I store the source code (both the client and the server) for the iOS app "VK Exchange", previously available on App Store (2015 - 2017). The app had over 4.5 star-rating on the AppStore and has reached TOP-50 rankings in the *Social* category. The app was removed from the store in 2017 by me due to the lack of time to support the project.

### About
"VK Exchange" was an app that let people exchange social value in VK social network. In order to start sharing the social value, the user had to:
* download the app from the App Store
* log in to the existing VK account (or create a new one!)
* grant the app access to the user's photos and feed
* use in-app currency to request other people to like your content

#### Screenshots

<img src="/static/1.PNG" width="220"/> <img src="/static/2.PNG" width="220"/> <img src="/static/3.PNG" width="220"/>

### Architecture - iOS

**Authorization**

The iOS app was built in Objective-C using powerful tools and 3-rd party libraries and SDKs. In order to log in to the VK social network I used `VK SDK for iOS` Cocoapod, which has a wide variaty of functions to synchronise the state with that of the social network account. Please look at `VKAuthorizationViewController.m`, where I handle authorization-specific actions (such as checking whether the SDK token has expired or not).

In case the required method was not available by `VK SDK`, I had to implement one by my own, primarily using the `AFNetworking` Cocoapod.

<img src="/static/login.jpeg" width="220"/>

**Analytics**

When dealing with a user base of that size, it was important for me to ensure that proper analytics tools are embedded in the app. For that, I've successfully relied on `Flurry-iOS-SDK` pod.

**Ads**

As a way of monetization, I've used *Vungle* framework as a main ads provider. I've also used in-app purchases as a way to get in-app currency.

<img src="/static/inapp.jpeg" width="220"/>

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

### Architecture - Server

The implementations of the server-side logic can be found in the `server` folder. The whole server-side was implemented using `PHP` in conjunction with `PHP Data Objects` to support seamless integration with `SQLite 3` framework (see `server/common.php:MyDB` for more info). In order to prevent fraud, I've used hashing with a unique key (stored in `iOS` database) shared between the server and an application), see `server/common.php:check_sha512` for more info. Note that the time of request was also hashed and stored on the server for 2 days, which ensured that no request could be repeated during the attack.

Overall, the implementation of the server could support 100k users in total and over 1k daily active users (up to 10 consecutive requests).



