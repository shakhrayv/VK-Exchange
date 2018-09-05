
#import <UIKit/UIKit.h>
#import <MFSideMenu.h>
#import <MFSideMenuContainerViewController.h>
#import <MDSwitch.h>
#import <GBStorage.h>
#import "UIView+Additions.h"
#import <Flurry.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "Protocols.h"

@import StoreKit;

@interface LeftMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ShopProtocol, SKStoreProductViewControllerDelegate> {
    
    //Main table view
    UITableView *tableView;
    
    //Profile photo
    UIImageView *profilePhotoImageView;
    
    NSMutableArray *labels;
    NSMutableArray *imagesSelected;
    NSMutableArray *imagesNotSelected;
    UILabel* initialsLabel;
    UIButton* getVIPButton;
    int selectedIndex;
    UILabel *nameLabel;
    
    //Balance
    UIView *allView;
    
    //Pictures names
    NSArray *picturesNames;
    
    UIView *turboView;
    SCLAlertView *prompt;
    BOOL unlockRequested;
    NSTimer*timer;
    MDSwitch *_switch;
    BOOL canPrompt;
}

- (void) update;
- (int) getSelectedIndex;
- (void) resetMenuIndex;
- (void) synchronizeSwitch: (BOOL) value;


@end
