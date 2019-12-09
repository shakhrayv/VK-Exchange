//
//  ModalShopNavigationViewController.m
//  VK Likes
//
//  Created by Vlad on 28/01/16.
//  Copyright © 2016 Vlad Shakhray. All rights reserved.
//

#import "ModalShopNavigationViewController.h"

@interface ModalShopNavigationViewController ()

@end

@implementation ModalShopNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) finished {
    [_shopDelegate finished:self];
}

- (void) cancel {
    [self finished];
}

@end
