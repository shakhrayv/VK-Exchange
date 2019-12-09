
#import "VKGetMoneyViewController.h"

#define _k @"SHOULD_SHOW_INTERESTITIAL"
#define _sh @"SERVER_PERMISSION_TO_SHOW_AD"
#define udfset(obj, key) [[NSUserDefaults standardUserDefaults] setObject: obj forKey: key]
#define udfsetbool(bool, key) [[NSUserDefaults standardUserDefaults] setBool: bool forKey: key]
#define udfgetobj(key) [[NSUserDefaults standardUserDefaults] objectForKey: key]
#define udfgetbool(key) [[NSUserDefaults standardUserDefaults] boolForKey: key]


typedef enum {
    ErrorTypeNoTasksAvailable,
    ErrorTypePoorInternetConnection,
    ErrorTypeServerError,
    ErrorTypeOther
} ErrorType;

typedef enum {
    TaskTypePhoto,
    TaskTypeSubscriber,
    TaskTypeRepost
} TaskType;

NSTimeInterval availabilityTime = 1;
CGFloat buttonWidth;
CGFloat buttonHeight;
CGFloat photoSize;
CGFloat offsetL;
CGFloat dist;
CGFloat offsetTop;

@implementation VKGetMoneyViewController

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

#pragma mark - Loading/showing tasks
- (void) loadTask {
    
    [self hideErrorMessage:NO];
    [((AppDelegate *) [[UIApplication sharedApplication] delegate]) updateLeftMenu];
    
    NSString *token = [Utilities generateUniqueString];
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    NSString *types = @"photo,subscriber,repost";
    NSString *key0 = [NSStringFromClass([NSObject class]) sha256];
    NSString *pass = [[NSString stringWithFormat:@"%@%@photosubscriberrepost%@", token, userID, key0] sha512];
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
        serverResponse = responseObject;
        if ([responseObject[@"response"][@"count"] intValue]) {
            //Task is available
            
            NSString * __block photoID = [NSString stringWithFormat:@"%i", [responseObject[@"response"][@"task"][@"id"] intValue]];
            NSString * __block ownerID = [NSString stringWithFormat:@"%i", [responseObject[@"response"][@"task"][@"owner_id"] intValue]];
            NSLog(@"%@ %@", ownerID, photoID);
            if ([(NSString*)responseObject[@"response"][@"task"][@"type"] isEqualToString: @"photo"]) {
                
                //Checking if photo was not liked before
                VKRequest *request0 = [VKRequest requestWithMethod:@"likes.isLiked"
                                                        parameters:@{@"user_id":userID,
                                                                     @"type":@"photo",
                                                                     @"owner_id":ownerID,
                                                                     @"item_id":photoID}];
                request0.attempts = 5;
                request0.requestTimeout = VK_TIMEOUT;
                [request0 executeWithResultBlock:^(VKResponse *response0) {
                    //NSLog(@"%@", response0.json);
                    
                    if ([[response0.json objectForKey:@"liked"] intValue]) {
                        //Photo was liked before, load another task
                        [self loadTask];
                        return;
                    }
                    
                    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_LOAD_IMAGES] boolValue] || (![[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_LOAD_IMAGES] && SETTINGS_DEFAULT_VALUE_LOAD_IMAGES)) {
                        
                        //Loading photo (with quality preferences) and user information
                        NSString *ID = [NSString stringWithFormat:@"%@_%@", ownerID, photoID];
                        NSString* accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_ACCESS_TOKEN];
                        VKRequest *request1 = [VKRequest requestWithMethod:@"photos.getById" parameters:@{@"photos":ID,
                                                                                                          @"photo_sizes":@"1",
                                                                                                          @"access_token":accessToken}];
                        request1.attempts = 5;
                        request1.requestTimeout = VK_TIMEOUT;
                        [request1 executeWithResultBlock:^(VKResponse *response1) {
                            CGFloat imageSize = 2*size;
                            if ([[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TRAFFIC_ECONOMY] boolValue] || (![[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TRAFFIC_ECONOMY] && SETTINGS_DEFAULT_VALUE_TRAFFIC_ECONOMY)) {
                                imageSize = size;
                            }
                            NSMutableArray *properSizeTypes = [self getPhotoSizeTypesForPhotoSize:imageSize];
                            NSString *URLString = NULL;
                            NSArray *sizes = response1.json[0][@"sizes"];
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
                            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL]];
                            [self presentTaskOfType:TaskTypePhoto withPhoto:image name:NULL comment:NULL];
                        } errorBlock:^(NSError *error) {
                            if (error.code == VK_API_ERROR) {
                                [self loadTask];
                            } else {
                                [self showError:ErrorTypePoorInternetConnection];
                            }
                        }];
                    } else {
                        [self presentTaskOfType:TaskTypePhoto withPhoto:NULL name:NULL comment:NULL];
                    }
                } errorBlock:^(NSError *error) {
                    if (error.code == VK_API_ERROR) {
                        [self loadTask];
                    } else {
                        [self showError:ErrorTypePoorInternetConnection];
                    }
                }];
                
                //End of loading photo type task
            } else if ([(NSString*)responseObject[@"response"][@"task"][@"type"] isEqualToString: @"subscriber"]) {
                
                NSString *  __block ownerID = [NSString stringWithFormat:@"%i", [responseObject[@"response"][@"task"][@"owner_id"] intValue]];
                //NSLog(@"subscr %@", ownerID);
                //Checking if user was not subscriber before
                VKRequest *request0 = [VKRequest requestWithMethod:@"friends.get" parameters:@{@"user_id":userID} ];
                request0.attempts = 5;
                request0.requestTimeout = VK_TIMEOUT;
                [request0 executeWithResultBlock:^(VKResponse *response0) {
                    
                    //Checking in friends
                    if ((BOOL)[(NSArray*)response0.json[@"items"] containsObject:[NSNumber numberWithLong:(long)[ownerID intValue]]]) {
                        //NSLog(@"Already a friend.\n");
                        [self loadTask];
                        return;
                    } else {
                        //Checking in followers
                        VKRequest *requestf = [VKRequest requestWithMethod:@"friends.getRequests" parameters:@{@"user_id":userID} ];
                        requestf.attempts = 5;
                        requestf.requestTimeout = VK_TIMEOUT;
                        [requestf executeWithResultBlock:^(VKResponse *responsef) {
                            
                            //NSLog(@"Subscribers:%@", responsef.json[@"users"][@"items"]);
                            if ((BOOL)[(NSArray*)responsef.json[@"users"][@"items"] containsObject:[NSNumber numberWithLong:(long)[ownerID intValue]]]) {
                                NSLog(@"Already a subscriber.\n");
                                [self loadTask];
                                return;
                            } else {
                                //Loading profile info (subscriber task)
                                VKRequest *request1 = [VKRequest requestWithMethod:@"users.get" parameters:@{@"user_ids":ownerID, @"fields":@"photo_max,photo_max_orig,city"} ];
                                request1.attempts = 5;
                                request1.requestTimeout = VK_TIMEOUT;
                                [request1 executeWithResultBlock:^(VKResponse *response1) {
                                    
                                    NSString *name = [NSString stringWithFormat:@"%@ %@", [response1.json[0] objectForKey:@"first_name"], [response1.json[0] objectForKey:@"last_name"]];
                                    NSString *city = response1.json[0][@"city"][@"title"];
                                    
                                    //Load profile photo
                                    NSString* urlString;
                                    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TRAFFIC_ECONOMY] boolValue] || (![[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_KEY_TRAFFIC_ECONOMY] && SETTINGS_DEFAULT_VALUE_TRAFFIC_ECONOMY)) {
                                        urlString = response1.json[0][@"photo_max"];
                                    } else {
                                        urlString = response1.json[0][@"photo_max_orig"];
                                    }
                                    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:SERVER_TIMEOUT]];
                                    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                                    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        [self presentTaskOfType:TaskTypeSubscriber withPhoto:(UIImage*)responseObject name:name comment:city];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        [self showError:ErrorTypePoorInternetConnection];
                                    }];
                                    [requestOperation start];
                                } errorBlock:^(NSError *error) {
                                    if (error.code == VK_API_ERROR) {
                                        [self loadTask];
                                    } else {
                                        [self showError:ErrorTypePoorInternetConnection];
                                    }
                                }];
                            }
                            
                        } errorBlock:^(NSError *error) {
                            if (error.code == VK_API_ERROR) {
                                [self loadTask];
                            } else {
                                [self showError:ErrorTypePoorInternetConnection];
                            }
                        }];
                    }
                    
                } errorBlock:^(NSError *error) {
                    if (error.code == VK_API_ERROR) {
                        [self loadTask];
                    } else {
                        [self showError:ErrorTypePoorInternetConnection];
                    }
                }];
            } else if ([(NSString*)responseObject[@"response"][@"task"][@"type"] isEqualToString: @"repost"]) {
                NSString *ID = [NSString stringWithFormat:@"%@_%@", ownerID, photoID];
                //Checking if photo was not liked before
                VKRequest *request0 = [VKRequest requestWithMethod:@"wall.getById"
                                                        parameters:@{@"posts":ID,
                                                                     @"extended":@"1",
                                                                     @"copy_history_depth":@"1"}];
                request0.attempts = 5;
                request0.requestTimeout = VK_TIMEOUT;
                [request0 executeWithResultBlock:^(VKResponse *response) {
                    NSDictionary *json = response.json;
                    if (json[@"items"] && ((NSArray*)json[@"items"]).count) {
                        NSDictionary *task = json[@"items"][0];
                        NSString *text = @"";
                        if (![task[@"text"] isEqualToString:@""]) {
                            text = task[@"text"];
                        } else if (task[@"attachments"]) {
                            for (NSDictionary* __block attachment in (NSArray*)task[@"attachments"]) {
                                if ([attachment[@"type"] isEqualToString:@"link"]) {
                                    text = [NSString stringWithFormat:@"Repost: %@", attachment[@"link"][@"title"]];
                                    break;
                                }
                            }
                            NSDictionary* attachment = task[@"attachments"][0];
                            if ([attachment[@"type"] isEqualToString:@"photo"]) {
                                text = NSLocalizedString(@"Фотография", nil);
                            } else if ([attachment[@"type"] isEqualToString:@"video"]) {
                                text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Видео", nil), attachment[@"video"][@"title"]];
                            } else if ([attachment[@"type"] isEqualToString:@"poll"]) {
                                text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Опрос", nil), attachment[@"poll"][@"question"]];
                            }
                        } else if (task[@"copy_history"]) {
                            BOOL isFound = false;
                            for (NSDictionary* __block post in (NSArray*)task[@"copy_history"]) {
                                if (![post[@"text"] isEqualToString:@""]) {
                                    text = [NSString stringWithFormat:@"Repost: %@", post[@"text"]];
                                    isFound = true;
                                    break;
                                }
                            }
                            if (!isFound) {
                                for (NSDictionary* __block post in (NSArray*)task[@"copy_history"]) {
                                    if ([[NSString stringWithFormat:@"%i", [post[@"owner_id"] intValue]] characterAtIndex:0] =='-') {
                                        NSString *groupID = [[NSString stringWithFormat:@"%i", [post[@"owner_id"] intValue]] substringFromIndex:1];
                                        for (NSDictionary* __block group in (NSArray*)json[@"groups"]) {
                                            if ([[NSString stringWithFormat:@"%i", [group[@"id"] intValue]] isEqualToString:groupID]) {
                                                text = [NSString stringWithFormat:@"Repost: %@", group[@"name"]];
                                                isFound = true;
                                                break;
                                            }
                                        }
                                    } else {
                                        NSString *userID = [NSString stringWithFormat:@"%i", [post[@"owner_id"] intValue]];
                                        for (NSDictionary* __block user in (NSArray*)json[@"profiles"]) {
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

                        VKRequest *request1 = [VKRequest requestWithMethod:@"users.get"
                                                                parameters:@{@"user_ids":ownerID,
                                                                             @"fields":@"first_name,second_name",
                                                                             @"name_case":@"gen"}];
                        request1.attempts = 5;
                        request1.requestTimeout = VK_TIMEOUT;
                        [request1 executeWithResultBlock:^(VKResponse *response1) {
                            NSString *first_name = response1.json[0][@"first_name"];
                            NSString *last_name = response1.json[0][@"last_name"];
                            NSString *comment = [NSString stringWithFormat:@"Запись %@ %@", first_name, last_name];
                            NSString *__block photoURL;
                            if (task[@"attachments"]) {
                                for (NSDictionary* __block attachment in (NSArray*)task[@"attachments"]) {
                                    if ([attachment[@"type"] isEqualToString:@"photo"]) {
                                        photoURL = attachment[@"photo"][@"photo_604"];
                                        break;
                                    } else if ([attachment[@"type"] isEqualToString:@"link"] && attachment[@"link"][@"photo"]) {
                                        photoURL = attachment[@"link"][@"photo"][@"photo_604"];
                                        break;
                                    } else if([attachment[@"type"] isEqualToString:@"video"]) {
                                        photoURL = attachment[@"video"][@"photo_604"];
                                        break;
                                    }
                                }
                            }
                            if (!photoURL) {
                                if (task[@"copy_history"] && task[@"copy_history"][0][@"attachments"]) {
                                    for (NSDictionary* __block attachment in (NSArray*)task[@"copy_history"][0][@"attachments"]) {
                                        if ([attachment[@"type"] isEqualToString:@"photo"]) {
                                            photoURL = attachment[@"photo"][@"photo_604"];
                                            break;
                                        } else if ([attachment[@"type"] isEqualToString:@"link"] && attachment[@"link"][@"photo"]) {
                                            photoURL = attachment[@"link"][@"photo"][@"photo_604"];
                                            break;
                                        } else if([attachment[@"type"] isEqualToString:@"video"]) {
                                            photoURL = attachment[@"video"][@"photo_604"];
                                            break;
                                        }
                                    }
                                }
                            }
                            if (photoURL) {
                                NSURL *photoURL_ = [NSURL URLWithString:photoURL];
                                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoURL_]];
                                [self presentTaskOfType:TaskTypeRepost withPhoto:image name:text comment:comment];
                            } else {
                                UIImage *placeholder = [UIImage imageNamed:@"PencilBig"];
                                [self presentTaskOfType:TaskTypeRepost withPhoto:placeholder name:text comment:comment];
                            }
                        } errorBlock:^(NSError *error) {
                            if (error.code == VK_API_ERROR) {
                                [self loadTask];
                            } else {
                                [self showError:ErrorTypePoorInternetConnection];
                            }
                        }];
                    } else {
                        [self loadTask];
                    }
                } errorBlock:^(NSError *error) {
                    if (error.code == VK_API_ERROR) {
                        [self loadTask];
                    } else {
                        [self showError:ErrorTypePoorInternetConnection];
                    }
                }];
            }
        } else {
            [self showError:ErrorTypeNoTasksAvailable];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self showError:ErrorTypePoorInternetConnection];
    }];
}

