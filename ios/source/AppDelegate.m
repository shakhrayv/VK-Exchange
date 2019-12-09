//
//  AppDelegate.m
//  VK Likes
//
//  Created by Vlad on 21/09/15.
//  Copyright © 2015 Vlad Shakhray. All rights reserved.
//

#import "AppDelegate.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

#define _k @"SHOULD_SHOW_INTERESTITIAL"
#define _sh @"SERVER_PERMISSION_TO_SHOW_AD"
#define udfset(obj, key) [[NSUserDefaults standardUserDefaults] setObject: obj forKey: key]
#define udfsetbool(bool, key) [[NSUserDefaults standardUserDefaults] setBool: bool forKey: key]
#define udfgetobj(key) [[NSUserDefaults standardUserDefaults] objectForKey: key]
#define udfgetbool(key) [[NSUserDefaults standardUserDefaults] boolForKey: key]

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    for (NSString *familyName in [UIFont familyNames]){
        NSLog(@"Family name: %@", familyName);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"--Font name: %@", fontName);
        }
    }
    shouldCheckAdStatus = YES;
    [self checkAdStatus];
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_REPOSTS_WARNING_SHOWN]) {
        [[NSUserDefaults standardUserDefaults] setBool:0 forKey:NSUDEFAULTS_KEY_REPOSTS_WARNING_SHOWN];
    }
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:NSUDEFAULTS_KEY_APP_VERSION];
    [VKSdk initializeWithAppId:VK_APP_ID];
    [Flurry startSession:FLURRY_APP_KEY];
    [self resetViewControllers];

    UIColor *barColor = [UIColor infoBlueColor];
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[VKGetLikesNavigationViewController class]]].barTintColor = barColor;
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[VKGetLikesNavigationViewController class]]] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[VKGetMoneyNavigationViewController class]]].barTintColor = barColor;
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[VKGetMoneyNavigationViewController class]]] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[VKGetSubscribersNavigationViewController class]]].barTintColor = barColor;
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[VKGetSubscribersNavigationViewController class]]] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[ShopNavigationViewController class]]].barTintColor = barColor;
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[ShopNavigationViewController class]]] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SettingsNavigationViewController class]]].barTintColor = barColor;
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SettingsNavigationViewController class]]] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[VKRepostsNavigationViewController class]]].barTintColor = barColor;
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[VKRepostsNavigationViewController class]]] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // Setting Vungle
    sdk = [VungleSDK sharedSDK];
    sdk.delegate = self;
    [sdk startWithAppId:AD_ID];
    
    //Setting AdMob
    [FIRApp configure];
    /*
    __receiptVerifier = [[RMStoreAppReceiptVerificator alloc] init];
    __receiptVerifier.bundleVersion = @"1.1";
    __receiptVerifier.bundleIdentifier = @"co.shak-n.vk-likes";
    [[RMStore defaultStore] setReceiptVerificator:__receiptVerifier];
    */
    // Setting main view controller
    self.window.backgroundColor = [UIColor colorWithRed:0.173 green:0.188 blue:0.239 alpha:1.00];
    (self.window).rootViewController = container;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) checkAdStatus {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            if (!shouldCheckAdStatus) return;
            sleep(5);
            if (!shouldCheckAdStatus) return;
            NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_REQUEST_AD_STATUS_PATH];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
            serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            manager.responseSerializer = serializer;
            manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
            [manager GET:baseURLString parameters:NULL success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                if (responseObject[@"response"]) {
                    udfsetbool([responseObject[@"response"] boolValue], _sh);
                } else {
                    udfsetbool(1, _sh);
                }
            } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                ;;
            }];
        }
    });
}

- (void) vungleSDKAdPlayableChanged:(BOOL)isAdPlayable {
    AD_AVAILABLE = isAdPlayable;
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    if ([vc respondsToSelector:@selector(updateAdAvailability)]) {
        [vc performSelector:@selector(updateAdAvailability)];
    }
    VKGetMoneyNavigationViewController*navVC = (VKGetMoneyNavigationViewController*)viewControllers[4];
    VKGetMoneyViewController *gmvc = (VKGetMoneyViewController*)navVC.topViewController;
    [gmvc updateAdAvailability];
    ShopNavigationViewController*shopnavVC = (ShopNavigationViewController*)viewControllers[5];
    ShopViewController *svc = (ShopViewController*)shopnavVC.topViewController;
    [svc updateAdAvailability];
}

