//
//  VKAuthorizationViewController.h
//  VK Likes
//
//  Created by Vlad on 23/09/15.
//  Copyright © 2015 Vlad Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "NSString+Hashes.h"
#import "LeftMenuViewController.h"
#import <MFSideMenuContainerViewController.h>
#import <MFSideMenu.h>
#import <VKSdk.h>
#import "Constants.h"
#import <AFNetworking.h>
#import <GBStorage.h>
#import <UIImageView+AFNetworking.h>
#import <Colours.h>
#import <VungleSDK/VungleSDK.h>

#import "Utilities.h"
#import "ShopViewController.h"
#import "ShopNavigationViewController.h"
#import "ModalShopNavigationViewController.h"
#import "VKGetLikesViewController.h"
#import "VKGetLikesNavigationViewController.h"
#import "AppDelegate.h"
#import "LicenseViewController.h"
#import "LicenseNavigationViewController.h"

@class ShopViewController;

@interface VKAuthorizationViewController : UIViewController <VKSdkDelegate, VKSdkUIDelegate, CloseLicenseProtocol>
{
    UIButton *loginButton;
    NSArray *scope;
    VKSdk *sdkInstance;
    UIActivityIndicatorView *activityIndicator;
    BOOL isCaptchaPresented;
}

@end
