//
//  VKGetSubscribersViewController.m
//  VK Likes
//
//  Created by Vlad on 26/12/15.
//  Copyright © 2015 Vlad Shakhray. All rights reserved.
//

#import "VKGetSubscribersViewController.h"

#define _k @"SHOULD_SHOW_INTERESTITIAL"
#define _sh @"SERVER_PERMISSION_TO_SHOW_AD"
#define udfset(obj, key) [[NSUserDefaults standardUserDefaults] setObject: obj forKey: key]
#define udfsetbool(bool, key) [[NSUserDefaults standardUserDefaults] setBool: bool forKey: key]
#define udfgetobj(key) [[NSUserDefaults standardUserDefaults] objectForKey: key]
#define udfgetbool(key) [[NSUserDefaults standardUserDefaults] boolForKey: key]

CGFloat separatorWidth = 0.5;
CGFloat borderOffset = 14;
@implementation VKGetSubscribersViewController

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

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Setting Flurry
    [Flurry logEvent:@"GetSubscribersSession" timed:YES];
    
    //Setting VK SDK
    [VKSdk instance].uiDelegate = self;
    
    UIImage* profilePhoto = GBStorage(GBSTORAGE_DEFAULT_NAMESPACE)[GBSTORAGE_PHOTO_MAX_SQUARED];
    if (profilePhoto)
        [photoImageView setImage:profilePhoto];
    
    //Updating
    [self updateBrief];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setMinimumDismissTimeInterval:1.0];
    
    [self updateData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_GET_SUBSCRIBERS_WELCOME_SHOWN]) {
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showWelcome) userInfo:nil repeats:NO];
    } else {
        [self attemptToLoadInterestitial];
    }
    [self updateBalance];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1];
    
    //Setting VK SDK initial parameters
    isCaptchaPresented = NO;
    
    //Constants
    CGFloat cornerRadius = 7;
    
    //Adding arrow
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 38, 38);
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    [self.view addSubview:menuButton];
    
    //Setting navigation title
    self.navigationItem.title = NSLocalizedString(self.view.frame.size.width!=320?@"Заказать подписчиков":@"Подписчики", nil);
    for (UIView *parentView in self.navigationController.navigationBar.subviews)
        for (UIView *childView in parentView.subviews)
            if ([childView isKindOfClass:[UIImageView class]])
                [childView removeFromSuperview];
    
    //Adding profile photo
    CGFloat imageSize = self.view.frame.size.height==480?80:self.view.frame.size.width/2.5;
    photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-imageSize/2.0, self.view.frame.size.height==480?64+30:self.view.frame.size.height/5.0, imageSize, imageSize)];
    photoImageView.layer.cornerRadius = imageSize/2;
    photoImageView.clipsToBounds = YES;
    [self.view addSubview:photoImageView];
    
    //Adding friends label
    CGFloat _1offset = self.view.frame.size.height==480?28:40;
    friendsLabel = [[UILabel alloc] init];
    friendsLabel.text = @"0";
    friendsLabel.font = [UIFont systemFontOfSize:20.0f];
    friendsLabel.textColor = [UIColor blackColor];
    [friendsLabel sizeToFit];
    [friendsLabel setY:photoImageView.frame.origin.y+photoImageView.frame.size.height+_1offset];
    [self.view addSubview:friendsLabel];
    
    //Adding followers label
    followersLabel = [[UILabel alloc] init];
    followersLabel.text = @"0";
    followersLabel.font = [UIFont systemFontOfSize:20.0f];
    followersLabel.textColor = [UIColor blackColor];
    [followersLabel sizeToFit];
    [followersLabel setY:photoImageView.frame.origin.y+photoImageView.frame.size.height+_1offset];
    [self.view addSubview:followersLabel];
    
    //Adding in order label
    inOrderLabel = [[UILabel alloc] init];
    inOrderLabel.text = @"0/0";
    inOrderLabel.font = [UIFont systemFontOfSize:20.0f];
    inOrderLabel.textColor = [UIColor blackColor];
    [inOrderLabel sizeToFit];
    [inOrderLabel setY:photoImageView.frame.origin.y+photoImageView.frame.size.height+_1offset];
    [self.view addSubview:inOrderLabel];
    
    //Adding title labels
    CGFloat offset = 8;
    UILabel *titleLabel1 = [[UILabel alloc] init];
    UILabel *titleLabel2 = [[UILabel alloc] init];
    UILabel *titleLabel3 = [[UILabel alloc] init];
    titleLabel1.text = NSLocalizedString(@"ДРУЗЕЙ", nil);
    titleLabel2.text = NSLocalizedString(@"ПОДПИСЧИКОВ", nil);
    titleLabel3.text = NSLocalizedString(@"В ЗАКАЗЕ", nil);
    titleLabel1.font = [UIFont systemFontOfSize:9.0f];
    titleLabel2.font = [UIFont systemFontOfSize:9.0f];
    titleLabel3.font = [UIFont systemFontOfSize:9.0f];
    titleLabel1.textColor = [UIColor grayColor];
    titleLabel2.textColor = [UIColor grayColor];
    titleLabel3.textColor = [UIColor grayColor];
    [titleLabel1 sizeToFit];
    [titleLabel2 sizeToFit];
    [titleLabel3 sizeToFit];
    [titleLabel1 setY:friendsLabel.frame.origin.y+friendsLabel.frame.size.height+offset];
    [titleLabel2 setY:friendsLabel.frame.origin.y+friendsLabel.frame.size.height+offset];
    [titleLabel3 setY:friendsLabel.frame.origin.y+friendsLabel.frame.size.height+offset];
    [titleLabel1 setX:borderOffset+(self.view.frame.size.width-2*borderOffset-2*separatorWidth)*0.5/3.0 - titleLabel1.frame.size.width/2.0];
    [titleLabel2 setX:borderOffset+separatorWidth+(self.view.frame.size.width-2*borderOffset-2*separatorWidth)*1.5/3.0-titleLabel2.frame.size.width/2.0];
    [titleLabel3 setX:borderOffset+2*separatorWidth+(self.view.frame.size.width-2*borderOffset-2*separatorWidth)*2.5/3.0-titleLabel3.frame.size.width/2.0];
    [self.view addSubview:titleLabel1];
    [self.view addSubview:titleLabel2];
    [self.view addSubview:titleLabel3];
    [self updateFriendsAndFollowersLabels];
    [self updateInOrderLabel];
    
    //Adding order view
    backgroundOrderView = [[UIView alloc] initWithFrame:CGRectMake(borderOffset, titleLabel1.frame.origin.y+32, self.view.frame.size.width-2*borderOffset, 90)];
    backgroundOrderView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    backgroundOrderView.layer.cornerRadius = cornerRadius;
    [self.view addSubview:backgroundOrderView];
    
    //Adding order button
    CGFloat buttonsOffset = 8;
    UIColor *masterColor = [[UIColor colorWithRed:0.286 green:0.494 blue:0.882 alpha:1.00] lighten:0.6];
    orderButton = [UIButton new];
    [orderButton addTarget:self action:@selector(orderSubscribers:) forControlEvents:UIControlEventTouchUpInside];
    [orderButton setTitle:NSLocalizedString(@"ЗАКАЗАТЬ", nil) forState:UIControlStateNormal];
    orderButton.backgroundColor = masterColor;
    [orderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    orderButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    orderButton.frame = CGRectMake([backgroundOrderView getOriginX], [backgroundOrderView getLowerBound]+buttonsOffset, backgroundOrderView.frame.size.width, 34);
    orderButton.layer.cornerRadius = cornerRadius;
    [self.view addSubview:orderButton];
    
    CGFloat shopSize = 50;
    MDButton *button = [[MDButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-shopSize/2.0, self.view.frame.size.height-shopSize-16, shopSize, shopSize)];
    button.tag = 149;
    [button addTarget:self action:@selector(purchaseCoins) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = shopSize/2.0;
    [button setBackgroundColor:[UIColor colorWithRed:0.169 green:0.518 blue:0.941 alpha:1.00]];
    [button setImage:[UIImage imageNamed:@"ShopRepost"] forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    //Adding slider
    CGFloat sliderBorderOffset = 22;
    CGFloat sliderHeight = 20;
    CGFloat sliderBottomOffset = 20;
    CGFloat sliderWidth = backgroundOrderView.frame.size.width-2*sliderBorderOffset;
    slider = [[UISlider alloc] initWithFrame:CGRectMake(sliderBorderOffset, [backgroundOrderView getHeight]-sliderBottomOffset-sliderHeight, sliderWidth, sliderHeight)];
    [slider setThumbImage:[UIImage imageNamed:@"ThumbImage"] forState:UIControlStateNormal];
    [slider setTintColor:masterColor];
    slider.minimumValue = 5.0f;
    slider.maximumValue = 450.0f;
    slider.value = 9.0f;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider setMaximumTrackTintColor:[UIColor colorWithRed:0.725 green:0.710 blue:0.678 alpha:1.00]];
    [backgroundOrderView addSubview:slider];
    
    //Adding separators
    UIView *sep1 = [UIView new];
    UIView *sep2 = [UIView new];
    sep1.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    sep2.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    CGFloat sepoffset = 6;
    sep1.frame = CGRectMake(borderOffset+(self.view.frame.size.width-2*borderOffset-2*separatorWidth)*2/3.0, [friendsLabel getOriginY]+sepoffset, separatorWidth, [titleLabel3 getLowerBound]-[friendsLabel getOriginY]-2*sepoffset);
    sep2.frame = CGRectMake(borderOffset+separatorWidth+(self.view.frame.size.width-2*borderOffset-2*separatorWidth)/3.0, [friendsLabel getOriginY]+sepoffset, separatorWidth, [titleLabel3 getLowerBound]-[friendsLabel getOriginY]-2*sepoffset);
    [self.view addSubview:sep1];
    [self.view addSubview:sep2];
    
    //Adding subtotal
    [self updateSubtotal];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"GetSubscribersSession" withParameters:NULL];
    [welcome hideView];
}


