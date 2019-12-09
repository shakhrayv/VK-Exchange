//
//  SettingsViewController.m
//  VK Likes
//
//  Created by Vlad on 25/01/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import "SettingsViewController.h"

#define _k @"SHOULD_SHOW_INTERESTITIAL"
#define _sh @"SERVER_PERMISSION_TO_SHOW_AD"
#define udfset(obj, key) [[NSUserDefaults standardUserDefaults] setObject: obj forKey: key]
#define udfsetbool(bool, key) [[NSUserDefaults standardUserDefaults] setBool: bool forKey: key]
#define udfgetobj(key) [[NSUserDefaults standardUserDefaults] objectForKey: key]
#define udfgetbool(key) [[NSUserDefaults standardUserDefaults] boolForKey: key]

@interface SettingsViewController ()

@end

@implementation SettingsViewController

#pragma mark - AdMob

- (void) attemptToLoadInterestitial {
    if (!udfgetbool(_sh))
        return;
    if (hasJustClosedAd) {
        udfsetbool(0, _k);
        hasJustClosedAd = false;
        return;
    }
    if (udfgetbool(_k)) {
        interestitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-6261001507877178/8107709647"];
        interestitial.delegate = self;
        GADRequest *request = [GADRequest request];
        // Requests test ads on test devices.
        //request.testDevices = @[ @"33ae726d0227e7338701c0e27854c20b" ];
        [interestitial loadRequest:request];
    } else {
        udfsetbool(1, _k);
    }
}

- (void) interstitialDidReceiveAd:(GADInterstitial *)ad {
    if (self.isViewLoaded && self.view.window) {
        if (udfgetbool(_k)) {
            [ad presentFromRootViewController:self];
            udfsetbool(0, _k);
        }
    }
}

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    [Flurry logError:@"AdMob Interestitial Loading Error" message:[error localizedDescription] error:nil];
}

