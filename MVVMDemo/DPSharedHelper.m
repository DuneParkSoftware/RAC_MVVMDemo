//
//  DPSharedHelper.m
//  MVVMDemo
//
//  Created by Eric D. Baker on 02/01/14.
//  Copyright (c) 2014 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPSharedHelper.h"

@interface DPSharedHelper ()
@property (strong, nonatomic) NSNumber *number;
@end

@implementation DPSharedHelper

+ (instancetype)sharedHelper {
    static DPSharedHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DPSharedHelper new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    _number = @0;
    [self bump];

    return self;
}

- (void)reset {
    [self setNumber:@0];
}

/*
 Represents a background task that other observers may be interested in.
 */
- (void)bump {
    [self setNumber:@([self.number integerValue] + 1)];

    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);

        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {

            // NOTE -> We are switching to the main queue here. However, if we
            // stayed on the background queue here, RAC observers could still
            // be triggered so long as they include
            // deliverOn:[RACScheduler mainScheduler]
            dispatch_async(dispatch_get_main_queue(), ^{
                [self bump];
            });
        });
    });
}

@end
