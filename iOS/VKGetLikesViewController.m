
#import "VKGetLikesViewController.h"

#define tag1 1
#define tag2 2

#define _k @"SHOULD_SHOW_INTERESTITIAL"
#define _sh @"SERVER_PERMISSION_TO_SHOW_AD"
#define udfset(obj, key) [[NSUserDefaults standardUserDefaults] setObject: obj forKey: key]
#define udfsetbool(bool, key) [[NSUserDefaults standardUserDefaults] setBool: bool forKey: key]
#define udfgetobj(key) [[NSUserDefaults standardUserDefaults] objectForKey: key]
#define udfgetbool(key) [[NSUserDefaults standardUserDefaults] boolForKey: key]


@implementation VKGetLikesViewController

#pragma mark Setting up table view for selecting order

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return offers.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = (int) indexPath.row;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellReuseIdentifier"];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    numberLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16];
    numberLabel.text = (NSString*) offers[index][0];
    [numberLabel sizeToFit];
    CGRect frame = numberLabel.frame;
    frame.origin.x = 22;
    frame.origin.y = GET_LIKES_CONSTRAINT_ORDER_ROW_HEIGHT/2.0-frame.size.height/2.0;
    numberLabel.frame = frame;
    [cell addSubview:numberLabel];
    CGFloat heightOffset = 8;
    CGFloat buttonWidth = 75;
    UIButton *priceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-84, heightOffset, buttonWidth, GET_LIKES_CONSTRAINT_ORDER_ROW_HEIGHT-2*heightOffset)];
    priceButton.layer.cornerRadius = 6;
    priceButton.backgroundColor = [UIColor colorWithRed:0.816 green:0.341 blue:0.286 alpha:1.00];
    priceButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [priceButton setTitle:(NSString*)offers[index][1] forState:UIControlStateNormal];
    [priceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    priceButton.tag = indexPath.row+1;
    [priceButton addTarget:self action:@selector(pressedOrderLikes:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *coinImageView = [UIImageView new];
    CGFloat coinSize = 16;
    coinImageView.frame = CGRectMake(buttonWidth-coinSize-5, (GET_LIKES_CONSTRAINT_ORDER_ROW_HEIGHT-2*heightOffset)/2.0-coinSize/2.0, coinSize, coinSize);
    coinImageView.image = [UIImage imageNamed:@"Coin_48"];
    [coinImageView setUserInteractionEnabled:YES];
    [priceButton addSubview:coinImageView];
    [cell addSubview:priceButton];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return GET_LIKES_CONSTRAINT_ORDER_ROW_HEIGHT;
}

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void) pressedOrderLikes: (UIButton *) button {
    int quantity = 0;
    switch (button.tag) {
        case 1:
            quantity = 5;
            break;
        case 2:
            quantity = 15;
            break;
        case 3:
            quantity = 25;
            break;
        case 4:
            quantity = 50;
            break;
        case 5:
            quantity = 125;
            break;
        case 6:
            quantity = 375;
            break;
        case 7:
            quantity = 625;
            break;
        default:
            quantity = 15;
            break;
    }
    int balance = [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_BALANCE] intValue];
    if (balance < [prices[button.tag-1] intValue]) {
        [self purchaseCoins];
        return;
    }
    [self hideSelectingView];
    [SVProgressHUD setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14]];
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self orderLikes:quantity];
    });
}