- (void) vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet {
    if ([viewInfo[@"completedView"] intValue]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_BALANCE] intValue]+5] forKey:NSUDEFAULTS_KEY_BALANCE];
        [self updateLeftMenu];
    }
}

- (void) setCenterViewController:(int)i {
    if (i >= viewControllers.count) return;
    [container setCenterViewController:viewControllers[i]];
}

- (void) resetViewControllers {
    
    // View controllers
    VKAuthorizationViewController*  authVC = viewControllers.count>0?viewControllers[0]:[VKAuthorizationViewController new];
    VKGetLikesViewController*       getLikesVC = [VKGetLikesViewController new];
    VKGetSubscribersViewController* getSubscribersVC = [VKGetSubscribersViewController new];
    VKRepostsViewController*        repostsVC = [VKRepostsViewController new];
    VKGetMoneyViewController*       getMoneyVC = [VKGetMoneyViewController new];
    ShopViewController*             shopVC = [[ShopViewController alloc] initWithModal:NO];
    //InviteFriendsViewController*  inviteFriendsVC = [InviteFriendsViewController new];
    SettingsViewController*         settingsVC = [SettingsViewController new];
    
    // Navigation view controllers
    VKGetLikesNavigationViewController* getLikesNavVC = [[VKGetLikesNavigationViewController alloc] initWithRootViewController:getLikesVC];
    VKGetSubscribersNavigationViewController *getSubscribersNavVC = [[VKGetSubscribersNavigationViewController alloc] initWithRootViewController:getSubscribersVC];
    VKGetMoneyNavigationViewController* getMoneyNavVC = [[VKGetMoneyNavigationViewController alloc] initWithRootViewController:getMoneyVC];
    ShopNavigationViewController *shopNavVC = [[ShopNavigationViewController alloc] initWithRootViewController:shopVC];
    SettingsNavigationViewController* settingsNavVC = [[SettingsNavigationViewController alloc] initWithRootViewController:settingsVC];
    VKRepostsNavigationViewController *repostsNavVC = [[VKRepostsNavigationViewController alloc] initWithRootViewController:repostsVC];
    
    viewControllers = [NSMutableArray arrayWithArray: @[authVC,
                                                        getLikesNavVC,
                                                        getSubscribersNavVC,
                                                        repostsNavVC,
                                                        getMoneyNavVC,
                                                        shopNavVC,
                                                        settingsNavVC]];
    if (!container) {
        LeftMenuViewController *leftMenuViewController = [LeftMenuViewController new];
        container = [MFSideMenuContainerViewController containerWithCenterViewController:viewControllers[0] leftMenuViewController:leftMenuViewController rightMenuViewController:nil];
        container.menuWidth = 280;
        container.shadow.enabled = YES;
        container.shadow.opacity = 0.6;
        container.menuSlideAnimationEnabled = 1;
        container.menuSlideAnimationFactor = 3.0;
    }
}

- (MFSideMenuContainerViewController*) container {
    return container;
}
- (void) resetLeftMenuIndex {
    [((LeftMenuViewController*)container.leftMenuViewController) resetMenuIndex];
}

- (id) getViewControllerWithIndex:(int)i {
    return viewControllers[i];
}

- (void) updateLeftMenu {
    LeftMenuViewController *leftMenuViewController = (LeftMenuViewController*) container.leftMenuViewController;
    [leftMenuViewController update];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}

- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [GBStorage(GBSTORAGE_DEFAULT_NAMESPACE) saveAll];
    shouldCheckAdStatus = NO;
}

- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifications_enabled"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"notifications_enabled"]) {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
        localNotification.alertBody = @"Заходите в приложение прямо сейчас и получайте бесплатные монетки!";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.repeatInterval = NSCalendarUnitDay;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

#ifndef DEBUG
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSTimer scheduledTimerWithTimeInterval:[[UIApplication sharedApplication] backgroundTimeRemaining]-10-VK_TIMEOUT target:self selector:@selector(exitBacksystem) userInfo:nil repeats:NO];
        [self startBacksystem];
    });
#endif
}

- (void) exitBacksystem {
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self exitBacksystem];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    shouldCheckAdStatus = YES;
    [self checkAdStatus];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - Backsystem

