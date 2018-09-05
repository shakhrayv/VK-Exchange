//
//  VKAuthorizationViewController.m
//  VK Likes
//
//  Created by Vlad on 23/09/15.
//  Copyright © 2015 Vlad Shakhray. All rights reserved.
//

#import "VKAuthorizationViewController.h"

@implementation VKAuthorizationViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    sdkInstance = [VKSdk initializeWithAppId:VK_APP_ID];
    [sdkInstance registerDelegate:self];
    [sdkInstance setUiDelegate:self];
    
    //Setting background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGFloat offset = 150;
    UIImage *backgroundImage = [UIImage imageNamed:@"Background"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, offset, self.view.frame.size.width, backgroundImage.size.height*self.view.frame.size.width/backgroundImage.size.width)];
    imageView.image = backgroundImage;
    [self.view addSubview:imageView];
    CAGradientLayer *gradient = [CAGradientLayer layer];//Adding gradient
    gradient.frame = imageView.bounds;
    CGRect frame = imageView.bounds;
    frame.size.height=self.view.frame.size.height-offset;
    gradient.frame = frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:0.8] CGColor], nil];
    [imageView.layer insertSublayer:gradient atIndex:0];
    
    //Adding login button
    CGFloat w, h;
    w = self.view.frame.size.width;
    h = self.view.frame.size.height;
    loginButton = [[UIButton alloc] initWithFrame:CGRectMake(w/2.0 - LOGIN_BUTTON_WIDTH/2.0, h-LOGIN_BUTTON_OFFSET_BOTTOM-LOGIN_BUTTON_HEIGHT, LOGIN_BUTTON_WIDTH, LOGIN_BUTTON_HEIGHT)];
    [loginButton setTitle:NSLocalizedString(@"Войти", nil) forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
    [loginButton addTarget:self action:@selector(authorize) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setBackgroundColor:[[UIColor colorWithRed:0.827 green:0.251 blue:0.329 alpha:1.00] lighten:0.1]];
    loginButton.layer.cornerRadius = 6;
    loginButton.layer.borderWidth = 1;
    loginButton.layer.borderColor = [UIColor colorWithRed:0.427 green:0.020 blue:0.035 alpha:1.00].CGColor;
    loginButton.alpha = 1;
    [self.view addSubview:loginButton];
    UIImageView *VKLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VKLogo"]];
    CGFloat k = 0.17;
    [VKLogo setFrame:CGRectMake(30, 16, 154*k, 89*k)];
    [loginButton addSubview:VKLogo];
    
    [loginButton addTarget:self action:@selector(touchStarted:) forControlEvents:UIControlEventTouchDown];
    [loginButton addTarget:self action:@selector(touchEnded:) forControlEvents:UIControlEventTouchDragExit];
    
    //Adding title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    title.text = @"Накрутка";
    title.font = [UIFont fontWithName:@"AvenirNext-Medium" size:36];
    title.textColor = [UIColor colorWithRed:0.267 green:0.267 blue:0.267 alpha:1.00];
    title.textAlignment = NSTextAlignmentCenter;
    [title sizeToFit];
    UILabel *vkLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    vkLabel.text = @"ВКонтакте";
    vkLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
    vkLabel.textAlignment = NSTextAlignmentCenter;
    vkLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.00];
    [vkLabel sizeToFit];
    frame = title.frame;
    frame.origin.x = 20;
    frame.origin.y = offset-15-vkLabel.frame.size.height-title.frame.size.height;
    title.frame = frame;
    frame = vkLabel.frame;
    frame.origin.x = 30;
    frame.origin.y = offset-15-vkLabel.frame.size.height;
    vkLabel.frame = frame;
    [self.view addSubview:title];
    [self.view addSubview:vkLabel];
    
    //Adding heart image view
    CGFloat heartSize = 34;
    UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Heart_Red"]];
    heartImageView.frame = CGRectMake(title.frame.origin.x+title.frame.size.width+10, title.frame.origin.y+title.frame.size.height/2.0-heartSize/2.0, heartSize, heartSize);
    [self.view addSubview:heartImageView];
    
    //Adding license label and button
    UILabel *licenseLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    licenseLabel.text = NSLocalizedString(@"Используя данное приложение, Вы соглашаетесь с", nil);
    licenseLabel.textColor = [UIColor whiteColor];
    licenseLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
    licenseLabel.textAlignment = NSTextAlignmentCenter;
    [licenseLabel sizeToFit];
    UIButton *licenseButton = [[UIButton alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    [licenseButton setTitle:NSLocalizedString(@"Правилами", nil) forState:UIControlStateNormal];
    [licenseButton addTarget:self action:@selector(presentLicense) forControlEvents:UIControlEventTouchUpInside];
    [licenseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [licenseButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    licenseButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    [licenseButton sizeToFit];
    CGFloat licenseOffset = 14;
    CGFloat licenseDiff = 4;
    frame = licenseLabel.frame;
    frame.origin.x = self.view.frame.size.width/2.0-(licenseLabel.frame.size.width+licenseButton.frame.size.width+licenseDiff)/2.0;
    frame.origin.y = self.view.frame.size.height-licenseOffset-licenseLabel.frame.size.height/2.0;
    licenseLabel.frame = frame;
    frame = licenseButton.frame;
    frame.origin.x = self.view.frame.size.width/2.0-(-licenseLabel.frame.size.width+licenseButton.frame.size.width-licenseDiff)/2.0;
    frame.origin.y = self.view.frame.size.height-licenseOffset-licenseButton.frame.size.height/2.0;
    licenseButton.frame = frame;
    [self.view addSubview:licenseLabel];
    [self.view addSubview:licenseButton];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = loginButton.frame;
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];
    activityIndicator.alpha = 0;
    
    scope = @[VK_PER_PHOTOS, VK_PER_FRIENDS, VK_PER_WALL, VK_PER_GROUPS];
    [self showIfLoading:YES];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"nsudefaults_key_first_run"] || ![[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_ID]) {
        [VKSdk forceLogout];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:1] forKey:@"nsudefaults_key_first_run"];
    }
    [VKSdk wakeUpSession:scope completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            if (![self checkForLoadedInformation]) {
                [self loadVKData];
            } else {
                [self authorizationCompleted];
            }
        } else if (error) {
        }
    }];
    [self showIfLoading:NO];
}

