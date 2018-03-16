//
//  MDFiveEncryption.m
//  KPGesturePassword
//
//  Created by 刘鲲鹏 on 2018/3/15.
//  Copyright © 2018年 刘鲲鹏. All rights reserved.
//

#import "MDFiveEncryption.h"
#import <CommonCrypto/CommonDigest.h>

//秘钥
static NSString *encryptionKey = @"kjashflkjh2358fdg$%^WE#SDDFD][sdf";



@implementation MDFiveEncryption



+ (NSString *)md5EncryptWithString:(NSString *)string{
    return [self md5:[NSString stringWithFormat:@"%@%@", encryptionKey, string]];
}

+ (NSString *)md5:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

@end


