//
//  CCConfigurationHelper.m
//  CircleLove
//
//  Created by mm on 8/25/14.
//  Copyright (c) 2014 xiaomiaos. All rights reserved.
//

#import "CCConfigurationHelper.h"
#import "CCConstants.h"

@implementation CCConfigurationHelper

+(void)setApplicationStartupDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    [defaults setBool:NO forKey:CCNotFirstLaunch];
    [defaults setBool:NO forKey:CCAlreadyLogin];
    [defaults setBool:YES forKey:CCNeedLoadInitialData];
    [defaults setBool:YES forKey:CCNeedCompletedInfo];
    [defaults setInteger:-1 forKey:CCCurrentUserID];
    [defaults setObject:@"" forKey:CCCurrentUsername];
    [defaults setObject:@"" forKey:CCEaseMobUsername];
    [defaults setObject:@"30" forKey:CCLastLocationLatitude];
    [defaults setObject:@"114" forKey:CCLastLocationLongitude];
    [defaults setInteger:-1 forKey:CCLastDisplayedCircle];
    [defaults setObject:@"" forKey:CCUMENGDEVICETOKEN];

    [defaults synchronize];
}

+(BOOL)getBoolValueForConfigurationKey:(NSString *)_objectkey
{
    // create an instance of NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize]; // let's make sure the object is synchronized
    return [defaults boolForKey:_objectkey];
}

+(NSString *)getStringValueForConfigurationKey:(NSString *)_objectkey
{
    // create an instance of NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize]; // let's make sure the object is synchronized
    if ([defaults stringForKey:_objectkey] == nil )
    {
        // I don't want a (null) returned since the result might be a text property of a UILabel
        return @"";
    }
    else
    {

        return [defaults stringForKey:_objectkey];
    }
}
+(void)setBoolValueForConfigurationKey:(NSString *)_objectkey withValue:(BOOL)_boolvalue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize]; // let's make sure the object is synchronized
    [defaults setBool:_boolvalue forKey:_objectkey];
    [defaults synchronize]; // make sure you're synchronized again
}

+(void)setStringValueForConfigurationKey:(NSString *)_objectkey withValue:(NSString *)_value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize]; //let's make sure the object is synchronized
    [defaults setValue:_value forKey:_objectkey];
    [defaults synchronize]; // make sure you're synchronized again
}


@end