//
//  RCServerManager.h
//  RandomCafe
//
//  Created by Admin on 27.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPlace.h"

@interface RCServerManager : NSObject

+ (RCServerManager*) sharedManager;
- (void) getPlacesNearMyLocation:(CLLocationCoordinate2D)location
                        WithType:(NSString*)type
                       OnSuccess:(void(^)(NSArray* places)) success
                       OnFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getArrayPhotoPlaceWithID:(NSString*) placeID
                        OnSuccess:(void(^)(NSString* photoPlace)) success
                        OnFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getArrayFeedbackPlaceWithID:(NSString*) placeID
                           OnSuccess:(void(^)(NSArray* feedbackArray)) success
                           OnFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
