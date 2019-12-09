//
//  LeftMenuViewController.m
//  VK Likes
//
//  Created by Vlad on 18/11/15.
//  Copyright © 2015 Vlad Shakhray. All rights reserved.
//

#import "LeftMenuViewController.h"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isSelected = indexPath.row==selectedIndex;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellReuseIdentifier"];
    cell.backgroundColor = isSelected?[UIColor colorWithRed:0.204 green:0.227 blue:0.286 alpha:1.00]:[UIColor clearColor];
    UIView* cellBackgroundView = [UIView new];
    cellBackgroundView.backgroundColor = [UIColor colorWithRed:0.180 green:0.204 blue:0.255 alpha:1.00];
    cell.selectedBackgroundView = cellBackgroundView;
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = labels[indexPath.row];
    titleLabel.textColor = isSelected?[UIColor whiteColor]:[UIColor colorWithRed:0.694 green:0.702 blue:0.733 alpha:1.00];
    titleLabel.font = isSelected?[UIFont fontWithName:@"AvenirNext-Bold" size:13]:[UIFont fontWithName:@"AvenirNext-Medium" size:13];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleLabel sizeToFit];
    CGRect frame = titleLabel.frame;
    frame.origin.x = 50;
    frame.origin.y = TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-frame.size.height/2.0+1;
    titleLabel.frame = frame;
    [cell.contentView addSubview:titleLabel];
    
    BOOL isSelectedSmall = indexPath.row==3||indexPath.row==4;
    CGFloat imageSize = isSelectedSmall?18:14;
    CGFloat xOffset = isSelectedSmall?17:20;
    
    UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-imageSize/2.0, imageSize, imageSize)];
    picture.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Icon%@_32", picturesNames[indexPath.row], indexPath.row==selectedIndex?@"White":@"Gray"]];
    [cell.contentView addSubview:picture];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (void) resetMenuIndex {
    selectedIndex = 0;
    [tableView reloadData];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_VIEW_STANDARD_ROW_HEIGHT;
}

