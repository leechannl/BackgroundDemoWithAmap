//
//  CCAPIHelper.h
//  CircleLove
//
//  Created by mm on 8/25/14.
//  Copyright (c) 2014 xiaomiaos. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCAPIHelper : NSObject

/**
 *  Get the shared APIHelper instance.
 *
 *  @return APIHelper instance.
 */
+ (instancetype)sharedInstance;


/**
 *  Call the server to send SMS code to phone with `phoneNumber`
 *
 *  @param phoneNumber
 *
 *  Use side effect to store SMSCodeID into CCAPIHelper instance.
 */
- (void)getSMSCodeWithPhoneNumber:(NSString *)phoneNumber
                      success:(void (^) (id))success
                       failed:(void (^) (id))failed;


/**
 *  Register account by phone
 *
 *  @param phoneNumber
 *  @param SMSCode
 *  @param SMSCodeID
 *
 */
- (void)registerByPhoneNumber:(NSString *)phoneNumber
                  withSMSCode:(NSString*)SMSCode
                      success:(void (^) (id))success
                       failed:(void (^) (id))failed;

/**
 *  Login by phone
 *
 *  @param phoneNumber
 *  @param SMSCode
 *  @param SMSCodeID
 */
- (void)loginByPhoneNumber:(NSString *)phoneNumber
                  withSMSCode:(NSString*)SMSCode
                      success:(void (^) (id))success
                       failed:(void (^) (id))failed;

/**
 *  Login with username/password
 *
 *  @param username
 *  @param password
 *
 */
- (void)loginWithUsername:(NSString *)username
                  password:(NSString *)password
                  success:(void (^) (id))success
                   failed:(void (^) (id))failed;

/**
 *  Upload device token to server
 */
- (void)uploadDeviceTokenWithSuccess:(void (^) (id))success
                              failed:(void (^) (id))failed;


/**
 *  Logout
 */
- (void)logoutWithSuccess:(void (^) (id))success
                   failed:(void (^) (id))failed;

/**
 *  Check token validation synchronous
 *
 *  @return Yes if token is valid, otherwise No
 */
- (BOOL)isCCTokenValid;

/**
 *  Complete personal info.
 *
 *  @param avatar
 *  @param nickname
 *  @param email
 *  @param gender
 *  @param birthday
 *  @param backgroundImage
 *
 */
- (void)completeUserAvatar:(UIImage *)avatar
                  nickname:(NSString *)nickname
                  password:(NSString *)password
                     email:(NSString *)email
                    gender:(NSInteger)gender
                  birthday:(NSString *)birthday
           backgroundImage:(UIImage *)backgroundImage
                   success:(void (^) (id))success
                    failed:(void (^) (id))failed;

/**
 *  Get User current news.
 */
- (void)getRecentNewsWithSuccess:(void (^) (id))success
                          failed:(void (^) (id))failed;


/**
 *  Get user notifications.
 */
- (void)getNotificationsWithSuccess:(void (^) (id))success
                             failed:(void (^) (id))failed;

/**
 *  Get historical notification
 */
- (void)getHistoricalNotificationsWithSuccess:(void (^) (id))success
                                       failed:(void (^) (id))failed;

/**
 *  handle invitation
 */
- (void)handleInvitationWithInvitationID:(NSNumber *)invitationID
                                  Status:(NSNumber *)status
                                 success:(void (^) (id))success
                                  failed:(void (^) (id))failed;

/**
 *  Get image use image id, image including background image
 */
- (void)getImageWithimageID:(NSInteger)imageID
                           success:(void (^) (id))success
                            failed:(void (^) (id))failed;

/**
 *  Get user info using user id
 */
- (void)getUserInfoWithUserID:(NSInteger)userID
                           success:(void (^) (id))success
                            failed:(void (^) (id))failed;

/**
 *  Get user info using username
 */
- (void)getUserInfoWithUsername:(NSString *)username
                           success:(void (^) (id))success
                            failed:(void (^) (id))failed;

/**
 *  Get friends list
 */
- (void)getFriendListWithsuccess:(void (^) (id))success
                          failed:(void (^) (id))failed;

