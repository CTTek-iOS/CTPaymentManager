//
//  AppDelegate.h
//  CTPaymentManagerDemo
//
//  Created by 胡昆1 on 11/16/15.
//  Copyright © 2015 cn.chutong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaySelectCtrl.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak,nonatomic) PaySelectCtrl* payCtrl;

@end

