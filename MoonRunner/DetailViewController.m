//
//  DetailViewController.m
//  MoonRunner
//
//  Created by cbz on 7/29/15.
//  Copyright (c) 2015 zgpeace. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "Location.h"
#import "MathController.h"
#import "Run.h"
#import "MulticolorPolylineSegment.h"
#import "Badge.h"
#import "BadgeController.h"
#import "BadgeAnnotation.h"

@interface DetailViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *badgeImageView;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setRun:(Run *)run
{
    if (_run != run) {
        _run = run;
        [self configureView];
    }
}

- (void)configureView {

    self.distanceLabel.text = [MathController stringifyDistance:self.run.distance.floatValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:self.run.timestamp];
    
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@", [MathController stringifySecondCount:self.run.duration.intValue usingLongFormat:YES]];
    
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@", [MathController stringifyAvyPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.intValue]];
    
    [self loadMap];
    
    Badge *badge = [[BadgeController defaultController] bestBadgeForDistance:self.run.distance.floatValue];
    self.badgeImageView.image = [UIImage imageNamed:badge.imageName];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (IBAction)displayModeToggled:(UISwitch *)sender
{
    self.badgeImageView.hidden = !sender.isOn;
    self.infoButton.hidden = !sender.isOn;
    self.mapView.hidden = sender.isOn;
}

- (IBAction)infoButtonPressed
{
    Badge *badge = [[BadgeController defaultController] bestBadgeForDistance:self.run.distance.floatValue];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:badge.name message:badge.information delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKCoordinateRegion)mapRegion
{
    MKCoordinateRegion region;
    Location *initialLoc = self.run.locations.firstObject;
    
    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;
    
    for (Location *location in self.run.locations) {
        if (location.latitude.floatValue < minLat) {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng) {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat) {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng) {
            maxLng = location.longitude.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * 1.1f; // 10% padding
    region.span.longitudeDelta = (maxLng - minLng) * 1.1f; // 10% padding
    
    
    return  region;
    
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
//    if ([overlay isKindOfClass:[MKPolyline class]]) {
//        MKPolyline *polyLine = (MKPolyline *)overlay;
//        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
//        aRenderer.strokeColor = [UIColor blackColor];
//        aRenderer.lineWidth = 3;
//        return aRenderer;
//    }
    
    if ([overlay isKindOfClass:[MulticolorPolylineSegment class]]) {
        MulticolorPolylineSegment *polyLine = (MulticolorPolylineSegment *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = polyLine.color;
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    
    return nil;
}

- (MKPolyline *)polyLine {
    
    CLLocationCoordinate2D coords[self.run.locations.count];
    
    for (int i = 0; i < self.run.locations.count; i++) {
        Location *location = [self.run.locations objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
    }
    
    return [MKPolyline polylineWithCoordinates:coords count:self.run.locations.count];
    
    
}

- (void)loadMap
{
    if (self.run.locations.count > 0) {
        self.mapView.hidden = NO;
        
        // set the map bounds
        [self.mapView setRegion:[self mapRegion]];
        
        // make the line(s !) on the map
//        [self.mapView addOverlay:[self polyLine]];
        NSArray *colorSegmentArray = [MathController colorSegmentsForLocations:self.run.locations.array];
        [self.mapView addOverlays:colorSegmentArray];
        [self.mapView addAnnotations:[[BadgeController defaultController] annotationsForRun:self.run]];
    } else {
        // no locations were found!
        self.mapView.hidden = YES;
        
        UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"Error" message:@"Sorry, this run has no locations saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    BadgeAnnotation *badgeAnnotation = (BadgeAnnotation *)annotation;
    
    MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"checkpoint"];
    if (!annView) {
        annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"checkpoint"];
        annView.image = [UIImage imageNamed:@"mapPin"];
        annView.canShowCallout = YES;
    }
    
    UIImageView *badgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 50)];
    badgeImageView.image = [UIImage imageNamed:badgeAnnotation.imageName];
    badgeImageView.contentMode = UIViewContentModeScaleAspectFit;
    annView.leftCalloutAccessoryView = badgeImageView;
    
    return annView;
}




































@end
