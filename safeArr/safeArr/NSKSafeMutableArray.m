//
//  NSKSafeMutableArray.m
//  safeArr
//
//  Created by cheyipai.com on 17/1/9.
//  Copyright © 2017年 kong. All rights reserved.
//


#import "NSKSafeMutableArray.h"


@interface NSKSafeMutableArray()
{
    CFMutableArrayRef _array;
}
@end

@implementation NSKSafeMutableArray

- (id)init
{
    return [self initWithCapacity:10];
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    if (self)
    {
        _array = CFArrayCreateMutable(kCFAllocatorDefault, numItems,  &kCFTypeArrayCallBacks);
    }
    return self;
}
- (NSUInteger)count {
    
    __block NSUInteger result;
    dispatch_sync(self.syncQueue, ^{
        result = CFArrayGetCount(_array);
    });
    return result;
}

- (id)objectAtIndex:(NSUInteger)index {
    
    __block id result;
    dispatch_sync(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(_array);
        result = index<count ? CFArrayGetValueAtIndex(_array, index) : nil;
    });
    
    return result;
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    __block NSUInteger blockindex = index;
    dispatch_barrier_async(self.syncQueue, ^{
        
        if (!anObject)
            return;
        
        NSUInteger count = CFArrayGetCount(_array);
        if (blockindex > count) {
            blockindex = count;
        }
        CFArrayInsertValueAtIndex(_array, index, (__bridge const void *)anObject);
        
    });
    
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    
    dispatch_barrier_async(self.syncQueue, ^{
        
        NSUInteger count = CFArrayGetCount(_array);
        NSLog(@"count:%lu,index:%lu",(unsigned long)count,(unsigned long)index);
        if (index < count) {
            CFArrayRemoveValueAtIndex(_array, index);
        }
    });
}

- (void)addObject:(id)anObject
{
    dispatch_barrier_async(self.syncQueue, ^{
        
        if (!anObject)
            return;
        
        CFArrayAppendValue(_array, (__bridge const void *)anObject);
        
    });
}

- (void)removeLastObject {
    dispatch_barrier_async(self.syncQueue, ^{
        
        NSUInteger count = CFArrayGetCount(_array);
        if (count > 0) {
            CFArrayRemoveValueAtIndex(_array, count-1);
        }
        
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    
    
    dispatch_barrier_async(self.syncQueue, ^{
        
        if (!anObject)
            return;
        
        NSUInteger count = CFArrayGetCount(_array);
        CFArraySetValueAtIndex(_array, index, (__bridge const void*)anObject);
    });
}

#pragma mark Optional

- (void)removeAllObjects
{
    
    dispatch_barrier_async(self.syncQueue, ^{
        CFArrayRemoveAllValues(_array);
    });
}

- (NSUInteger)indexOfObject:(id)anObject{
    
    if (!anObject)
        return NSNotFound;
    
    __block NSUInteger result;
    dispatch_sync(self.syncQueue, ^{
        NSUInteger count = CFArrayGetCount(_array);
        result = CFArrayGetFirstIndexOfValue(_array, CFRangeMake(0, count), (__bridge const void *)(anObject));
    });
    return result;
    
    
    return result;
}
#pragma mark - Private
- (dispatch_queue_t)syncQueue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.kong.NSKSafeMutableArray", DISPATCH_QUEUE_CONCURRENT);
    });
     return queue;
    
}
@end