- (void) vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
    isCaptchaPresented = NO;
}


- (void) vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    if (!isCaptchaPresented) {
        VKCaptchaViewController *captchaVC = [VKCaptchaViewController captchaControllerWithError:captchaError];
        [self presentViewController:captchaVC animated:YES completion:nil];
        isCaptchaPresented = YES;
    }
}

- (void) authorizationCompleted {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *token = [Utilities generateUniqueString];
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_ID];
        NSString *urlString = [NSString stringWithFormat:@"%@/user.shouldReward.php?token=%@&user_id=%@&pass=%@", SERVER_URL, token, userID, [[NSString stringWithFormat:@"%@%@%@", token, userID, [NSStringFromClass([NSSet class]) sha256]] sha512]];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:SERVER_TIMEOUT];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject[@"response"] boolValue])
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_BALANCE] intValue]+15] forKey:NSUDEFAULTS_KEY_BALANCE];
            [[NSUserDefaults standardUserDefaults] setBool:[responseObject[@"response"] boolValue] forKey:NSUDEFAULTS_KEY_SHOULD_REWARD];
            [self.menuContainerViewController setPanMode:MFSideMenuPanModeDefault];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] updateLeftMenu];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setCenterViewController:1];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showErrorWithTitle:@"Неизвестная ошибка" message:error.description cancelButtonTitle:@"ОК"];
            [[NSUserDefaults standardUserDefaults] setBool:0 forKey:NSUDEFAULTS_KEY_SHOULD_REWARD];
        }];
        [operation start];
    });
}

- (BOOL) checkForLoadedInformation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return  [defaults objectForKey:NSUDEFAULTS_KEY_PHOTO_QUEUE] &&
            [defaults objectForKey:NSUDEFAULTS_KEY_BALANCE] &&
            [defaults objectForKey:NSUDEFAULTS_KEY_USER_INFO] &&
            [defaults objectForKey:NSUDEFAULTS_KEY_WALL_POSTS];
}

#pragma mark - Login button