/**
 *  Get circles list
 */
- (void)getCircleListWithsuccess:(void (^) (id))success
                          failed:(void (^) (id))failed;

/**
 *  Create circle
 */
- (void)createCircleWithCircleName:(NSString *)circleName
                              type:(NSNumber *)type
                           success:(void (^) (id))success
                            failed:(void (^) (id))failed;

/**
 *  Update circle option
 *
 */
- (void)updateCircleOptionWithCircleID:(NSNumber *)circleID
                       isShareLocation:(BOOL)isShareLocation
                        isShareBattery:(BOOL)isShareBattery
                      isShareTransport:(BOOL)isShareTransport
                        isShareNetwork:(BOOL)isShareNetwork
                               success:(void (^) (id))success
                                failed:(void (^) (id))failed;

/**
 *  Leave circle.
 */

- (void)leaveCircleWithCircleID:(NSNumber *)circleID
                        success:(void (^) (id))success
                         failed:(void (^) (id))failed;

/**
 *  Dismiss circle.
 */
- (void)dismissCircleWithCircleID:(NSNumber *)circleID
                          success:(void (^) (id))success
                           failed:(void (^) (id))failed;

/**
 *  Invite new member
 */
- (void)inviteMemberToCircle:(NSNumber *)circleID
                      phones:(NSArray *)phones
                          success:(void (^) (id))success
                           failed:(void (^) (id))failed;

/**
 *  Get circle member list
 */
- (void)getCircleMembersWithCircleID:(NSInteger)circleID
                             success:(void (^) (id))success
                              failed:(void (^) (id))failed;

/**
 *  Get circle member location
 */
- (void)getCircleMemberLocationWithCircleID:(NSInteger)circleID
                                    success:(void (^) (id))success
                                     failed:(void (^) (id))failed;

/**
 *  Upload user location
 */
- (void)uploadUserLocationWithLatitude:(double)latitude
                             longitude:(double)longitude
                               address:(NSString *)address
                               success:(void (^) (id))success
                                failed:(void (^) (id))failed;

/**
 *  Publish news
 *  
 *      @param circleID. If nil then publish news to all circles
 *      @param type. It is the only required parameter in API, others could be nil
 *      @param pictures. API support uploading multiple pictures, but this method only support upload one picture
 *
 */
- (void)publishNewsWithCircleID:(NSNumber *)circleID
                           type:(NSNumber *)type
                        subtype:(NSNumber *)subtype
                        content:(NSString *)content
                       latitude:(float)latitude
                      longitude:(float)longitude
                        address:(NSString *)address
                        weather:(NSString *)weather
                         device:(NSString *)device
                       pictures:(NSArray *)pictures
                        success:(void (^) (id))success
                         failed:(void (^) (id))failed;

/**
 *  Create place in circle
 */
- (void)createPlaceWithCircleID:(NSNumber *)circleID
                       latitude:(float)latitude
                      longitude:(float)longitude
                        address:(NSString *)address
                        picture:(UIImage *)picture
                         radius:(float)radius
                           name:(NSString *)name
                        success:(void (^) (id))success
                         failed:(void (^) (id))failed;

/**
 *  Get places in circle
 */
- (void)getPlacesWithCircleID:(NSNumber *)circleID
                      success:(void (^) (id))success
                       failed:(void (^) (id))failed;

/**
 *  Update place in circle
 */
- (void)updatePlaceWithPlaceID:(NSNumber *)placeID
                       latitude:(float)latitude
                      longitude:(float)longitude
                        address:(NSString *)address
                        picture:(UIImage *)picture
                         radius:(float)radius
                           name:(NSString *)name
                        success:(void (^) (id))success
                         failed:(void (^) (id))failed;

/**
 *  delete place
 */
- (void)deletePlaceWithPlaceID:(NSNumber *)placeID
                        success:(void (^) (id))success
                         failed:(void (^) (id))failed;


/**
 *  Baidu LBS weather API
 */

- (void)getWeatherWithLatitude:(float)latitude
                     longitude:(float)longitude
                       success:(void (^) (id))success
                        failed:(void (^) (id))failed;


@end