- (void) tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedIndex == (int) indexPath.row) {
        [[(AppDelegate*)[[UIApplication sharedApplication] delegate] container] setMenuState:MFSideMenuStateClosed];
        return;
    }
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setCenterViewController:(int)indexPath.row+1];
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] container] setMenuState:MFSideMenuStateClosed];
    selectedIndex = (int)indexPath.row;
    [tableView_ reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = 0;
    self.view.backgroundColor = [UIColor colorWithRed:0.173 green:0.188 blue:0.239 alpha:1.00];

    labels = [NSMutableArray arrayWithObjects:NSLocalizedString(@"ЗАКАЗАТЬ ЛАЙКИ", nil), NSLocalizedString
              (@"ЗАКАЗАТЬ ПОДПИСЧИКОВ", nil), NSLocalizedString(@"ЗАКАЗАТЬ РЕПОСТЫ", nil), NSLocalizedString(@"ЗАРАБОТАТЬ МОНЕТЫ", nil), NSLocalizedString(@"МАГАЗИН", nil), NSLocalizedString(@"НАСТРОЙКИ", nil), nil];
    picturesNames = [NSArray arrayWithObjects:@"Heart", @"User", @"Repost", @"Coin", @"Shop", @"Settings", nil];

    //Setting up table view
    tableView = [UITableView new];
    tableView.frame = CGRectMake(0, 999, self.view.frame.size.width, 999);
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor colorWithRed:0.34 green:0.48 blue:0.80 alpha:1];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellReuseIdentifier"];
    [self.view addSubview:tableView];
    
    //Addding profile photo image view and circle around it
    CGFloat photoSize = 74;
    CGFloat offsetY = 50;
    CGFloat diff = 10;
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(140-photoSize/2.0-diff, offsetY-diff, photoSize+2*diff, photoSize+2*diff)];
    circleView.backgroundColor = [UIColor clearColor];
    circleView.layer.cornerRadius = circleView.frame.size.height/2.0;
    circleView.layer.borderWidth = 0.5;
    circleView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.00].CGColor;
    [self.view addSubview:circleView];
    profilePhotoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(140-photoSize/2.0, offsetY, photoSize, photoSize)];
    profilePhotoImageView.clipsToBounds = YES;
    profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.size.width/2.0;
    [self.view addSubview:profilePhotoImageView];
    
    //Turbo view
    CGFloat height = TABLE_VIEW_STANDARD_ROW_HEIGHT;
    UIColor *backgrColor = [UIColor colorWithRed:0.141 green:0.153 blue:0.192 alpha:1.00];
    turboView = [[UIView alloc] initWithFrame:CGRectMake(0, [self.view getHeight]-height, 280, height)];
    turboView.backgroundColor = backgrColor;
    [self.view addSubview:turboView];
    CGFloat size = 16;
    CGFloat offsetX = 18;
    UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rocket"]];
    imgv.frame = CGRectMake(offsetX, height/2.0-size/2.0, size, size);
    [turboView addSubview:imgv];
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = NSLocalizedString(@"ТУРБО", nil);
    titleLabel.textColor = [UIColor colorWithWhite:0.71 alpha:1];
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleLabel sizeToFit];
    [titleLabel setX: 50];
    [titleLabel setY: height/2.0-titleLabel.frame.size.height/2.0+1];
    [turboView addSubview:titleLabel];
    _switch = [[MDSwitch alloc] init];
    [_switch addTarget:self action:@selector(resetCanPrompt) forControlEvents:UIControlEventAllTouchEvents];
    [_switch addTarget:self action:@selector(updateTurbo:) forControlEvents:UIControlEventValueChanged];
    _switch.thumbOff = [UIColor colorWithWhite:0.85 alpha:1];
    _switch.trackOff = [UIColor colorWithWhite:0.5 alpha:1];
    //_switch.trackOn = [UIColor colorWithRed:0.361 green:0.502 blue:0.490 alpha:1.00];
    //_switch.thumbOn = [UIColor whiteColor];
    [_switch setWidth:50];
    [_switch setHeight:30];
    [_switch setX:280-TABLE_VIEW_STANDARD_RIGHT_OFFSET-_switch.frame.size.width];
    [_switch setY:height/2.0-_switch.frame.size.height/2.0];
    [turboView addSubview:_switch];
}

- (int) getSelectedIndex {
    return selectedIndex;
}
- (void) resetCanPrompt {
    canPrompt = YES;
}

- (void) synchronizeSwitch:(BOOL)value {
    canPrompt = NO;
    _switch.on = value;
}

- (void) updateSettings {
    [((SettingsViewController*)(((SettingsNavigationViewController*)[((AppDelegate*) [[UIApplication sharedApplication] delegate]) getViewControllerWithIndex:6]).topViewController)) synchronizeSwitch:[[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TURBO] boolValue]];
}


- (void) updateTurbo: (MDSwitch *) sender {
    if (!canPrompt) return;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_IS_PRIVILEGED] boolValue]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sender.on] forKey:SETTINGS_KEY_TURBO];
        [self updateSettings];
    } else if (((MDSwitch*)sender).on == 1) {
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(showPrompt) userInfo:nil repeats:NO];
    }
}

- (void) productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [timer invalidate];
    timer = nil;
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [self updateSwitch];
    [self updateSettings];
}

- (void) updateSwitch {
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_IS_PRIVILEGED] boolValue]) {
        _switch.on = 0;
    } else {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TURBO]) {
            _switch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TURBO] boolValue];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:SETTINGS_DEFAULT_VALUE_TURBO] forKey:SETTINGS_KEY_TURBO];
            _switch.on = SETTINGS_DEFAULT_VALUE_TURBO;
        }
    }
}

- (void) close{
    [prompt hideView];
    [self updateSwitch];
    [self updateSettings];
}

- (void) rate {
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",AS_APP_ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    [self unlockTurbo:NULL];
}