#pragma mark - Ordering
- (void) orderSubscribers: (id) sender {
    int subscribers = ((int) slider.value/5)*5;
    int price = subscribers*7;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_BALANCE] intValue] < price) {
        [self purchaseCoins];
        return;
    }
    [SVProgressHUD setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14]];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int subscribers = ((int) slider.value/5)*5;
        NSString *token = [Utilities generateUniqueString];
        NSString *quantity = [NSString stringWithFormat:@"%i", subscribers];
        NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
        int dateAddedInt = [[NSDate date] timeIntervalSince1970];
        NSString *dateAdded = [NSString stringWithFormat:@"%i", dateAddedInt];
        NSString *priority = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TURBO] boolValue]&[[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_IS_PRIVILEGED] boolValue]];
        NSString *key = [NSStringFromClass([UIButton class]) sha256];
        NSString *pass = [[NSString stringWithFormat:@"%@%@%@%@%@%@", token, userID, dateAdded, quantity, priority, key] sha512];
        NSDictionary *parameters = @{   @"token":token,
                                        @"user_id":userID,
                                        @"date_added":dateAdded,
                                        @"quantity":quantity,
                                        @"priority":priority,
                                        @"pass":pass
                                        };
        NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_REQUEST_SUBSCRIBERS_PATH];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
        serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.responseSerializer = serializer;
        manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
        [manager GET:baseURLString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject objectForKey:@"response"]) {
                int money = [responseObject[@"response"][@"balance"] intValue];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:money] forKey:NSUDEFAULTS_KEY_BALANCE];
                [self updateBalance];
                [self updateBrief];
                [((AppDelegate *) [[UIApplication sharedApplication] delegate]) updateLeftMenu];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Заказ принят!", nil)];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Ошибка сервера", nil)];
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Нет соединения", nil)];
        }];
    });
}

