//
//  PaySelectCtrl.h
//  ksbk
//
//  Created by 胡昆1 on 8/17/15.
//  Copyright (c) 2015 cn.chutong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSOrder.h"
#import "PaymentRequest.h"

typedef void (^PaySucceedHandle)();
typedef void (^PayFailtureHandle)();

@interface PaySelectCtrl : UIViewController

@property (nonatomic, strong) KSOrder* order;
@property (nonatomic, strong) PaymentRequest* paymentRequest;

@property (nonatomic, strong) PaySucceedHandle  paySucceedHandle;
@property (nonatomic, strong) PayFailtureHandle payFailtureHandle;

@property BOOL isVipPay;

@property (nonatomic, strong) NSMutableDictionary *membershipDict;

@end
