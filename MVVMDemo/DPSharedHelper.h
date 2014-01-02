//
//  DPSharedHelper.h
//  MVVMDemo
//
//  Created by Eric D. Baker on 02/01/14.
//  Copyright (c) 2014 DuneParkSoftware, LLC. All rights reserved.
//

@import Foundation;

/*
 A singleton object with a bindable property.
 There may be situations where a singleton's property may have any number of
 subscribers, but since the singleton is a long-lived object, the subscribers
 must dispose of their subscriptions themselves.
 */
@interface DPSharedHelper : NSObject

@property (readonly) NSNumber *number;

+ (instancetype)sharedHelper;

- (void)reset;

@end
