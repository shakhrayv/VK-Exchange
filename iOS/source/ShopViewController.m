
#import "ShopViewController.h"

//===Purchase identifiers===//
#define Purchase25CoinsProductIdentifier @"co.codelovin.25"
#define Purchase50CoinsProductIdentifier @"co.codelovin.50"
#define Purchase125CoinsProductIdentifier @"co.codelovin.125"
#define Purchase250CoinsProductIdentifier @"co.codelovin.250"
#define Purchase500CoinsProductIdentifier @"co.codelovin.500"
#define Purchase1250CoinsProductIdentifier @"co.codelovin.1250"
#define Purchase3750CoinsProductIdentifier @"co.codelovin.3750"
#define Purchase3750CoinsSalesProductIdentifier @"co.codelovin.3750s"

@implementation ShopViewController


#pragma mark - Setting up table view

int goldenPrice = 6;
int salesHit = -1;

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (adAvailable)
        return section==0||section==1?1:amounts.count;
    return section==0?1:amounts.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (adAvailable)
        return 3;
    return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_VIEW_STANDARD_ROW_HEIGHT;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellReuseIdentifier"];
    cell.backgroundColor = [UIColor whiteColor];
    
    //Setting label
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    if (indexPath.section == 0) {
        textLabel.text = NSLocalizedString(@"Баланс", nil);
    } else if (adAvailable && indexPath.section==1) {
        textLabel.text = [NSString stringWithFormat:@"5 %@", NSLocalizedString(@"монет", nil)];
    } else if ((adAvailable && indexPath.section==2)||(!adAvailable && indexPath.section==1)) {
        switch (indexPath.row) {
            case 0:
                textLabel.text = [NSString stringWithFormat:@"25 %@", NSLocalizedString(@"монет", nil)];
                break;
            case 1:
                textLabel.text = [NSString stringWithFormat:@"50 %@", NSLocalizedString(@"монет", nil)];
                break;
            case 2:
                textLabel.text = [NSString stringWithFormat:@"125 %@", NSLocalizedString(@"монет", nil)];
                break;
            case 3:
                textLabel.text = [NSString stringWithFormat:@"250 %@", NSLocalizedString(@"монет", nil)];
                break;
            case 4:
                textLabel.text = [NSString stringWithFormat:@"500 %@", NSLocalizedString(@"монет", nil)];
                break;
            case 5:
                textLabel.text = [NSString stringWithFormat:@"1250 %@", NSLocalizedString(@"монет", nil)];
                break;
            case 6:
                textLabel.text = [NSString stringWithFormat:@"3750 %@", NSLocalizedString(@"монет", nil)];
            default:
                break;
        }
    }
    textLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    [textLabel sizeToFit];
    CGRect frame = textLabel.frame;
    frame.origin.x = TABLE_VIEW_STANDARD_LEFT_OFFSET;
    frame.origin.y = TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-frame.size.height/2.0;
    textLabel.frame = frame;
    [cell.contentView addSubview:textLabel];
    
    //Checking for spin kit
    if (adAvailable) {
        if (isSelected && ((isSelectedFree && indexPath.section==1)||(!isSelectedFree && indexPath.row == selectedPaid-1&&indexPath.section==2))) {
            for (UIView* view in cell.contentView.subviews) {
                if ([view isKindOfClass:[RTSpinKitView class]]) {
                    return cell;
                }
            }
            RTSpinKitView *spinKit = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArc color:[UIColor colorWithRed:0.086 green:0.514 blue:0.973 alpha:1.00] spinnerSize:25];
            spinKit.frame = CGRectMake(self.view.frame.size.width-TABLE_VIEW_STANDARD_RIGHT_OFFSET-25, TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-12.5, 25, 25);
            [spinKit startAnimating];
            [cell.contentView addSubview:spinKit];
            return cell;
        }
    } else {
        if (isSelected&&indexPath.section==1&&indexPath.row==selectedPaid-1) {
            for (UIView* view in cell.contentView.subviews) {
                if ([view isKindOfClass:[RTSpinKitView class]]) {
                    return cell;
                }
            }
            RTSpinKitView *spinKit = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArc color:[UIColor colorWithRed:0.086 green:0.514 blue:0.973 alpha:1.00] spinnerSize:25];
            spinKit.frame = CGRectMake(self.view.frame.size.width-TABLE_VIEW_STANDARD_RIGHT_OFFSET-25, TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-12.5, 25, 25);
            [spinKit startAnimating];
            [cell.contentView addSubview:spinKit];
            return cell;
        }
    }
    
    //Setting price label button
    UIButton *priceLabel = [[UIButton alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    if (adAvailable ? (indexPath.section==2) : (indexPath.section==1)) {
        NSString* defaultPrice = isSalesInProgress?DEFAULT_PRICE_PACK_7S:DEFAULT_PRICE_PACK_7;
        NSString *defProductId = isSalesInProgress?Purchase3750CoinsSalesProductIdentifier:Purchase3750CoinsProductIdentifier;
        switch (indexPath.row) {
            case 0:
                if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES]) {
                    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES];
                    if ([dict objectForKey:Purchase25CoinsProductIdentifier]) {
                        [priceLabel setTitle:(NSString*)[dict objectForKey:Purchase25CoinsProductIdentifier]  forState:UIControlStateNormal];
                        
                    } else {
                        [priceLabel setTitle: DEFAULT_PRICE_PACK_1 forState:UIControlStateNormal];
                    }
                } else {
                    [priceLabel setTitle: DEFAULT_PRICE_PACK_1 forState:UIControlStateNormal];
                }
                break;
            case 1:
                if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES]) {
                    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES];
                    if ([dict objectForKey:Purchase50CoinsProductIdentifier]) {
                        [priceLabel setTitle:(NSString*)[dict objectForKey:Purchase50CoinsProductIdentifier]  forState:UIControlStateNormal];
                    } else {
                        [priceLabel setTitle: DEFAULT_PRICE_PACK_2 forState:UIControlStateNormal];
                    }
                } else {
                    [priceLabel setTitle: DEFAULT_PRICE_PACK_2 forState:UIControlStateNormal];
                }
                break;
            case 2:
                if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES]) {
                    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES];
                    if ([dict objectForKey:Purchase125CoinsProductIdentifier]) {
                        [priceLabel setTitle:(NSString*)[dict objectForKey:Purchase125CoinsProductIdentifier]  forState:UIControlStateNormal];
                    } else {
                        [priceLabel setTitle: DEFAULT_PRICE_PACK_3 forState:UIControlStateNormal];
                    }
                } else {
                    [priceLabel setTitle: DEFAULT_PRICE_PACK_3 forState:UIControlStateNormal];
                }
                break;
            case 3:
                if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES]) {
                    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES];
                    if ([dict objectForKey:Purchase250CoinsProductIdentifier]) {
                        [priceLabel setTitle:(NSString*)[dict objectForKey:Purchase250CoinsProductIdentifier]  forState:UIControlStateNormal];
                    } else {
                        [priceLabel setTitle: DEFAULT_PRICE_PACK_4 forState:UIControlStateNormal];
                    }
                } else {
                    [priceLabel setTitle: DEFAULT_PRICE_PACK_4 forState:UIControlStateNormal];
                }
                break;
            case 4:
                if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES]) {
                    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES];
                    if ([dict objectForKey:Purchase500CoinsProductIdentifier]) {
                        [priceLabel setTitle:(NSString*)[dict objectForKey:Purchase500CoinsProductIdentifier]  forState:UIControlStateNormal];
                    } else {
                        [priceLabel setTitle: DEFAULT_PRICE_PACK_5 forState:UIControlStateNormal];
                    }
                } else {
                    [priceLabel setTitle: DEFAULT_PRICE_PACK_5 forState:UIControlStateNormal];
                }
                break;
            case 5:
                if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES]) {
                    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES];
                    if ([dict objectForKey:Purchase1250CoinsProductIdentifier]) {
                        [priceLabel setTitle:(NSString*)[dict objectForKey:Purchase1250CoinsProductIdentifier]  forState:UIControlStateNormal];
                    } else {
                        [priceLabel setTitle: DEFAULT_PRICE_PACK_6 forState:UIControlStateNormal];
                    }
                } else {
                    [priceLabel setTitle: DEFAULT_PRICE_PACK_6 forState:UIControlStateNormal];
                }
                break;
            case 6:
                if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES]) {
                    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES];
                    if ([dict objectForKey:defProductId]) {
                        [priceLabel setTitle:(NSString*)[dict objectForKey:defProductId]  forState:UIControlStateNormal];
                    } else {
                        [priceLabel setTitle: defaultPrice forState:UIControlStateNormal];
                    }
                } else {
                    [priceLabel setTitle: defaultPrice forState:UIControlStateNormal];
                }
                break;
            default:
                break;
        }
        priceLabel.tag = indexPath.row+1;
    } else if (adAvailable && indexPath.section==1) {
        [priceLabel setTitle: NSLocalizedString(@"БЕСПЛАТНО", nil) forState:UIControlStateNormal];
        priceLabel.tag = 0;
    }
    if (adAvailable && indexPath.section==1) {
        priceLabel.titleLabel.font = [UIFont systemFontOfSize:12 weight:0.2];
    } else {
        priceLabel.titleLabel.font = [UIFont systemFontOfSize:14 weight:0.2];
    }
    UIColor *priceLabelColor = indexPath.row!=goldenPrice?[UIColor colorWithRed:0.086 green:0.514 blue:0.973 alpha:1.00]:[UIColor colorWithRed:0.749 green:0.608 blue:0.231 alpha:1.00];
    [priceLabel setTitleColor: priceLabelColor forState:UIControlStateNormal];
    [priceLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    priceLabel.backgroundColor = [UIColor whiteColor];
    priceLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    [priceLabel sizeToFit];
    frame = priceLabel.frame;
    CGFloat addition = (TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-frame.size.height)/2.0;
    frame.origin.x = self.view.frame.size.width-TABLE_VIEW_STANDARD_RIGHT_OFFSET-20-frame.size.width;
    frame.origin.y = TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-frame.size.height/2.0-addition-7*((indexPath.row==goldenPrice)||indexPath.row==salesHit-1);
    frame.size.height+=2*addition;
    frame.size.width+=20;
    priceLabel.frame = frame;
    priceLabel.layer.borderWidth = 1;
    priceLabel.layer.cornerRadius = 5;
    priceLabel.layer.borderColor = priceLabelColor.CGColor;
    [priceLabel addTarget:self action:@selector(buttonHighlighted:) forControlEvents:UIControlEventTouchDown];
    [priceLabel addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [priceLabel addTarget:self action:@selector(buttonReleased:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchDragExit];

    if (indexPath.row==salesHit-1) {
        UILabel *saleHitLabel = [[UILabel alloc] init];
        saleHitLabel.text = indexPath.row==goldenPrice?NSLocalizedString(@"ЛУЧШЕЕ ПРЕДЛОЖЕНИЕ", nil):NSLocalizedString(@"ХИТ ПРОДАЖ", nil);
        saleHitLabel.font = [UIFont systemFontOfSize:8];
        saleHitLabel.textColor = [UIColor grayColor];
        [saleHitLabel sizeToFit];
        [saleHitLabel setX: [priceLabel getRightBound]-[saleHitLabel getWidth]];
        [saleHitLabel setY: [priceLabel getLowerBound] + (TABLE_VIEW_STANDARD_ROW_HEIGHT-[priceLabel getLowerBound])/2.0-[saleHitLabel getHeight]/2.0];
        [cell.contentView addSubview:saleHitLabel];
    }
    
    if (indexPath.row==goldenPrice) {
        UILabel *saleHitLabel = [[UILabel alloc] init];
        saleHitLabel.text = indexPath.row==goldenPrice?(isSalesInProgress?NSLocalizedString(@"ВРЕМЕННАЯ АКЦИЯ", nil):NSLocalizedString(@"ЛУЧШЕЕ ПРЕДЛОЖЕНИЕ", nil)):NSLocalizedString(@"ХИТ ПРОДАЖ", nil);
        saleHitLabel.font = [UIFont systemFontOfSize:8];
        saleHitLabel.textColor = [UIColor grayColor];
        [saleHitLabel sizeToFit];
        [saleHitLabel setX: [priceLabel getRightBound]-[saleHitLabel getWidth]];
        [saleHitLabel setY: [priceLabel getLowerBound] + (TABLE_VIEW_STANDARD_ROW_HEIGHT-[priceLabel getLowerBound])/2.0-[saleHitLabel getHeight]/2.0];
        [cell.contentView addSubview:saleHitLabel];
    }
    
    if (indexPath.section!=0) {
        [cell.contentView addSubview:priceLabel];
        return  cell;
    }
    
    //Adding balance label
    UIImageView *balanceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Balance"]];
    CGFloat standardSize = 20;
    balanceImageView.frame = CGRectMake(self.view.frame.size.width-TABLE_VIEW_STANDARD_RIGHT_OFFSET-standardSize, TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-standardSize/2.0, standardSize, standardSize);
    [cell.contentView addSubview:balanceImageView];
    UILabel *balance = [[UILabel alloc] initWithFrame:CGRectMake(-999, -999, 999, 999)];
    balance.text = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_BALANCE] intValue]];
    balance.font = [UIFont fontWithName:@"Roboto-Regular" size:16];
    [balance sizeToFit];
    frame = balance.frame;
    frame.origin.x = self.view.frame.size.width-TABLE_VIEW_STANDARD_RIGHT_OFFSET-standardSize-8-frame.size.width;
    frame.origin.y = TABLE_VIEW_STANDARD_ROW_HEIGHT/2.0-frame.size.height/2.0;
    balance.frame = frame;
    [cell.contentView addSubview:balance];
    return cell;
}