- (void) sliderValueChanged: (id) sender {
    [self updateSubtotal];
}

- (void) updateBrief {
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    NSString *type = @"subscriber";
    NSString *key = [NSStringFromClass([UIImageView class]) sha256];
    NSString *pass = [[NSString stringWithFormat:@"%@%@%@", userID, type, key] sha512];
    NSDictionary *parameters = @{@"user_id":userID,
                                 @"type":type,
                                 @"pass":pass
                                 };
    NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_REQUEST_TOTALS_PATH];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer = serializer;
    manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
    [manager GET:baseURLString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (responseObject[@"response"]) {
            NSNumber *number1 = [NSNumber numberWithInt:[responseObject[@"response"][0][@"completed"] intValue]];
            NSNumber *number2 = [NSNumber numberWithInt:[responseObject[@"response"][0][@"ordered"] intValue]];
            [[NSUserDefaults standardUserDefaults] setObject:@[number1, number2] forKey:NSUDEFAULTS_KEY_SUBSCRIBERS_BRIEF];
            [self updateInOrderLabel];
        } else if (responseObject[@"error"]) {
            [Flurry logError:@"Server error" message:[NSString stringWithFormat:@"%i", [responseObject[@"error"] intValue]] error:NULL];
        } else {
            [Flurry logError:@"Corrupted response" message:NULL error:NULL];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        ;
    }];
}

