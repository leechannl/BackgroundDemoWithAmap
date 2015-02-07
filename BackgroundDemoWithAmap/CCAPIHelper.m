//
//  CCAPIHelper.m
//  CircleLove
//
//  Created by mm on 8/25/14.
//  Copyright (c) 2014 xiaomiaos. All rights reserved.
//

#import "AFNetworking.h"
#import "CCAPIHelper.h"
#import "CCConstants.h"
#import "CCConfigurationHelper.h"
#import <UICKeyChainStore.h>

@interface CCAPIHelper ()

@property (nonatomic, strong) NSString *SMSCodeID;

@end

@implementation CCAPIHelper


+ (instancetype)sharedInstance
{
    static CCAPIHelper *_sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CCAPIHelper alloc] init];
    });

    return _sharedInstance;
}

- (BOOL)isCCTokenValid
{
    NSString *token = [UICKeyChainStore keyChainStore][CCCirclelove_API_Token];
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/news/recent?token=%@", CCCircleloveServerAddress, CCCircleloveServerPort, token];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    NSError *error;
    [NSURLConnection sendSynchronousRequest:urlRequest
                          returningResponse:&response
                                      error:&error];
    // Synchronous request could not get status code, see this post:
    //  http://stackoverflow.com/questions/3912532/ios-how-can-i-receive-http-401-instead-of-1012-nsurlerrorusercancelledauthenti
    if (error.code == kCFURLErrorUserCancelledAuthentication) {
        NSLog(@"Circle love token expired.");
        return NO;
    }
    return YES;
}

- (void)getSMSCodeWithPhoneNumber:(NSString *)phoneNumber success:(void (^) (id))success failed:(void (^) (id))failed
{

    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/auth/smsCode/%@", CCCircleloveServerAddress, CCCircleloveServerPort, phoneNumber];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *parameter = @{@"forRegister": @"true"};
    [manager GET:requestURL parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if ([responseObject objectForKey:@"smsCodeID"]) {
                 self.SMSCodeID = responseObject[@"smsCodeID"];
             }
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)registerByPhoneNumber:(NSString *)phoneNumber withSMSCode:(NSString *)SMSCode success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/auth/registerBySMSCode", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"phone": phoneNumber,
                                @"smsCode": SMSCode,
                                // TODO. Add youmeng token later
                                };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)loginByPhoneNumber:(NSString *)phoneNumber withSMSCode:(NSString *)SMSCode success:(void (^) (id))success failed:(void (^) (id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/auth/loginBySMSCode", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"phone": phoneNumber,
                                @"smsCode": SMSCode,
                                // TODO. Add youmeng token later
                                };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:requestURL parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [UICKeyChainStore setString:responseObject[@"token"] forKey:CCCirclelove_API_Token];
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/auth/login", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"username": username,
                                @"password": password,
                                @"device_token": [CCConfigurationHelper getStringValueForConfigurationKey:CCUMENGDEVICETOKEN]};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [UICKeyChainStore setString:responseObject[@"token"] forKey:CCCirclelove_API_Token];
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)uploadDeviceTokenWithSuccess:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/auth/updateDeviceToken", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameters = @{@"device_token": [CCConfigurationHelper getStringValueForConfigurationKey:CCUMENGDEVICETOKEN]};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager PUT:requestURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

- (void)logoutWithSuccess:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/auth/logout", CCCircleloveServerAddress, CCCircleloveServerPort];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager POST:requestURL parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];

}

- (void)completeUserAvatar:(UIImage *)avatar nickname:(NSString *)nickname password:(NSString *)password email:(NSString *)email gender:(NSInteger)gender birthday:(NSString *)birthday backgroundImage:(UIImage *)backgroundImage success:(void (^) (id))success failed:(void (^) (id))failed
{
    [self getQiniuUplodTokenWithsuccess:^(id x) {
        NSString *uploadToken = x[@"uploadToken"];
        [self uploadToQiniuWithImage:avatar
                         uploadToken:uploadToken
                             success:^(NSDictionary *avatarDict) {
                                 NSString *avatarKey = avatarDict[@"key"];
                                 [self uploadToQiniuWithImage:backgroundImage
                                                  uploadToken:uploadToken
                                                      success:^(NSDictionary *backgroundImageDict) {
                                                          NSString *backgroundImageKey = backgroundImageDict[@"key"];
                                                          NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/user/completeInfo", CCCircleloveServerAddress, CCCircleloveServerPort];
                                                          NSDictionary *parameter = @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token],
                                                                                      @"nickname": nickname,
                                                                                      @"password": password,
                                                                                      @"email": email ? email : @"",
                                                                                      @"gender": @(gender),
                                                                                      @"birthday": birthday ? birthday : @"",
                                                                                      @"avatar": avatarKey,
                                                                                      @"background": backgroundImageKey
                                                                                      };
                                                          
                                                          AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                                          
                                                          [manager GET:requestURL parameters:parameter
                                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                              success(responseObject);
                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                              NSLog(@"%@", operation.responseObject[@"errorDesc"]);
                                                              failed(@(operation.response.statusCode));
                                                          }];
                                                      } failed:^(id x) {}];
                             } failed:^(id x) {}];
    } failed:^(id x) {}];
}

