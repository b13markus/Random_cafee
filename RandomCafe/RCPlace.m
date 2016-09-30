//
//  RCPlace.m
//  RandomCafe
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "RCPlace.h"

@implementation RCPlace

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    self = [super init];
    if (self) {
        
        self.name = [responseObject objectForKey:@"name"];
        self.placeID = [responseObject objectForKey:@"id"];
        
        NSDictionary* location = [responseObject objectForKey:@"location"];
        self.address = [location objectForKey:@"address"];
        self.coordinatePlaceLat = [location objectForKey:@"lat"];
        self.coordinatePlaceLng = [location objectForKey:@"lng"];
        
        NSDictionary* contact = [responseObject objectForKey:@"contact"];
        self.phoneNumber = [contact objectForKey:@"phone"];
        
    }
    return self;
}


@end