- (void) orderLikes: (int) likes {
    NSString *token = [Utilities generateUniqueString];
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    int dateAdded = [[NSDate date] timeIntervalSince1970];
    NSString *shouldPay = @"1";
    bool priority_ = [[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TURBO] boolValue] & [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_IS_PRIVILEGED] boolValue];
    NSString *priority = [NSString stringWithFormat:@"%i", priority_];
    NSString *key = [NSStringFromClass([NSMutableArray class]) sha256];
    NSString *pass = [[NSString stringWithFormat:@"%@%@%@%i%i%@%@%@", token, userID, selectedPhotoID, dateAdded, likes, shouldPay, priority, key] sha512];
    NSDictionary *parameters = @{   @"token":token,
                                    @"user_id":userID,
                                    @"id":selectedPhotoID,
                                    @"date_added":[NSString stringWithFormat:@"%i", dateAdded],
                                    @"quantity":[NSString stringWithFormat:@"%i", likes],
                                    @"should_pay":shouldPay,
                                    @"priority":priority,
                                    @"pass":pass
                                    };
    NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_REQUEST_LIKES_ON_PHOTO_PATH];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer = serializer;
    manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
    [manager GET:baseURLString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (((NSDictionary*)responseObject)[@"response"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus: @"Заказ принят!"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self hideSelectingView];
                    [mainScrollView setUserInteractionEnabled:YES];
                });
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
                    [self hideSelectingView];
                    [mainScrollView setUserInteractionEnabled:YES];
                    [Flurry logError:@"Server error" message:[NSString stringWithFormat:@"%i", [responseObject[@"error"] intValue]] error:nil];
                });
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Нет соединения", nil)];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self hideSelectingView];
                    [mainScrollView setUserInteractionEnabled:YES];
                });
            });
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"Нет соединения"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self hideSelectingView];
            [mainScrollView setUserInteractionEnabled:YES];
        });
    }];
}

- (void) purchaseCoins {
    ShopViewController *shopVC = [[ShopViewController alloc] initWithModal:YES];
    ModalShopNavigationViewController *shopNavVc = [[ModalShopNavigationViewController alloc] initWithRootViewController:shopVC];
    shopVC.delegate = shopNavVc;
    shopNavVc.shopDelegate = self;
    [self presentViewController:shopNavVc animated:YES completion:nil];
}

