//
//  ViewController.m
//  CTPaymentManagerDemo
//
//  Created by 胡昆1 on 11/16/15.
//  Copyright © 2015 cn.chutong. All rights reserved.
//

#import "ViewController.h"
#import "PaySelectCtrl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goPaymentPage:(UIButton*)btn
{
    PaySelectCtrl* vc = [[PaySelectCtrl alloc] initWithNibName:@"PaySelectCtrl" bundle:nil];

    [self.navigationController  pushViewController:vc animated:YES];

}

@end