- (void) presentTaskOfType: (TaskType) type withPhoto: (UIImage * _Nullable) photo name: (NSString*) name comment: (NSString *) comment {
    [self hideSpinner];
    activity.alpha = 0;
    if (!photo) {
        photo = [UIImage imageNamed:@"Placeholder"];
    }
    [UIView animateWithDuration:ANIMATIONS_DURATION_1X animations:^{
        updateButton.alpha = 0;
    }];
    UIColor *titleColor = [UIColor colorWithWhite:0.2 alpha:1];
    UIColor *commentColor = [UIColor colorWithWhite:0.6 alpha:1];
    [likeButton setTitle:NSLocalizedString(type==TaskTypePhoto?@"ЛАЙКНУТЬ  (+1)":type==TaskTypeSubscriber?@"ПОДПИСАТЬСЯ  (+3)":@"РЕПОСТНУТЬ (+7)", nil) forState:UIControlStateNormal];
    [titleLabel removeFromSuperview];
    titleLabel = nil;
    [commentLabel removeFromSuperview];
    commentLabel = nil;
    
    if (type==TaskTypeSubscriber || type == TaskTypeRepost) {
        commentLabel = [[UILabel alloc] init];
        [commentLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:14]];
        commentLabel.textColor = commentColor;
        commentLabel.textAlignment = NSTextAlignmentCenter;
        commentLabel.text = comment;
        [commentLabel sizeToFit];
        [commentLabel setY: likeButton.frame.origin.y-offsetL-commentLabel.frame.size.height];
        [commentLabel setX: self.view.frame.size.width/2.0-commentLabel.frame.size.width/2.0];
        [self.view addSubview:commentLabel];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20]];
        titleLabel.textColor = titleColor;
        titleLabel.text = name;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleLabel sizeToFit];
        [titleLabel setY: commentLabel.frame.origin.y-7-titleLabel.frame.size.height];
        [titleLabel setX: 30];
        [titleLabel setWidth: self.view.frame.size.width-60];
        [self.view addSubview:titleLabel];
        
        commentLabel.alpha = 0;
        titleLabel.alpha = 0;
    }
    
    CGFloat imageSize = type==TaskTypePhoto?photoSize:MIN(titleLabel.frame.origin.y-15-offsetTop, self.view.frame.size.width*0.4f);
    
    CGRect frame1 = [mainImageView frame];
    CGRect frame2 = frame1;
    frame2.origin.x = -mainImageView.frame.size.width;
    CGRect frame4;
    if (type == TaskTypePhoto) {
        frame4 = CGRectMake(self.view.frame.size.width/2.0-imageSize/2.0, offsetTop, imageSize, imageSize);
    } else {
        frame4 = CGRectMake(self.view.frame.size.width/2.0-imageSize/2.0,titleLabel.frame.origin.y-22-imageSize, imageSize, imageSize);
    }
    CGRect frame3 = frame4;
    frame3.origin.x = self.view.frame.size.width;
    UIImageView* __block imageView = [[UIImageView alloc] initWithFrame:frame3];
    imageView.image = [photo cropToSize:CGSizeMake(MIN(photo.size.width, photo.size.height), MIN(photo.size.width, photo.size.height)) usingMode:NYXCropModeCenter];
    if (type == TaskTypeSubscriber || type == TaskTypeRepost) {
        imageView.layer.cornerRadius = imageSize/2.0;
    } else if (type == TaskTypePhoto) {
        imageView.layer.cornerRadius = 4;
    }
    imageView.layer.shadowColor = [UIColor grayColor].CGColor;
    imageView.layer.shadowOpacity = 1;
    imageView.layer.shadowOffset = CGSizeMake(0, 10);
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    
    [UIView animateWithDuration:ANIMATIONS_DURATION_1X delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        mainImageView.frame = frame2;
        imageView.frame = frame4;
    } completion:^(BOOL finished) {
        mainImageView = imageView;
        [self showButtons:YES immediate:NO];
        [UIView animateWithDuration:ANIMATIONS_DURATION_2X animations:^{
            titleLabel.alpha = 1;
            commentLabel.alpha = 1;
        }];
    }];
}

