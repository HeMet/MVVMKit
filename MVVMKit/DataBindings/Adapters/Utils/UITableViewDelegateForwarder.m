//
//  UITableViewDelegateForwarder.m
//  MVVMKit
//
//  Created by Евгений Губин on 14.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

#import "UITableViewDelegateForwarder.h"

@implementation UITableViewDelegateForwarder

-(instancetype) init {
    if (self = [super init]) {
        self.selectorsToIgnore = [NSArray new];
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSString* selector = NSStringFromSelector(aSelector);
    if ([self.selectorsToIgnore containsObject:selector]) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.delegate respondsToSelector:aSelector]) {
        return self.delegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end