- (void) showErrorWithTitle: (NSString *) title message: (NSString *) message cancelButtonTitle: (NSString *) buttonTitle {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(title
, nil) message:NSLocalizedString(message, nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* button = [UIAlertAction actionWithTitle:NSLocalizedString(buttonTitle, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
    [alert addAction:button];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) showIfLoading: (BOOL) loading {
    activityIndicator.alpha = loading;
    loginButton.alpha = !loading;
    [self.view setNeedsDisplay];
}

#pragma mark - Delegate methods

- (void) authorize {
    [self touchEnded:loginButton];
    [self showIfLoading:YES];
    [VKSdk wakeUpSession:scope completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            if (![self checkForLoadedInformation]) {
                [self loadVKData];
            } else {
                [self authorizationCompleted];
            }
        } else if (state == VKAuthorizationInitialized || state==VKAuthorizationError) {
            [VKSdk authorize:scope];
        }
    }];
}

- (void) vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {
        [[NSUserDefaults standardUserDefaults] setObject: [NSString stringWithFormat:@"%i", [result.user.id intValue]] forKey:NSUDEFAULTS_KEY_USER_ID];
        [[NSUserDefaults standardUserDefaults] setObject:result.token.accessToken forKey:NSUDEFAULTS_KEY_ACCESS_TOKEN];
        [self loadVKData];
    } else {
        [self showIfLoading:NO];
    }
}

- (void) vkSdkAccessTokenUpdated:(VKAccessToken *)newToken oldToken:(VKAccessToken *)oldToken {
    [[NSUserDefaults standardUserDefaults] setObject:newToken.accessToken forKey:NSUDEFAULTS_KEY_ACCESS_TOKEN];
}

- (void) vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self showIfLoading:YES];
    [self authorize];
}

- (void) vkSdkUserAuthorizationFailed {
    [self showIfLoading:NO];
}

#pragma mark - Loading required user data

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) resetViewControllers];
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]) resetLeftMenuIndex];
    [self.menuContainerViewController setPanMode:MFSideMenuPanModeNone];
    [self showIfLoading:NO];
}

