//
//  KSOrder.h
//  ksbk
//
//  Created by 胡昆1 on 8/18/15.
//  Copyright (c) 2015 cn.chutong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PayChannel) {
    AliPayWay = 1,
    YinLianPayWay,
  WxPayWay
};

@interface KSOrder : NSObject

+ (KSOrder*)initWithConsultOrderId:(NSString*)consultId;

@property (nonatomic, strong) NSString* consultId;

@end
