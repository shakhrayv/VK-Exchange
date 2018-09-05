
#import <UIKit/UIKit.h>
#import <MDSwitch.h>
#import <MDTableViewCell.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MFSideMenu.h>
#import <MFSideMenuContainerViewController.h>
#import <GBStorage.h>
#import <VKSdk.h>
#import <SCLAlertView.h>
#import <Flurry.h>
#import "Constants.h"
#import "AppDelegate.h"
@import StoreKit;
@import GoogleMobileAds;

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate, GADInterstitialDelegate> {
    UITableView* tableView;
    SCLAlertView* welcome;
    NSTimer *timer;
    BOOL unlockRequested;
    SCLAlertView *prompt;
    MDSwitch *__switch;
    BOOL canPrompt;
    GADInterstitial* interestitial;
    BOOL hasJustClosedAd;
}

- (void) synchronizeSwitch: (BOOL) value;


@end
