//
//  RCDetailViewController.h
//  RandomCafe
//
//  Created by Admin on 29.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCPlace.h"

@interface RCDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) RCPlace* place;

@end
