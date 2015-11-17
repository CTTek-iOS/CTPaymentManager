//
//  PaymentConfig.h
//  ksbk
//
//  Created by 胡昆1 on 8/18/15.
//  Copyright (c) 2015 cn.chutong. All rights reserved.
//

#ifndef ksbk_PaymentConfig_h
#define ksbk_PaymentConfig_h


#define WX_APP_ID @"wxd452f233a534c52f"
#define WX_MCH_ID @"1246858001"
#define WX_API_KEY @"c3c54402cb9492812dc56c1bf242afb6"


//银联
#define KBtn_width        200
#define KBtn_height       80
#define KXOffSet          (self.view.frame.size.width - KBtn_width) / 2
#define KYOffSet          80
#define kCellHeight_Normal  50
#define kCellHeight_Manual  145

#define kVCTitle          @"商户测试"
#define kBtnFirstTitle    @"获取订单，开始测试"
#define kWaiting          @"正在获取TN,请稍后..."
#define kNote             @"提示"
#define kConfirm          @"确定"
#define kErrorNet         @"网络错误"
#define kResult           @"支付结果：%@"


#define kMode_Development             @"01"
#define kMode_Distrubute             @"00"
#define kURL_TN_Normal                @"http://202.101.25.178:8080/sim/gettn"
#define kURL_TN_Configure             @"http://202.101.25.178:8080/sim/app.jsp?user=123456789"

#endif