- (void) unlockTurbo: (id) sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:1] forKey:NSUDEFAULTS_KEY_IS_PRIVILEGED];
    if (unlockRequested)
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:1] forKey:SETTINGS_KEY_TURBO];
    unlockRequested = NO;
    [self updateSwitch];
    [self updateSettings];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendUnlock: SERVER_PRIVILEGE_MAX_ATTEMPTS];
    });
}

- (void) sendUnlock: (int) times {
    if (times >= 0) {
        NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
        NSString *key = [NSStringFromClass([NSUserDefaults class]) sha256];
        NSString *pass = [[NSString stringWithFormat:@"%@%@", userID, key] sha512];
        NSDictionary *parameters = @{   @"user_id":userID,
                                        @"pass":pass
                                        };
        NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_REQUEST_PRIVILEGE_PATH];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
        serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.responseSerializer = serializer;
        manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
        [manager GET:baseURLString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"response"]) {
                if (![responseObject[@"response"][@"privileged"] boolValue]) {
                    [self sendUnlock:times-1];
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            [self sendUnlock:times-1];
        }];
    } else {
        [Flurry logError:@"PrivilegeError" message:@"Error while privileging user" error:nil];
    }
}

- (void) showPrompt {
    prompt = [[SCLAlertView alloc] initWithNewWindow];
    
    [prompt setTitleFontFamily:@"AvenirNext-Medium" withSize:18];
    [prompt setBodyTextFontFamily:@"AvenirNext-Regular" withSize:13];
    [prompt setShouldDismissOnTapOutside:NO];
    
    SCLButton *button1 = [prompt addButton:NSLocalizedString(@"Оценить", nil) target:self selector:@selector(rate)];
    button1.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor colorWithRed:1.000 green:0.839 blue:0.251 alpha:1.00];
        buttonConfig[@"textColor"] = [UIColor whiteColor];
        
        return buttonConfig;
    };
    
    SCLButton *button2 = [prompt addButton:NSLocalizedString(@"Закрыть", nil) target:self selector:@selector(close)];
    button2.buttonFormatBlock = ^NSDictionary* (void)
    {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        
        buttonConfig[@"backgroundColor"] = [UIColor whiteColor];
        buttonConfig[@"textColor"] = [UIColor blackColor];
        buttonConfig[@"borderColor"] = [UIColor whiteColor];
        buttonConfig[@"borderWidth"] = @"1.0f";
        
        return buttonConfig;
    };
    
    [prompt showCustom:self image:[UIImage imageNamed:@"RatePrompt"] color:[UIColor colorWithRed:1.000 green:0.839 blue:0.251 alpha:1.00] title: NSLocalizedString(@"Турбо", nil) subTitle:NSLocalizedString(@"Поставьте приложению 5 звезд в App Store, чтобы активировать Турбо режим.\nБесплатно и навсегда!", nil) closeButtonTitle:nil duration:0.0];
}

//Updates table view position
- (void) updateTableViewPosition {
    [tableView setY:allView.frame.origin.y +allView.frame.size.height+22];
    [tableView setHeight: [turboView getOriginY]-[tableView getOriginY]];
    [self.view setNeedsDisplay];
}