- (void) manageSalesHit {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SALES_HIT]) {
        salesHit = [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SALES_HIT] intValue];
        [tableView reloadData];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_REQUEST_SALES_HIT_INFORMATION_PATH];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
        serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.responseSerializer = serializer;
        manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
        [manager GET:baseURLString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject objectForKey:@"response"]) {
                int hit = [responseObject[@"response"] intValue];
                if (hit != salesHit) {
                    salesHit = hit;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [tableView reloadData];
                    });
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            ;
        }];
    });
}

- (void) getSalesInformation {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SALES]) {
        isSalesInProgress = [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SALES] intValue];
        [tableView reloadData];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_REQUEST_SALES_INFORMATION_PATH];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
        serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.responseSerializer = serializer;
        manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
        [manager GET:baseURLString parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject objectForKey:@"response"]) {
                int hit = [responseObject[@"response"] intValue];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:hit] forKey:NSUDEFAULTS_KEY_SALES];
                if (hit != isSalesInProgress) {
                    isSalesInProgress = hit;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [tableView reloadData];
                    });
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            ;
        }];
    });
}

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void) adFinished {
    isSelected = NO;
    isSelectedFree = NO;
    [tableView reloadData];
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (adAvailable && section==1) {
        return NSLocalizedString(@"Получите монеты бесплатно после просмотра короткого видео.", nil);
    }
    if ((adAvailable && section==2) || (!adAvailable && section==1)) {
        return NSLocalizedString(@"Мы рады, когда Вам приятно. Именно поэтому Вы получаете 25% сверх каждой покупки в качестве подарка!", nil);
    }
    return nil;
}

