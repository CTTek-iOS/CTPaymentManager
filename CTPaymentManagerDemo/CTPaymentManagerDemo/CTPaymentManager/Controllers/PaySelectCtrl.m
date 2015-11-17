//
//  PaySelectCtrl.m
//  ksbk
//
//  Created by 胡昆1 on 8/17/15.
//  Copyright (c) 2015 cn.chutong. All rights reserved.
//

#import "PaySelectCtrl.h"
#import "WxPayCell.h"
#import "AliPayCell.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "PaymentConfig.h"

//银联头文件
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "UPPayPlugin.h"

//阿里支付
#import "DataSigner.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>

#import "AppDelegate.h"

#define kPaymentSucceedNotification @"kPaymentSucceedNotification"
#define kPaymentFailtureNotification @"kPaymentFailtureNotification"



@interface PaySelectCtrl ()<UPPayPluginDelegate, UIAlertViewDelegate>
{
    UIAlertView* _alertView;
    NSMutableData* _responseData;

}

@property (nonatomic, strong) NSDictionary* dicOrderResult;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

//银联专用
@property(nonatomic, copy)NSString *tnMode;

@end

@implementation PaySelectCtrl

@synthesize paymentRequest = _paymentRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"支付订单";
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.payCtrl  = self;
    
    UIView *view         = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySucceed)  name:kPaymentFailtureNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payFailture) name:kPaymentSucceedNotification  object:nil];
}


- (PaymentRequest*)paymentRequest
{
    if (!_paymentRequest) {
        
        _paymentRequest = [[PaymentRequest alloc] init];
        _paymentRequest.wxPayParames = [[WxPayParams alloc] init];
        _paymentRequest.aliPayParames = [[AliPayParames alloc] init];
        
    }
    
    return _paymentRequest;
}

- (void)paySucceed
{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"支付成功");
                
            });
        });
}

- (void)payFailture
{

    if (self.payFailtureHandle) {
        
        self.payFailtureHandle();
        
    }

}


-(void)onResp:(BaseResp*)resp{
    
    if ([resp isKindOfClass:[PayResp class]]){
        
        PayResp*response=(PayResp*)resp;
        
        switch(response.errCode){
                
            case WXSuccess:
                
                NSLog(@"支付成功");
                
                [self paySucceed];
                
                break;
                
            default:
                
                NSLog(@"支付失败，retcode=%d",resp.errCode);

                [self payFailture];
                
                break;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellId1 = @"AliPayCell";
    NSString* cellId2 = @"WxPayCell";
    NSString* cellId3 = @"UPPayCell";
    
    if (indexPath.row == 0) {
        
        AliPayCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId1];
        
        if (!cell) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:cellId1 owner:self options:nil] objectAtIndex:0];
            
        }
        
        return cell;
        
    }else if(indexPath.row == 1){
        
        WxPayCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId2];
        
        if (!cell) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:cellId2 owner:self options:nil] objectAtIndex:0];
        }

        return cell;
        
    }else if(indexPath.row == 2){
        
        WxPayCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId2];
        
        if (!cell) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:cellId3 owner:self options:nil] objectAtIndex:0];
        }
        
        return cell;
    }
    
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        
        [self payAliAction];
        
    }else if(indexPath.row == 1){
        
        [self StartWxPayment];
        
    }else if (indexPath.row == 2){
    
        self.tnMode = kMode_Distrubute;

        [self YinlianPayProgress];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)YinlianPayProgress
{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableDictionary* dic = nil;
    
        NSLog(@"银联=  %@",dic);
        
       NSString* tn = [dic[@"payment"] objectForKey:@"trade_no"];//[@"prepay_id"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
     
            [UPPayPlugin startPay:tn mode:self.tnMode viewController:self delegate:self];
            
        });
    });
    


}

- (void)startNetWithURL:(NSURL *)url
{

    [self showAlertWait];
    
    NSURLRequest * urlRequest=[NSURLRequest requestWithURL:url];
    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConn start];
}

#pragma mark - Alert

