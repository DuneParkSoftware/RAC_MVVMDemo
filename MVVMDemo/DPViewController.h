//
//  DPViewController.h
//  MVVMDemo
//
//  Created by Eric D. Baker on 02/01/14.
//  Copyright (c) 2014 DuneParkSoftware, LLC. All rights reserved.
//

@import UIKit;

@class DPViewModel;

@interface DPViewController : UIViewController
@property (readonly) DPViewModel *viewModel;
@end
