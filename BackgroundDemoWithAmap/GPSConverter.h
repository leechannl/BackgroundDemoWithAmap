//
//  GPSConverter.h
//  BackgroundDemoWithAmap
//
//  Created by mm on 2/6/15.
//  Copyright (c) 2015 Pirate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GPSConverter : NSObject

+ (CLLocationCoordinate2D )convertToMarsUseAlgorithmWithCoordinate:(CLLocationCoordinate2D )coordinate;

+ (CLLocationCoordinate2D )convertToMarsUseDBWithCoordinate:(CLLocationCoordinate2D )coordinate;

@end
