//
//  VKRepostsViewController.m
//  VK Likes
//
//  Created by Vlad on 02/04/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import "VKRepostsViewController.h"

#define _k @"SHOULD_SHOW_INTERESTITIAL"
#define _sh @"SERVER_PERMISSION_TO_SHOW_AD"
#define udfset(obj, key) [[NSUserDefaults standardUserDefaults] setObject: obj forKey: key]
#define udfsetbool(bool, key) [[NSUserDefaults standardUserDefaults] setBool: bool forKey: key]
#define udfgetobj(key) [[NSUserDefaults standardUserDefaults] objectForKey: key]
#define udfgetbool(key) [[NSUserDefaults standardUserDefaults] boolForKey: key]


@interface VKRepostsViewController ()

@end

const CGFloat shopSize = 50;
CGFloat offset = 14;

@implementation VKRepostsViewController

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

- (void) updateSubtotal: (UISlider*) slider {
    UIView *initialView = subtotals[slider.tag];
    CGPoint initialPosition = origin(initialView);
    CGFloat initialWidth = width(initialView);
    [initialView removeFromSuperview];
    initialView = nil;
    UIView *whitey = whiteys[slider.tag];
    UIView* subtotalView = [UIView new];
    UIColor *subtotalColor = [UIColor colorWithWhite:0.4 alpha:1];
    UIImageView *subscriberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MegaphoneReposts"]];
    [subscriberImageView setSize:CGSizeMake(15, 15)];
    [subscriberImageView sizeToFit];
    UILabel *subscribersLabel = [UILabel new];
    subscribersLabel.text = [NSString stringWithFormat:@"%i", (int) (slider.value/5) *5];
    subscribersLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
    subscribersLabel.textColor = subtotalColor;
    [subscribersLabel sizeToFit];
    UILabel *equalLabel = [UILabel new];
    equalLabel.textColor = subtotalColor;
    equalLabel.text = @"=";
    equalLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
    [equalLabel sizeToFit];
    UIImageView *costImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MoneyReposts"]];
    [costImageView setSize:CGSizeMake(18, 18)];
    UILabel *costLabel = [UILabel new];
    costLabel.text = [NSString stringWithFormat:@"%i", ((int) (slider.value/5) *5)*9];
    costLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
    costLabel.textColor = subtotalColor;
    [costLabel sizeToFit];
    CGFloat sideOffset = 10;
    CGFloat mid = 5;
    CGRect frame = subtotalView.frame;
    frame.size.height = 2*sideOffset + MAX(subscriberImageView.frame.size.height, MAX(subscribersLabel.frame.size.height, MAX(equalLabel.frame.size.height, MAX(costImageView.frame.size.height, costLabel.frame.size.height))));
    frame.size.width = sideOffset + subscriberImageView.frame.size.width+mid+subscribersLabel.frame.size.width+mid+equalLabel.frame.size.width+mid+costImageView.frame.size.width+mid+costLabel.frame.size.width+sideOffset;
    frame.origin.x = initialPosition.x-(frame.size.width-initialWidth)/2.0;
    frame.origin.y = initialPosition.y;
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
    [whitey addSubview:subtotalView];
    subtotals[slider.tag] = subtotalView;
}

