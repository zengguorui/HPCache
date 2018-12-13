//
//  HPCache.m
//  HPCache
//
//  Created by 曾国锐 on 2018/12/12.
//  Copyright © 2018年 曾国锐. All rights reserved.
//

#import "HPCache.h"

@interface HPCache()

@property (nonatomic, readonly) NSMutableDictionary *cacheObjects;
@property (nonatomic, readonly) dispatch_queue_t queue;

@end

@implementation HPCache

const char *_Nullable kCacheQueueName = "kCacheQueueName";

- (instancetype)init{
    if (self = [super init]) {
        _cacheObjects = [NSMutableDictionary dictionary];
        _queue = dispatch_queue_create(kCacheQueueName, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+ (HPCache *)sharedInstance{
    static HPCache *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HPCache alloc] init];
    });
    return instance;
}

- (id)objectForKey:(id<NSCopying>)key{
    __block id rv = nil;
    
    dispatch_sync(self.queue, ^{
        rv = [self.cacheObjects objectForKey:key];
    });
    
    return rv;
}

- (void)setObject:(id)object forKey:(id<NSCopying>)Key{
    dispatch_barrier_sync(self.queue, ^{
        [self.cacheObjects setObject:object forKey:Key];
    });
}

- (void)removeObjectForKey:(nonnull id<NSCopying>)Key{
    dispatch_barrier_sync(self.queue, ^{
        [self.cacheObjects removeObjectForKey:Key];
    });
}

@end
