//
//  DPViewModel.m
//  MVVMDemo
//
//  Created by Eric D. Baker on 02/01/14.
//  Copyright (c) 2014 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPViewModel.h"
#import "DPSharedHelper.h"

@interface DPViewModel ()
@property (strong, nonatomic) NSString *string;
@end

@implementation DPViewModel

-(instancetype)init {
    self = [super init];
    if (!self) return nil;

    NSLog(@"viewmodel init -> %p", self);

    @weakify(self);
    [[self.didBecomeActiveSignal logAll] subscribeNext:^(id x) {
        // NOTE -> capturing 'x' in this block will lead to a retain cycle,
        //         preventing this viewModel from being released.
        //         Use weak 'self' instead.
        @strongify(self);

        // Bind to the shared instance so long as this view model is active.
        RAC(self, string) = [[RACObserve(DPSharedHelper.sharedHelper, number)
                              takeUntil:self.didBecomeInactiveSignal]
                             map:^id(id value) {
                                 return [value stringValue];
                             }];
    }];

    [[self.didBecomeInactiveSignal logAll] subscribeNext:^(id x){
        // Just for logging purposes.
    }];

    return self;
}

-(void)dealloc {
    // Make sure we get dealloc'd so that we don't leak!
    NSLog(@"viewmodel dealloc -> %p", self);
}

@end
