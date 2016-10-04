//
//  RCSettingTableViewCell.m
//  RandomCafe
//
//  Created by Admin on 03.10.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "RCSettingTableViewCell.h"
#import "RCConstant.h"

@implementation RCSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.distanceRange.inputAccessoryView = numberToolbar;
}


-(void)doneWithNumberPad{
    [self.distanceRange resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    NSString *textLenght = [NSString stringWithFormat:@"%@", self.distanceRange.text];

    if ([textLenght length] == 0) {
      NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"4" , RCRadiusDidChangeInfoKey, nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RCRadiusDidChangeNotification
                                                            object:nil
                                                          userInfo:dictionary];
    } else {
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.distanceRange.text , RCRadiusDidChangeInfoKey, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RCRadiusDidChangeNotification
                                                        object:nil
                                                      userInfo:dictionary];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
 
    NSString *textLenght = [NSString stringWithFormat:@"%@", [textField text]];
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if ([textLenght length] > 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message"
                                                       message:@"Too long"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
    
}

@end