- (void) updateBrief {
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    NSString *type = @"photo";
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
            [[NSUserDefaults standardUserDefaults] setObject:(NSDictionary*)responseObject[@"response"][@"tasks"] forKey:NSUDEFAULTS_KEY_LIKES_BRIEF];
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

#pragma mark Showing/hiding selecting view
- (void) showSelectingView {
    if (selected) return;
    selected = YES;
    selectedPictureImageView.alpha = 1;
    mainScrollView.userInteractionEnabled = NO;
    [UIView animateWithDuration:ANIMATIONS_DURATION_2X animations:^{
        [selectingView setY: [self.view getHeight] - SELECTED_VIEW_HEIGHT];
        [selectedPictureImageView setY:64];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void) finished:(UIViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) hideSelectingView{
    if (!selected) return;
    selected = NO;
    CGRect frame = selectingView.frame;
    frame.origin.y = 2*self.view.frame.size.height-selectingView.frame.size.height-self.navigationController.navigationBar.frame.size.height;
    CGRect frame2 = selectedPictureImageView.frame;
    frame2.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:ANIMATIONS_DURATION_1X animations:^{
        selectingView.frame = frame;
        selectedPictureImageView.frame = frame2;
    }completion:^(BOOL finished) {
        selectedPictureImageView.alpha = 0;
        [likesTableView setContentOffset:CGPointMake(0, 0)];
        mainScrollView.userInteractionEnabled = YES;
    }];
}

- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage{
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    return retVal;
}

- (void) hideSelectingView_button {
    [self hideSelectingView];
}
#pragma mark Configuring main scroll view

- (void) updateMainScrollView {
    int count = (int) photoQueue.count;
    CGFloat photoSizePt = (self.view.frame.size.width-3*GET_LIKES_CONSTRAINT_PHOTO_OFFSET)/2.0;
    CGFloat optimalPhotoSizePx = photoSizePt*2;
    NSMutableArray *properSizeTypes = [self getPhotoSizeTypesForMinimal:optimalPhotoSizePx andMaximalPhotoSize:optimalPhotoSizePx];
    
    if (!mainScrollView) {
        mainScrollView = [[VKScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        int rows = ceil(count/2.0f);
        CGFloat contentSizeHeight = rows*(photoSizePt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)+(rows+1)*GET_LIKES_CONSTRAINT_PHOTO_OFFSET;
        mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentSizeHeight);
        mainScrollView.delegate = self;
        [self.view addSubview:mainScrollView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [mainScrollView setNeedsDisplay];
        });
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped:)];
        [mainScrollView addGestureRecognizer:tapGestureRecognizer];
        mainScrollView.alwaysBounceVertical = YES;
        
        //Updating content
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
        [mainScrollView addSubview:refreshControl];
    }
    
    //Updating height
    int rows = ceil(count/2.0f);
    CGFloat contentSizeHeight = rows*(photoSizePt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)+(rows+1)*GET_LIKES_CONSTRAINT_PHOTO_OFFSET;
    mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentSizeHeight);
    
    //Setting each image
    for (int i = 0; i < count; i++) {
        
        NSString *photoID = [NSString stringWithFormat:@"%@", photoQueue[i][@"id"]];
        
        //Image views
        if (imageViews.count < i+1) {
            UIImageView *imageView = [UIImageView new];
            imageView.backgroundColor = [UIColor whiteColor];
            CGRect frame;
            frame.size.width = photoSizePt;
            frame.size.height = photoSizePt;
            frame.origin.x = i%2==0?GET_LIKES_CONSTRAINT_PHOTO_OFFSET:GET_LIKES_CONSTRAINT_PHOTO_OFFSET*2+photoSizePt;
            frame.origin.y = (i/2)*(GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photoSizePt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)+GET_LIKES_CONSTRAINT_PHOTO_OFFSET;
            imageView.frame = frame;
            [mainScrollView addSubview:imageView];
            [imageViews addObject:imageView];
        }
        UIImageView *imageView = imageViews[i];
        
        //Bar views
        if (barViews.count < i+1) {
            UIView *barView = [UIView new];
            barView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            CGRect frame;
            frame.size.width = photoSizePt;
            frame.size.height = GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT;
            frame.origin.x = imageView.frame.origin.x;
            frame.origin.y = imageView.frame.origin.y+photoSizePt;
            barView.frame = frame;
            frame.origin.y += frame.size.height-1;
            frame.size.height = 1;
            UIView *shadowView = [[UIView alloc]  initWithFrame:frame];
            shadowView.layer.shadowOffset = CGSizeMake(0, 0.5);
            shadowView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
            shadowView.layer.shadowOpacity = 0.8;
            CGRect shadowRect = CGRectInset(shadowView.bounds, 5, 0);
            shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
            [shadowViews insertObject:shadowView atIndex:i];
            barView.layer.borderColor = [UIColor colorWithRed:0.863 green:0.867 blue:0.871 alpha:1.00].CGColor;
            barView.layer.borderWidth = 0.5;
            [mainScrollView addSubview:shadowView];
            [mainScrollView addSubview:barView];
            [barViews addObject:barView];
        }
        UIView *barView = barViews[i];
        
        //Adding 'completed/ordered' label
        CGFloat sideOffset = 14;
        CGFloat midOffset = 6;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_LIKES_BRIEF]) {
            NSDictionary *dict = (NSDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_LIKES_BRIEF];
            if ([dict objectForKey:photoID]) {
                int completed = [dict[photoID][@"completed"] intValue];
                int ordered = [dict[photoID][@"ordered"] intValue];
                BOOL done = false;
                for (UIView* __strong view in barView.subviews) {
                    if ([view isKindOfClass:[UILabel class]] && view.tag == tag1) {
                        UILabel *label = (UILabel *) view;
                        label.frame = CGRectMake(-999, -999, 999, 999);
                        label.text = [NSString stringWithFormat:@"%i/%i", completed, ordered];
                        [label sizeToFit];
                        CGRect frame = label.frame;
                        frame.origin.y = barView.frame.size.height/2.0-frame.size.height/2.0+1;
                        frame.origin.x = barView.frame.size.width-sideOffset-frame.size.width;
                        label.frame = frame;
                        done = true;
                        break;
                    }
                }
                if (!done) {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
                    label.text = [NSString stringWithFormat:@"%i/%i", completed, ordered];
                    label.textColor = [UIColor colorWithRed:0.973 green:0.396 blue:0.408 alpha:1.00];
                    label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
                    [label sizeToFit];
                    CGRect frame = label.frame;
                    frame.origin.y = barView.frame.size.height/2.0-frame.size.height/2.0+1;
                    frame.origin.x = barView.frame.size.width-sideOffset-frame.size.width;
                    label.frame = frame;
                    label.tag = tag1;
                    [barView addSubview:label];
                }
            } else {
                for (UIView* __strong view in barView.subviews) {
                    if ([view isKindOfClass:[UILabel class]] && view.tag == tag1) {
                        [view removeFromSuperview];
                    }
                }
            }
        } else {
            for (UIView* __strong view in barView.subviews) {
                if ([view isKindOfClass:[UILabel class]] && view.tag == tag1) {
                    [view removeFromSuperview];
                }
            }
        }
        
        //Adding likes label
        int barSubviewsCount = (int)[barView subviews].count;
        if (barSubviewsCount>1) {
            for (UIView* subview in [barView subviews]) {
                if ([subview isKindOfClass:[UILabel class]] && subview.tag == tag2) {
                    UILabel *subviewLabel = (UILabel*) subview;
                    subviewLabel.text = [NSString stringWithFormat:@"%i", [photoQueue[i][@"likes"][@"count"] intValue]];
                }
            }
        } else {
            UIImage* heartImage = [UIImage imageNamed:@"Heart_SmallGray"];
            CGFloat maxSize = 16;
            UIImageView *heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(sideOffset, GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT/2.0-MIN(heartImage.size.height, maxSize)/2.0, MIN(heartImage.size.width, maxSize), MIN(heartImage.size.height, maxSize))];
            heartImageView.image = heartImage;
            [barView addSubview:heartImageView];
            UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
            likesLabel.text = [NSString stringWithFormat:@"%i", [photoQueue[i][@"likes"][@"count"] intValue]];
            likesLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
            likesLabel.textAlignment = NSTextAlignmentLeft;
            likesLabel.tag = tag2;
            likesLabel.textColor = [UIColor colorWithRed:0.733 green:0.757 blue:0.780 alpha:0.95];
            [likesLabel sizeToFit];
            likesLabel.frame = CGRectMake(sideOffset+midOffset+MIN(heartImage.size.width, maxSize), GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT/2.0-likesLabel.frame.size.height/2.0+1, likesLabel.frame.size.width, likesLabel.frame.size.height);
            [barView addSubview:likesLabel];
            [self.view setNeedsDisplay];
        }
        
        if (imageView.image && loadedPhotoIDs.count > i && [loadedPhotoIDs[i] isEqualToString:photoID]) {
            continue;
        }
        loadedPhotoIDs[i] = @"";
        if (GBStorage(GBSTORAGE_DEFAULT_NAMESPACE)[photoID]) {
            imageView.image = [self centerCropImage:(UIImage*) GBStorage(GBSTORAGE_DEFAULT_NAMESPACE)[photoID]];
        } else {
            imageView.image = [UIImage imageNamed:@"Placeholder"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *URLString;
                NSArray *sizes = photoQueue[i][@"sizes"];
                for (int i = 0; i < properSizeTypes.count; i++) {
                    if (URLString) break;
                    for (int j = 0; j < sizes.count; j++) {
                        if ([sizes[j][@"type"] isEqual:properSizeTypes[i]]) {
                            URLString = sizes[j][@"src"];
                            break;
                        }
                    }
                }
                NSURL *photoURL = [NSURL URLWithString:URLString];
                UIImage *image;
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
                while (!image) {
                    usleep(1000);
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = [self centerCropImage:image];
                    GBStorage(GBSTORAGE_DEFAULT_NAMESPACE)[photoID] = imageView.image;
                    [GBStorage(GBSTORAGE_DEFAULT_NAMESPACE) save:photoID];
                });
                if (loadedPhotoIDs.count <= i) {
                    [loadedPhotoIDs addObject:photoID];
                } else {
                    loadedPhotoIDs[i] = photoID;
                }
            });
        }
    }
    
    if (imageViews.count > count) {
        for (size_t i = imageViews.count-1; i >= count; i--) {
            [imageViews[i] removeFromSuperview];
            [imageViews removeObjectAtIndex:i];
        }
    }
    if (loadedPhotoIDs.count > count) {
        for (size_t i = loadedPhotoIDs.count-1; i >= count; i--) {
            [loadedPhotoIDs removeObjectAtIndex:i];
        }
    }
    if (barViews.count > count) {
        for (size_t i = barViews.count-1; i >= count; i--) {
            [barViews[i] removeFromSuperview];
            [barViews removeObjectAtIndex:i];
        }
    }
    if (shadowViews.count > count) {
        for (size_t i = shadowViews.count-1; i >= count; i--) {
            [shadowViews[i] removeFromSuperview];
            [shadowViews removeObjectAtIndex:i];
        }
    }
    [self.view setNeedsDisplay];
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


