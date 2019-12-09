//
//  VKRepostsViewController.h
//  VK Likes
//
//  Created by Vlad on 02/04/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MDTableViewCell.h>
#import <MDButton.h>
#import <UIImage+AFNetworking.h>
#import <NYXImagesKit.h>
#import <GBStorage.h>
#import <VKApi.h>

#import "LeftMenuViewController.h"
#import "VKScrollView.h"
#import "ShopViewController.h"
#import "ModalShopNavigationViewController.h"
#import "Protocols.h"

#import "Constants.h"
@protocol ShopProtocol;
@import GoogleMobileAds;

@interface VKRepostsViewController : UIViewController <ShopProtocol, GADInterstitialDelegate> {
    UIScrollView *scrollView;
    NSMutableDictionary *posts;
    NSMutableArray *labels;
    NSMutableArray *whiteys;
    NSMutableArray *sliders;
    NSMutableArray *subtotals;
    UIRefreshControl *refreshControl;
    SCLAlertView *welcome;
    GADInterstitial* interestitial;
    BOOL hasJustClosedAd;
}



@end