- (void) order: (UIButton *) sender {
    UIView* whitey = whiteys[sender.tag-1];
    int val = 0;
    for (UIView *view in whitey.subviews) {
        if ([view isKindOfClass:[UISlider class]]){
            UISlider *sl = (UISlider*) view;
            val = ((int)sl.value/5)*5;
        }
    }
    if (val == 0) {
        return;
    }
    int balance = [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_BALANCE] intValue];
    if (val * 9 > balance) {
        [self openShop];
        return;
    }
    [SVProgressHUD setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14]];
    [SVProgressHUD show];
    NSString *token = [Utilities generateUniqueString];
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    int dateAdded = [[NSDate date] timeIntervalSince1970];
    NSString *shouldPay = @"1";
    bool priority_ = [[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TURBO] boolValue] & [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_IS_PRIVILEGED] boolValue];
    NSString *priority = [NSString stringWithFormat:@"%i", priority_];
    NSString *key = [NSStringFromClass([UIViewController class]) sha256];
    NSString *pass = [[NSString stringWithFormat:@"%@%@%@%i%i%@%@%@", token, userID, [NSString stringWithFormat:@"%i", [posts[@"items"][sender.tag-1][@"id"] intValue]], dateAdded, val, shouldPay, priority, key] sha512];
    NSDictionary *parameters = @{   @"token":token,
                                    @"user_id":userID,
                                    @"id":[NSString stringWithFormat:@"%i", [posts[@"items"][sender.tag-1][@"id"] intValue]],
                                    @"date_added":[NSString stringWithFormat:@"%i", dateAdded],
                                    @"quantity":[NSString stringWithFormat:@"%i", val],
                                    @"should_pay":shouldPay,
                                    @"priority":priority,
                                    @"pass":pass
                                    };
    NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_REQUEST_REPOSTS_PATH];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer = serializer;
    manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
    [manager GET:baseURLString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (((NSDictionary*)responseObject)[@"response"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus: @"Заказ принят!"];
            });
            [self updateBrief];
            int money = [responseObject[@"response"][@"balance"] intValue];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:money] forKey:NSUDEFAULTS_KEY_BALANCE];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateBalance];
                [((AppDelegate*)[[UIApplication sharedApplication] delegate]) updateLeftMenu];
            });
        } else if ((NSDictionary*)responseObject[@"error"]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Ошибка сервера", nil)];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [Flurry logError:@"Server error" message:[NSString stringWithFormat:@"%i", [responseObject[@"error"] intValue]] error:nil];
                });
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Нет соединения", nil)];
            });
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"Нет соединения"];
    }];
}

- (void) openShop {
    ShopViewController *shopVC = [[ShopViewController alloc] initWithModal:YES];
    ModalShopNavigationViewController *shopNavVc = [[ModalShopNavigationViewController alloc] initWithRootViewController:shopVC];
    shopVC.delegate = shopNavVc;
    shopNavVc.shopDelegate = self;
    [self presentViewController:shopNavVc animated:YES completion:nil];
}

