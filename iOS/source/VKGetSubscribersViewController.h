
#import <UIKit/UIKit.h>
#import <MFSideMenu.h>
#import <MFSideMenuContainerViewController.h>
#import <GBStorage.h>
#import <MDSlider.h>
#import <SVProgressHUD.h>
#import <Flurry.h>
#import <NYXImagesKit.h>
#import <VKSdk.h>
#import <SCLAlertView.h>
#import "Constants.h"
#import "ShopViewController.h"
#import "ModalShopNavigationViewController.h"
#import "Protocols.h"
#import "UIView+Additions.h"

@import GoogleMobileAds;

@interface VKGetSubscribersViewController : UIViewController <ShopProtocol, VKSdkUIDelegate, GADInterstitialDelegate> {
    UIImageView* photoImageView;
    UIButton *orderButton;
    UIView* subtotalView;
    UIView *backgroundOrderView;
    
    //Labels
    UILabel *friendsLabel;
    UILabel *followersLabel;
    UILabel *inOrderLabel;
    
    //Slider
    UISlider *slider;
    SCLAlertView* welcome;
    
    BOOL isCaptchaPresented;
    GADInterstitial* interestitial;
    BOOL hasJustClosedAd;
}



@end
