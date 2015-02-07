//
//  CCConstants.h
//  CircleLove
//
//  Created by mm on 8/25/14.
//  Copyright (c) 2014 xiaomiaos. All rights reserved.
//

#import <Foundation/Foundation.h>

// My application switches
#define     CCActivateGPSOnStartUp              YES
#define     CCInstallCrashHandler               NO

// Keys that are used to store data
// Userdefault
#define     CCRegistered                        @"CCRegistered"
#define     CCAlreadyLogin                      @"CCAlreadyIsLogin"
#define     CCNotFirstLaunch                    @"CCNotFirstLaunch"
#define     CCNeedLoadInitialData               @"CCNeedLoadInitialData"
#define     CCEaseMobUsername                   @"CCEaseMobUsername"
#define     CCNeedCompletedInfo                 @"CCNeedCompletedInfo"
#define     CCCurrentUserID                     @"CCCurrentUserID"
#define     CCCurrentUsername                   @"CCCurrentUsername"
#define     CCLastDisplayedCircle               @"CCLastDisplayedCircle"
#define     CCLastLocationLatitude              @"CCLastLocationLatitude"
#define     CCLastLocationLongitude             @"CCLastLocationLongitude"
#define     CCUMENGDEVICETOKEN                  @"CCUMENGDEVICETOKEN"

// KeyChain
#define     CCEaseMobPassword                   @"CCEaseMobPassword"
#define     CCCirclelove_API_Token              @"CCCircleloveAPIToken"

// Server related
#define     CCCircleloveServerAddress           @"218.244.142.86"
#define     CCCircleloveServerPort              @(9080)
#define     CCQiniuServerAddress                @"upload.qiniu.com"
#define     CCQiniuServerPort                   @(80)


typedef enum : NSUInteger {
    CCGenderMale = 1,
    CCGenderFemale = 2,
} CCGender;

typedef enum : NSUInteger {
    CCSystemNotification = 1,
    CCNormalNews = 2,
    CCCheckIn = 3,
    CCMark = 4,
    CCHelp = 5,
    CCEnterPlace = 6,
    CCLeavePlace = 7,
} CCNewsType;

typedef enum : NSUInteger {
    CCSleep = 1,
    CCWakeup = 2,
    CCReturningHome = 3,
    CCMeeting = 4,
    CCRequireDate = 5,
    CCRequireChat = 6,
    CCRequireMeal = 7,
} CCNewsSubType;

// Macros
static NSUInteger CommentCount;

#define commentToolBarButtonWidth 44
#define CCScreenSize [UIScreen mainScreen].bounds.size

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// Umeng macros
#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending) 
#define _IPHONE80_ 80000