- (void)showAlertWait
{
    [self hideAlert];
    _alertView = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [_alertView show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(_alertView.frame.size.width / 2.0f - 15, _alertView.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [_alertView addSubview:aiv];

}


- (void)showAlertMessage:(NSString*)msg
{
    [self hideAlert];
    _alertView = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:self cancelButtonTitle:kConfirm otherButtonTitles:nil, nil];
    [_alertView show];

}
- (void)hideAlert
{
    if (_alertView != nil)
    {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
        _alertView = nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _alertView = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 阿里支付

//============================================================
// 支付宝贝流程实现
// 更新时间：2015年8月18日
// 负责人：HUKUN
//============================================================
- (void)payAliAction
{

        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"123456",@"test", nil];
    
        [self requestForAliPayOrderWithParam:param];
  
    
}

- (void)requestForAliPayOrderWithParam:(NSMutableDictionary *)param
{

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary* dic = nil;

        dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"123456",@"test", nil];
 
        
        NSLog(@"psc返回结果 =======> app_notify_url = %@",dic);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if (dic) {
                
                [self payActionWithResultDic:dic[@"payment"] AndResultDic:dic];
                
            }
            
        });
    });
}

- (void)payActionWithResultDic:(NSDictionary*)dic AndResultDic:(NSDictionary*)dicResult
{
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088612117404563";
    NSString *seller = @"info@kswiki.com";
    NSString *privateKey = @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAJoDAQHVkOxP0sscLyWTL8IlOKWMq75+lvIXmJTGZJ3NsoMV2lNMX7vklOazvlPrZN7BZHkHkYIzjwxNWE1u+QS+i6vCslzmnRMoO/hFiZ7fHPkyifklXfmb/efhc2p06w3nzwtoVceASInTh6iHibGMaCjifpKlV6sl17lvoT79AgMBAAECgYB1v7ozZs8ofVcShvfc6I1pCAApQkXEnRBXA4dap9whcjT7V+fWK9w90WOuhtoLWzuBu6ZPimPLghPqOfA7M48ay9gv7HMhVt9dWVIgf0DmmtNeCEEu0S5ex9x82d2t36PRbcAtBVTBQK4OJKSQ3V1sAxylZS6TZ1CgcSTksyHdgQJBAMiWSwPjRlWE6c0VHyb/J0F1zAtS3zdCHrDDoK+54D3wNIvrkIvG9p+YwL3MUETnQIXxKBBuAfz9imBLDhQoQ1ECQQDEjtvH9Y0RnfWWInnBNa0cN64CIwwkypGHkmr3ghi2hDqo/4kZJL8hnhVHiubzErars8ThdCPIJCK0QNRk3t3tAkAG4WDhWUJoXI7Ighj3dXkbPbcqDEWr15DF72/rlyyh80NaKVJj+Qcsoki6Oe/m7SfBcGw3ZA6dZvUAKJLrDhaBAkAn+q61YzqIRMq4+NYu+E33mVOpV5uWuCUVoDBlm26PYSHVUfR+yrydh9voK1aCRmIlVnFLMiY9BSyR4UXSJoqZAkAhBxGmwYu4dI1sbMbkFeFShNNLpFUoic1xo5kFQLlWCNkcRue9zxQQp2jQTbLjSnibclptWxxk/53+ZuSUVZE6";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    
    //将商品信息赋予AlixPayOrder的成员变量
    self.paymentRequest.aliPayParames.order = [[Order alloc] init];
    self.paymentRequest.aliPayParames.order.partner = partner;
    self.paymentRequest.aliPayParames.order.seller = seller;
    
    self.paymentRequest.aliPayParames.order.tradeNO = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
    self.paymentRequest.aliPayParames.order.productName = [dic objectForKey:@"product_title"];
    self.paymentRequest.aliPayParames.order.productDescription = [dic objectForKey:@"product_content"];
    self.paymentRequest.aliPayParames.order.amount = [NSString stringWithFormat:@"%@", [dic objectForKey:@"total_fee"]];
    self.paymentRequest.aliPayParames.order.notifyURL =  dicResult[@"app_notify_url"]; //[dic objectForKey:@"biz_notify_url"];
    
    NSLog(@"app_notify_url = %@",self.paymentRequest.aliPayParames.order.notifyURL);
    
    self.paymentRequest.aliPayParames.order.service = @"mobile.securitypay.pay";
    self.paymentRequest.aliPayParames.order.paymentType = @"1";
    self.paymentRequest.aliPayParames.order.inputCharset = @"utf-8";
    self.paymentRequest.aliPayParames.order.itBPay = @"30m";
    self.paymentRequest.aliPayParames.order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"ksbk";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [self.paymentRequest.aliPayParames.order description];
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);

    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            NSString *resultStatus =  [resultDic objectForKey:@"resultStatus"];
            
            if (resultStatus.integerValue == 9000) {
                
                //处理成功的回调
                NSLog(@"支付成功");

                [self paySucceed];
                
            }
            else {
                
                //处理失败的回调
                NSLog(@"支付失败");
                
                [self payFailture];
            }
            
        }];
        
    }
    
    
}


