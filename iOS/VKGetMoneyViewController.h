//
//  VKGetMoneyViewController.h
//  VK Likes
//
//  Created by Vlad Shakhray on 30/10/15.
//  Copyright © 2015 Vlad Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSString+Hashes.h"
#import <RTSpinKitView.h>
#import <AFNetworking.h>
#import <VKSdk.h>
#import <VungleSDK/VungleSDK.h>

#import <SCLAlertView.h>
#import <MFSideMenu.h>
#import <MFSideMenuContainerViewController.h>
#import "Constants.h"
#import <NYXImagesKit.h>
#import "Utilities.h"
#import <Flurry.h>
#import "UIView+Additions.h"
#import <Colours.h>
#import "AppDelegate.h"
@import GoogleMobileAds;

@interface VKGetMoneyViewController : UIViewController <VKSdkUIDelegate, GADInterstitialDelegate> {
    //Image views
    UIImageView *mainImageView;
    UIImageView *errorImageView;
    
    UIViewController* tmp_vc;
    //Dictionaries
    NSDictionary *serverResponse;
    
    //Buttons
    UIButton *likeButton;
    UIButton *ignoreButton;
    UIButton *watchVideoButton;
    UIButton *updateButton;
    
    //Labels
    UILabel *errorDescriptionLabel;
    UILabel *errorTitleLabel;
    UILabel *titleLabel;
    UILabel *commentLabel;
    
    //Constraints
    CGFloat size;
    
    //Other
    BOOL isCaptchaPresented;
    
    //BackSystem
    NSThread *thread;
    
    //Welcome view
    SCLAlertView *welcome;
    BOOL buttonDimmed;
    UIActivityIndicatorView *activity;
    GADInterstitial* interestitial;
    BOOL hasJustClosedAd;
}

//Ads
- (void) updateAdAvailability;


@end
