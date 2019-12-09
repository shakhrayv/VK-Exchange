//
//  Protocols.h
//  VK Likes
//
//  Created by Vlad on 31/01/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#ifndef Protocols_h
#define Protocols_h

@protocol CancelProtocol <NSObject>

@required
- (void) cancel;

@end

@protocol ShopProtocol <NSObject>

@required
- (void) finished: (UIViewController *) controller;

@end

#endif /* Protocols_h */
