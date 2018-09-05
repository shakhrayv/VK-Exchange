
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <VKSdk.h>
#import <UIImageView+AFNetworking.h>
#import <AFNetworking.h>
#import <GBStorage.h>
#import <SVProgressHUD.h>
#import <MFSideMenuContainerViewController.h>
#import <MFSideMenu.h>
#import "UIImage+ImageEffects.h"
#import "NSString+Hashes.h"
#import <NYXImagesKit.h>
#import <Flurry.h>

#import "VKScrollView.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "Constants.h"
#import "ShopViewController.h"
#import "ModalShopNavigationViewController.h"
#import "Protocols.h"
#import "Utilities.h"
#import "UIView+Additions.h"

@import GoogleMobileAds;

@protocol ShopProtocol;

@interface VKGetLikesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ShopProtocol, VKSdkUIDelegate, UIGestureRecognizerDelegate, GADInterstitialDelegate> {
    
    //Main photo information
    NSMutableArray *photoQueue;
    
    //Image views
    NSMutableArray *imageViews;
    NSMutableArray *barViews;
    NSMutableArray *loadedPhotoIDs;
    NSMutableArray *shadowViews;
    
    //Downloading photos
    int indexOfPhotoInDownload;
    BOOL isLoadingPhoto;
    int photoIndexInInitialQueue;
    UIImage* photoInBetterResolution;
    
    //Gesture recognizers
    UITapGestureRecognizer* tapGestureRecognizer;
    
    //Ordering likes
    UILabel* currentLikesChoiceLabel;
    UIButton* orderButton;
    
    UIButton *orderLikes;
    
    //Scroll view
    UIScrollView *mainScrollView;
    
    BOOL selected;
    
    UIView *selectingView;
    UIImageView *selectedPictureImageView;
    NSArray *offers;
    NSString* selectedPhotoID;
    NSArray *prices;
    //Captcha
    BOOL isCaptchaPresented;
    
    //Updating
    UIRefreshControl *refreshControl;
    
    UITableView*likesTableView;
    
    //Gesture recognizers (scroll)
    CGPoint initialGRPoint;
    BOOL isScrollActive;
    SCLAlertView *welcome;
    
    UIView*view1;
    UIView *view2;
    
    GADInterstitial* interestitial;
    BOOL hasJustClosedAd;
}



@end