- (void)getRecentNewsWithSuccess:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/news/recent", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token]};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL
      parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)getNotificationsWithSuccess:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/notification/unread", CCCircleloveServerAddress, CCCircleloveServerPort];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager GET:requestURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)getHistoricalNotificationsWithSuccess:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/notification/history", CCCircleloveServerAddress, CCCircleloveServerPort];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager GET:requestURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];

}

- (void)handleInvitationWithInvitationID:(NSNumber *)invitationID Status:(NSNumber *)status success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/invite/%@", CCCircleloveServerAddress, CCCircleloveServerPort, invitationID];
    NSDictionary *parameter = @{@"status": status};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager PUT:requestURL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

- (void)getImageWithimageID:(NSInteger)imageID success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/media/urls", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token],
                                @"id": @(imageID)};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager GET:requestURL
      parameters:parameter
         success:^(AFHTTPRequestOperation *operation, NSDictionary *dict) {
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             manager.responseSerializer = [AFImageResponseSerializer serializer];
             [manager GET:dict[@"url"]
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation, UIImage *image) {
                      success(image);
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      NSLog(@"%@", operation.responseObject[@"errorDesc"]);
                      failed(@(operation.response.statusCode));
                  }];

         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)getUserInfoWithUserID:(NSInteger)userID success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/user/info", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token],
                                @"id": @(userID)};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL
      parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)getUserInfoWithUsername:(NSString *)username success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/user/info", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token],
                                @"username": username};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL
      parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)getFriendListWithsuccess:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/user/frends", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token]};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL
      parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)getCircleListWithsuccess:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/circle", CCCircleloveServerAddress, CCCircleloveServerPort];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager GET:requestURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)createCircleWithCircleName:(NSString *)circleName type:(NSNumber *)type success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/circle", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameters = @{@"type": type,
                                 @"name": circleName
                                 };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager POST:requestURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

- (void)updateCircleOptionWithCircleID:(NSNumber *)circleID isShareLocation:(BOOL)isShareLocation isShareBattery:(BOOL)isShareBattery isShareTransport:(BOOL)isShareTransport isShareNetwork:(BOOL)isShareNetwork success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/option/circle/%@", CCCircleloveServerAddress, CCCircleloveServerPort, circleID];
    NSDictionary *parameters = @{@"share_location": isShareLocation ? @(1) : @(0),
                                 @"share_battery": isShareBattery ? @(1) : @(0),
                                 @"share_transport": isShareTransport ? @(1) : @(0),
                                 @"share_network": isShareNetwork ? @(1) : @(0)
                                 };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager PUT:requestURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

- (void)leaveCircleWithCircleID:(NSNumber *)circleID success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/circle/%@/member", CCCircleloveServerAddress, CCCircleloveServerPort, circleID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager DELETE:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

- (void)dismissCircleWithCircleID:(NSNumber *)circleID success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/circle/%@", CCCircleloveServerAddress, CCCircleloveServerPort, circleID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager DELETE:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

- (void)inviteMemberToCircle:(NSNumber *)circleID phones:(NSArray *)phones success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/invite", CCCircleloveServerAddress, CCCircleloveServerPort];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    NSDictionary *parameters = @{@"circle_id": circleID,
                                 @"phones": phones,
                                 };
    [manager POST:requestURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

- (void)getCircleMembersWithCircleID:(NSInteger)circleID success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/circleMember/list", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token],
                                @"circle_id": @(circleID)};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL
      parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)getCircleMemberLocationWithCircleID:(NSInteger)circleID success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/userLocation/listInCircle", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token],
                                @"circle_id": @(circleID)};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL
      parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)uploadUserLocationWithLatitude:(double)latitude longitude:(double)longitude address:(NSString *)address success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/userStatus", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter;
    if (address) {
        parameter = @{@"latitude": @(latitude),
                      @"longitude": @(longitude),
                      @"address": address
                      };
    } else {
        parameter = @{@"latitude": @(latitude),
                      @"longitude": @(longitude),
                      };
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager POST:requestURL parameters:parameter
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              success(responseObject);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", operation.responseObject[@"errorDesc"]);
              failed(@(operation.response.statusCode));
          }];
}

