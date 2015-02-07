//
//  loggerFormatter.m
//  ios-starter-kit
//
//  Created by mm on 12/13/14.
//  Copyright (c) 2014 Pirate. All rights reserved.
//

#import "loggerFormatter.h"
#import <DateTools.h>

@implementation loggerFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    return [NSString stringWithFormat:@"%@ | %@ | %@ @ %d | %@", [logMessage.timestamp formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"], logMessage.fileName, logMessage.function, (int)logMessage.line, logMessage.message];
}

@end
