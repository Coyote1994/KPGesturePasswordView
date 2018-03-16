//
//  MDFiveEncryption.h
//  KPGesturePassword
//
//  Created by 刘鲲鹏 on 2018/3/15.
//  Copyright © 2018年 刘鲲鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDFiveEncryption : NSObject

//md5加密方法
+ (NSString *)md5EncryptWithString:(NSString *)string;

@end
