//
//  VKScrollView.m
//  VK Likes
//
//  Created by Vlad on 27/02/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import "VKScrollView.h"

@implementation VKScrollView

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (self.tracking) {
        CGFloat diff = contentInset.top - self.contentInset.top;
        CGPoint translation = [self.panGestureRecognizer translationInView:self];
        translation.y -= diff * 3.0 / 2.0;
        [self.panGestureRecognizer setTranslation:translation inView:self];
    }
    [super setContentInset:contentInset];
}

@end