- (void)publishNewsWithCircleID:(NSNumber *)circleID type:(NSNumber *)type subtype:(NSNumber *)subtype content:(NSString *)content latitude:(float)latitude longitude:(float)longitude address:(NSString *)address weather:(NSString *)weather device:(NSString *)device pictures:(NSArray *)pictures success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/news/create", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithDictionary: @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token],
                                                                                      @"type": type}];
    if (circleID) {
        [parameter setValue:circleID forKey:@"circle_id"];
    }
    if (subtype) {
        [parameter setValue:subtype forKey:@"subtype"];
    }
    if (content) {
        [parameter setValue:content forKey:@"content"];
    }
    if (latitude && longitude) {
        [parameter setValue:@(latitude) forKey:@"latitude"];
        [parameter setValue:@(longitude) forKey:@"longitude"];
    }
    if (address) {
        [parameter setValue:address forKey:@"address"];
    }
    if (weather) {
        [parameter setValue:weather forKey:@"weather"];
    }
    if (device) {
        [parameter setValue:device forKey:@"device"];
    }
    if ([pictures count] > 0) {
        UIImage *picture = [pictures lastObject];
        [self getQiniuUplodTokenWithsuccess:^(id x) {
            NSString *uploadToken = x[@"uploadToken"];

            [self uploadToQiniuWithImage:picture uploadToken:uploadToken success:^(NSDictionary *dict) {
                NSString *pictureKey = dict[@"key"];
                [parameter setValue:pictureKey forKey:@"picture"];

                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                [manager GET:requestURL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    success(responseObject);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@", operation.responseObject[@"errorDesc"]);
                    failed(@(operation.response.statusCode));
                }];
            } failed:^(id x) { }];
        } failed:^(id x) { }];
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:requestURL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", operation.responseObject[@"errorDesc"]);
            failed(@(operation.response.statusCode));
        }];
    }
}

- (void)createPlaceWithCircleID:(NSNumber *)circleID latitude:(float)latitude longitude:(float)longitude address:(NSString *)address picture:(UIImage *)picture radius:(float)radius name:(NSString *)name success:(void (^)(id))success failed:(void (^)(id))failed
{
    [self getQiniuUplodTokenWithsuccess:^(id x) {
        NSString *uploadToken = x[@"uploadToken"];
        [self uploadToQiniuWithImage:picture uploadToken:uploadToken success:^(NSDictionary *dict) {
            NSString *pictureKey = dict[@"key"];
            NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/place", CCCircleloveServerAddress, CCCircleloveServerPort];
            NSDictionary *parameter = @{@"circle_id": circleID,
                                        @"latitude": @(latitude),
                                        @"longitude": @(longitude),
                                        @"address": address,
                                        @"picture": pictureKey,
                                        @"radius": @(radius),
                                        @"name": name
                                        };
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
            [manager POST:requestURL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@", operation.responseObject[@"errorDesc"]);
                    failed(@(operation.response.statusCode));
            }];
        } failed:^(id x) {
            failed(x);
        }];
    } failed:^(id x) {
            failed(x);
    }];
}

- (void)getPlacesWithCircleID:(NSNumber *)circleID success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/place/circle/%@", CCCircleloveServerAddress, CCCircleloveServerPort, circleID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

- (void)updatePlaceWithPlaceID:(NSNumber *)placeID latitude:(float)latitude longitude:(float)longitude address:(NSString *)address picture:(UIImage *)picture radius:(float)radius name:(NSString *)name success:(void (^)(id))success failed:(void (^)(id))failed
{
    [self getQiniuUplodTokenWithsuccess:^(id x) {
        NSString *uploadToken = x[@"uploadToken"];
        [self uploadToQiniuWithImage:picture uploadToken:uploadToken success:^(NSDictionary *dict) {
            NSString *pictureKey = dict[@"key"];
            NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/place/%@", CCCircleloveServerAddress, CCCircleloveServerPort, placeID];
            NSDictionary *parameter = @{
                                        @"latitude": @(latitude),
                                        @"longitude": @(longitude),
                                        @"address": address,
                                        @"picture": pictureKey,
                                        @"radius": @(radius),
                                        @"name": name
                                        };
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
            [manager PUT:requestURL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@", operation.responseObject[@"errorDesc"]);
                    failed(@(operation.response.statusCode));
            }];
        } failed:^(id x) {
            failed(x);
        }];
    } failed:^(id x) {
            failed(x);
    }];
}

- (void)deletePlaceWithPlaceID:(NSNumber *)placeID success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/v1/place/%@", CCCircleloveServerAddress, CCCircleloveServerPort, placeID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[UICKeyChainStore keyChainStore][CCCirclelove_API_Token] forHTTPHeaderField:@"token"];
    [manager DELETE:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

#pragma mark - Private methods

- (void)getQiniuUplodTokenWithsuccess:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@/quanzi/media/uploadToken", CCCircleloveServerAddress, CCCircleloveServerPort];
    NSDictionary *parameter = @{@"token": [UICKeyChainStore keyChainStore][CCCirclelove_API_Token]};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL
      parameters:parameter
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", operation.responseObject[@"errorDesc"]);
             failed(@(operation.response.statusCode));
         }];
}

- (void)uploadToQiniuWithImage:(UIImage *)image uploadToken:(NSString*)uploadToken success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://%@:%@", CCQiniuServerAddress, CCQiniuServerPort];
    NSDictionary *parameter = @{@"token": uploadToken};

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:requestURL parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0)
                                    name:@"file"
                                fileName:@"file.jpg"
                                mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

- (void)getWeatherWithLatitude:(float)latitude longitude:(float)longitude success:(void (^)(id))success failed:(void (^)(id))failed
{
    NSString *requestURL = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric&appid=7802c6d228c6e6226188b537cc48c2b4", latitude, longitude];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseObject[@"errorDesc"]);
        failed(@(operation.response.statusCode));
    }];
}

@end
