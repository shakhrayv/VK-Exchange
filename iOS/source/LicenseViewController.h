//
//  LicenseViewController.h
//  VK Likes
//
//  Created by Vlad on 16/02/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CloseLicenseProtocol <NSObject>

- (void) close: (id) controller;

@end

@interface LicenseViewController : UIViewController <UITextViewDelegate> {
    UITextView *textView;
}

@property id <CloseLicenseProtocol> delegate;

@end