#pragma mark - Pressing buttons

- (void) buttonHighlighted: (UIButton *) sender {
    UIColor *color = sender.tag!=goldenPrice+1?[UIColor colorWithRed:0.086 green:0.514 blue:0.973 alpha:1.00]:[UIColor colorWithRed:0.749 green:0.608 blue:0.231 alpha:1.00];
    sender.backgroundColor = color;
}

- (void) buttonPressed: (UIButton *) sender {
    [self buttonReleased:sender];
    if (isSelected) return;
    isSelected = YES;
    if (sender.tag==0) {
        isSelectedFree = YES;
        [tableView reloadData];
        [self getFreeCoins];
        return;
    }
    
    isSelectedFree = NO;
    selectedPaid = (int)sender.tag;
    [tableView reloadData];
    if([SKPaymentQueue canMakePayments] && !isDeviceJailbroken()){
        NSString *identifier;
        switch (selectedPaid) {
            case 1:
                identifier = Purchase25CoinsProductIdentifier;
                break;
            case 2:
                identifier = Purchase50CoinsProductIdentifier;
                break;
            case 3:
                identifier = Purchase125CoinsProductIdentifier;
                break;
            case 4:
                identifier = Purchase250CoinsProductIdentifier;
                break;
            case 5:
                identifier = Purchase500CoinsProductIdentifier;
                break;
            case 6:
                identifier = Purchase1250CoinsProductIdentifier;
                break;
            case 7:
                identifier = isSalesInProgress?Purchase3750CoinsSalesProductIdentifier:Purchase3750CoinsProductIdentifier;
                break;
            default:
                break;
        }
        [[RMStore defaultStore] addPayment:identifier success:^(SKPaymentTransaction *transaction) {
            [self userPurchasedPack];
            isSelected = NO;
            [tableView reloadData];
        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            int code = (int) error.code;
            isSelected = NO;
            [tableView reloadData];
            switch (code) {
                case 2:
                    [self showErrorWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Пожалуйста, попробуйте снова.", nil) cancelButtonTitle:@"ОК"];
                    break;
                default:
                    [self showErrorWithTitle:NSLocalizedString(@"Недоступно", nil) message:NSLocalizedString(@"К сожалению, данный товар сейчас недоступен. Пожалуйста, проверьте соединение и повторите снова.", nil) cancelButtonTitle:@"ОК"];
            }
        }];
    } else if (isDeviceJailbroken()){
        [Flurry logEvent:@"Jailbreak detected"];
        [self showErrorWithTitle:NSLocalizedString(@"Доступ запрещен", nil) message:NSLocalizedString(@"К сожалению, на вашем устройстве было обнаружено подозрительное ПО. Пожалуйста, убедитесь, что вы используете официальную ОС от Apple и попробуйте снова.", nil) cancelButtonTitle:NSLocalizedString(@"Отменить", nil)];
        isSelected = NO;
        isSelectedFree = NO;
        [tableView reloadData];
    } else {
        [self showErrorWithTitle:NSLocalizedString(@"Родительский контроль", nil) message:NSLocalizedString(@"К сожалению, Вы не можете совершать покупки. Пожалуйста, отключите родительский контроль и попробуйте снова.", nil) cancelButtonTitle:NSLocalizedString(@"Отменить", nil)];
    }
}

- (void) buttonReleased: (UIButton *) sender {
    sender.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Transactions and purchasing

- (void) userPurchasedPack {
    NSString *token = [Utilities generateUniqueString];
    NSString *userID = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"]];
    int amount = [amounts[selectedPaid-1] intValue];
    NSString *amountString = [NSString stringWithFormat:@"%i", amount];
    NSString *key = [NSStringFromClass([NSAttributedString class]) sha256];
    NSString *pass = [[NSString stringWithFormat:@"%@%@%@%@", token, userID, amountString, key] sha512];
    NSDictionary *parameters = @{   @"token":token,
                                    @"user_id":userID,
                                    @"amount":amountString,
                                    @"pass":pass};
    NSString *baseURLString = [NSString stringWithFormat:@"%@/%@", SERVER_URL, SERVER_USER_PURCHASED_MONEY_PACK_PATH];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer = serializer;
    manager.requestSerializer.timeoutInterval = SERVER_TIMEOUT;
    [manager GET:baseURLString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
        if (responseObject[@"response"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[responseObject[@"response"][@"balance"] intValue]] forKey:NSUDEFAULTS_KEY_BALANCE];
            [((AppDelegate*)[[UIApplication sharedApplication] delegate]) updateLeftMenu];
            [tableView reloadData];
        } else {
            [self showErrorWithTitle:NSLocalizedString(@"Ошибка сервера", nil) message: @"Произошла неизвестная ошибка с нашей стороны. Мы начислим Вам монеты в ближайшее время." cancelButtonTitle:@"ОК"];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self showErrorWithTitle:NSLocalizedString(@"Нет соединения", nil) message:NSLocalizedString(@"Пожалуйста, проверьте свое интернет соединение и попробуйте снова", nil) cancelButtonTitle:@"ОК"];
    }];
}

