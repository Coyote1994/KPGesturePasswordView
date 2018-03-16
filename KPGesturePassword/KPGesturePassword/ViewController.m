//
//  ViewController.m
//  KPGesturePassword
//
//  Created by 刘鲲鹏 on 2018/3/14.
//  Copyright © 2018年 刘鲲鹏. All rights reserved.
//

#import "ViewController.h"
#import "KPGesturePasswordView.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    /** 手势密码 */
    
    KPGesturePasswordView *passView = [[KPGesturePasswordView alloc]initWithFrame:CGRectMake(50, self.view.frame.size.height-self.view.frame.size.width-60, self.view.frame.size.width - 100, self.view.frame.size.width - 100)];
    [self.view addSubview:passView];
    passView.normalColor = [UIColor lightGrayColor];
    passView.selectedColor = [UIColor grayColor];
    passView.errorColor = [UIColor redColor];
    
    [passView setFirstGestureFinished:^{
        /** 提示请再次确认密码 */
        NSLog(@"请再次确认密码");
    }];
    
    [passView setSetPassword:^(BOOL isRight, NSString *password) {
        if (isRight) {
            /** password 上传服务器 */
            NSLog(@"恭喜您密码设置成功");
        }else {
            /** 重新设置密码 */
            NSLog(@"两次手势密码不一致，请重新设置密码");
        }
    }];
    
    passView.allowErrorNumber = 3;
    
    [passView setVerifyPassword:^(BOOL isRight, int number) {
        if (isRight) {
            NSLog(@"本地密码验证成功");
            /** 服务器端验证密码 */
        }else {
            NSLog(@"%@", [NSString stringWithFormat:@"本地密码验证失败,你还有 %d 次输入机会",number]);
            if (number == 0) { // 达到设定的次数
                
            }
        }
    }];
    
    [passView reSetGesturePassword];
    
    /** TouchID密码 */
    [self checkoutTouchID];
    
}

- (void)checkoutTouchID
{
    // 创建LAContext
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    
    // 提示验证指纹的原因
    NSString *reason = @"请验证已有指纹";
    
    // 指纹输入失败之后的弹出框的选项
    context.localizedFallbackTitle = @"输入密码解锁";
    
    // 首先使用 canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        // 支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError *error) {
            if (success) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // 验证成功，主线程处理UI
                }];
            }
            else
            {
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        // 系统取消授权，如其他APP切入
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        // 用户取消验证Touch ID
                        break;
                    }
                    case LAErrorAuthenticationFailed:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            // 验证失败(三次验证都没有通过)
                        }];
                        
                        break;
                    }
                    case LAErrorPasscodeNotSet:
                    {
                        // 系统未设置密码
                        break;
                    }
                    case LAErrorTouchIDNotAvailable:
                    {
                        // 设备Touch ID不可用，例如未打开
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled:
                    {
                        // 设备Touch ID不可用，用户未录入
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            // 用户选择输入密码，切换主线程处理
                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            // 其他情况，切换主线程处理
                        }];
                        break;
                    }
                }
            }
        }];
    }
    else
    {
        // 不支持指纹识别，LOG出错误详情
        NSLog(@"不支持指纹识别");
        
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
            {
                NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorPasscodeNotSet:
            {
                NSLog(@"A passcode has not been set");
                break;
            }
            default:
            {
                NSLog(@"TouchID not available");
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
}



@end
