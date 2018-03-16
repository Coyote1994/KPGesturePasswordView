//
//  KPGesturePasswordView.h
//  KPGesturePassword
//
//  Created by 刘鲲鹏 on 2018/3/15.
//  Copyright © 2018年 刘鲲鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPGesturePasswordView : UIView

/** 正常颜色 */
@property (nonatomic, strong) UIColor *normalColor;

/** 选中颜色 */
@property (nonatomic, strong) UIColor *selectedColor;

/** 密码错误显示颜色 */
@property (nonatomic, strong) UIColor *errorColor;

/** 第一次手势完成回调 */
@property (nonatomic, copy) void (^firstGestureFinished)(void);

/**
 *  第二次手势完成（设置密码成功）回调
 *
 *  isRight  : 是否正确
 *  password : md5后的密码
 */
@property (nonatomic, copy) void (^setPassword)(BOOL isRight, NSString *password);

/** 验证密码允许输入错误最大次数 */
@property (nonatomic, assign) int allowErrorNumber;

/**
 *  验证密码回调
 *
 *  isRight :   是否正确
 *  number  :   剩余次数
 */
@property (nonatomic, copy) void (^verifyPassword)(BOOL isRight, int number);


/** 重设手势密码 */
- (void)reSetGesturePassword;

@end
