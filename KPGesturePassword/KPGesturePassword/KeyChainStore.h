//
//  KeyChainStore.h
//  GeXiaZi
//
//  Created by Coyote on 16/10/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainStore : NSObject


/**
 *  将数据存储到钥匙串
 *  service : 字段名
 *  data : 存储内容
 */
+ (void)save:(NSString *)service data:(id)data;

/**
 *  从钥匙串中读取数据
 *  service : 字段名
 */
+ (id)load:(NSString *)service;

/**
 *  删除钥匙串中的数据
 *  service : 字段名
 */
+ (void)deleteKeyData:(NSString *)service;

@end