#pragma mark - Navigation and views

- (instancetype) initWithModal: (BOOL) modal {
    self = [super init];
    if (self) {
        isModal = modal;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [tableView reloadData];
    [Flurry logEvent:@"ShopSession" timed:YES];
    [self adFinished];
    NSSet *products = [NSSet setWithArray:@[Purchase25CoinsProductIdentifier, Purchase50CoinsProductIdentifier, Purchase125CoinsProductIdentifier, Purchase250CoinsProductIdentifier, Purchase500CoinsProductIdentifier, Purchase1250CoinsProductIdentifier, Purchase3750CoinsProductIdentifier, Purchase3750CoinsSalesProductIdentifier]];
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        for (SKProduct* product in products) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES]) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_PRICES]];
                [dict setValue:[self localizedPriceFromProduct:product] forKey:product.productIdentifier];
                [[NSUserDefaults standardUserDefaults] setObject:dict forKey:NSUDEFAULTS_KEY_SHOP_PRICES];
            } else {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setValue:[self localizedPriceFromProduct:product] forKey:product.productIdentifier];
                [[NSUserDefaults standardUserDefaults] setObject:dict forKey:NSUDEFAULTS_KEY_SHOP_PRICES];
            }
        }
        [tableView reloadData];
    } failure:^(NSError *error) {
        [self showErrorWithTitle:@"Магазин недоступен" message:@"In-App Store недоступен в данный момент. Пожалуйста, проверьте свое Интернет-соединение и попробуйте снова." cancelButtonTitle:@"ОК"];
    }];
    [self manageSalesHit];
    [self getSalesInformation];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [welcome hideView];
    [Flurry endTimedEvent:@"ShopSession" withParameters:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!isModal && ![[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_SHOP_WELCOME_SHOWN]) {
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showWelcome) userInfo:nil repeats:NO];
    }
    [tableView reloadData];
    [self updateAdAvailability];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    isSalesInProgress = NO;
    
    adAvailable = AD_AVAILABLE;
    amounts = [NSMutableArray arrayWithArray: @[@25, @50, @125, @250, @500, @1250, @3750]];
    
    identifiers = @[Purchase25CoinsProductIdentifier,
                    Purchase50CoinsProductIdentifier,
                    Purchase125CoinsProductIdentifier,
                    Purchase250CoinsProductIdentifier,
                    Purchase500CoinsProductIdentifier,
                    Purchase1250CoinsProductIdentifier,
                    Purchase3750CoinsProductIdentifier,
                    Purchase3750CoinsSalesProductIdentifier
                    ];
    
    if (isModal) {
        self.navigationItem.title = NSLocalizedString(@"Купить монеты", nil);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelShopping)];
    } else {
        self.navigationItem.title = NSLocalizedString(@"Магазин", nil);
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, 0, 30, 30);
        [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    }
    self.view.backgroundColor = [UIColor colorWithWhite:BACKGROUND_WHITE_COMPONENT alpha:1];
    
    //Setting table view
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, -self.tabBarController.tabBar.frame.size.height, 0);
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellReuseIdentifier"];
    tableView.backgroundColor = [UIColor colorWithWhite:BACKGROUND_WHITE_COMPONENT alpha:1];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.delaysContentTouches = NO;
    [self.view addSubview:tableView];
}