- (void) interstitialWillDismissScreen:(GADInterstitial *)ad {
    hasJustClosedAd = true;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==3) {
        return 2;
    }
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_VIEW_STANDARD_ROW_HEIGHT;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Турбо режим обеспечивает увеличение скорости выполнения Ваших заданий более чем в 8 раз!", nil);
        case 1:
            return NSLocalizedString(@"Данный режим использует меньше траффика, загружая изображения худшего качества.", nil);
        case 2:
            return NSLocalizedString(@"Если не показывать изображения во время заработка монет, то скорость загрузки очередного задания будет выше.", nil);
        default:
            return nil;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDTableViewCell *cell = [[MDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellReuseIdentifier"];
    cell.backgroundColor = [UIColor whiteColor];
    cell.rippleColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    //Setting label
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    switch (indexPath.section) {
        case 0:
            textLabel.text = NSLocalizedString(@"Турбо", nil);
            break;
        case 1:
            textLabel.text = NSLocalizedString(@"Экономия траффика", nil);
            break;
        case 2:
            textLabel.text = NSLocalizedString(@"Загружать изображения", nil);
            break;
        case 3:
            if (indexPath.row == 0) {
                textLabel.text = NSLocalizedString(@"Оценить приложение", nil);
            } else {
                textLabel.text = NSLocalizedString(@"Связаться с нами", nil);
            }
            break;
        case 4:
            textLabel.text = NSLocalizedString(@"Версия", nil);
            break;
        case 5:
            textLabel.text = NSLocalizedString(@"Выйти", nil);
            break;
        default:
            break;
    }
    if (indexPath.section == 5) {
        textLabel.textColor = [UIColor colorWithRed:0.020 green:0.204 blue:0.553 alpha:1.00];
    }
    textLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    [textLabel sizeToFit];
    CGRect frame = textLabel.frame;
    frame.origin.x = indexPath.section!=0?TABLE_VIEW_STANDARD_LEFT_OFFSET:TABLE_VIEW_STANDARD_LEFT_OFFSET+16;
    frame.origin.y = TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-frame.size.height/2.0;
    
    /*
    //Adding '+10 coins' label
    if (indexPath.section == 2 && indexPath.row == 0 && ![[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_RATED_APP]) {
        frame.origin.y -= 6;
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor grayColor];
        label.text = NSLocalizedString(@"+10 МОНЕТ", nil);
        label.font = [UIFont systemFontOfSize:9];
        [label sizeToFit];
        [label setX: frame.origin.x];
        [label setY:frame.origin.y+frame.size.height+(TABLE_VIEW_STANDARD_ROW_HEIGHT-frame.origin.y-frame.size.height)/2.0-label.frame.size.height/2.0-1];
        [cell.contentView addSubview:label];
    }*/
    textLabel.frame = frame;
    [cell.contentView addSubview:textLabel];
    
    //Adding star image
    if (indexPath.section == 3 && indexPath.row == 0) {
        UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SettingsStar"]];
        CGFloat size = 23;
        imgv.frame = CGRectMake(self.view.frame.size.width-TABLE_VIEW_STANDARD_RIGHT_OFFSET-size-3, TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-size/2.0, size, size);
        [cell.contentView addSubview:imgv];
    }
    
    //Adding turbo image
    if (indexPath.section == 0) {
        UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Turbo"]];
        CGFloat size = 20;
        imgv.frame = CGRectMake([textLabel getOriginX]-size-4, TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-size/2.0, size, size);
        [cell.contentView addSubview:imgv];
    }
    
    //Setting switch (if needed)
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) {
        MDSwitch *_switch = [[MDSwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-TABLE_VIEW_STANDARD_RIGHT_OFFSET-40, TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-10, 40, 20)];
        [cell.contentView addSubview:_switch];
        [_switch addTarget:self action:@selector(updateSwitchValue:) forControlEvents:UIControlEventValueChanged];
        _switch.trackOff = [UIColor colorWithRed:0.741 green:0.741 blue:0.741 alpha:1.00];
        if (indexPath.section == 1) {
            _switch.tag = 0;
            if (![[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TRAFFIC_ECONOMY]) {
                _switch.on = SETTINGS_DEFAULT_VALUE_TRAFFIC_ECONOMY;
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:SETTINGS_DEFAULT_VALUE_TRAFFIC_ECONOMY] forKey:SETTINGS_KEY_TRAFFIC_ECONOMY];
            } else {
                _switch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TRAFFIC_ECONOMY] boolValue];
            }
            _switch.trackOn = [UIColor colorWithRed:0.631 green:0.969 blue:0.765 alpha:1.00];
            _switch.thumbOn = [UIColor colorWithRed:0.275 green:0.941 blue:0.533 alpha:1.00];
        } else if (indexPath.section == 2) {
            _switch.tag = 1;
            if (![[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_LOAD_IMAGES]) {
                _switch.on = SETTINGS_DEFAULT_VALUE_LOAD_IMAGES;
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:SETTINGS_DEFAULT_VALUE_LOAD_IMAGES] forKey:SETTINGS_KEY_LOAD_IMAGES];
            } else {
                _switch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_LOAD_IMAGES] boolValue];
            }
            _switch.trackOn = [UIColor colorWithRed:0.631 green:0.765 blue:0.969 alpha:1.00];
            _switch.thumbOn = [UIColor colorWithRed:0.275 green:0.533 blue:0.941 alpha:1.00];
        } else {
            __switch = _switch;
            [__switch addTarget:self action:@selector(resetCanPrompt) forControlEvents:UIControlEventAllTouchEvents];
            _switch.tag = 2;
            _switch.trackOn = [UIColor colorWithRed:0.949 green:0.875 blue:0.584 alpha:1.00];
            _switch.thumbOn = [[UIColor colorWithRed:0.969 green:0.710 blue:0.204 alpha:1.00] lighten:0.9];
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
    }
    
    //Setting app version
    if (indexPath.section == 4) {
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
        versionLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_APP_VERSION];
        versionLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        versionLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
        [versionLabel sizeToFit];
        frame = versionLabel.frame;
        frame.origin.x = self.view.frame.size.width-TABLE_VIEW_STANDARD_RIGHT_OFFSET-frame.size.width;
        frame.origin.y = TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-frame.size.height/2.0;
        versionLabel.frame = frame;
        [cell.contentView addSubview:versionLabel];
    }
    
    //Changing contact us color if mail cannot be sent
    if (indexPath.section == 3 && indexPath.row == 1) {
        if (![MFMailComposeViewController canSendMail]) {
            
            textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        }
    }
    return cell;
}

- (void) synchronizeSwitch:(BOOL)value {
    canPrompt = NO;
    __switch.on = value;
}

- (void) updateMenu {
    [((LeftMenuViewController*)(((MFSideMenuContainerViewController*)[((AppDelegate*) [[UIApplication sharedApplication] delegate]) container]).leftMenuViewController)) synchronizeSwitch:[[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TURBO] boolValue]];
}

- (void) updateSwitchValue: (id) sender {
    switch (((MDSwitch*)sender).tag) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:((MDSwitch*)sender).on] forKey:SETTINGS_KEY_TRAFFIC_ECONOMY];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:((MDSwitch*)sender).on] forKey:SETTINGS_KEY_LOAD_IMAGES];
            break;
        case 2:
            if (!canPrompt) return;
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_IS_PRIVILEGED] boolValue]) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:((MDSwitch*)sender).on] forKey:SETTINGS_KEY_TURBO];
                [self updateMenu];
            } else if (((MDSwitch*)sender).on == 1) {
                [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(showPrompt) userInfo:nil repeats:NO];
            }
    }
}

