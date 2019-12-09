
#import "NSString+Hashes.h"
#import <MFSideMenu.h>
#import <MFSideMenuContainerViewController.h>
#import <AFNetworking.h>
#import <MDTableViewCell.h>
#import <RTSpinKitView.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "VKAuthorizationViewController.h"
#import "Protocols.h"
#import "UIView+Additions.h"
#import <RMStore.h>
#import "JBroken.h"

@import UIKit;
@import Foundation;
@import StoreKit;

@interface ShopViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SKRequestDelegate> {
    NSArray* identifiers;
    BOOL isModal;
    NSMutableArray *amounts;
    UITableView *tableView;
    UILabel *balanceLabel;
    BOOL isSelected;
    BOOL isSelectedFree;
    int selectedPaid;
    BOOL adAvailable;
    SCLAlertView *welcome;
    UIViewController *tmp_vc;
    BOOL isSalesInProgress;
}

- (instancetype) initWithModal: (BOOL) modal;


@property id <CancelProtocol> delegate;
- (void) updateAdAvailability;


@end
