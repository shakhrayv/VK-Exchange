//
//  UIView+Additions.h
//
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>

#define width(x) [x getWidth]
#define height(x) [x getHeight]
#define x(x) [x getOriginX]
#define y(x) [x getOriginY]
#define rightBound(x) [x getRightBound]
#define lowerBound(x) [x getLowerBound]
#define origin(x) [x getOrigin]

@interface UIView (Additions)

- (void) setWidth: (CGFloat) width;
- (void) setHeight: (CGFloat) height;
- (void) setSize: (CGSize) size;
- (void) setOrigin: (CGPoint) origin;
- (void) setX: (CGFloat) x;
- (void) setY: (CGFloat) y;

- (CGFloat) getLowerBound;
- (CGFloat) getRightBound;

- (CGFloat) getWidth;
- (CGFloat) getHeight;
- (CGFloat) getOriginX;
- (CGFloat) getOriginY;
- (CGPoint) getOrigin;

@end
