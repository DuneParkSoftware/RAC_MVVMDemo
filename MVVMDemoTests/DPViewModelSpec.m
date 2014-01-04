//
//  DPViewModelSpec.m
//  MVVMDemo
//
//  Created by Eric D. Baker on 03/Jan/14.
//  Copyright (c) 2014 DuneParkSoftware, LLC. All rights reserved.
//

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "OCMock.h"

#import "DPViewModel.h"
#import "DPSharedHelper.h"

//BOOL(^blk)(DPViewModel *) = ^BOOL(DPViewModel *viewModel) {
//    return NO;
//};

SpecBegin(DPViewModel)

describe(@"DPViewModel", ^{
    __block NSNumber *(^blkTestResetCommandEnabledWithHelperNumber)(NSNumber *);

    beforeAll(^{
        blkTestResetCommandEnabledWithHelperNumber = ^NSNumber *(NSNumber *number) {
            id mockHelper = [OCMockObject mockForClass:[DPSharedHelper class]];
            [[[mockHelper expect] andReturn:[RACSignal return:number]] rac_valuesForKeyPath:@"number" observer:[OCMArg any]];

            DPViewModel *viewModel = [[DPViewModel alloc] initWithHelper:mockHelper];

            __block NSNumber *enabled = nil;
            [[[[viewModel resetCommand] enabled] take:1] subscribeNext:^(id x) {
                enabled = [x copy];
            }];

            [mockHelper verify];
            return enabled;
        };
    });

    it(@"should not enable the reset command when the helper number is < 5", ^{
        __block NSNumber *enabled;
        expect(^{
            enabled = blkTestResetCommandEnabledWithHelperNumber(@4);
        }).toNot.raise(NSInternalInconsistencyException);

        expect(enabled).will.beFalsy();
    });

    it(@"should enable the reset command when the helper number is >= 5", ^{
        __block NSNumber *enabled;
        expect(^{
            enabled = blkTestResetCommandEnabledWithHelperNumber(@5);
        }).toNot.raise(NSInternalInconsistencyException);

        expect(enabled).will.beTruthy();
    });

    xit(@"should successfully reset the helper's number when the number is > 10");

    xit(@"should error when resetting the helper's number when the number is <= 10");
});

SpecEnd
