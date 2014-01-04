//
//  DPViewModel.h
//  MVVMDemo
//
//  Created by Eric D. Baker on 02/Jan/14.
//  Copyright (c) 2014 DuneParkSoftware, LLC. All rights reserved.
//

#import "RVMViewModel.h"

@class DPSharedHelper;

@interface DPViewModel : RVMViewModel
@property (readonly, nonatomic) NSString *string;
@property (readonly, nonatomic) RACCommand *resetCommand;

- (instancetype)initWithHelper:(DPSharedHelper *)helper;

@end
