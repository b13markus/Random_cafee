//
//  RCServerManager.m
//  RandomCafe
//
//  Created by Admin on 27.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "RCServerManager.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@implementation RCServerManager

+ (RCServerManager*) sharedManager {
    static RCServerManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RCServerManager alloc]init];
    });
    return manager;
}

- (void) getPlacesNearMyLocation:(CLLocationCoordinate2D)location
                        WithType:(NSString*)type
                       OnSuccess:(void(^)(NSArray* places)) success
                       OnFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSString* clientID = @"UXVD1VCC3OJA1BQVEHL1DCIXSU2Y5B0UDZ2QMKWC45GZHLDI";
    NSString* clientSecret = @"FWU1SCVSA32UPL3OORVFNZGR3CQXWCI0OUKCKDGGKTIO1U4O";
    NSString* v = @"20130815";
    NSString* ll = [NSString stringWithFormat:@"%f,%f", location.latitude , location.longitude];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:clientID, @"client_id", clientSecret, @"client_secret", v, @"v", ll, @"ll", type , @"query", nil];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:@"https://api.foursquare.com/v2/venues/search" parameters:params progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             NSLog(@"%@",responseObject);
             NSError *error;
             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                                options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                  error:&error];
             
             NSMutableArray* arrayWithPlaces = [[NSMutableArray alloc]init];

             if (! jsonData) {
                 
                 NSLog(@"Got an error: %@", error);
                 
             } else {
                 
                 NSDictionary* response = [responseObject objectForKey:@"response"];
                 NSArray* objectArray = [response objectForKey:@"venues"];
                 
                 for (NSDictionary* dict in objectArray ) {
                     RCPlace* place = [[RCPlace alloc] initWithServerResponse:dict];
                     [arrayWithPlaces addObject:place];
                 }
             }

             for (RCPlace* place in arrayWithPlaces) {
                 NSLog(@"================ %@", place);
             }
             
             NSLog(@"%@", arrayWithPlaces);
             if (success) {
                 success(arrayWithPlaces);
             }
             
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"error - %@", error);
         }];
    
}

- (void) getArrayPhotoPlaceWithID:(NSString*) placeID
                        OnSuccess:(void(^)(NSString* photoPlace)) success
                        OnFailure:(void(^)(NSError* error, NSInteger statusCode)) failure   {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/photos?oauth_token=TACGZSNCFQ33KD2CSYJLZSRO2500OPJ30IFHL2AIR5UDWUQ0&v=20160928", placeID] parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
         
             NSDictionary* response = [responseObject objectForKey:@"response"];
             NSDictionary* photosArray = [response objectForKey:@"photos"];
             NSArray* items = [photosArray objectForKey:@"items"];

             NSString* photoPlaceURL;
             
             if (items.count == 0) {
             } else {
                 
                 NSDictionary* dict  = [items objectAtIndex:0];
                 
                 NSString* prefix = [dict objectForKey:@"prefix"];
                 NSString* suffix = [dict objectForKey:@"suffix"];
                 NSString* photoPlace = [NSString stringWithFormat:@"%@300x400%@", prefix, suffix];
                 photoPlaceURL = photoPlace;
             }
       
     if (success) {
         success(photoPlaceURL);
         
                }
             }
     
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"error - %@", error);
         }];
}

- (void) getArrayFeedbackPlaceWithID:(NSString*) placeID
                        OnSuccess:(void(^)(NSArray* feedbackArray)) success
                        OnFailure:(void(^)(NSError* error, NSInteger statusCode)) failure   {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/tips?sort=recent&oauth_token=TACGZSNCFQ33KD2CSYJLZSRO2500OPJ30IFHL2AIR5UDWUQ0&v=20160928", placeID] parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             
             NSDictionary* response = [responseObject objectForKey:@"response"];
             NSDictionary* tipsArray = [response objectForKey:@"tips"];
             NSArray* items = [tipsArray objectForKey:@"items"];
             
             if (items.count == 0) {
             } else {
             }
             if (success) {
                 success(items);
             }
         }
     
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"error - %@", error);
         }];

}

@end