- (void) loadVKData {
    
    //Configuring ads
    __block NSString *errorDescription;
    __block NSMutableArray *photoArray = [NSMutableArray new];
    int taskCount = 0;
    __block int tasksCompleted = 0;
    __block BOOL shouldCancel = NO;
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_ID];
    
    //Getting photo queue
    VKRequest *profileRequest = [VKRequest requestWithMethod:@"photos.get" parameters:@{VK_API_ALBUM_ID:@"profile", @"photo_sizes":@"1", VK_API_EXTENDED: @"1", @"rev":@"1", VK_API_USER_ID:userID, VK_API_COUNT:[NSString stringWithFormat:@"%i", MAX_PROFILE_PHOTOS]}];
    profileRequest.attempts = 5;
    profileRequest.requestTimeout = VK_TIMEOUT;
    [profileRequest executeWithResultBlock:^(VKResponse *response) {
        NSMutableArray *array = response.json[@"items"];
        [photoArray addObjectsFromArray:array];
        tasksCompleted++;
        VKRequest* wallRequest = [VKRequest requestWithMethod:@"photos.get" parameters:@{VK_API_ALBUM_ID:@"wall", @"photo_sizes":@"1", VK_API_EXTENDED: @"1", @"rev":@"1", VK_API_USER_ID:userID, VK_API_COUNT:[NSString stringWithFormat:@"%i", MAX_WALL_PHOTOS]}];
        wallRequest.attempts = 5;
        wallRequest.requestTimeout = VK_TIMEOUT;
        [wallRequest executeWithResultBlock:^(VKResponse *response) {
            NSMutableArray *array = response.json[@"items"];
            [photoArray addObjectsFromArray:array];
            tasksCompleted++;
        } errorBlock:^(NSError *error) {
            errorDescription = error.description;
            shouldCancel = YES;
        }];
    } errorBlock:^(NSError *error) {
        errorDescription = error.description;
        shouldCancel = YES;
    }];
    taskCount+=2;
    
    //Getting wall posts
    VKRequest *wallRequest = [VKRequest requestWithMethod:@"wall.get" parameters:@{@"owner_id":userID, VK_API_EXTENDED: @"1", VK_API_COUNT:[NSString stringWithFormat:@"%i", MAX_WALL_POSTS]}];
    wallRequest.attempts = 5;
    wallRequest.requestTimeout = VK_TIMEOUT;
    [wallRequest executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"%@", response.json);
        [[NSUserDefaults standardUserDefaults] setObject:(NSDictionary*)response.json forKey:NSUDEFAULTS_KEY_WALL_POSTS];
        tasksCompleted++;
    } errorBlock:^(NSError *error) {
        errorDescription = error.description;
        shouldCancel = YES;
    }];
    taskCount+=1;
    
    //Getting main user info
    VKRequest *userInfoRequest = [[VKApi users] get:@{@"user_ids":userID, @"fields":@"status,counters,sex,bdate,verified,photo_max,deactivated", VK_API_ACCESS_TOKEN:[[NSUserDefaults standardUserDefaults] objectForKey: NSUDEFAULTS_KEY_ACCESS_TOKEN]}];
    userInfoRequest.attempts = 5;
    userInfoRequest.requestTimeout = VK_TIMEOUT;
    [userInfoRequest executeWithResultBlock:^(VKResponse *response) {
        
        //Seting sex
        if (response.json[0][@"sex"]) {
            switch ([response.json[0][@"sex"] intValue]) {
                case 1:
                    [Flurry setGender:@"f"];
                    break;
                case 2:
                    [Flurry setGender:@"m"];
                    break;
                default:
                    break;
            }
        }
        
        //Setting age
        if (response.json[0][@"bdate"] && [((NSString*)response.json[0][@"bdate"]) length]>5) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"dd.MM.yyyy"];
            NSDate*date = [dateFormatter dateFromString:((NSString*)response.json[0][@"bdate"])];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                                       fromDate:date
                                                         toDate:[NSDate date]
                                                        options:0];
            int years = (int) components.year;
            [Flurry setAge:years];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:(NSDictionary*)(response.json[0]) forKey:NSUDEFAULTS_KEY_USER_INFO];
        tasksCompleted++;
        NSString* urlString = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"photo_max"];
        NSURL* url = [NSURL URLWithString:urlString];
        NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:SERVER_TIMEOUT];
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            GBStorage(GBSTORAGE_DEFAULT_NAMESPACE)[GBSTORAGE_PHOTO_MAX_SQUARED] = responseObject;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [GBStorage(GBSTORAGE_DEFAULT_NAMESPACE) save:GBSTORAGE_PHOTO_MAX_SQUARED];
            });
            
            tasksCompleted++;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            errorDescription = error.description;
            shouldCancel = YES;
        }];
        [requestOperation start];
        
    } errorBlock:^(NSError *error) {
        errorDescription = error.description;
        shouldCancel = YES;
    }];
    taskCount+=2;
    
    //Getting money information
    NSString *token = [Utilities generateUniqueString];
    NSString *urlString = [NSString stringWithFormat:@"%@/user.register.php?token=%@&user_id=%@&pass=%@", SERVER_URL, token, userID, [[NSString stringWithFormat:@"%@%@%@", token, userID, [NSStringFromClass([NSString class]) sha256]] sha512]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:SERVER_TIMEOUT];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[responseObject[@"balance"] intValue]] forKey:NSUDEFAULTS_KEY_BALANCE];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[responseObject[@"privileged"] boolValue]] forKey:NSUDEFAULTS_KEY_IS_PRIVILEGED];
        tasksCompleted++;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorDescription = error.description;
        shouldCancel = YES;
    }];
    [operation start];
    taskCount++;
    
    //Waiting until all processes are finished
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (taskCount!=tasksCompleted){
            if (shouldCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showErrorWithTitle:@"Неизвестная ошибка" message:errorDescription cancelButtonTitle:@"ОК"];
                });
                return;
            }
            usleep(100);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:photoArray forKey:NSUDEFAULTS_KEY_PHOTO_QUEUE];
            [self authorizationCompleted];
        });
    });
    
}


#pragma mark - License

- (void) presentLicense {
    LicenseViewController *licenseVC = [LicenseViewController new];
    licenseVC.delegate = self;
    LicenseNavigationViewController *navVC = [[LicenseNavigationViewController alloc] initWithRootViewController:licenseVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void) close:(id)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button darkening

- (void) touchStarted: (UIButton *) button {
    CGColorRef cgcolor = [button.backgroundColor CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(cgcolor);
    
    if(CGColorGetNumberOfComponents(cgcolor) == 2) {
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        [button.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
        [button setBackgroundColor:[color darken:0.2]];
    } else if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(cgcolor);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [button setBackgroundColor:[color darken:0.2]];
    }
}

- (void) touchEnded: (UIButton *) button {
    CGColorRef cgcolor = [button.backgroundColor CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(cgcolor);
    
    if(CGColorGetNumberOfComponents(cgcolor) == 2) {
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        [button.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
        button.backgroundColor = [color lighten:0.25];
        [self.view setNeedsDisplay];
    } else if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(cgcolor);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [button setBackgroundColor:[color lighten:0.25]];
        [self.view setNeedsDisplay];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
