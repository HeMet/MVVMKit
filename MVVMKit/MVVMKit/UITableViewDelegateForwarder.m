//
//  UITableViewDelegateForwarder.m
//  MVVMKit
//
//  Created by Евгений Губин on 14.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

#import "UITableViewDelegateForwarder.h"

@implementation UITableViewDelegateForwarder

- (BOOL)respondsToSelector:(SEL)aSelector {
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
