//
//  DPViewModel.m
//  MVVMDemo
//
//  Created by Eric D. Baker on 02/Jan/14.
//  Copyright (c) 2014 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPViewModel.h"
#import "DPSharedHelper.h"

@interface DPViewModel ()
// This is a "weak" pointer because it points to a singleton.
@property (weak, nonatomic) DPSharedHelper *helper;
@property (strong, nonatomic) NSString *string;
@property (strong, nonatomic) RACCommand *resetCommand;
@end

@implementation DPViewModel

- (instancetype)init {
    // By default, use the DPSharedHelper singleton.
    self = [self initWithHelper:[DPSharedHelper sharedHelper]];
    return self;
}

- (instancetype)initWithHelper:(DPSharedHelper *)helper {
    self = [super init];
    if (!self) return nil;

    _helper = helper;

    NSLog(@"viewmodel init -> %p", self);

    @weakify(self);
    [[self.didBecomeActiveSignal logAll] subscribeNext:^(id x) {
        // NOTE -> capturing 'x' in this block will lead to a retain cycle,
        //         preventing this viewModel from being released.
        //         Use weak 'self' instead.
        @strongify(self);

        // Bind to the shared instance so long as this view model is active.
        RAC(self, string) = [[RACObserve(self.helper, number)
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
    return [RACObserve(self.helper, number) map:^id(id value) {
        return @([value integerValue] >= 5);
    }];
}

- (RACCommand *)resetCommand {
    if (!_resetCommand) {
        @weakify(self);
        _resetCommand = [[RACCommand alloc] initWithEnabled:[self canResetSignal] signalBlock:^RACSignal *(id input) {
            @strongify(self);

            RACSignal *executionSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> commandSubscriber) {
                // Command execution has begun.
                [commandSubscriber sendNext:nil];

                // Simulate an error if the helper number is <= 10.
                if ([self.helper.number integerValue] <= 10) {
                    [commandSubscriber sendError:[NSError errorWithDomain:@"DPViewModel error domain"
                                                                     code:1
                                                                 userInfo:@{ NSLocalizedDescriptionKey : @"Error in resetCommand. DPSharedHelper number is <= 10" }]];
                } else {
                    // Send the current number to the command subscriber, then
                    // perform the reset and complete the command.
                    [commandSubscriber sendNext:[self.helper number]];

                    [self.helper reset];
                    [commandSubscriber sendCompleted];
                }

                return nil;
            }];
            return executionSignal;
        }];
    }
    return _resetCommand;
}

- (void)dealloc {
    // Make sure we get dealloc'd so that we don't leak!
    NSLog(@"viewmodel dealloc -> %p", self);
}

@end