- (void) finished:(UIViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateMainScrollView {
    int count = (int)((NSMutableArray*)posts[@"items"]).count;
    CGFloat hg = REPOSTS_ROW_HEIGHT+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT;
    CGFloat offset = 14;
    if (!scrollView) {
        scrollView = [[VKScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        scrollView.alwaysBounceVertical = YES;
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, count*(REPOSTS_ROW_HEIGHT+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)+offset*(count+2)+shopSize);
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.delaysContentTouches = NO;
        scrollView.userInteractionEnabled = YES;
        [self.view addSubview:scrollView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [scrollView setNeedsDisplay];
        });
        
        //Updating content
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(updateAll) forControlEvents:UIControlEventValueChanged];
        [scrollView addSubview:refreshControl];
    }
    if (whiteys.count != ((NSArray*)posts[@"items"]).count) {
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, count*(REPOSTS_ROW_HEIGHT+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)+offset*(count+2)+shopSize);
        [scrollView setNeedsDisplay];
    }
    if (!whiteys) whiteys = [NSMutableArray new];
    if (!labels) labels = [NSMutableArray new];
    if (!sliders) sliders = [NSMutableArray new];
    if (!subtotals) subtotals = [NSMutableArray new];
    
    for (int i = 0; i < count; i++) {
        if (whiteys.count <= i) {
            UIView * whitey = [[UIView alloc] initWithFrame:CGRectMake(offset, i*hg+(i+1)*offset, self.view.frame.size.width-2*offset, hg)];
            whitey.backgroundColor = [UIColor whiteColor];
            whitey.layer.cornerRadius = 3.0f;
            //whitey.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
            //whitey.layer.borderWidth = 0.5f;
            whitey.layer.shadowColor = [UIColor colorWithWhite:0.4 alpha:0.6].CGColor;
            whitey.layer.shadowOffset = CGSizeZero;
            whitey.layer.shadowOpacity = 0.3;
            [whiteys addObject:whitey];
            NSLog(@"white %i", i);
            [scrollView addSubview:whitey];
        }
        UIView *whitey = whiteys[i];
        
        // Image view - tag 1
        UIImageView* __block imageView;
        for (UIView *sub in whitey.subviews) {
            if (sub.tag == 108) {
                imageView = (UIImageView*) sub;
                break;
            }
        }
        if (!imageView) imageView = [UIImageView new];
        imageView.tag = 108;
        //Adding image
        CGFloat imageViewSize = self.view.frame.size.width==320?40:60;
        CGFloat ext = imageViewSize+10;
        CGFloat imageViewOffset = 12;
        imageView.image = [UIImage imageNamed:@"Pencil"];
        imageView.frame = CGRectMake(imageViewOffset, (whitey.frame.size.height-GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)/2.0-ext/2.0, ext, ext);
        imageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        imageView.layer.cornerRadius = ext/2.0;
        imageView.clipsToBounds = YES;
        UIImage* placeholder = [UIImage imageNamed:@"Pencil"];
        NSString *__block photoURL;
        if (posts[@"items"][i][@"attachments"]) {
            for (NSDictionary* __block attachment in (NSArray*)posts[@"items"][i][@"attachments"]) {
                if ([attachment[@"type"] isEqualToString:@"photo"]) {
                    photoURL = attachment[@"photo"][@"photo_130"];
                    break;
                } else if ([attachment[@"type"] isEqualToString:@"link"] && attachment[@"link"][@"photo"]) {
                    photoURL = attachment[@"link"][@"photo"][@"photo_130"];
                    break;
                } else if([attachment[@"type"] isEqualToString:@"video"]) {
                    photoURL = attachment[@"video"][@"photo_130"];
                    break;
                }
            }
        }
        if (!photoURL) {
            if (posts[@"items"][i][@"copy_history"] && posts[@"items"][i][@"copy_history"][0][@"attachments"]) {
                for (NSDictionary* __block attachment in (NSArray*)posts[@"items"][i][@"copy_history"][0][@"attachments"]) {
                    if ([attachment[@"type"] isEqualToString:@"photo"]) {
                        photoURL = attachment[@"photo"][@"photo_130"];
                        break;
                    } else if ([attachment[@"type"] isEqualToString:@"link"] && attachment[@"link"][@"photo"]) {
                        photoURL = attachment[@"link"][@"photo"][@"photo_130"];
                        break;
                    } else if([attachment[@"type"] isEqualToString:@"video"]) {
                        photoURL = attachment[@"video"][@"photo_130"];
                        break;
                    }
                }
            }
        }
        if (!photoURL) {
            imageView.image = placeholder;
        } else {
            if (GBStorage(GBSTORAGE_DEFAULT_NAMESPACE)[photoURL]) {
                imageView.image = [self centerCropImage:(UIImage*) GBStorage(GBSTORAGE_DEFAULT_NAMESPACE)[photoURL]];
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image;
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
                    while (!image) {
                        usleep(1000);
                        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = [self centerCropImage:image];
                        GBStorage(GBSTORAGE_DEFAULT_NAMESPACE)[photoURL] = image;
                        [GBStorage(GBSTORAGE_DEFAULT_NAMESPACE) save:photoURL];
                    });
                });
            }
        }
        [whitey addSubview:imageView];
    
        //Adding text
        NSString *text = @"";
        if (![posts[@"items"][i][@"text"] isEqualToString:@""]) {
            text = posts[@"items"][i][@"text"];
        } else if (posts[@"items"][i][@"attachments"]) {
            for (NSDictionary* __block attachment in (NSArray*)posts[@"items"][i][@"attachments"]) {
                if ([attachment[@"type"] isEqualToString:@"link"]) {
                    text = [NSString stringWithFormat:@"Repost: %@", attachment[@"link"][@"title"]];
                    break;
                }
            }
            NSDictionary* attachment = posts[@"items"][i][@"attachments"][0];
            if ([attachment[@"type"] isEqualToString:@"photo"]) {
                text = NSLocalizedString(@"Фотография", nil);
            } else if ([attachment[@"type"] isEqualToString:@"video"]) {
                text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Видео", nil), attachment[@"video"][@"title"]];
            } else if ([attachment[@"type"] isEqualToString:@"poll"]) {
                text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Опрос", nil), attachment[@"poll"][@"question"]];
            }
        } else if (posts[@"items"][i][@"copy_history"]) {
            BOOL isFound = false;
            for (NSDictionary* __block post in (NSArray*)posts[@"items"][i][@"copy_history"]) {
                if (![post[@"text"] isEqualToString:@""]) {
                    text = [NSString stringWithFormat:@"Repost: %@", post[@"text"]];
                    isFound = true;
                    break;
                }
            }
            if (!isFound) {
                for (NSDictionary* __block post in (NSArray*)posts[@"items"][i][@"copy_history"]) {
                    if ([[NSString stringWithFormat:@"%i", [post[@"owner_id"] intValue]] characterAtIndex:0] =='-') {
                        NSString *groupID = [[NSString stringWithFormat:@"%i", [post[@"owner_id"] intValue]] substringFromIndex:1];
                        for (NSDictionary* __block group in (NSArray*)posts[@"groups"]) {
                            if ([[NSString stringWithFormat:@"%i", [group[@"id"] intValue]] isEqualToString:groupID]) {
                                text = [NSString stringWithFormat:@"Repost: %@", group[@"name"]];
                                isFound = true;
                                break;
                            }
                        }
                    } else {
                        NSString *userID = [NSString stringWithFormat:@"%i", [post[@"owner_id"] intValue]];
                        for (NSDictionary* __block user in (NSArray*)posts[@"profiles"]) {
                            if ([[NSString stringWithFormat:@"%i", [user[@"id"] intValue]] isEqualToString:userID]) {
                                text = [NSString stringWithFormat:@"Repost: %@", [NSString stringWithFormat:@"%@ %@", user[@"first_name"], user[@"last_name"]]];
                                isFound = true;
                                break;
                            }
                        }
                    }
                }
                if (!isFound) {
                    text = @"Repost";
                }
            }
        }
        if ([text isEqualToString:@""]) {
            text = NSLocalizedString(@"Запись", nil);
        }
        if (labels.count <= i) [labels addObject:[UILabel new]];
        UILabel *textLabel = labels[i];
        [textLabel setX:2*imageViewOffset+imageViewSize+10];
        [textLabel setY:imageViewOffset+8];
        textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15];
        textLabel.text = text;
        textLabel.textColor = [UIColor colorWithWhite:0 alpha:1];
        [textLabel sizeToFit];
        [textLabel setWidth:[whitey getWidth]-[textLabel getOriginX]-imageViewOffset];
        [whitey addSubview:textLabel];
        
        
        //Adding info
        UIColor *mainColor = [UIColor colorWithWhite:0.75 alpha:1];
        CGFloat offset = 12;
        BOOL isPresent = false;
        for (UIView * view in whitey.subviews) {
            if (view.tag == 103) {
                isPresent = true;
                break;
            }
        }
        if (isPresent) {
            for (UIView * view in whitey.subviews) {
                if (view.tag == 103) {
                    UILabel *lab = (UILabel *)view;
                    lab.text = [NSString stringWithFormat:@"%i", [posts[@"items"][i][@"reposts"][@"count"] intValue]];
                }
            }
        } else {
            CGFloat size = 15;
            UIImageView *messages = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Reposts"]];
            messages.frame = CGRectMake(2*offset-4, whitey.frame.size.height-imageViewOffset-size, size, size);
            [whitey addSubview:messages];
            UILabel *commentsLabel = [[UILabel alloc] init];
            commentsLabel.tag = 103;
            commentsLabel.text = [NSString stringWithFormat:@"%i", [posts[@"items"][i][@"reposts"][@"count"] intValue]];
            commentsLabel.textColor = mainColor;
            commentsLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
            [commentsLabel sizeToFit];
            [commentsLabel setWidth:60];
            [commentsLabel setX:[messages getRightBound]+9];
            [commentsLabel setY:[messages getOriginY]+[messages getHeight]/2.0-commentsLabel.frame.size.height/2.0];
            [whitey addSubview:commentsLabel];
        }
        
        
        //Adding order button
        BOOL isButtonPlaced = false;
        for (UIView * view in whitey.subviews) {
            if (view.tag == i+1) {
                isButtonPlaced = true;
            }
        }
        CGFloat buttonWidth = 110;
        CGFloat buttonHeight = 30;
        if (!isButtonPlaced) {
            UIButton *orderButton = [[UIButton alloc] initWithFrame:CGRectMake([whitey getWidth]-buttonWidth-imageViewOffset*2, [whitey getHeight]-buttonHeight-imageViewOffset, buttonWidth, buttonHeight)];
            orderButton.backgroundColor = [UIColor clearColor];
            [orderButton setTitle:NSLocalizedString(@"Заказать", nil) forState:UIControlStateNormal];
            orderButton.layer.cornerRadius = 4;
            orderButton.layer.borderColor = [UIColor colorWithRed:0.239 green:0.624 blue:0.663 alpha:1.00].CGColor;
            orderButton.layer.borderWidth = 1;
            [orderButton setTitleColor:[UIColor colorWithRed:0.239 green:0.624 blue:0.663 alpha:1.00] forState:UIControlStateNormal];
            orderButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
            orderButton.tag = i+1;
            [orderButton addTarget:self action:@selector(order:) forControlEvents:UIControlEventTouchUpInside];
            [whitey addSubview:orderButton];
        }
        
        //Adding a slider
        BOOL isSet = false;
        for (UIView *sl in whitey.subviews) {
            if ([sl isKindOfClass:[UISlider class]]) {
                isSet = true;
                break;
            }
        }
        if (!isSet) {
            CGFloat doffset = width(self.view)==320?0:20;
            UISlider* slider = [[UISlider alloc] initWithFrame:CGRectMake([textLabel getOriginX]+imageViewOffset+doffset, [whitey getHeight]-GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT-50, [textLabel getRightBound]-[textLabel getOriginX]-imageViewOffset*2-2*doffset, 30)];
            slider.clipsToBounds = YES;
            [slider setThumbImage:[UIImage imageNamed:@"Oval"] forState:UIControlStateNormal];
            slider.minimumValue = 5.0;
            slider.value = 9.0;
            slider.tag = i;
            slider.maximumValue = 250.0;
            [slider addTarget:self action:@selector(updateSubtotal:) forControlEvents:UIControlEventValueChanged];
            [whitey addSubview:slider];
            [sliders addObject:slider];
        }
        
        //Adding subtotal view
        if (subtotals.count <= i) {
            UIView *subtotalView = [UIView new];
            UIColor *subtotalColor = [UIColor colorWithWhite:0.1 alpha:1];
            UIImageView *subscriberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MegaphoneReposts"]];
            [subscriberImageView setSize:CGSizeMake(15, 15)];
            [subscriberImageView sizeToFit];
            UILabel *subscribersLabel = [UILabel new];
            subscribersLabel.text = [NSString stringWithFormat:@"%i", (int) (((UISlider*)sliders[i]).value/5) *5];
            subscribersLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
            subscribersLabel.textColor = subtotalColor;
            [subscribersLabel sizeToFit];
            UILabel *equalLabel = [UILabel new];
            equalLabel.textColor = subtotalColor;
            equalLabel.text = @"=";
            equalLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
            [equalLabel sizeToFit];
            UIImageView *costImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MoneyReposts"]];
            [costImageView setSize:CGSizeMake(18, 18)];
            UILabel *costLabel = [UILabel new];
            costLabel.text = [NSString stringWithFormat:@"%i", (int) (((UISlider*)sliders[i]).value/5) *5*9];
            costLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
            costLabel.textColor = subtotalColor;
            [costLabel sizeToFit];
            CGFloat sideOffset = 10;
            CGFloat mid = 5;
            CGRect frame = subtotalView.frame;
            frame.size.height = 2*sideOffset + MAX(subscriberImageView.frame.size.height, MAX(subscribersLabel.frame.size.height, MAX(equalLabel.frame.size.height, MAX(costImageView.frame.size.height, costLabel.frame.size.height))));
            frame.size.width = sideOffset + subscriberImageView.frame.size.width+mid+subscribersLabel.frame.size.width+mid+equalLabel.frame.size.width+mid+costImageView.frame.size.width+mid+costLabel.frame.size.width+sideOffset;
            frame.origin.x = x(textLabel)+width(textLabel)/2.0-frame.size.width/2.0;
            frame.origin.y = ([((UISlider*)sliders[i]) getOriginY]-[textLabel getLowerBound])/2.0+[textLabel getLowerBound]-frame.size.height/2.0+6.5;
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
            [whitey addSubview:subtotalView];
            [subtotals addObject:subtotalView];
        }
        
        //Adding tasks brief label
        if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_REPOSTS_BRIEF]) {
            NSDictionary* dict = (NSDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_REPOSTS_BRIEF];
            if ([dict objectForKey:[NSString stringWithFormat:@"%i", [posts[@"items"][i][@"id"] intValue]]]) {
                int ordered = [dict[[NSString stringWithFormat:@"%i", [posts[@"items"][i][@"id"] intValue]]][@"ordered"] intValue];
                int completed = [dict[[NSString stringWithFormat:@"%i", [posts[@"items"][i][@"id"] intValue]]][@"completed"] intValue];
                NSString *text = [NSString stringWithFormat:@"%i/%i", completed, ordered];
                BOOL __block isFound = false;
                for (UIView* __strong view in whitey.subviews) {
                    if (view.tag == 130) {
                        UILabel *label = (UILabel *) view;
                        label.text = text;
                        isFound = true;
                    }
                }
                if (!isFound) {
                    UIImageView *reposts = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Tasks"]];
                    reposts.frame = CGRectMake(80, whitey.frame.size.height-imageViewOffset-15, 15, 15);
                    reposts.tag = 131;
                    [whitey addSubview:reposts];
                    UILabel *repostsLabel = [[UILabel alloc] init];
                    repostsLabel.tag = 5;
                    repostsLabel.text = text;
                    repostsLabel.textColor = [UIColor colorWithRed:0.851 green:0.298 blue:0.192 alpha:1.00];
                    repostsLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
                    [repostsLabel sizeToFit];
                    [repostsLabel setX:[reposts getRightBound]+9];
                    [repostsLabel setY:[reposts getOriginY]+[reposts getHeight]/2.0-repostsLabel.frame.size.height/2.0];
                    [repostsLabel setWidth:60];
                    repostsLabel.tag = 130;
                    [whitey addSubview:repostsLabel];
                }
            } else {
                for (UIView* __strong view in whitey.subviews) {
                    if (view.tag == 130 || view.tag == 131) {
                        [view removeFromSuperview];
                        view = nil;
                    }
                }
            }
        }
    }
    for (UIView *v __strong in scrollView.subviews) {
        if (v.tag == 149) {
            [v removeFromSuperview];
            v = nil;
        }
    }
    MDButton *button = [[MDButton alloc] initWithFrame:CGRectMake(width(self.view)/2.0-shopSize/2.0, count*(GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT+REPOSTS_ROW_HEIGHT)+(count+1)*offset, shopSize, shopSize) type:0 rippleColor:[UIColor whiteColor]];
    button.tag = 149;
    [button addTarget:self action:@selector(openShop) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = shopSize/2.0;
    [button setBackgroundColor:[UIColor colorWithRed:0.169 green:0.518 blue:0.941 alpha:1.00]];
    [button setImage:[UIImage imageNamed:@"ShopRepost"] forState:UIControlStateNormal];
    [scrollView addSubview:button];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateAll];
    [self updateBalance];
    [self.view setNeedsDisplay];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [welcome hideView];
}

