//
//  RCDetailInfoPopupView.m
//  RandomCafe
//
//  Created by Admin on 27.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "RCDetailInfoPopupView.h"
#import "RCPlace.h"
#import "RCServerManager.h"
//#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@implementation RCDetailInfoPopupView

+ (instancetype)loadUserInfoView {
    
    NSArray *viewes = [[NSBundle mainBundle] loadNibNamed:@"RCDetailInfoPopupView" owner:nil options:nil];
    
    RCDetailInfoPopupView *newUserInfoView = [viewes firstObject];
    
    return newUserInfoView;
}

- (id) initWithPlace:(RCPlace*) place
           namePlace:(NSString*) name
        addressPlace:(NSString*) address {
    
    self = [super init];
    if (self) {
        
        self.photoPlace.contentMode = UIViewContentModeScaleAspectFill;
        self.photoPlace.clipsToBounds = YES;
        
        [[RCServerManager sharedManager]
         getArrayPhotoPlaceWithID:place.placeID
         OnSuccess:^(NSString *photoPlace) {
             
             NSLog(@"= = = = = = ==  == = = == = = = === = ===== = ====== = ==%@", photoPlace);
            
             NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:photoPlace]];
             UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.jpg"];
             __weak typeof(self) weakSelf = self;
             [self.photoPlace setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage *image) {
                                                 
                                                  weakSelf.photoPlace.image = image;
                                            
                                              } failure:nil];
 
          
         }
         OnFailure:^(NSError *error, NSInteger statusCode) {
             NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
         }];

        self.namePlace.text = name;
        self.addressPlace.text = address;
        
    }
    
    return self;
}

@end
