//
//  RCPlace.h
//  RandomCafe
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
#import <UIKit/UIKit.h>

@interface RCPlace : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* address;
@property (strong, nonatomic) NSString* coordinatePlaceLat;
@property (strong, nonatomic) NSString* coordinatePlaceLng;
@property (strong, nonatomic) NSString* placeID;
@property (strong, nonatomic) NSString* phoneNumber;

- (id) initWithServerResponse:(NSDictionary*) responseObject;

@end
