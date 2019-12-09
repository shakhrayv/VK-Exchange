//
//  ModalShopNavigationViewController.h
//  VK Likes
//
//  Created by Vlad on 28/01/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopViewController.h"
#import "Protocols.h"

@class ShopViewController;

@interface ModalShopNavigationViewController : UINavigationController <CancelProtocol>

@property id <ShopProtocol> shopDelegate;

@end