- (void) userTapped: (UITapGestureRecognizer*) tapGR {
    if (selected) {
        return;
    }
    int count = (int) photoQueue.count;
    CGPoint tapLocation = [tapGR locationInView:mainScrollView];
    CGFloat x = tapLocation.x;
    CGFloat y = tapLocation.y;
    CGFloat photo_size_pt = (self.view.frame.size.width-3*GET_LIKES_CONSTRAINT_PHOTO_OFFSET)/2.0;
    if (x > GET_LIKES_CONSTRAINT_PHOTO_OFFSET && x < GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt) {
        int k = (int)y%(int)(GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)==0 ? (int)y/(GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT) : ceil(y/(double)(GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT));
        if (y > (k-1)*(GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)+GET_LIKES_CONSTRAINT_PHOTO_OFFSET) {
            if (2*k-2 < count) {
                selectedPhotoID = [NSString stringWithFormat:@"%@", photoQueue[2*k-2][@"id"]];
                UIImage *image = ((UIImageView*)imageViews[2*k-2]).image;
                CGFloat width = [self.view getWidth];
                CGFloat height = [self.view getHeight] - 64 - SELECTED_VIEW_HEIGHT;
                CGFloat w_h = width/height;
                CGFloat image_w = image.size.width;
                CGFloat image_h = image.size.height;
                CGFloat image_w_h = image_w/image_h;
                if (image_w_h > w_h) {
                    image = [image cropToSize:CGSizeMake(image_h*w_h, image_h) usingMode:NYXCropModeCenter];
                } else {
                    image = [image cropToSize:CGSizeMake(image_w, image_w/w_h) usingMode:NYXCropModeCenter];
                }
                [self blurredImage: image];
                [self showSelectingView];
            }
        }
    } else if (x > 2*GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt && x < 2*GET_LIKES_CONSTRAINT_PHOTO_OFFSET+2*photo_size_pt) {
        int k = (int)y%(int)(GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)==0 ? (int)y/(GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT) : ceil(y/(double)(GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT));
        if (y > (k-1)*(GET_LIKES_CONSTRAINT_PHOTO_OFFSET+photo_size_pt+GET_LIKES_CONSTRAINT_INFO_BAR_HEIGHT)+GET_LIKES_CONSTRAINT_PHOTO_OFFSET) {
            if (2*k-1 < count) {
                selectedPhotoID = [NSString stringWithFormat:@"%@", photoQueue[2*k-1][@"id"]];
                UIImage *image = ((UIImageView*)imageViews[2*k-1]).image;
                CGFloat width = [self.view getWidth];
                CGFloat height = [self.view getHeight] - 64 - SELECTED_VIEW_HEIGHT;
                CGFloat w_h = width/height;
                CGFloat image_w = image.size.width;
                CGFloat image_h = image.size.height;
                CGFloat image_w_h = image_w/image_h;
                if (image_w_h > w_h) {
                    image = [image cropToSize:CGSizeMake(image_h*w_h, image_h) usingMode:NYXCropModeCenter];
                } else {
                    image = [image cropToSize:CGSizeMake(image_w, image_w/w_h) usingMode:NYXCropModeCenter];
                }
                [self blurredImage:image];
                [self showSelectingView];
            }
        }
    }
}

