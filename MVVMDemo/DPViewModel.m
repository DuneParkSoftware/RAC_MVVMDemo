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
@property (strong, nonatomic) RACCommand *resetCommand;
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

- (RACSignal *)canResetSignal {
    // We cannot reset the number until it is > 5.
    return [RACObserve(DPSharedHelper.sharedHelper, number) map:^id(id value) {
        return @([value integerValue] >= 5);
    }];
}

- (RACCommand *)resetCommand {
    if (!_resetCommand) {
        _resetCommand = [[RACCommand alloc] initWithEnabled:[self canResetSignal] signalBlock:^RACSignal *(id input) {

            RACSignal *executionSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> commandSubscriber) {
                // Command execution has begun.
                [commandSubscriber sendNext:nil];

                // Simulate an error if the shared helper number is <= 10.
                if ([DPSharedHelper.sharedHelper.number integerValue] <= 10) {
                    [commandSubscriber sendError:[NSError errorWithDomain:@"DPViewModel error domain"
                                                                     code:1
                                                                 userInfo:@{ NSLocalizedDescriptionKey : @"Error in resetCommand. DPSharedHelper number is <= 10" }]];
                } else {
                    // Send the current number to the command subscriber, then
                    // perform the reset and complete the command.
                    [commandSubscriber sendNext:[DPSharedHelper.sharedHelper number]];

                    [DPSharedHelper.sharedHelper reset];
                    [commandSubscriber sendCompleted];
                }

                return nil;
            }];
            return executionSignal;
        }];
    }
    return _resetCommand;
}

-(void)dealloc {
    // Make sure we get dealloc'd so that we don't leak!
    NSLog(@"viewmodel dealloc -> %p", self);
}

@end
