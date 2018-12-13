# HPCache 手机缓存模型
一个简单的线程安全且高吞吐量的模型，用于存储简单数据，支持model存储，无需转换。

## 思路
* 创业一个自定义的`DISPATCH_QUEUE_CONCURRENT`队列。
* 将`dispatch_sync`（或`dispatch_async`）用于不修改状态的操作。
* 将`dispatch_barrier_sync`（或`dispatch_barrier_async`）用于可能修改状态的操作。

## 注意
这里的属性被标记为`nonatomic`，因为这里有自定义的代码使用了自定义的队列和屏障来管理线程安全。

## 代码
```javascript

//HPCache.h
#import <Foundation/Foundation.h>


@interface HPCache : NSObject

+ (HPCache *)sharedInstance;

- (id)objectForKey:(nonnull id<NSCopying>)key;
- (void)setObject:(id)object forKey:(nonnull id<NSCopying>)Key;
- (void)removeObjectForKey:(nonnull id<NSCopying>)Key;

@end

```

```javascript

//HPCache.m
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


```

