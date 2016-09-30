//
//  RCDetailViewController.m
//  RandomCafe
//
//  Created by Admin on 29.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "RCDetailViewController.h"
#import "RCServerManager.h"
#import "UIImageView+AFNetworking.h"
#import "RCTableViewCell.h"

@interface RCDetailViewController ()

@property (strong, nonatomic) NSArray* arrayWithFeedback;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *photoPlaceImageView;
@property (strong, nonatomic) IBOutlet UILabel *namePlaceLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressPlaceLabel;
@property (strong, nonatomic) IBOutlet UILabel *phonePlaceLabel;

@end

@implementation RCDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.namePlaceLabel.text = self.place.name;
    self.addressPlaceLabel.text = self.place.address;
    self.phonePlaceLabel.text = self.place.phoneNumber;
    
    self.photoPlaceImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoPlaceImageView.clipsToBounds = YES;
    
    [self getPhotoFromServerWithPlaceID:self.place.placeID];
    [self getFeedbackFromServerWithPlaceID:self.place.placeID];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

# pragma Mark - API

- (void) getFeedbackFromServerWithPlaceID:(NSString*) placeID {
    
    __weak typeof(self) weakSelf = self;
    [[RCServerManager sharedManager]
     getArrayFeedbackPlaceWithID:placeID OnSuccess:^(NSArray *feedbackArray) {

         weakSelf.arrayWithFeedback = feedbackArray;
         [weakSelf.tableView reloadData];
     }
     
      OnFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
}

- (void) getPhotoFromServerWithPlaceID:(NSString*) placeID {
    
    [[RCServerManager sharedManager]
     getArrayPhotoPlaceWithID:placeID
     OnSuccess:^(NSString *photoPlace) {
         
         NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:photoPlace]];
         UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.jpg"];
         __weak typeof(self) weakSelf = self;
         [self.photoPlaceImageView setImageWithURLRequest:request
                                placeholderImage:placeholderImage
                                         success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage *image) {
                                             
                                             weakSelf.photoPlaceImageView.image = image;
                                             
                                         } failure:nil];
         
         
                      UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:photoPlace]]];
                      self.photoPlaceImageView.image = image;
     }
     
     OnFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    
    if ([self.arrayWithFeedback count] == 0) {
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.tableView.scrollEnabled = YES;
        self.tableView.separatorStyle =     UITableViewCellSeparatorStyleSingleLine;
    }
    
    return [self.arrayWithFeedback count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RCTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"RCTableViewCell"];
    
    if (cell == nil) {
        cell = [[RCTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RCTableViewCell"];
    }
    
    cell.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    cell.userAvatar.clipsToBounds = YES;
    
    NSDictionary* dict  = [self.arrayWithFeedback objectAtIndex:indexPath.row];
    
    NSString* text = [dict objectForKey:@"text"];
    
    NSDictionary* dictionaryWithUser = [dict objectForKey:@"user"];
    NSString* firtName = [dictionaryWithUser objectForKey:@"firstName"];
    NSString* lastName = [dictionaryWithUser objectForKey:@"lastName"];
    
    NSDictionary* dictionaryWithPhoto = [dictionaryWithUser objectForKey:@"photo"];
    NSString* prefix = [dictionaryWithPhoto objectForKey:@"prefix"];
    NSString* suffix = [dictionaryWithPhoto objectForKey:@"suffix"];
    
    NSString* photoURL = [NSString stringWithFormat:@"%@original%@", prefix, suffix];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:photoURL]];
    UIImage* placeholderImage = [UIImage imageNamed:@"placeholder.jpg"];
  //  __weak typeof(self) weakSelf = cell;
    [cell.userAvatar setImageWithURLRequest:request
                           placeholderImage:placeholderImage
                                    success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage *image) {
                                        
                                        cell.userAvatar.image = image;
                                        
                                    } failure:nil];

    cell.userFullName.text = firtName;
    cell.userText.text = text;

    return cell;
}

@end