- (void) updateSubtotal {
    [subtotalView removeFromSuperview];
    subtotalView = [UIView new];
    UIColor *subtotalColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.00];
    UIImageView *subscriberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SubscriberGray_32"]];
    [subscriberImageView sizeToFit];
    UILabel *subscribersLabel = [UILabel new];
    subscribersLabel.text = [NSString stringWithFormat:@"%i", (int) (slider.value/5) *5];
    subscribersLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15];
    subscribersLabel.textColor = subtotalColor;
    [subscribersLabel sizeToFit];
    UILabel *equalLabel = [UILabel new];
    equalLabel.textColor = subtotalColor;
    equalLabel.text = @"=";
    equalLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15];
    [equalLabel sizeToFit];
    UIImageView *costImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CoinsGray_32"]];
    [costImageView sizeToFit];
    UILabel *costLabel = [UILabel new];
    costLabel.text = [NSString stringWithFormat:@"%i", ((int) (slider.value/5) *5)*7];
    costLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15];
    costLabel.textColor = subtotalColor;
    [costLabel sizeToFit];
    CGFloat sideOffset = 10;
    CGFloat mid = 5;
    [subtotalView removeFromSuperview];
    CGRect frame = subtotalView.frame;
    frame.size.height = 2*sideOffset + MAX(subscriberImageView.frame.size.height, MAX(subscribersLabel.frame.size.height, MAX(equalLabel.frame.size.height, MAX(costImageView.frame.size.height, costLabel.frame.size.height))));
    frame.size.width = sideOffset + subscriberImageView.frame.size.width+mid+subscribersLabel.frame.size.width+mid+equalLabel.frame.size.width+mid+costImageView.frame.size.width+mid+costLabel.frame.size.width+sideOffset;
    frame.origin.x = backgroundOrderView.frame.size.width/2.0-frame.size.width/2.0;
    frame.origin.y = 15;
    subtotalView.frame = frame;
    CGFloat h = frame.size.height;
    [subscriberImageView setOrigin:CGPointMake(sideOffset, h/2.0-subscriberImageView.frame.size.height/2.0)];
    [subscribersLabel setOrigin:CGPointMake(sideOffset+mid+subscriberImageView.frame.size.width, h/2.0-subscribersLabel.frame.size.height/2.0)];
    [equalLabel setOrigin:CGPointMake(subscribersLabel.frame.origin.x+subscribersLabel.frame.size.width+mid, h/2.0-equalLabel.frame.size.height/2.0)];
    [costImageView setOrigin:CGPointMake(equalLabel.frame.origin.x+mid+equalLabel.frame.size.width, h/2.0-costImageView.frame.size.height/2.0)];
    [costLabel setOrigin:CGPointMake(costImageView.frame.size.width+mid+costImageView.frame.origin.x, h/2.0-costLabel.frame.size.height/2.0)];
    [subtotalView addSubview:subscriberImageView];
    [subtotalView addSubview:subscribersLabel];
    [subtotalView addSubview:equalLabel];
    [subtotalView addSubview:costImageView];
    [subtotalView addSubview:costLabel];
    [backgroundOrderView addSubview:subtotalView];
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - Updating

//Updates friends and followers label
- (void) updateFriendsAndFollowersLabels {
    NSString *friendsText = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"counters"][@"friends"] intValue]];
    NSString *followersText = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"counters"][@"followers"] intValue]];
    
    [friendsLabel setWidth:999];
    [friendsLabel setText:friendsText];
    [friendsLabel sizeToFit];
    [friendsLabel setX:borderOffset+(self.view.frame.size.width-2*borderOffset-2*separatorWidth)*0.5/3.0-friendsLabel.frame.size.width/2.0];
    
    [followersLabel setWidth:999];
    [followersLabel setText:followersText];
    [followersLabel sizeToFit];
    [followersLabel setX:borderOffset+separatorWidth+(self.view.frame.size.width-2*borderOffset-2*separatorWidth)*1.5/3.0-followersLabel.frame.size.width/2.0];
    
}