#pragma mark - 微信支付

//============================================================
// V3&V4支付流程实现
// 注意:参数配置请查看 https://pay.weixin.qq.com/wiki/doc/api/app.php?chapter=9_12&index=2
// 更新时间：2015年8月18日
// 负责人：HUKUN
//============================================================
- (void)StartWxPayment
{


        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)WxPayWay], @"payment_channel", self.order.consultId, @"counsel_order_id",nil];
        [self requestForWXPayOrderWithParam:param];
    
    
}

- (void)requestForWXPayOrderWithParam:(NSMutableDictionary *)param
{

    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableDictionary* dic = nil;

        dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"123456",@"test", nil];
    
        self.paymentRequest.wxPayParames.prepayid = [dic[@"payment"] objectForKey:@"prepay_id"];//[@"prepay_id"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self payWexin];
            
        });
    });
}

- (void)payWexin
{
    PayReq* req             = [[PayReq alloc] init];

    //test数据
    self.paymentRequest.wxPayParames.timestamp = @"1439974597";
    self.paymentRequest.wxPayParames.prepayid = @"wx20150819164931377b75bdb00179201367";
    self.paymentRequest.wxPayParames.noncestr = @"9f655cc8884fda7ad6d8a6fb15cc001e";
    
    req.openID              = self.paymentRequest.wxPayParames.appId;
    req.partnerId           = self.paymentRequest.wxPayParames.partnerid;
    req.prepayId            = self.paymentRequest.wxPayParames.prepayid;
    req.nonceStr            = self.paymentRequest.wxPayParames.noncestr;
    req.timeStamp           = self.paymentRequest.wxPayParames.timestamp.integerValue;
    req.package             = self.paymentRequest.wxPayParames.package;
    
    req.sign                = self.paymentRequest.wxPayParames.sign;
    
    NSLog(@"%@ ---- %@", self.paymentRequest.wxPayParames.package,self.paymentRequest.wxPayParames.sign);
    
    
    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
    [WXApi sendReq:req];
}



#pragma mark UPPayPluginResult
- (void)UPPayPluginResult:(NSString *)result
{
    NSString* msg = [NSString stringWithFormat:kResult, result];
    
    NSLog(@"msg = %@",msg);
//    [self showAlertMessage:msg];
    if ([result isEqualToString:@"success"]) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
    
                    [self paySucceed];
                
            });
        
    }else if([result isEqualToString:@"fail"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
    
        });
        
    }else if ([result isEqualToString:@"cancel"]){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
        
            
        });
        
        
    
    }
}


#pragma mark - connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    NSHTTPURLResponse* rsp = (NSHTTPURLResponse*)response;
    NSInteger code = [rsp statusCode];
    if (code != 200)
    {
        
    }
    else
    {

        [self paySucceed];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self hideAlert];
    NSString* tn = [[NSMutableString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    if (tn != nil && tn.length > 0)
    {
        NSLog(@"tn=%@",tn);
        [UPPayPlugin startPay:tn mode:self.tnMode viewController:self delegate:self];
    }

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self showAlertMessage:kErrorNet];
}


@end
