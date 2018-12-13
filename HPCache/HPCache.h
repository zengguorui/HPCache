//
//  HPCache.h
//  HPCache
//
//  Created by 曾国锐 on 2018/12/12.
//  Copyright © 2018年 曾国锐. All rights reserved.
//  线程安全的手机缓存模型

#import <Foundation/Foundation.h>


@interface HPCache : NSObject

+ (HPCache *)sharedInstance;

- (id)objectForKey:(nonnull id<NSCopying>)key;
- (void)setObject:(id)object forKey:(nonnull id<NSCopying>)Key;
- (void)removeObjectForKey:(nonnull id<NSCopying>)Key;

@end

