//
//  RCSettingTableViewCell.h
//  RandomCafe
//
//  Created by Admin on 03.10.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCSettingTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *distanceRange;
@property (strong, nonatomic) IBOutlet UILabel *nameSettings;

@end
