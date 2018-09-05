//
//  UIView+Additions.m
//  VK Likes
//
//  Created by Vlad on 19/02/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (void) setWidth: (CGFloat) width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void) setHeight: (CGFloat) height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void) setSize: (CGSize) size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void) setOrigin: (CGPoint) origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void) setX:(CGFloat) x {
    CGPoint origin = self.frame.origin;
    origin.x = x;
    [self setOrigin:origin];
}

- (void) setY:(CGFloat) y {
    CGPoint origin = self.frame.origin;
    origin.y = y;
    [self setOrigin:origin];
}

- (CGFloat) getLowerBound { return self.frame.origin.y+self.frame.size.height; }
- (CGFloat) getRightBound { return self.frame.origin.x+self.frame.size.width; }

- (CGFloat) getWidth { return self.frame.size.width; }
- (CGFloat) getHeight { return self.frame.size.height; }
- (CGFloat) getOriginX { return self.frame.origin.x; }
- (CGFloat) getOriginY { return self.frame.origin.y; }
- (CGPoint) getOrigin { return self.frame.origin; }

@end
