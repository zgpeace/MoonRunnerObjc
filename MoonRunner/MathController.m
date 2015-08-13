//
//  MathController.m
//  MoonRunner
//
//  Created by cbz on 7/29/15.
//  Copyright (c) 2015 zgpeace. All rights reserved.
//

#import "MathController.h"
#import "Location.h"
#import "MulticolorPolylineSegment.h"

static bool const isMetric = YES;
static float const metersInKM = 1000;
static float const metersInMile = 1609.344;

@implementation MathController

+ (NSString *)stringifyDistance:(float)meters
{
    float unitDivider;
    NSString *unitName;
    
    // metric
    if (isMetric) {
        unitName = @"km";
        // to get from meters to kilometers divide by this
        unitDivider = metersInKM;
    }
    // U.S.
    else
    {
        unitName = @"mi";
        // to get from meters to miles divide by this
        unitDivider = metersInMile;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", (meters / unitDivider), unitName];
}

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat
{
    int remainingSeconds = seconds;
    int hours = remainingSeconds / 3600;
    remainingSeconds = remainingSeconds - hours * 3600;
    int minutes = remainingSeconds / 60;
    remainingSeconds = remainingSeconds - minutes * 60;
    
    if (longFormat) {
        if(hours > 0) {
            return [NSString stringWithFormat:@"%ihr %imin %isec", hours, minutes, remainingSeconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%imin %isec", minutes, remainingSeconds];
        } else {
            return [NSString stringWithFormat:@"%isec", remainingSeconds];
        }

    } else {
        if(hours > 0) {
            return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, remainingSeconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%02i:%02i", minutes, remainingSeconds];
        } else {
            return [NSString stringWithFormat:@"00:%02i", remainingSeconds];
        }
    }
    
}

+ (NSString *)stringifyAvyPaceFromDist:(float)meters overTime:(int)seconds
{
    if (seconds == 0 || meters == 0) {
        return @"0";
    }
    
    float avgPaceSecMeters = seconds / meters;
    
    float unitMultiplier;
    NSString *unitName;
    
    // metric
    if (isMetric) {
        unitName = @"min/km";
        unitMultiplier = metersInKM;
        // U.S.
    } else {
        unitName = @"min/mi";
        unitMultiplier = metersInMile;
    }
    
    int paceMin = (int) ((avgPaceSecMeters * unitMultiplier) / 60);
    int paceSec = (int) (avgPaceSecMeters * unitMultiplier - (paceMin*60));
    
    return [NSString stringWithFormat:@"%i:%02i %@", paceMin, paceSec, unitName];
    
}

+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations
{
    // make array of all apeeds, find slowest+fastest
    NSMutableArray *speeds = [NSMutableArray array];
    double slowestSpeed = DBL_MAX;
    double fastestSpeed = 0.0;
    
    for (int i = 1; i < locations.count; i++) {
        Location *firstLoc = [locations objectAtIndex:(i-1)];
        Location *secondeLoc = [locations objectAtIndex:i];
        
        CLLocation *firstLocCL = [[CLLocation alloc] initWithLatitude:firstLoc.latitude.doubleValue longitude:firstLoc.longitude.doubleValue];
        CLLocation *secondLocCL = [[CLLocation alloc] initWithLatitude:secondeLoc.latitude.doubleValue longitude:secondeLoc.longitude.doubleValue];
        
        double distance = [secondLocCL distanceFromLocation:firstLocCL];
        double time = [secondeLoc.timestamp timeIntervalSinceDate:firstLoc.timestamp];
        double speed = distance/time;
        
        slowestSpeed = speed < slowestSpeed ? speed : slowestSpeed;
        fastestSpeed = speed > fastestSpeed ? speed : fastestSpeed;
        
        [speeds addObject:@(speed)];
        
    }
    
    // now knowing the slowest+fastest, we can get mean too
    double meanSpeed = (slowestSpeed + fastestSpeed) / 2;
    
    // RGB for red (slowest)
    CGFloat r_red = 1.0f;
    CGFloat r_green = 20/255.0f;
    CGFloat r_blue = 44/255.0f;
    
    // RGB for yellow (middle)
    CGFloat y_red = 1.0f;
    CGFloat y_green = 215/255.0f;
    CGFloat y_blue = 0.0f;
    
    // RGB for green (fastest)
    CGFloat g_red = 0.0f;
    CGFloat g_green = 146/255.0f;
    CGFloat g_blue = 78/255.0f;
    
    NSMutableArray *colorSegments = [NSMutableArray array];
    
    for (int i = 1;  i < locations.count; i++) {
        Location *firstLoc = [locations objectAtIndex:(i -1)];
        Location *secondLoc = [locations objectAtIndex:i];
        
        CLLocationCoordinate2D coords[2];
        coords[0].latitude = firstLoc.latitude.doubleValue;
        coords[0].longitude = firstLoc.longitude.doubleValue;
        
        coords[1].latitude = secondLoc.latitude.doubleValue;
        coords[1].longitude = secondLoc.longitude.doubleValue;
        
        NSNumber *speed = [speeds objectAtIndex:(i-1)];
        UIColor *color = nil;
        
        // between red and yellow
        if (speed.doubleValue < meanSpeed) {
            double retio = (speed.doubleValue - slowestSpeed) / (meanSpeed - slowestSpeed);
            CGFloat red = r_red + retio * (y_red - r_red);
            CGFloat green = r_green + retio * (y_green - r_green);
            CGFloat blue = r_blue + retio * (y_blue - r_blue);
            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
            
            // between yellow and green
        } else {
            double retio = (speed.doubleValue - meanSpeed) / (fastestSpeed - meanSpeed);
            CGFloat red = y_red + retio * (g_red - y_red);
            CGFloat green = y_green + retio * (g_green - y_green);
            CGFloat blue = y_blue + retio * (g_blue - y_blue);
            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
        }
        
        MulticolorPolylineSegment *segment = [MulticolorPolylineSegment polylineWithCoordinates:coords count:2];
        segment.color = color;
        
        [colorSegments addObject:segment];
        
    }
    
    
    return  colorSegments;
}

@end

































