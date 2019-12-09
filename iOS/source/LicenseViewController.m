//
//  LicenseViewController.m
//  VK Likes
//
//  Created by Vlad on 16/02/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import "LicenseViewController.h"

@implementation LicenseViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Terms of Service";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSString *txtFilePath = [[NSBundle mainBundle] pathForResource:@"license" ofType:@"txt"];
    NSString *txtFileContents = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:NULL];
    NSArray *strings = [txtFileContents componentsSeparatedByString:@"\n"];
    NSMutableAttributedString *final = [[NSMutableAttributedString alloc] initWithString:txtFileContents];
    textView = [[UITextView alloc] initWithFrame:CGRectMake(2, 64, self.view.frame.size.width-2, self.view.frame.size.height-64)];
    textView.editable = NO;
    textView.delegate = self;
    for (size_t i = 0; i < strings.count; i++) {
        NSString *string = strings[i];
        if ([string isEqualToString:@""]) continue;
        UIFont *font;
        size_t index = [txtFileContents rangeOfString:string].location;
        if (i == 1) {
            font = [UIFont boldSystemFontOfSize:32];
        }
        if (i == 3) {
            font = [UIFont systemFontOfSize:15];
        }
        if ([[string substringToIndex:1] isEqualToString:@"•"]) {
            font = [UIFont systemFontOfSize:17];
        }
        if (!font) {
            font = [UIFont boldSystemFontOfSize :17];
        }
        if (font) {
            [final addAttribute:NSFontAttributeName value:font range:NSMakeRange(index, string.length)];
        }
    }
    textView.attributedText = final;
    [self.view addSubview:textView];
}

- (void)viewDidLayoutSubviews {
    [textView setContentOffset:CGPointZero animated:NO];
}

- (void) close {
    [self.delegate close:self];
}

@end