#pragma mark - Showing/hiding views

- (void) addActivityIndicatorWithStyle: (UIActivityIndicatorViewStyle) style toButton: (UIButton*) button {
    UIActivityIndicatorView *activity_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    activity_.frame = CGRectMake(button.frame.size.width-button.frame.size.height/2.0-activity_.frame.size.width/2.0, button.frame.size.height/2.0-activity_.frame.size.height/2.0, activity_.frame.size.width, activity_.frame.size.height);
    [activity_ startAnimating];
    [button addSubview:activity_];
}

- (void) showError: (ErrorType) errorType {
    [self showButtons:NO immediate:NO];
    activity.alpha = 0;
    [self hideTask];
    [self hideSpinner];
    updateButton.alpha = 1;
    
    //Setting error description
    if (!errorDescriptionLabel) {
        errorDescriptionLabel = [UILabel new];
        errorDescriptionLabel.textColor = [UIColor grayColor];
        errorDescriptionLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
        errorDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        errorDescriptionLabel.numberOfLines = 0;
        [self.view addSubview:errorDescriptionLabel];
    }
    
    //Updating error info
    NSString *description;
    switch (errorType) {
        case ErrorTypeNoTasksAvailable:
            description = @"В данный момент нет доступных заданий.\nПожалуйста, попробуйте снова.";
            break;
        case ErrorTypeServerError:
            description = @"Произошла какая-то ошибка с нашей стороны.\nМы приносим свои извинения.\nПожалуйста, попробуйте снова.";
            break;
        case ErrorTypePoorInternetConnection:
            description = @"Не удалось соединиться с сервером.\nПожалуйста, проверьте соединение и \nпопробуйте снова.";
            break;
        default:
            description = @"Произошла неизвестная ошибка.\nПожалуйста, попробуйте снова.";
            break;
    }
    description = NSLocalizedString(description, nil);
    errorDescriptionLabel.text = description;
    
    errorDescriptionLabel.frame = CGRectMake(-999, -999, self.view.frame.size.width, 999);
    [errorDescriptionLabel sizeToFit];
    CGRect frame = errorDescriptionLabel.frame;
    frame.origin.x = self.view.frame.size.width/2.0-frame.size.width/2.0;
    frame.origin.y = ignoreButton.frame.origin.y - 60 - frame.size.height;
    errorDescriptionLabel.frame = frame;
    
    //Setting image
    if (!errorImageView) {
        errorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-75, 64+(errorDescriptionLabel.frame.origin.y-64)/2.0-75, 150, 150)];
        [self.view addSubview:errorImageView];
    }
    errorImageView.alpha = 1;
    errorDescriptionLabel.alpha = 1;
    NSString *imageName;
    switch (errorType) {
        case ErrorTypeNoTasksAvailable:
            imageName = @"NoTasks";
            break;
        case ErrorTypePoorInternetConnection:
            imageName = @"PoorInternet";
            break;
        default:
            imageName = @"UnknownError";
            break;
    }
    errorImageView.image = [UIImage imageNamed:imageName];
}

