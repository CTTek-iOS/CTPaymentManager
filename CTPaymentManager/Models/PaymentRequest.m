//
//  PaymentRequest.m
//  ksbk
//
//  Created by 胡昆1 on 8/18/15.
//  Copyright (c) 2015 cn.chutong. All rights reserved.
//

#import "PaymentRequest.h"
#import "PaymentConfig.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PaymentRequest

@synthesize wxPayParames = _wxPayParames,aliPayParames = _aliPayParames;

- (WxPayParams*)wxPayParames
{
    if (!_wxPayParames ) {
        
        _wxPayParames = [[WxPayParams alloc] init];
        
    }

    return _wxPayParames;
}


- (AliPayParames*)aliPayParames
{
    if (!_aliPayParames ) {
        
        _aliPayParames = [[AliPayParames alloc] init];
        
    }
    
    return _aliPayParames;
}


@end

@implementation AliPayParames


@end


@implementation WxPayParams

@synthesize appId = _appId,package = _package, noncestr = _noncestr, timestamp = _timestamp, sign = _sign, partnerid = _partnerid;


- (NSString*)appId
{
    
    if (!_appId) {
        
        _appId = WX_APP_ID;
    }
    
    
    return _appId;

}

- (NSString*)partnerid
{
    if (!_partnerid) {
        
        _partnerid = WX_MCH_ID;
    }
    
    
    return _partnerid;

}

- (NSString*)package
{
    return @"Sign=WXPay";
}

- (NSString*)noncestr
{
    NSLog(@"获取noncestr");
    
    if (!_noncestr) {
        
        NSInteger nonce = arc4random()%1000000000000;
        
        _noncestr = [NSString stringWithFormat:@"%ld",(long)nonce];
        
    }
    
    return _noncestr;

}

- (NSString*)timestamp
{
    if (!_timestamp) {
        
        _timestamp = [NSString stringWithFormat:@"%ld",time(NULL)];
        
    }
    
    return _timestamp;

}

- (NSString*)sign
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.appId,@"appid",self.partnerid,@"partnerid",self.prepayid,@"prepayid",self.package,@"package",
                         
                         self.noncestr,@"noncestr",self.timestamp,@"timestamp",nil];

    
    NSString* tempStr = [self translateDicIntoSignString:dic];
    
    return [self md5:tempStr].uppercaseString;
    
}

- (NSString*)translateDicIntoSignString:(NSDictionary*)dic
{
    NSArray* array           = [dic allKeys];
    NSArray* paramSortAarray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return  [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSString* stringForSign = [[NSString alloc] init];
    for (int i = 0; i < [array count] ; i++) {
       
        NSString* tempKey       = [paramSortAarray objectAtIndex:i];
        NSString* tempContent   = [dic objectForKey:tempKey];
       
        if ((((NSString*)tempContent).length == 0) ||
            (id)tempContent == [NSNull null] ) {
            
            continue;
        }
        
        if ( i == [array count] - 1) {
            
            NSString* appendString = [NSString stringWithFormat:@"%@=%@",tempKey,tempContent];
            stringForSign = [stringForSign stringByAppendingString:appendString];
            
        }else{
            
            NSString* appendString = [NSString stringWithFormat:@"%@=%@&",tempKey,tempContent];
            stringForSign = [stringForSign stringByAppendingString:appendString];
            
        }
        
    }
    
    
    stringForSign = [stringForSign stringByAppendingString:[NSString stringWithFormat:@"&key=%@",WX_API_KEY]];
    
    NSLog(@"stringForSign = %@",stringForSign);
    
    return stringForSign;
}


- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
