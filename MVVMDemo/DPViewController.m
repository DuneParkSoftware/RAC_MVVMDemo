//
//  DPViewController.m
//  MVVMDemo
//
//  Created by Eric D. Baker on 02/01/14.
//  Copyright (c) 2014 DuneParkSoftware, LLC. All rights reserved.
//

#import "DPViewController.h"
#import "DPViewModel.h"

@interface DPViewController ()

/*
 The viewModel can either be a property that gets instantiated in code, or in
 Interface Builder.
 */

//@property (strong, nonatomic) DPViewModel *viewModel;
@property (strong, nonatomic) IBOutlet DPViewModel *viewModel;
@end

@implementation DPViewController

#pragma mark - View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
//    self.viewModel = [DPViewModel new];

    UILabel *label = (UILabel *)[self.view viewWithTag:1];
    if (label) {
        RAC(label, text) = RACObserve(self.viewModel, string);
    }
}

/*
 The view controller dictates the "active" state of the view model.
 */

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.viewModel.active = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.active = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewModel.active = NO;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.viewModel.active = NO;
}

-(void)dealloc {
    NSLog(@"view controller dealloc");
}

@end