- (void) hideErrorMessage: (BOOL) animated {
    if (animated) {
        [UIView animateWithDuration:ANIMATIONS_DURATION_2X animations:^{
            errorImageView.alpha = 0;
            errorDescriptionLabel.alpha = 0;
        }];
    } else {
        errorImageView.alpha = 0;
        errorDescriptionLabel.alpha = 0;
    }
}

- (void) showButtons: (BOOL) show immediate: (BOOL) immediate {
    likeButton.enabled = show;
    ignoreButton.enabled = show;
    if (immediate) {
        likeButton.alpha = (float) show;
        ignoreButton.alpha = (float) show;
    } else {
        [UIView animateWithDuration:ANIMATIONS_DURATION_2X animations:^{
            likeButton.alpha = (float) show;
            ignoreButton.alpha = (float) show;
        }];
    }
}

- (void) hideSpinner {
    for (UIButton *button in @[likeButton, ignoreButton, watchVideoButton, updateButton]) {
        for (UIView *subview __strong in button.subviews) {
            if ([subview isKindOfClass:[UIActivityIndicatorView class]]) {
                [subview removeFromSuperview];
                subview = nil;
            }
        }
    }
}

- (void) enableButtons: (BOOL) enable {
    likeButton.enabled = enable;
    ignoreButton.enabled = enable;
    watchVideoButton.enabled = enable;
    updateButton.enabled = enable;
}

