//
//  UITableViewDelegateForwarder.h
//  MVVMKit
//
//  Created by Евгений Губин on 14.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

// Can not do this in Swift code, because it causes a crash. It seems, messages are worwarded incorrectly.

@interface UITableViewDelegateForwarder : NSObject<UITableViewDelegate>

@property (assign, nonatomic) id<UITableViewDelegate> delegate;

@end