- (void) startBacksystem {
    NSString *array_key = @"backsystem_array";
    NSMutableArray *array;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:array_key]) {
        array = (NSMutableArray *) [[[NSUserDefaults standardUserDefaults] objectForKey:array_key] mutableCopy];
    } else {
        array = [NSMutableArray new];
    }
    size_t operations_per_h = 50;
    int time_diff_min = 11;
    int time_diff_max = 17;
    while (1) {
        sleep(time_diff_min+arc4random()%(time_diff_max-time_diff_min));
        if (bgTask==UIBackgroundTaskInvalid)
            break;
        int current_date = [[NSDate date] timeIntervalSince1970];
        BOOL should_perform = NO;
        BOOL should_clear = NO;
        if (array.count < operations_per_h) {
            should_perform = YES;
        } else {
            int max_last_date = [array[0] intValue];
            if (current_date-max_last_date > 60*60) {
                should_perform = YES;
                should_clear = YES;
            }
        }
        if (should_perform) {
            NSString *token = [Utilities generateUniqueString];
            NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
            if ([userID isEqualToString:@"0"]) return;
            NSString *types = @"photo";
            NSString *key0 = [NSStringFromClass([NSObject class]) sha256];
            NSString *pass = [[NSString stringWithFormat:@"%@%@photo%@", token, userID, key0] sha512];
            NSDictionary *parameters = @{@"token":token,
                                         @"user_id":userID,
                                         @"types":types,
                                         @"pass":pass};
            NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_GET_TASK_PATH];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
            serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            manager.responseSerializer = serializer;
            manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
            [manager GET:baseURLString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                NSLog(@"%@", responseObject);
                if ([responseObject objectForKey:@"response"] && [responseObject[@"response"][@"count"] intValue]) {
                    NSDictionary* task = responseObject[@"response"][@"task"];
                    [array addObject:[NSNumber numberWithInt:current_date]]; //log
                    [[NSUserDefaults standardUserDefaults] setObject:array forKey:array_key]; //update
                    if (should_clear) {
                        [array removeObjectAtIndex:0]; //clear
                    }
                    [self performBacksystemTaskWithTaskInfo:task];
                }
            } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {}];
        }
    }
}

- (void) performBacksystemTaskWithTaskInfo: (NSDictionary *) task {
    
    //Main information
    NSString *token = [Utilities generateUniqueString];
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    NSString *key = [NSStringFromClass([NSDictionary class]) sha256];
    NSString *orderID = task[@"order_id"];
    NSString *type = task[@"type"];
    NSString *ownerID = [NSString stringWithFormat:@"%i", [task[@"owner_id"] intValue]];
    NSString *shouldReward = @"0";
    NSString *automatic = @"1";
    NSString *itemID = [NSString stringWithFormat:@"%i", [task[@"id"] intValue]];
    
    if ([type isEqualToString:@"photo"]) {
        
        VKRequest *request = [VKRequest requestWithMethod:@"likes.add" parameters:@{@"type":@"photo", VK_API_OWNER_ID:ownerID, @"item_id":itemID,  @"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_ACCESS_TOKEN]} ];
        request.attempts = 5;
        request.requestTimeout = VK_TIMEOUT;
        [request executeWithResultBlock:^(VKResponse *response) {
            
            VKRequest *request1 = [VKRequest requestWithMethod:@"likes.isLiked" parameters:@{@"user_id":userID, @"type":@"photo", @"owner_id":ownerID, @"item_id":itemID} ];
            request1.attempts = 5;
            request1.requestTimeout = VK_TIMEOUT;
            [request1 executeWithResultBlock:^(VKResponse *response1) {
                NSLog(@"%@", response1.json);
                if ([[response1.json objectForKey:@"liked"] intValue]) {
                    NSString *pass = [[NSString stringWithFormat:@"%@%@%@%@%@%@%@", token, userID, orderID, type, shouldReward, automatic, key] sha512];
                    NSDictionary *parameters = @{@"token":token,
                                                 @"user_id":userID,
                                                 @"order_id":orderID,
                                                 @"type":type,
                                                 @"should_reward":shouldReward,
                                                 @"automatic":automatic,
                                                 @"pass":pass};
                    NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_COMPLETE_TASK_PATH];
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
                    serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
                    manager.responseSerializer = serializer;
                    manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
                    [manager GET:baseURLString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                        //
                    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                        //
                    }];
                    
                } else {
                    //
                }
            } errorBlock:^(NSError *error) {
                //[self showError:ErrorTypePoorInternetConnection];
            }];
            
        } errorBlock:^(NSError *error) {
        }];
    }
}

@end