- (void) hideTask {
    titleLabel.alpha = 0;
    commentLabel.alpha = 0;
    mainImageView.alpha = 0;
}

- (void) pressedIntermediateAction: (id) sender {
    [self touchEnded:likeButton];
    NSString *type = serverResponse[@"response"][@"task"][@"type"];
    if ([type isEqualToString:@"repost"] && ![[NSUserDefaults standardUserDefaults] boolForKey:NSUDEFAULTS_KEY_REPOSTS_WARNING_SHOWN]) {
        SCLAlertView* alert = [[SCLAlertView alloc] init];
        [alert setTitleFontFamily:@"AvenirNext-Medium" withSize:18];
        [alert setBodyTextFontFamily:@"AvenirNext-Regular" withSize:13];
        [alert setShouldDismissOnTapOutside:YES];
        [alert addButton:@"Репостнуть (+7)" actionBlock:^{
            [[NSUserDefaults standardUserDefaults] setBool:1 forKey:NSUDEFAULTS_KEY_REPOSTS_WARNING_SHOWN];
            [self pressedAction:sender];
        }];
        [alert showCustom:self image:[UIImage imageNamed:@"RepostWarning"] color:[UIColor colorWithRed:0.996 green:0.647 blue:0.157 alpha:1.00] title:@"Репост" subTitle:@"Вы пытаетесь репостнуть запись. Заранее предупреждаем, что удалять записи со стены запрещено." closeButtonTitle:@"Отмена" duration:0.0];
    } else {
        [self pressedAction:sender];
    }
}

