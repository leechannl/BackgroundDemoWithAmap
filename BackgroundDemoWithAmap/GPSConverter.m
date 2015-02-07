//
//  GPSConverter.m
//  BackgroundDemoWithAmap
//
//  Created by mm on 2/6/15.
//  Copyright (c) 2015 Pirate. All rights reserved.
//

#import "CocoaLumberjack/DDLog.h"
#import "CSqlite.h"
#import <sqlite3.h>
#import "GPSConverter.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

const double a = 6378245.0;
const double ee = 0.00669342162296594323;

@implementation GPSConverter

#pragma mark - Use algorithm to converte GPS data

+ (CLLocationCoordinate2D )convertToMarsUseAlgorithmWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if ([GPSConverter isOutOfChina:coordinate]) {
        return coordinate;
    }
    double dLat = [GPSConverter convertLatitudeWithX:coordinate.latitude - 105.0 y:coordinate.longitude - 35.0];
    double dLon = [GPSConverter convertLongitudeWithX:coordinate.latitude - 105.0 y:coordinate.longitude - 35.0];
    double radLat = coordinate.latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake(coordinate.latitude + dLat, coordinate.longitude + dLon);

    return newCoordinate;
}

+ (BOOL)isOutOfChina:(CLLocationCoordinate2D)coordinate
{
    double lat = coordinate.latitude;
    double lon = coordinate.longitude;

    if (lon < 72.004 || lon > 137.8347)
        return YES;
    if (lat < 0.8293 || lat > 55.8271)
        return YES;

    return NO;
}

+ (double)convertLatitudeWithX:(double)x y:(double)y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

+ (double)convertLongitudeWithX:(double)x y:(double)y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

#pragma mark - Use DB to convert GPS data

+ (CLLocationCoordinate2D)convertToMarsUseDBWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"gps" ofType:@"db"];
    sqlite3 *db;
    if (sqlite3_open([sqLiteDb UTF8String], &db) != SQLITE_OK) {
        DDLogError(@"Failed to open database");
    }
//    [sqliteDB openSqlite];
    int TenLat=0;
    int TenLog=0;
    TenLat = (int)(coordinate.latitude*10);
    TenLog = (int)(coordinate.longitude*10);

    NSString *query = [[NSString alloc]initWithFormat:@"SELECT offLat,offLog FROM gpsT WHERE lat=%d AND log=%d", TenLat, TenLog];
//    NSString *query = [[NSString alloc]initWithFormat:@"SELECT * FROM gpsT"];
    DDLogInfo(@"SQL query: %@", query);

    sqlite3_stmt *statement;

    int offLat=0;
    int offLog=0;
    if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
        offLat = sqlite3_column_int(statement, 0);
        offLog = sqlite3_column_int(statement, 1);
        }
    } else {
        DDLogError(@"Error: %s", sqlite3_errmsg(db));
    }

    coordinate.latitude = coordinate.latitude+offLat*0.0001;
    coordinate.longitude = coordinate.longitude + offLog*0.0001;
    return coordinate;
}

@end
