//
//  AppDelegate.h
//  VK Likes
//
//  Created by Vlad on 21/09/15.
//  Copyright © 2015 Vlad Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKGetLikesViewController.h"
#import "VKGetMoneyViewController.h"
#import "VKAuthorizationViewController.h"
#import "LeftMenuViewController.h"
#import <MFSideMenuContainerViewController.h>
#import "VKGetSubscribersViewController.h"
#import "ShopViewController.h"
#import <VKSdk.h>
#import "Constants.h"
#import <Flurry.h>
#import <VungleSDK/VungleSDK.h>
#import "VKRepostsNavigationViewController.h"
#import "VKRepostsViewController.h"

#import <RMStore.h>
#import <RMStoreAppReceiptVerificator.h>

#import "Utilities.h"
#import "ShopNavigationViewController.h"
#import "VKGetSubscribersNavigationViewController.h"
#import "SettingsNavigationViewController.h"
#import "SettingsViewController.h"
#import "VKGetLikesNavigationViewController.h"
#import "VKGetMoneyNavigationViewController.h"

@import Firebase;

@interface AppDelegate : UIResponder <UIApplicationDelegate, VungleSDKDelegate> {
    __block NSThread *thread;
    NSMutableArray *viewControllers;
    MFSideMenuContainerViewController *container;
    BOOL shouldStop;
    UIBackgroundTaskIdentifier __block bgTask;
    VungleSDK* sdk;
    bool shouldCheckAdStatus;
}

@property RMStoreAppReceiptVerificator* _receiptVerifier;
@property (strong, nonatomic) UIWindow *window;

- (void) setCenterViewController: (int) i;
- (void) updateLeftMenu;
- (MFSideMenuContainerViewController*) container;
- (id) getViewControllerWithIndex: (int) i;
- (void) resetViewControllers;
- (void) resetLeftMenuIndex;

@end
