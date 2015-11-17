//
//  KSOrder.m
//  ksbk
//
//  Created by 胡昆1 on 8/18/15.
//  Copyright (c) 2015 cn.chutong. All rights reserved.
//

#import "KSOrder.h"

@implementation KSOrder

+ (KSOrder*)initWithConsultOrderId:(NSString*)consultId
{

    KSOrder* instance = [[KSOrder alloc] init];
    
    instance.consultId = consultId;
    
    return instance;
}


@end
