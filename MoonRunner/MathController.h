//
//  MathController.h
//  MoonRunner
//
//  Created by cbz on 7/29/15.
//  Copyright (c) 2015 zgpeace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathController : NSObject

+ (NSString *)stringifyDistance:(float)meters;
+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;
+ (NSString *)stringifyAvyPaceFromDist:(float)meters overTime:(int)seconds;

+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations;

@end
