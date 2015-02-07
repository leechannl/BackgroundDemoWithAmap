//
//  AppDelegate.m
//  BackgroundDemoWithAmap
//
//  Created by mm on 2/2/15.
//  Copyright (c) 2015 Pirate. All rights reserved.
//

#import "AppDelegate.h"
#import <MAMapKit/MAMapKit.h>
#import "CocoaLumberjack/DDLog.h"
#import "loggerFormatter.h"
#import "LocationShareModel.h"
#import "CCAPIHelper.h"
#import "GPSConverter.h"
#import "ViewController.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong,nonatomic) LocationShareModel * shareModel;
@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;

@property (nonatomic, strong) ViewController *vc;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [MAMapServices sharedServices].apiKey = @"b90f98c91402b008a7bc5a3a69266757";

    [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:DDLogLevelVerbose];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelVerbose];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    loggerFormatter *formatter = [[loggerFormatter alloc] init];
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:1.000 green:0.118 blue:0.114 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagError];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:1.000 green:0.514 blue:0.000 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagWarning];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.482 green:0.482 blue:0.506 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.278 green:0.729 blue:0.984 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.000 green:0.353 blue:1.000 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagVerbose];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [fileLogger setLogFormatter:formatter];
    [DDLog addLogger:fileLogger withLevel:DDLogLevelVerbose];

    // Get app document directory
    [self applicationDocumentsDirectory];

    self.shareModel = [LocationShareModel sharedModel];
    self.shareModel.afterResume = NO;

    [self addApplicationStatusToPList:@"didFinishLaunchingWithOptions"];

    UIAlertView * alert;

    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){

        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];

    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){

        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];

    } else{

        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates

        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.

        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            NSLog(@"UIApplicationLaunchOptionsLocationKey");

            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;

            self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
            self.shareModel.anotherLocationManager.delegate = self;
            self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;

            if(IS_OS_8_OR_LATER) {
                [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
            }

            [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];

            [self addResumeLocationToPList];
        }
    }

    return YES;
}

#pragma mark - Core location delegate


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    DDLogInfo(@"locationManager didUpdateLocations: %@",locations);

    for (CLLocation *location in locations) {
//        NSDate *eventDate = location.timestamp;
//        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

        // Only use the recent data
//        if (abs(howRecent) < 10) {
        if (true){
            DDLogInfo(@"Get raw location from Core Location, latitude: %+.6f, longitude: %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
            NSString *username = @"13971125425";
            NSString *password = @"888888";
            //    NSString *username = @"13006197380";
            //    NSString *password = @"qqqqqq";
            //            NSString *username = @"18627005213";
            //            NSString *password = @"123456";
            //        NSString *username = @"15972206047";
            //        NSString *password = @"123456";
            
//            CLLocationCoordinate2D adjustCoordinate = [GPSConverter convertToMarsUseAlgorithmWithCoordinate:location.coordinate];
            CLLocationCoordinate2D adjustCoordinate = [GPSConverter convertToMarsUseDBWithCoordinate:location.coordinate];
            DDLogInfo(@"Adjust latitude: %+.6f, longitude: %+.6f\n", adjustCoordinate.latitude, adjustCoordinate.longitude);

            self.vc = (ViewController *)self.window.rootViewController;
            [self.vc addAnnotationToMapWithCoordinate:adjustCoordinate];

            [self updateLocationWithLatitude:adjustCoordinate.latitude longitude:adjustCoordinate.longitude username:username password:password];
        }
        
        for(int i=0;i<locations.count;i++){
            CLLocation * newLocation = [locations objectAtIndex:i];
            CLLocationCoordinate2D theLocation = newLocation.coordinate;
            CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
            
            self.myLocation = theLocation;
            self.myLocationAccuracy = theAccuracy;
        }
        [self addLocationToPList:self.shareModel.afterResume];
    }
}

#pragma mark - Application life cycle

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];

    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];

    [self addApplicationStatusToPList:@"applicationDidEnterBackground"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DDLogInfo(@"applicationDidBecomeActive");

    [self addApplicationStatusToPList:@"applicationDidBecomeActive"];

    //Remove the "afterResume" Flag after the app is active again.
    self.shareModel.afterResume = NO;

    if(self.shareModel.anotherLocationManager)
        [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];

    self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
    self.shareModel.anotherLocationManager.delegate = self;
    self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;

    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    DDLogInfo(@"applicationWillTerminate");
    [self addApplicationStatusToPList:@"applicationWillTerminate"];
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    DDLogInfo(@"Application document directory: %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);

    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/////////////////////////////////////////////////////////////////////////////////
// Below are 3 functions that add location and Application status to PList
// The purpose is to collect location information locally

-(void)addResumeLocationToPList{

    NSLog(@"addResumeLocationToPList");
    UIApplication* application = [UIApplication sharedApplication];

    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";

    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [self.shareModel.myLocationDictInPlist setObject:@"UIApplicationLaunchOptionsLocationKey" forKey:@"Resume"];
    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];

    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];

    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];

    if (!savedProfile){
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    }
    else{
        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }

    if(self.shareModel.myLocationDictInPlist)
    {
        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
    }

    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}

-(void)addLocationToPList:(BOOL)fromResume{
    NSLog(@"addLocationToPList");

    UIApplication* application = [UIApplication sharedApplication];

    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";

    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.latitude]  forKey:@"Latitude"];
    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.longitude] forKey:@"Longitude"];
    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocationAccuracy] forKey:@"Accuracy"];

    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];

    if(fromResume)
        [self.shareModel.myLocationDictInPlist setObject:@"YES" forKey:@"AddFromResume"];
    else
        [self.shareModel.myLocationDictInPlist setObject:@"NO" forKey:@"AddFromResume"];

    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];

    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];

    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];

    if (!savedProfile){
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    }
    else{
        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }

    NSLog(@"Dict: %@",self.shareModel.myLocationDictInPlist);

    if(self.shareModel.myLocationDictInPlist)
    {
        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
    }

    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}

-(void)addApplicationStatusToPList:(NSString*)applicationStatus{

    NSLog(@"addApplicationStatusToPList");
    UIApplication* application = [UIApplication sharedApplication];

    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";

    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [self.shareModel.myLocationDictInPlist setObject:applicationStatus forKey:@"applicationStatus"];
    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];

    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];

    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];

    if (!savedProfile){
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    }
    else{
        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }

    if(self.shareModel.myLocationDictInPlist)
    {
        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
    }

    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}

#pragma mark - API request

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