- (void)blurredImage: (UIImage *) image_
{
    selectedPictureImageView.image = image_;
}

#pragma mark - Setting up view

- (NSMutableArray *) getPhotoSizeTypesForMinimal: (CGFloat) minimal andMaximalPhotoSize: (CGFloat) maximal {
    NSMutableArray *result = [NSMutableArray new];
    CGFloat photoSizePx;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TRAFFIC_ECONOMY] boolValue]) {
        photoSizePx = minimal;
    } else {
        photoSizePx = maximal;
    }
    if (photoSizePx >= 1024) {
        [result addObject:@"w"];
    }
    if (photoSizePx >= 807) {
        [result addObject:@"z"];
    }
    if (photoSizePx >= 604) {
        [result addObject:@"y"];
    }
    if (photoSizePx >= 510) {
        [result addObject:@"x"];
    }
    if (photoSizePx >= 320) {
        [result addObject:@"r"];
    }
    if (photoSizePx >= 200) {
        [result addObject:@"q"];
    }
    if (photoSizePx >= 130) {
        [result addObject:@"p"];
    }
    if (photoSizePx >= 130) {
        [result addObject:@"o"];
    }
    if (photoSizePx >= 75) {
        [result addObject:@"m"];
    }
    return result;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateBalance];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:NSUDEFAULTS_KEY_SHOULD_REWARD]) {
        [[NSUserDefaults standardUserDefaults] setBool:0 forKey:NSUDEFAULTS_KEY_SHOULD_REWARD];
        welcome = [[SCLAlertView alloc] init];
        [welcome setTitleFontFamily:@"AvenirNext-Medium" withSize:18];
        [welcome setBodyTextFontFamily:@"AvenirNext-Regular" withSize:13];
        [welcome setShouldDismissOnTapOutside:YES];
        [welcome showCustom:self image:[UIImage imageNamed:@"Reward"] color:[UIColor colorWithRed:0.976 green:0.635 blue:0.271 alpha:1.00] title:NSLocalizedString(@"Подарок!", nil) subTitle:@"Мы добавили Вам 15 монеток на счет. Заходите каждый день и получайте еще больше!" closeButtonTitle:@"Спасибо!" duration:15.0];
        return;
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_GET_LIKES_WELCOME_SHOWN]) {
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(showWelcome) userInfo:nil repeats:NO];
    } else {
        [self attemptToLoadInterestitial];
    }
}

