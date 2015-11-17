//
//  PaymentRequest.h
//  ksbk
//
//  Created by 胡昆1 on 8/18/15.
//  Copyright (c) 2015 cn.chutong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@class AliPayParames;
@class WxPayParams;

@interface PaymentRequest : NSObject

@property (nonatomic, strong) AliPayParames* aliPayParames;
@property (nonatomic, strong) WxPayParams*   wxPayParames;


@end



@interface AliPayParames : NSObject

@property (nonatomic, strong) Order* order;

@end


@interface WxPayParams : NSObject

@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* partnerid;
@property (nonatomic, strong) NSString* prepayid;
@property (nonatomic, strong) NSString* package;
@property (nonatomic, strong) NSString* noncestr;
@property (nonatomic, strong) NSString* timestamp;
@property (nonatomic, strong) NSString* sign;

@end