- (UIImage *)centerCropImage:(UIImage *)image
{
    // Use smallest side length as crop square length
    CGFloat squareLength = MIN(image.size.width, image.size.height);
    // Center the crop area
    CGRect clippedRect = CGRectMake((image.size.width - squareLength) / 2, (image.size.height - squareLength) / 2, squareLength, squareLength);
    
    // Crop logic
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}


- (BOOL) automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (void) updateAll {
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_ID];
    
    //Getting wall posts
    VKRequest *wallRequest = [VKRequest requestWithMethod:@"wall.get" parameters:@{@"owner_id":userID, VK_API_EXTENDED: @"1", VK_API_COUNT:[NSString stringWithFormat:@"%i", MAX_WALL_POSTS]}];
    wallRequest.attempts = 5;
    wallRequest.requestTimeout = VK_TIMEOUT;
    [wallRequest executeWithResultBlock:^(VKResponse *response) {
        [[NSUserDefaults standardUserDefaults] setObject:response.json forKey:NSUDEFAULTS_KEY_WALL_POSTS];
        posts = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_WALL_POSTS]];
        [self updateMainScrollView];
        [self updateBrief];
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl endRefreshing];
        });
    } errorBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl endRefreshing];
        });
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_REPOSTS_WELCOME_SHOWN]) {
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showWelcome) userInfo:nil repeats:NO];
    } else {
        [self attemptToLoadInterestitial];
    }
}