- (BOOL) automaticallyAdjustsScrollViewInsets {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!imageViews) imageViews = [NSMutableArray new];
    if (!barViews) barViews = [NSMutableArray new];
    if (!shadowViews) shadowViews = [NSMutableArray new];
    
    //Setting VK SDK initial parameters
    isCaptchaPresented = NO;
    
    //Setting background color
    self.view.backgroundColor = [UIColor colorWithRed:0.929 green:0.933 blue:0.941 alpha:1.00];
    
    //Setting menu button
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 38, 38);
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.title = NSLocalizedString(@"Заказать лайки", nil);
    for (UIView *parentView in self.navigationController.navigationBar.subviews)
        for (UIView *childView in parentView.subviews)
            if ([childView isKindOfClass:[UIImageView class]])
                [childView removeFromSuperview];
    [self updateBalance];
    
    selectingView = [[UIView alloc] initWithFrame:CGRectMake(0, 2*self.view.frame.size.height-SELECTED_VIEW_HEIGHT-64, self.view.frame.size.width, SELECTED_VIEW_HEIGHT)];
    selectingView.backgroundColor = [UIColor whiteColor];
    CGFloat tableViewOffset = 0;
    likesTableView = [[UITableView alloc] initWithFrame:CGRectMake(tableViewOffset, 0, self.view.frame.size.width-2*tableViewOffset, SELECTED_VIEW_HEIGHT)];
    likesTableView.scrollsToTop = NO;
    [likesTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellReuseIdentifier"];
    likesTableView.backgroundColor = [UIColor clearColor];
    likesTableView.delegate = self;
    likesTableView.dataSource = self;
    [selectingView addSubview:likesTableView];
    offers = @[ @[@"5 лайков", @"15"], @[@"15 лайков", @"45"], @[@"25 лайков", @"75"], @[@"50 лайков", @"150"], @[@"125 лайков", @"250"], @[@"375 лайков", @"500"], @[@"625 лайков", @"625"]];
    prices = @[@15, @45, @75, @150, @250, @500, @625];
    selectingView.layer.masksToBounds = NO;
    selectingView.layer.shadowOpacity = 0.4;
    selectingView.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:0.6].CGColor;
    selectingView.layer.shadowOffset = CGSizeMake(0, -6);
    
    selectedPictureImageView = [UIImageView new];
    selectedPictureImageView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-SELECTED_VIEW_HEIGHT-64);
    selectedPictureImageView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    panGR.delegate = self;
    [selectedPictureImageView addGestureRecognizer:panGR];
    selectedPictureImageView.layer.shadowColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    selectedPictureImageView.layer.shadowOpacity = 0.5;
    selectedPictureImageView.layer.shadowOffset = CGSizeMake(0, -4);
    
    CAGradientLayer *theGradient = [CAGradientLayer layer];
    CGRect frame = selectedPictureImageView.bounds;
    frame.origin.y += frame.size.height*0.6;
    frame.size.height /= 5.0/2.0;
    theGradient.frame = frame;
    theGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor clearColor] CGColor],
                          (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] CGColor], nil];
    [selectedPictureImageView.layer insertSublayer:theGradient atIndex:0];
    CGFloat buttonSize = 30;
    CGFloat boundsOffset = 14;
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-boundsOffset-buttonSize, [selectedPictureImageView getHeight]-boundsOffset-buttonSize, buttonSize, buttonSize)];
    [closeButton addTarget:self action:@selector(hideSelectingView_button) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *closeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChevronDown"]];
    closeImageView.frame = closeButton.frame;
    [selectedPictureImageView addSubview:closeImageView];
    [selectedPictureImageView addSubview:closeButton];
    
    UIButton *shopButton = [[UIButton alloc] initWithFrame:CGRectMake(boundsOffset, [selectedPictureImageView getHeight]-boundsOffset-buttonSize, buttonSize, buttonSize)];
    [shopButton addTarget:self action:@selector(purchaseCoins) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *shopImageViewSmall = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShoppingSmall"]];
    shopImageViewSmall.frame = shopButton.frame;
    [selectedPictureImageView addSubview:shopImageViewSmall];
    [selectedPictureImageView addSubview:shopButton];
}

#pragma mark - Navigation and views

- (void) pan: (UIPanGestureRecognizer*) gr {
    CGPoint velocity = [gr velocityInView:gr.view];
    BOOL isHorizontalPanning = fabs(velocity.x) > fabs(velocity.y);
    if (gr.state == UIGestureRecognizerStateBegan) {
        if (isHorizontalPanning) return;
        isScrollActive = YES;
        initialGRPoint = [gr locationInView:self.view];
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        if (isScrollActive) {
            CGPoint translationPoint = [gr locationInView:self.view];
            CGFloat delta = translationPoint.y-initialGRPoint.y;
            [selectedPictureImageView setY:MAX(64+delta,64)];
            [selectingView setY:MAX([self.view getHeight]-SELECTED_VIEW_HEIGHT+delta, [self.view getHeight]-SELECTED_VIEW_HEIGHT)];
        }
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        isScrollActive = NO;
        CGFloat v = velocity.y;
        CGFloat sgn = v>0?-1:1;
        CGFloat a = v*sgn;
        CGFloat t = -v/a;
        CGFloat end = initialGRPoint.y+v*t+a*t*t/2.0;
        CGFloat speed = MAX(v, ANIM_MIN_VELOCITY);
        CGFloat dest;
        if (end < [self.view getHeight]*ANIM_VIEW_KOEF) {
            dest = 64;
        } else if (end >= [self.view getHeight]*(1-ANIM_VIEW_KOEF)) {
            dest = [self.view getHeight];
        } else {
            if (sgn==1) {
                dest = 64;
                speed/=2;
            } else if (sgn == -1){
                dest = [self.view getHeight];
            }
        }
        [UIView animateWithDuration:fabs(dest-[selectedPictureImageView getOriginY])/speed delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [selectedPictureImageView setY: dest];
            [selectingView setY:dest+[selectedPictureImageView getHeight]];
        } completion:^(BOOL finished) {
            if (dest == [self.view getHeight]) {
                [self attemptToLoadInterestitial];
                selected = NO;
                [mainScrollView setUserInteractionEnabled:YES];
                selectedPictureImageView.alpha = 0;
            } else {
                selected = YES;
            }
        }];
    }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"GetLikesSession" withParameters:NULL];
    [self hideSelectingView];
    [welcome hideView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Setting SVProgressHud
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setMinimumDismissTimeInterval:1.0];
    
    //Setting VK SDK
    [VKSdk instance].uiDelegate = self;
    
    [Flurry logEvent:@"GetLikesSession" timed:YES];
    photoQueue = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_PHOTO_QUEUE];
    
    [self updateMainScrollView];
    
    //Adding selecting view
    if (!selectingView.superview) {
        [self.view addSubview:selectingView];
    }
    
    [self updateBrief];
    
    //Added selected picture image views
    if (!selectedPictureImageView.superview) {
        [self.view addSubview:selectedPictureImageView];
    }
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