#pragma mark - Actions (like/subscriber/repost)
- (void) pressedAction: (id) sender {
    
    //[self touchEnded:likeButton];
    [self addActivityIndicatorWithStyle:UIActivityIndicatorViewStyleGray toButton:likeButton];
    [self startAvailabilitySession:availabilityTime];
    
    [self loadTask];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Main information
        NSString *token = [Utilities generateUniqueString];
        NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
        NSString *key = [NSStringFromClass([NSDictionary class]) sha256];
        NSString *orderID = serverResponse[@"response"][@"task"][@"order_id"];
        NSString *type = serverResponse[@"response"][@"task"][@"type"];
        NSString *ownerID = [NSString stringWithFormat:@"%i", [serverResponse[@"response"][@"task"][@"owner_id"] intValue]];
        NSString *shouldReward = @"1";
        NSString *automatic = @"0";
        NSString *itemID = [NSString stringWithFormat:@"%i", [serverResponse[@"response"][@"task"][@"id"] intValue]];
        
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
                            if ([(NSDictionary*) responseObject objectForKey:@"response"]) {
                                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[responseObject[@"response"][@"balance"] intValue]] forKey:NSUDEFAULTS_KEY_BALANCE];
                                [self updateBalance];
                            } else {
                                //[self showError:ErrorTypeServerError];
                            }
                        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                            [self showError:ErrorTypePoorInternetConnection];
                        }];
                        
                    } else {
                        //[self loadTask];
                    }
                } errorBlock:^(NSError *error) {
                    if (error.code == VK_API_ERROR) {
                        [self loadTask];
                    } else {
                        [self showError:ErrorTypePoorInternetConnection];
                    }
                }];
            } errorBlock:^(NSError *error) {
                if (error.code == VK_API_ERROR) {
                    [self loadTask];
                } else {
                    [self showError:ErrorTypePoorInternetConnection];
                }
            }];
            
        } else if ([type isEqualToString:@"subscriber"]) {
            
            //Subscriber task
            VKRequest *request = [VKRequest requestWithMethod:@"friends.add" parameters:@{@"user_id":ownerID,@"follow":@"1"} ];
            request.attempts = 5;
            request.requestTimeout = VK_TIMEOUT;
            [request executeWithResultBlock:^(VKResponse *response) {
                NSLog(@"attempt successfull");
                if ([response.json intValue]) {
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
                        NSLog(@"response received");
                        if ([(NSDictionary*) responseObject objectForKey:@"response"]) {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[responseObject[@"response"][@"balance"] intValue]] forKey:NSUDEFAULTS_KEY_BALANCE];
                            NSLog(@"%i", [responseObject[@"response"][@"balance"] intValue]);
                            [self updateBalance];
                        } else {
                        }
                    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                        NSLog(@"errorrrr");
                        [self showError:ErrorTypePoorInternetConnection];
                    }];
                } else {
                    //[self loadTask];
                }
            } errorBlock:^(NSError *error) {
                NSLog(@"%@", error.description);
                if (error.code == VK_API_ERROR) {
                    [self loadTask];
                } else {
                    [self showError:ErrorTypePoorInternetConnection];
                }
            }];
        } else if ([type isEqualToString:@"repost"]) {
            NSString *objID = [NSString stringWithFormat:@"wall%@_%@", ownerID, itemID];
            VKRequest *request = [VKRequest requestWithMethod:@"wall.repost" parameters:@{@"object":objID, @"access_token":[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_ACCESS_TOKEN]} ];
            request.attempts = 5;
            request.requestTimeout = VK_TIMEOUT;
            [request executeWithResultBlock:^(VKResponse *response) {
                if ([response.json[@"success"] intValue]) {
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
                        if ([(NSDictionary*) responseObject objectForKey:@"response"]) {
                            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[responseObject[@"response"][@"balance"] intValue]] forKey:NSUDEFAULTS_KEY_BALANCE];
                            [self updateBalance];
                        } else {
                            ;
                        }
                    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                        [self showError:ErrorTypePoorInternetConnection];
                    }];
                    ;
                }
            } errorBlock:^(NSError *error) {
                if (error.code == VK_API_ERROR) {
                    [self loadTask];
                } else {
                    [self showError:ErrorTypePoorInternetConnection];
                }
            }];
        }
    });
}

- (void) pressedIgnore: (id) sender {
    [self startAvailabilitySession:availabilityTime];
    [self touchEnded:sender];
    [self addActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhite toButton:sender];
    [self loadTask];
}

- (void) update: (id) sender {
    [self startAvailabilitySession:availabilityTime];
    [self touchEnded:sender];
    [self addActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhite toButton:sender];
    [self hideErrorMessage:NO];
    [self loadTask];
}

#pragma mark - Navigation and views

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showButtons:NO immediate:YES];
    [Flurry logEvent:@"GetMoneySession" timed:YES];
    [self showError:ErrorTypeOther];
    [self hideErrorMessage:NO];
    [self hideTask];
    updateButton.alpha = 0;
    [self loadTask];
    [self updateAdAvailability];
    [self adFinished];
    activity.alpha = 1;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"GetMoneySession" withParameters:NULL];
    [welcome hideView];
    activity.alpha = 0;
}

