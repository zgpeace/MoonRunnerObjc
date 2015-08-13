//
//  BadgeEarnStatus.h
//  MoonRunner
//
//  Created by cbz on 8/12/15.
//  Copyright (c) 2015 zgpeace. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Badge;
@class Run;

@interface BadgeEarnStatus : NSObject

@property (strong, nonatomic) Badge *badge;
@property (strong, nonatomic) Run *earnRun;
@property (strong, nonatomic) Run *silverRun;
@property (strong, nonatomic) Run *goldRun;
@property (strong, nonatomic) Run *bestRun;

@end