#pragma mark - Updating user info

- (void) updateData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateDataPerformTask];
        [self updateBrief];
    });
}

- (void) updateDataPerformTask {
    
    //Getting profile photo queue
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    VKRequest *profileRequest = [VKRequest requestWithMethod:@"photos.get" parameters:@{VK_API_ALBUM_ID:@"profile", @"photo_sizes":@"1", VK_API_EXTENDED: @"1", @"rev":@"1", VK_API_USER_ID:userID, VK_API_COUNT:[NSString stringWithFormat:@"%i", MAX_PROFILE_PHOTOS]}];
    profileRequest.attempts = 5;
    profileRequest.requestTimeout = VK_TIMEOUT;
    __block NSMutableArray *photoArray = [NSMutableArray new];
    [profileRequest executeWithResultBlock:^(VKResponse *response) {
        NSMutableArray *array = response.json[@"items"];
        [photoArray addObjectsFromArray:array];
        VKRequest* wallRequest = [VKRequest requestWithMethod:@"photos.get" parameters:@{VK_API_ALBUM_ID:@"wall", @"photo_sizes":@"1", VK_API_EXTENDED: @"1", @"rev":@"1", VK_API_USER_ID:userID, VK_API_COUNT:[NSString stringWithFormat:@"%i", MAX_WALL_PHOTOS]}];
        wallRequest.attempts = 5;
        wallRequest.requestTimeout = VK_TIMEOUT;
        [wallRequest executeWithResultBlock:^(VKResponse *response) {
            NSMutableArray *array = response.json[@"items"];
            [photoArray addObjectsFromArray:array];
            
            //Update
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setObject:photoArray forKey:NSUDEFAULTS_KEY_PHOTO_QUEUE];
                photoQueue = photoArray;
                [self updateMainScrollView];
            });
            
        } errorBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [refreshControl endRefreshing];
            });
            
        }];
    } errorBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl endRefreshing];
        });
        
    }];
    
    VKRequest *userInfoRequest = [[VKApi users] get:@{VK_API_USER_IDS:userID, VK_API_FIELDS:@"status,counters,sex,bdate,verified,photo_max,deactivated", VK_API_ACCESS_TOKEN:[[NSUserDefaults standardUserDefaults] objectForKey: NSUDEFAULTS_KEY_ACCESS_TOKEN]}];
    userInfoRequest.attempts = 5;
    userInfoRequest.requestTimeout = VK_TIMEOUT;
    [userInfoRequest executeWithResultBlock:^(VKResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateMainScrollView];
            [refreshControl endRefreshing];
        });
    } errorBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl endRefreshing];
        });
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
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:1] forKey:NSUDEFAULTS_KEY_GET_LIKES_WELCOME_SHOWN];
    welcome = [[SCLAlertView alloc] init];
    [welcome setTitleFontFamily:@"AvenirNext-Medium" withSize:18];
    [welcome setBodyTextFontFamily:@"AvenirNext-Regular" withSize:13];
    [welcome setShouldDismissOnTapOutside:YES];
    [welcome showCustom:self image:[UIImage imageNamed:@"GetLikesImage"] color:[UIColor colorWithRed:0.980 green:0.204 blue:0.518 alpha:1.00] title:NSLocalizedString(TEXT_GET_LIKES_WELCOME_TITLE, nil) subTitle:NSLocalizedString(TEXT_GET_LIKES_WELCOME_TEXT, nil) closeButtonTitle:NSLocalizedString(@"Отлично!",nil) duration:15.0];
}

@end
