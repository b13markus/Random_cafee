//
//  RCDetailInfoPopupView.h
//  RandomCafe
//
//  Created by Admin on 27.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCPlace.h"

@interface RCDetailInfoPopupView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *photoPlace;
@property (strong, nonatomic) IBOutlet UILabel *namePlace;
@property (strong, nonatomic) IBOutlet UILabel *addressPlace;

+ (instancetype)loadUserInfoView;

- (id) initWithPlace:(RCPlace*) place
           namePlace:(NSString*) name
        addressPlace:(NSString*) address;

@end