- (void) showWelcome {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:1] forKey:NSUDEFAULTS_KEY_REPOSTS_WELCOME_SHOWN];
    welcome = [[SCLAlertView alloc] init];
    [welcome setTitleFontFamily:@"AvenirNext-Medium" withSize:18];
    [welcome setBodyTextFontFamily:@"AvenirNext-Regular" withSize:13];
    [welcome setShouldDismissOnTapOutside:YES];
    [welcome showCustom:self image:[UIImage imageNamed:@"Reposts-Menu"] color:[UIColor colorWithRed:0.255 green:0.608 blue:0.976 alpha:1.00] title:NSLocalizedString(TEXT_GET_REPOSTS_WELCOME_TITLE, nil) subTitle:NSLocalizedString(TEXT_GET_REPOSTS_WELCOME_TEXT, nil) closeButtonTitle:NSLocalizedString(@"ОК",nil) duration:15.0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Retrieving posts
    posts = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_WALL_POSTS]];
    
    NSLog(@"%@", posts);
    
    //Setting background color
    self.view.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    
    //Setting up navigation
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 38, 38);
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.title = NSLocalizedString(@"Репосты", nil);
    for (UIView *parentView in self.navigationController.navigationBar.subviews)
        for (UIView *childView in parentView.subviews)
            if ([childView isKindOfClass:[UIImageView class]])
                [childView removeFromSuperview];
    [self updateBalance];
}

- (void) showMenu {
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
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

- (void) updateBrief {
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    NSString *type = @"repost";
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
        if (responseObject[@"response"] && [responseObject[@"response"][@"count"] intValue]) {
            [[NSUserDefaults standardUserDefaults] setObject:(NSDictionary*)responseObject[@"response"][@"tasks"] forKey:NSUDEFAULTS_KEY_REPOSTS_BRIEF];
            [self updateMainScrollView];
        }  else if (responseObject[@"error"]) {
            [Flurry logError:@"Server error" message:[NSString stringWithFormat:@"%i", [responseObject[@"error"] intValue]] error:NULL];
        } else {
            [Flurry logError:@"Corrupted response" message:NULL error:NULL];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        ;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