- (void) tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        if (indexPath.row == 1) {
            if (![MFMailComposeViewController canSendMail]) return;
            MFMailComposeViewController *mailComposeVC = [MFMailComposeViewController new];
            [mailComposeVC setToRecipients:@[CONTACT_EMAIL]];
            [mailComposeVC setSubject:[NSString stringWithFormat:@"Запрос в поддержку (#%@)", [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]]]];
            mailComposeVC.mailComposeDelegate = self;
            [self presentViewController:mailComposeVC animated:YES completion:nil];
        } else {
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",AS_APP_ID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            [self unlockTurbo:NULL];
        }
    } else if (indexPath.section == 5) {
        [self logout];
    }
}

- (void) productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [timer invalidate];
    timer = nil;
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [tableView reloadData];
    [self updateMenu];
}

- (void) resetCanPrompt {
    canPrompt = YES;
}

- (void) showPrompt {
    prompt = [[SCLAlertView alloc] init];
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

- (void) close{
    [prompt hideView];
    [tableView reloadData];
    [self updateMenu];
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
    [tableView reloadData];
    [self updateMenu];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendUnlock:SERVER_PRIVILEGE_MAX_ATTEMPTS];
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

- (void) logout {
    dispatch_async(dispatch_get_main_queue(), ^{
        [GBStorage(GBSTORAGE_DEFAULT_NAMESPACE) removeAllPermanently];
        for (NSString* key in @[NSUDEFAULTS_KEY_PHOTO_QUEUE,
                                NSUDEFAULTS_KEY_ACCESS_TOKEN,
                                NSUDEFAULTS_KEY_USER_INFO,
                                NSUDEFAULTS_KEY_BALANCE,
                                NSUDEFAULTS_KEY_LIKES_BRIEF,
                                NSUDEFAULTS_KEY_SUBSCRIBERS_BRIEF]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
        [VKSdk forceLogout];
    });
    
    //Transitioning
    UIView *fromView = self.view;
    UIView *toView = (UIView *)([[UIImageView alloc] initWithImage:[self imageWithView:((UIViewController*)([(AppDelegate*)[[UIApplication sharedApplication] delegate] getViewControllerWithIndex:0])).view]]);
    toView.layer.shadowColor = [UIColor blackColor].CGColor;
    toView.layer.shadowOpacity = 0.3;
    toView.layer.shadowOffset = CGSizeMake(10, 0);
    CGRect viewSize = fromView.frame;
    BOOL scrollRight = NO;
    [fromView addSubview:toView];
    toView.frame = CGRectMake((scrollRight ? viewSize.size.width : -viewSize.size.width), viewSize.origin.y, viewSize.size.width, viewSize.size.height);
    [UIView animateWithDuration:ANIMATIONS_DURATION_4X
                     animations: ^{
                         toView.frame = CGRectMake(0, viewSize.origin.y, viewSize.size.width, viewSize.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [fromView removeFromSuperview];
                             [(AppDelegate*)[[UIApplication sharedApplication] delegate] setCenterViewController:0];
                         }
                     }];
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"SettingsSession" timed:YES];
    [tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"SettingsSession" withParameters:NULL];
    [welcome hideView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SETTINGS_WELCOME_SHOWN]) {
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showWelcome) userInfo:nil repeats:NO];
    } else {
        [self attemptToLoadInterestitial];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    unlockRequested = NO;
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 38, 38);
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];

    self.navigationItem.title = NSLocalizedString(@"Настройки", nil);
    for (UIView *parentView in self.navigationController.navigationBar.subviews)
        for (UIView *childView in parentView.subviews)
            if ([childView isKindOfClass:[UIImageView class]])
                [childView removeFromSuperview];
    UIColor *backgrc = [UIColor colorWithWhite:BACKGROUND_WHITE_COMPONENT alpha:1];
    self.view.backgroundColor = backgrc;
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
    self.automaticallyAdjustsScrollViewInsets = NO;
    tableView.backgroundColor = backgrc;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[MDTableViewCell class] forCellReuseIdentifier:@"CellReuseIdentifier"];
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showMenu {
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

#pragma mark - Showing welcome alert
- (void) showWelcome {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:1] forKey:NSUDEFAULTS_KEY_SETTINGS_WELCOME_SHOWN];
    welcome = [[SCLAlertView alloc] init];
    [welcome setTitleFontFamily:@"AvenirNext-Medium" withSize:18];
    [welcome setBodyTextFontFamily:@"AvenirNext-Regular" withSize:13];
    [welcome setShouldDismissOnTapOutside:YES];
    [welcome showCustom:self image:[UIImage imageNamed:@"SettingsImage"] color:[UIColor colorWithRed:0.612 green:0.612 blue:0.620 alpha:1.00] title:NSLocalizedString(TEXT_SETTINGS_WELCOME_TITLE, nil) subTitle:NSLocalizedString(TEXT_SETTINGS_WELCOME_TEXT, nil) closeButtonTitle:@"ОК" duration:15.0];
}

@end