//Updates balance label
- (void) updateBalance {
    [allView removeFromSuperview];
    allView = nil;
    allView = [UIView new];
    CGFloat offset=5;
    CGFloat leftOffset = 10;
    CGFloat topOffset = 6;
    
    //Coin imageView
    UIImageView *coinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Coins_32"]];
    
    //Balance label
    UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    balanceLabel.textColor = [UIColor whiteColor];
    balanceLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    balanceLabel.text = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_BALANCE] intValue]];
    [balanceLabel sizeToFit];
    
    //Plus
    UIImageView *plusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Plus_32"]];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openShop:)];
    [tapGR setCancelsTouchesInView:YES];
    [allView addGestureRecognizer:tapGR];
    
    //Setting allView
    CGRect frame = allView.frame;
    frame.size.width = 2*leftOffset+coinImageView.frame.size.width+2*offset+plusImageView.frame.size.width+balanceLabel.frame.size.width+1;
    frame.size.height = MAX(plusImageView.frame.size.height, MAX(balanceLabel.frame.size.height, coinImageView.frame.size.height))+2*topOffset;
    frame.origin.x = 140-frame.size.width/2.0;
    frame.origin.y = nameLabel.frame.origin.y + nameLabel.frame.size.height+6;
    allView.frame = frame;
    
    //Frames
    frame = coinImageView.frame;
    frame.origin.x = leftOffset;
    frame.origin.y = allView.frame.size.height/2.0-coinImageView.frame.size.height/2.0;
    coinImageView.frame = frame;
    frame = balanceLabel.frame;
    frame.origin.x = coinImageView.frame.origin.x+coinImageView.frame.size.width+offset;
    frame.origin.y = allView.frame.size.height/2.0-balanceLabel.frame.size.height/2.0;
    balanceLabel.frame = frame;
    frame = plusImageView.frame;
    frame.origin.x = balanceLabel.frame.origin.x+balanceLabel.frame.size.width+offset+1;
    frame.origin.y = allView.frame.size.height/2.0-plusImageView.frame.size.height/2.0-0.5;
    plusImageView.frame = frame;
    
    [allView addSubview:coinImageView];
    [allView addSubview:balanceLabel];
    [allView addSubview:plusImageView];
    
    allView.layer.cornerRadius = allView.frame.size.height/2.0;
    allView.layer.borderWidth = 0.5;
    allView.layer.borderColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.00].CGColor;
    [self.view addSubview:allView];
}


- (void) openShop: (UITapGestureRecognizer*) tapGR {
    ShopViewController *vc = [[ShopViewController alloc] initWithModal:YES];
    ModalShopNavigationViewController *navVC = [[ModalShopNavigationViewController alloc] initWithRootViewController:vc];
    vc.delegate = navVC;
    navVC.shopDelegate = self;
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void) finished:(UIViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

//Updates name displayed in left menu view controller
- (void) updateName {
    [nameLabel removeFromSuperview];
    nameLabel = nil;
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    nameLabel.text = [NSString stringWithFormat:@"%@. %@", [(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"first_name"] substringWithRange:NSMakeRange(0, 1)], [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"last_name"]];
    nameLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
    nameLabel.textColor = [UIColor colorWithRed:0.694 green:0.702 blue:0.733 alpha:1.00];
    [nameLabel sizeToFit];
    CGRect frame_ = nameLabel.frame;
    frame_.origin.y = profilePhotoImageView.frame.origin.y+profilePhotoImageView.frame.size.height+10+12;
    frame_.origin.x = 140-frame_.size.width/2.0;
    nameLabel.frame = frame_;
    [self.view addSubview:nameLabel];
}

//Update all info
- (void) update {
    UIImage *profilePhotoImage = GBStorage(GBSTORAGE_DEFAULT_NAMESPACE)[GBSTORAGE_PHOTO_MAX_SQUARED];
    if (profilePhotoImage) {
        profilePhotoImageView.image = profilePhotoImage;
    }
    [self updateName];
    [self updateBalance];
    [self updateTableViewPosition];
    [self.view setNeedsDisplay];
}

#pragma mark - Flurry

- (void) logErrorWithCode: (int) code description: (NSString *) description {
    [Flurry logError:[NSString stringWithFormat:@"%i", code] message:description error:NULL];
}

- (void) logEvent: (NSString *) event {
    [Flurry logEvent:event];
}

- (void) logEvent: (NSString *) event withParameters: (NSDictionary *) parameters {
    [Flurry logEvent:event withParameters:parameters];
}

- (void) startTimedEvent: (NSString *) event {
    [Flurry logEvent:event timed:YES];
}

- (void) endTimedEvent: (NSString *) event {
    [Flurry endTimedEvent:event withParameters:nil];
}

@end