- (void) setConstraints {
    if (self.view.frame.size.height==480.0f) {
        buttonHeight = 34.0f;
        buttonWidth = 228.0f;
        offsetL = 30.0f;
        dist = 16.0f;
        photoSize = 168.0f;
    } else if (self.view.frame.size.height==568) {
        buttonHeight = 40.0f;
        buttonWidth = 228.0f;
        offsetL = 45.0f;
        dist = 22.0f;
        photoSize = 184;
    } else {
        buttonHeight = 42.0f;
        buttonWidth = 228.0f;
        offsetL = 45.0f;
        dist = 22.0f;
        photoSize = 228.0f;
    }
    CGFloat navigationBarHeight = 64;
    offsetTop = (self.view.frame.size.height-navigationBarHeight-offsetL-2*dist-3*buttonHeight-photoSize)/2.0;
    offsetTop+=navigationBarHeight;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_GET_MONEY_WELCOME_SHOWN]) {
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showWelcome) userInfo:nil repeats:NO];
    }
    [self updateBalance];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [VKSdk instance].uiDelegate = self;
    [self.view setBackgroundColor: [UIColor colorWithRed:0.976 green:0.980 blue:0.988 alpha:1.00]];
    [self setConstraints];
    
    //Adding menu arrow
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 38, 38);
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    //Setting the rest of navigation view
    self.navigationItem.title = NSLocalizedString(@"Задания", nil);
    for (UIView *parentView in self.navigationController.navigationBar.subviews)
        for (UIView *childView in parentView.subviews)
            if ([childView isKindOfClass:[UIImageView class]])
                [childView removeFromSuperview];
    
    [self updateBalance];
    
    //Adding image view
    size = buttonWidth;
    
    //Colors and button constants
    UIColor *likeButtonColor = [UIColor colorWithRed:0.102 green:0.667 blue:0.627 alpha:1.00];
    UIColor *ignoreButtonColor = [UIColor colorWithRed:0.996 green:0.482 blue:0.376 alpha:1.00];
    UIColor *watchVideoButtonColor = [UIColor colorWithRed:0.996 green:0.722 blue:0.404 alpha:1.00];
    UIColor *updateButtonColor = [UIColor colorWithRed:0.169 green:0.918 blue:0.659 alpha:1.00];
    CGFloat buttonsCornerRadius = 4;
    
    //Adding like button
    likeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-buttonWidth/2.0, offsetTop+photoSize+offsetL, buttonWidth, buttonHeight)];
    [likeButton setTitle:NSLocalizedString(@"ЛАЙКНУТЬ  (+1)", nil) forState:UIControlStateNormal];
    [likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [likeButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:11]];
    [likeButton addTarget:self action:@selector(pressedIntermediateAction:) forControlEvents:UIControlEventTouchUpInside];
    likeButton.layer.cornerRadius = buttonsCornerRadius;
    [likeButton setBackgroundColor:likeButtonColor];
    [self.view addSubview:likeButton];
    
    //Adding ignore button
    ignoreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-buttonWidth/2.0, likeButton.frame.origin.y+buttonHeight+dist, buttonWidth, buttonHeight)];
    [ignoreButton setTitle:NSLocalizedString(@"ДАЛЕЕ", nil) forState:UIControlStateNormal];
    [ignoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ignoreButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:11]];
    [ignoreButton addTarget:self action:@selector(pressedIgnore:) forControlEvents:UIControlEventTouchUpInside];
    ignoreButton.layer.cornerRadius = buttonsCornerRadius;
    [ignoreButton setBackgroundColor:ignoreButtonColor];
    [self.view addSubview:ignoreButton];
    
    //Adding video button
    watchVideoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-buttonWidth/2.0, ignoreButton.frame.origin.y+buttonHeight+dist, buttonWidth, buttonHeight)];
    [watchVideoButton setTitle:NSLocalizedString(@"ПОСМОТРЕТЬ ВИДЕО  (+5)", nil) forState:UIControlStateNormal];
    [watchVideoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [watchVideoButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:11]];
    [watchVideoButton addTarget:self action:@selector(watchVideo:) forControlEvents:UIControlEventTouchUpInside];
    watchVideoButton.tag = 30;
    watchVideoButton.layer.cornerRadius = buttonsCornerRadius;
    [watchVideoButton setBackgroundColor:watchVideoButtonColor];
    [self.view addSubview:watchVideoButton];
    
    //Adding update button
    updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    updateButton.frame = ignoreButton.frame;
    [updateButton setTitle:NSLocalizedString(@"ОБНОВИТЬ", nil) forState:UIControlStateNormal];
    [updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [updateButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Bold" size:11]];
    [updateButton addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];
    updateButton.layer.cornerRadius = buttonsCornerRadius;
    [updateButton setBackgroundColor:updateButtonColor];
    [self.view addSubview:updateButton];
    
    [self configureButton:likeButton];
    [self configureButton:updateButton];
    [self configureButton:ignoreButton];
    [self configureButton:watchVideoButton];
    
    //Adding gradients
    [self addGradientToButton:likeButton];
    [self addGradientToButton:ignoreButton];
    [self addGradientToButton:watchVideoButton];
    [self addGradientToButton:updateButton];
    
    //Setting activity indicator
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.center = CGPointMake(self.view.frame.size.width/2.0, [watchVideoButton getOriginY]-dist-buttonHeight/2.0);
    [activity startAnimating];
    [self.view addSubview:activity];
    activity.alpha = 0;
    
    buttonDimmed = YES;
}

- (void) removeGradientsFromButton: (UIButton *) button {
    for (size_t i = 0; i < [button.layer.sublayers count]; i++) {
        CALayer *layer = button.layer.sublayers[i];
        if ([layer isKindOfClass:[CAGradientLayer class]] && layer.frame.size.height<10) {
            [layer removeFromSuperlayer];
        }
    }
}

- (void) touchStarted: (UIButton *) button {
    [self removeGradientsFromButton:button];
    CGColorRef cgcolor = [button.backgroundColor CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(cgcolor);
    
    if(CGColorGetNumberOfComponents(cgcolor) == 2) {
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        [button.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
        [button setBackgroundColor:[color darken:0.1]];
    } else if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(cgcolor);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [button setBackgroundColor:[color darken:0.1]];
    }
    buttonDimmed = YES;
}

- (void) touchEnded: (UIButton *) button {
    [self removeGradientsFromButton:button];
    CGColorRef cgcolor = [button.backgroundColor CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(cgcolor);
    
    if(CGColorGetNumberOfComponents(cgcolor) == 2) {
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        [button.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
        button.backgroundColor = [color lighten:10.0/9.0-1];
        [self.view setNeedsDisplay];
    } else if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(cgcolor);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [button setBackgroundColor:[color lighten:10.0/9.0-1]];
        [self.view setNeedsDisplay];
    }
    [self addGradientToButton:button];
    buttonDimmed = NO;
}

- (void) configureButton: (UIButton *) button {
    [button addTarget:self action:@selector(touchStarted:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(touchEnded:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchDragExit];
}

- (void) showMenu {
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

- (void) addGradientToButton: (UIButton *) button {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGRect frame = button.layer.bounds;
    float k = 0.94;
    float koeff = 0.2;
    frame.origin.y = frame.size.height*k;
    frame.size.height = frame.size.height*(1-k);
    gradientLayer.frame = frame;
    
    //UIColor *color1 = button.backgroundColor;
    UIColor *color2 = [button.backgroundColor darken:koeff];
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)color2.CGColor,
                            (id)color2.CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    gradientLayer.cornerRadius = button.layer.cornerRadius;
    [button.layer addSublayer:gradientLayer];
}

#pragma mark - Ads

- (void) updateAdAvailability {
    [UIView animateWithDuration:ANIMATIONS_DURATION_05X animations:^{
        watchVideoButton.alpha = AD_AVAILABLE?1:0.6;
    } completion:^(BOOL finished) {
        watchVideoButton.userInteractionEnabled = AD_AVAILABLE;
    }];
}

- (void) watchVideo: (id) sender {
    if (AD_AVAILABLE) {
        [self showAd];
    }
}

- (void) adFinished {
    if (buttonDimmed) {
        [self touchEnded:watchVideoButton];
    }
}

- (void) showAd {
    VungleSDK *sdk = [VungleSDK sharedSDK];
    NSError *e;
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    [sdk playAd:self withOptions:@{VunglePlayAdOptionKeyIncentivized:@YES,
                                   VunglePlayAdOptionKeyUser:userID
                                   } error:&e];
}

- (void) updateBalance {
    int price = [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_BALANCE] intValue];
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(-999, -999, 999, 24)];
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    moneyLabel.text = [NSString stringWithFormat:@"%i", price];
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
    [self.view setNeedsDisplay];
}

#pragma mark - Cropping and timer

- (void) startAvailabilitySession: (NSTimeInterval) t {
    [self enableButtons:NO];
    [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
}

- (void) handleTimer: (NSTimer *) timer {
    [timer invalidate];
    timer = nil;
    [self enableButtons:YES];
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

#pragma mark - Photo sizes

- (NSMutableArray *) getPhotoSizeTypesForPhotoSize: (CGFloat) photoSizePx {
    NSMutableArray *result = [NSMutableArray new];
    if (result) {
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
    return NULL;
}

#pragma mark - Showing welcome alert

- (void) showWelcome {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:1] forKey:NSUDEFAULTS_KEY_GET_MONEY_WELCOME_SHOWN];
    welcome = [[SCLAlertView alloc] init];
    [welcome setTitleFontFamily:@"AvenirNext-Medium" withSize:18];
    [welcome setBodyTextFontFamily:@"AvenirNext-Regular" withSize:13];
    [welcome setShouldDismissOnTapOutside:YES];
    [welcome showCustom:self image:[UIImage imageNamed:@"GetMoneyImage"] color:[UIColor colorWithRed:0.984 green:0.639 blue:0.224 alpha:1.00] title:NSLocalizedString(TEXT_GET_MONEY_WELCOME_TITLE, nil) subTitle:NSLocalizedString(TEXT_GET_MONEY_WELCOME_TEXT, nil) closeButtonTitle:NSLocalizedString(@"Закрыть",nil) duration:15.0];
}

@end