- (NSString*) localizedPriceFromProduct: (SKProduct*) product {
    int price = [product.price intValue];
    NSLocale *priceLocale = product.priceLocale;
    
    NSNumberFormatter* formatter= [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setLocale:priceLocale];
    
    NSString *code = formatter.currencyCode;
    
    // For Belarussian, Latvian, Russian and Tajikistani ruble
    if ([code isEqualToString:@"RUB"] ||
        [code isEqualToString:@"RUR"] ||
        [code isEqualToString:@"BYB"] ||
        [code isEqualToString:@"BYR"] ||
        [code isEqualToString:@"LVR"] ||
        [code isEqualToString:@"TJR"])
        return [NSString stringWithFormat:@"%d р.", price];
    
    // For Ukrainian Hryvnia
    if ([code isEqualToString:@"UAH"])
        return [NSString stringWithFormat:@"%d грн.", price];
    
    return [formatter stringFromNumber:@(price)];
}

- (void) showMenu {
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

- (void) cancelShopping {
    [_delegate cancel];
}

#pragma mark - Ads

- (void) showAd {
    VungleSDK *sdk = [VungleSDK sharedSDK];
    NSError *e;
    NSString *userID = [NSString stringWithFormat:@"%i", [[[NSUserDefaults standardUserDefaults] objectForKey:NSUDEFAULTS_KEY_USER_INFO][@"id"] intValue]];
    [sdk playAd:self withOptions:@{VunglePlayAdOptionKeyIncentivized:@YES,
                                   VunglePlayAdOptionKeyUser:userID
                                   } error:&e];
}

- (void) getFreeCoins {
    if (AD_AVAILABLE && adAvailable) {
        [self showAd];
    }
}

- (void) updateAdAvailability {
    UITableViewRowAnimation animationType = UITableViewRowAnimationFade;
    if (AD_AVAILABLE && !adAvailable) {
        adAvailable = YES;
        [tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:animationType];
    } else if (!AD_AVAILABLE && adAvailable){
        adAvailable = NO;
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:animationType];
    }
}

#pragma mark - Error handling

- (void) showErrorWithTitle: (NSString *) title message: (NSString *) message cancelButtonTitle: (NSString *) buttonTitle {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(title, nil) message:NSLocalizedString(message, nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* button = [UIAlertAction actionWithTitle:NSLocalizedString(buttonTitle, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
    [alert addAction:button];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Showing welcome alert

- (void) showWelcome {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:1] forKey:NSUDEFAULTS_KEY_SHOP_WELCOME_SHOWN];
    welcome = [[SCLAlertView alloc] init];
    [welcome setTitleFontFamily:@"AvenirNext-Medium" withSize:18];
    [welcome setBodyTextFontFamily:@"AvenirNext-Regular" withSize:13];
    [welcome setShouldDismissOnTapOutside:YES];
    [welcome showCustom:self image:[UIImage imageNamed:@"ShopImage"] color:[UIColor colorWithRed:0.133 green:0.525 blue:0.957 alpha:1.00] title:NSLocalizedString(TEXT_SHOP_WELCOME_TITLE, nil) subTitle:NSLocalizedString(TEXT_SHOP_WELCOME_TEXT, nil) closeButtonTitle:@"ОК" duration:15.0];
}

@end
