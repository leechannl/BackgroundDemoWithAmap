//
//  ViewController.m
//  BackgroundDemoWithAmap
//
//  Created by mm on 2/2/15.
//  Copyright (c) 2015 Pirate. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CocoaLumberjack/DDLog.h"
#import "ViewController.h"
#import "CCAPIHelper.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface ViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView = [MKMapView new];
    self.mapView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.mapView.showsUserLocation = YES;
    self.mapView.rotateEnabled = NO;
//    self.mapView.delegate = self;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];

    [self.view addSubview:self.mapView];

}

- (void)addAnnotationToMapWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.coordinate = coordinate;
    [self.mapView addAnnotation:anno];
}

#pragma mark - Map viev delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    DDLogInfo(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        NSString *username = @"13971125425";
        NSString *password = @"888888";
    //    NSString *username = @"13006197380";
    //    NSString *password = @"qqqqqq";
//        NSString *username = @"18627005213";
//        NSString *password = @"123456";
//    NSString *username = @"15972206047";
//    NSString *password = @"123456";

    [self updateLocationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude username:username password:password];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    DDLogInfo(@"Locate user failed, error: %@", error);
}

- (void)updateLocationWithLatitude:(double)latitude longitude:(double)longitude username:(NSString *)username password:(NSString *)password
{

    if ([[CCAPIHelper sharedInstance] isCCTokenValid]) {
        [[CCAPIHelper sharedInstance] uploadUserLocationWithLatitude:latitude longitude:longitude address:nil success:^(id x) {
            DDLogInfo(@"upload location successfully.");
        } failed:^(id x) {
            DDLogError(@"upload location failed.");
        }];
    } else {
        [[CCAPIHelper sharedInstance] loginWithUsername:username password:password success:^(id x) {
            DDLogInfo(@"Login successfully.");
            [[CCAPIHelper sharedInstance] uploadUserLocationWithLatitude:latitude longitude:longitude address:nil success:^(id x) {
                DDLogInfo(@"upload location successfully.");
            } failed:^(id x) {
                DDLogError(@"upload location failed.");
            }];
        } failed:^(id x) {
            DDLogError(@"Login failed.");
        }];
    }
}



@end
