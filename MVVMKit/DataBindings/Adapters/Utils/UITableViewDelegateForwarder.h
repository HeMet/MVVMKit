//
//  UITableViewDelegateForwarder.h
//  MVVMKit
//
//  Created by Евгений Губин on 14.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

#import <UIKit/UIKit.h>

// Can not do this in Swift code, because it causes a crash. It seems, messages are worwarded incorrectly.

@interface UITableViewDelegateForwarder : NSObject<UITableViewDelegate>

@property (nonatomic, assign) id<UITableViewDelegate> __nullable delegate;
@property (nonatomic, strong) NSArray* __nonnull selectorsToIgnore;

@end