//Update the label with the completed/ordered information
- (void) updateInOrderLabel {
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SUBSCRIBERS_BRIEF];
    int completed = [array[0] intValue];
    int ordered = [array[1] intValue];
    NSString *buttonText = [NSString stringWithFormat:@"%i / %i", completed, ordered];
    [inOrderLabel setWidth:999];
    [inOrderLabel setText:buttonText];
    [inOrderLabel sizeToFit];
    [inOrderLabel setX:borderOffset+2*separatorWidth+(self.view.frame.size.width-2*borderOffset-2*separatorWidth)*2.5/3.0-inOrderLabel.frame.size.width/2.0];
}

- (void) purchaseCoins {
    ShopViewController *shopVC = [[ShopViewController alloc] initWithModal:YES];
    ModalShopNavigationViewController *shopNavVc = [[ModalShopNavigationViewController alloc] initWithRootViewController:shopVC];
    shopVC.delegate = shopNavVc;
    shopNavVc.shopDelegate = self;
    [self presentViewController:shopNavVc animated:YES completion:nil];
}

- (void) finished:(UIViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateBalance {
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(-999, -999, 999, 24)];
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    moneyLabel.text = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_BALANCE] intValue]];
    moneyLabel.textColor = [UIColor whiteColor];
    moneyLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:18];
    [moneyLabel sizeToFit];
    CGRect frame = moneyLabel.frame;
    frame.origin.x = 24;
    frame.origin.y = 12-moneyLabel.frame.size.height/2.0;
    moneyLabel.frame = frame;
    UIImageView *coinsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Balance"]];
    coinsImageView.frame = CGRectMake(0, 3, 18, 18);
    [navigationView addSubview:moneyLabel];
    [navigationView addSubview:coinsImageView];
    CGPoint point = [navigationView convertPoint:navigationView.frame.origin toView:self.navigationController.navigationBar];
    CGRect rect = navigationView.frame;
    rect.origin.y+=5;
    rect.size.width=24+moneyLabel.frame.size.width;
    rect.origin.x = self.view.frame.size.width-point.x/2.0-24;
    navigationView.frame = rect;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navigationView];
}

- (void) showMenu {
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

#pragma mark - Updating user info

- (void) updateData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateDataPerformTask];
    });
}

- (void) updateDataPerformTask {
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    VKRequest *userInfoRequest = [[VKApi users] get:@{VK_API_USER_IDS:userID, VK_API_FIELDS:@"status,counters,sex,bdate,verified,photo_max,deactivated", VK_API_ACCESS_TOKEN:[[NSUserDefaults standardUserDefaults] objectForKey: NSUDEFAULTS_KEY_ACCESS_TOKEN]}];
    userInfoRequest.attempts = 5;
    userInfoRequest.requestTimeout = VK_TIMEOUT;
    [userInfoRequest executeWithResultBlock:^(VKResponse *response) {
        
        [[NSUserDefaults standardUserDefaults] setObject:(NSDictionary*)(response.json[0]) forKey:NSUDEFAULTS_KEY_USER_INFO];
        [self updateFriendsAndFollowersLabels];
        
    } errorBlock:^(NSError *error) {

    }];
}

#pragma mark - VK SDK

- (void) vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    if (!isCaptchaPresented) {
        VKCaptchaViewController *captchaVC = [VKCaptchaViewController captchaControllerWithError:captchaError];
        [self presentViewController:captchaVC animated:YES completion:nil];
        isCaptchaPresented = YES;
    }
}

- (void) vkSdkWillDismissViewController:(UIViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    isCaptchaPresented = NO;
}

#pragma mark - Showing welcome alert

- (void) showWelcome {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:1] forKey:NSUDEFAULTS_KEY_GET_SUBSCRIBERS_WELCOME_SHOWN];
    welcome = [[SCLAlertView alloc] init];
    [welcome setTitleFontFamily:@"AvenirNext-Medium" withSize:18];
    [welcome setBodyTextFontFamily:@"AvenirNext-Regular" withSize:13];
    [welcome setShouldDismissOnTapOutside:YES];
    [welcome showCustom:self image:[UIImage imageNamed:@"GetSubscribersImage"] color:[UIColor colorWithRed:0.427 green:0.600 blue:0.427 alpha:1.00] title:NSLocalizedString(TEXT_GET_SUBSCRIBERS_WELCOME_TITLE, nil) subTitle:NSLocalizedString(TEXT_GET_SUBSCRIBERS_WELCOME_TEXT, nil) closeButtonTitle:NSLocalizedString(@"ОК",nil) duration:15.0];
}

@end
