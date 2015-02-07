//
//  CCConfigurationHelper.h
//  CircleLove
//
//  Created by mm on 8/25/14.
//  Copyright (c) 2014 xiaomiaos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCConfigurationHelper : NSObject

+(void)setApplicationStartupDefaults;

+(BOOL)getBoolValueForConfigurationKey:(NSString *)_objectkey;

+(NSString *)getStringValueForConfigurationKey:(NSString *)_objectkey;

+(void)setBoolValueForConfigurationKey:(NSString *)_objectkey withValue:(BOOL)_boolvalue;

+(void)setStringValueForConfigurationKey:(NSString *)_objectkey withValue:(NSString *)_value;

@end
