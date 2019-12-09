//
//  Utilities.m
//  VK Likes
//
//  Created by Vlad on 15/02/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSString *) generateUniqueString {
    return [[NSUUID UUID] UUIDString];
}

@end
