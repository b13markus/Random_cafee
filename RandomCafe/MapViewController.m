//
//  ViewController.m
//  RandomCafe
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "RCPlace.h"
#import "RCServerManager.h"
#import "RCDetailInfoPopupView.h"
#import "RCDetailViewController.h"
#import "CDRTranslucentSideBar.h"
#import "RCSettingTableViewCell.h"
#import "RCConstant.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, CDRTranslucentSideBarDelegate, UITextFieldDelegate> {
    
    IBOutletCollection(UIButton) NSArray *placeButtons;
    IBOutlet UIButton *stumblButton;
    __weak IBOutlet MKMapView *myMapView;
    
    CLLocationManager *locatioManager;
    UITapGestureRecognizer *tapRecognizer;
}

@property (strong, nonatomic) IBOutlet UILabel *informationLabel;

@property (assign ,nonatomic) BOOL myLocation;
@property (assign ,nonatomic) BOOL OnRightSideBBT;
@property (assign, nonatomic) double myLocationCoordinateLongitude;
@property (assign, nonatomic) double myLocationCoordinateLatitude;
@property (assign, nonatomic) NSInteger randomIndexPlace;
@property (assign, nonatomic) NSInteger indexTapButton;
@property (strong, nonatomic) NSString* distanceRange;
@property (strong, nonatomic) MKDirections* directions;
@property (strong, nonatomic) NSArray* arrayWithPlaces;
@property (strong, nonatomic) CLGeocoder* geoCoder;
@property (strong, nonatomic) IBOutlet UIView* viewDetailPlace;//placeholderForPlaceDetailView
@property (strong, nonatomic) RCDetailInfoPopupView* detailView;
@property (strong, nonatomic) RCPlace* randomPlace;
@property (nonatomic, strong) CDRTranslucentSideBar *rightSideBar;
@property (strong, nonatomic) MKPointAnnotation* placeAnnotation;
@property (strong, nonatomic) MKPointAnnotation* myCyrrentCoordinateAnnotation;

- (IBAction)OnRightSideBarButtonTapped:(id)sender;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myCyrrentCoordinateAnnotation = [[MKPointAnnotation alloc] init];
    self.placeAnnotation = [[MKPointAnnotation alloc] init];
    
    self.geoCoder = [[CLGeocoder alloc] init];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.viewDetailPlace addGestureRecognizer:singleFingerTap];
    [self dissableAllButtons];
    [self stumblRounds];
    [self initializatSideBar];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(successfullyRetrievedObjects:)
               name:RCRadiusDidChangeNotification
             object:nil];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    [self currentLocation];
}

# pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
   
    if (_myLocation == NO) {
        [self cameraPosition];
        _myLocation = YES;
        
        for (UIButton* button in placeButtons) {
            button.enabled = YES;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
   
    if (self.myCyrrentCoordinateAnnotation.coordinate.latitude == view.annotation.coordinate.latitude && self.myCyrrentCoordinateAnnotation.coordinate.longitude == view.annotation.coordinate.longitude) {
        NSLog(@"test");
    } else {
        
        RCPlace* place = self.randomPlace;
        _detailView = [[RCDetailInfoPopupView loadUserInfoView]initWithPlace:place namePlace:place.name addressPlace:place.address];
       
        self.viewDetailPlace.hidden = NO;
        [self.viewDetailPlace addSubview:_detailView];
        [self.viewDetailPlace setFrame:self.detailView.frame];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
  
    [self.detailView removeFromSuperview];
    self.viewDetailPlace.hidden = YES;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 5.f;
        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
        return renderer;
        
    } else {

    } return nil;
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString* identifier = @"Annotation";
    
    MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
   
    if (!pin) {
        
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
    } else {
        pin.annotation = annotation;
    }
    
    return pin;
}

# pragma mark - Actions


- (IBAction) choosePlaceType:(UIButton*)sender {
    
    for (UIButton* button in placeButtons) {
        button.selected = NO;
    }
    
    if (sender.selected == YES) {
        sender.selected = NO;
    } else {
        sender.selected = YES;
    }
   
    [myMapView removeAnnotation:self.placeAnnotation];
    //[myMapView removeAnnotations:myMapView.annotations];
    [myMapView removeOverlays:[myMapView overlays]];

    NSArray* arrayTypePlace = @[@"cafe", @"fastfood", @"bar", @"restaurant"];
   
    [self getPlaceFromServerWithType:[arrayTypePlace objectAtIndex:sender.tag]];
    self.indexTapButton = sender.tag;
    stumblButton.enabled = YES;
}

- (IBAction)setRouteToPlace:(UIButton *)sender {
 
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    double delayInSeconds = 1.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
     });
    
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
    
    [myMapView removeAnnotation:self.placeAnnotation];
   // [myMapView removeAnnotations:myMapView.annotations];
    [myMapView removeOverlays:[myMapView overlays]];

    if ([self.arrayWithPlaces count] == 0) {
        [self showAlertWithTitle:@"Please change a distance" andMessage:@"There are not establishments in this distance"];
    
    } else {
        
    MKPointAnnotation* annotation = [self createRandomAnnotation];
    
    [myMapView addAnnotation:annotation];
    
    [self createRoutToAnnotation:annotation];
    [self ShowAllAnnotation];
    }
    
}

#pragma mark - Api

- (void) getPlaceFromServerWithType:(NSString*) type {
  
    myMapView.showsUserLocation = YES;
    myMapView.showsBuildings = YES;
    
    if (self.myCyrrentCoordinateAnnotation.coordinate.longitude == 0 && self.myCyrrentCoordinateAnnotation.coordinate.latitude == 0) {
        
        CLLocationCoordinate2D myLocationCoordinate = CLLocationCoordinate2DMake (myMapView.userLocation.coordinate.latitude, myMapView.userLocation.coordinate.longitude);
        
        NSLog(@"%f", myLocationCoordinate.longitude);
        
        self.myCyrrentCoordinateAnnotation.coordinate = myLocationCoordinate;
    }
    
    CLLocationCoordinate2D myLocation = self.myCyrrentCoordinateAnnotation.coordinate;///
    
    if (self.distanceRange.length == 0) {
        self.distanceRange = @"10";
    }
    
    [[RCServerManager sharedManager]
     getPlacesNearMyLocation:myLocation
     WithType:type
     WithRadius:self.distanceRange
     OnSuccess:^(NSArray *places) {
         self.arrayWithPlaces = places;
     }
     OnFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }
     ];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"setRandomPlace"]) {
        RCDetailViewController *detail = [segue destinationViewController];

       [detail setPlace:sender];
    }
}

#pragma mark - Private Methods

- (IBAction)foundTap:(UITapGestureRecognizer *)recognizer {
    
    self.informationLabel.hidden = YES;

        [myMapView removeOverlays:[myMapView overlays]];
        [myMapView removeAnnotations:myMapView.annotations];
        
        CGPoint point = [recognizer locationInView:myMapView];
        CLLocationCoordinate2D tapPoint = [myMapView convertPoint:point toCoordinateFromView:self.view];
        
        self.myCyrrentCoordinateAnnotation.coordinate = tapPoint;
        
        MKPointAnnotation *myNewLocation = [[MKPointAnnotation alloc] init];
        
        myNewLocation.coordinate = tapPoint;
        
        [myMapView addAnnotation:myNewLocation];

        [myMapView removeGestureRecognizer:recognizer];
}

- (void) successfullyRetrievedObjects:(NSNotification*) notification {
    NSString* radius = [notification.userInfo objectForKey:RCRadiusDidChangeInfoKey];
    self.distanceRange = radius;
}

- (void) stumblRounds {
    
    [stumblButton.layer setCornerRadius:5.0];
    [stumblButton.layer setMasksToBounds:YES];
    [stumblButton.layer setBorderColor:[UIColor colorWithRed:164.0f/255.0f green:22.0f/255.0f blue:35.0f/255.0f alpha:1.0f].CGColor];
    [stumblButton.layer setBorderWidth:1.0];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"setRandomPlace" sender:self.randomPlace];
}

- (MKPointAnnotation*) createRandomAnnotation {
    
    int count = (int) [self.arrayWithPlaces count];
    self.randomIndexPlace = arc4random_uniform(count);
    
    RCPlace* place = [self.arrayWithPlaces objectAtIndex:self.randomIndexPlace];
    self.randomPlace = place;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    
    CLLocationCoordinate2D locationPlace = CLLocationCoordinate2DMake ([place.coordinatePlaceLat doubleValue], [place.coordinatePlaceLng doubleValue]);
    
    annotation.coordinate = locationPlace;
    annotation.title      = place.name;
    
    self.placeAnnotation = annotation;
    
    return annotation;
}

- (void) createRoutToAnnotation:(MKPointAnnotation*) annotation {
    
    CLLocationCoordinate2D locationPlace = CLLocationCoordinate2DMake (annotation.coordinate.latitude, annotation.coordinate.longitude);
    CLLocationCoordinate2D coordinateAnnotation = locationPlace;
    
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
    
    CLLocationCoordinate2D myLocationCoordinate = self.myCyrrentCoordinateAnnotation.coordinate;
    MKPlacemark* placemark2 = [[MKPlacemark alloc] initWithCoordinate:myLocationCoordinate addressDictionary:nil];

    request.source = [[MKMapItem alloc] initWithPlacemark:placemark2];
    
    MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:coordinateAnnotation addressDictionary:nil];
    
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    request.destination = destination;
    request.transportType = MKDirectionsTransportTypeWalking;
    request.requestsAlternateRoutes = YES;
    
    self.directions = [[MKDirections alloc] initWithRequest:request];
    
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            [self showAlertWithTitle:@"Error" andMessage:[error localizedDescription]];
        } else if ([response.routes count] == 0) {
            [self showAlertWithTitle:@"Error" andMessage:@"No routes found"];
        } else {
            
            [myMapView removeOverlays:[myMapView overlays]];
            
            NSMutableArray* array = [NSMutableArray array];
            
            for (MKRoute* route in response.routes) {
                [array addObject:route.polyline];
            }
            
            [myMapView addOverlays:array level:MKOverlayLevelAboveLabels];
        }
    }
    ];
}

- (void) currentLocation {
    
    myMapView.showsUserLocation = YES;
    myMapView.showsBuildings = YES;
    
    locatioManager = [CLLocationManager new];
    if ([locatioManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locatioManager requestWhenInUseAuthorization];
    }

    locatioManager.distanceFilter = kCLDistanceFilterNone;
    locatioManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locatioManager startUpdatingLocation];
    locatioManager.delegate = self;

}

- (void) cameraPosition {
    
    myMapView.showsUserLocation = YES;
    myMapView.showsBuildings = YES;

    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:myMapView.userLocation.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(myMapView.userLocation.coordinate.latitude, myMapView.userLocation.coordinate.longitude) eyeAltitude:10000];
    [myMapView setCamera:camera animated:YES];
    
}

- (void) ShowAllAnnotation {
    
    MKMapRect zoomRect = MKMapRectNull;
    
    NSMutableArray* arrayWithAnnotations = [[NSMutableArray alloc] init];
    
    [arrayWithAnnotations addObject:self.myCyrrentCoordinateAnnotation];
    [arrayWithAnnotations addObject:self.placeAnnotation];
    
    if (self.myCyrrentCoordinateAnnotation.coordinate.latitude == myMapView.userLocation.coordinate.latitude && self.myCyrrentCoordinateAnnotation.coordinate.longitude == myMapView.userLocation.coordinate.longitude) {
        for (id <MKAnnotation> annotation in myMapView.annotations) {
         
            CLLocationCoordinate2D location = annotation.coordinate;
            
            MKMapPoint center = MKMapPointForCoordinate(location);
            
            static double delta = 8000;
            
            MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
            
            zoomRect = MKMapRectUnion(zoomRect, rect);
        }
        
    } else {
        
    for (id <MKAnnotation> annotation in arrayWithAnnotations) {

        CLLocationCoordinate2D location = annotation.coordinate;
        
        MKMapPoint center = MKMapPointForCoordinate(location);
        
        static double delta = 8000;
        
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
}
    
    zoomRect = [myMapView mapRectThatFits:zoomRect];
    
    [myMapView setVisibleMapRect:zoomRect
                     edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                        animated:YES];
}

- (void) showAlertWithTitle:(NSString*) title andMessage:(NSString*) message {
    [[[UIAlertView alloc]
      initWithTitle:title
      message:message
      delegate:nil
      cancelButtonTitle:@"OK"
      otherButtonTitles:nil] show];
}

- (void) dissableAllButtons {
    for (UIButton* button in placeButtons)  {
        button.selected = NO;
    }
    stumblButton.enabled = NO;
}

#pragma mark - SideBar

- (void) initializatSideBar {
    
    // Create Right SideBar
    self.rightSideBar = [[CDRTranslucentSideBar alloc] initWithDirectionFromRight:YES];
    self.rightSideBar.delegate = self;
    
    // Add PanGesture to Show SideBar by PanGesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    // Create Content of SideBar
    UITableView *tableView = [[UITableView alloc] init];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
    v.backgroundColor = [UIColor clearColor];
    [tableView setTableHeaderView:v];
    [tableView setTableFooterView:v];
    
    tableView.dataSource = self;
    tableView.delegate = self;

    [self.rightSideBar setContentViewInSideBar:tableView];
}

- (IBAction)OnRightSideBarButtonTapped:(id)sender {
    
    if (self.OnRightSideBBT == NO) {
        self.OnRightSideBBT = YES;
        [self.rightSideBar showInViewController:self];
    } else if (self.OnRightSideBBT == YES) {
        self.OnRightSideBBT = NO;
        [self.rightSideBar dismissAnimated:YES];
    }
    
}

#pragma mark - Gesture Handler

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
            self.rightSideBar.isCurrentPanGestureTarget = YES;
    }
    
    [self.rightSideBar handlePanGestureToShow:recognizer inView:self.view];
   
}

#pragma mark - CDRTranslucentSideBarDelegate

- (void)sideBar:(CDRTranslucentSideBar *)sideBar didAppear:(BOOL)animated {
           NSLog(@"Right SideBar did appear");
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar willAppear:(BOOL)animated {
   
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar didDisappear:(BOOL)animated {
   
    if (self.distanceRange.length == 0) {
        self.distanceRange = @"10";
    }
    NSArray* arrayTypePlace = @[@"cafe", @"fastfood", @"bar", @"restaurant"];
    NSString* type = [arrayTypePlace objectAtIndex:self.indexTapButton];
    [self getPlaceFromServerWithType:type];
}

- (void)sideBar:(CDRTranslucentSideBar *)sideBar willDisappear:(BOOL)animated {

        NSLog(@"Right SideBar will disappear");
}

#pragma mark - UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.row == 0) {
         return 83.5;
    }
    return 38;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        RCSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"changeRadius"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"changeRadius"];
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"changeRadius"];
            
            self.distanceRange = cell.distanceRange.text;
            
        }
        return cell;
        
    } else if (indexPath.row == 1) {
        RCSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChangeLocation"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"SettingsTableViewCell" bundle:nil] forCellReuseIdentifier:@"settingsCell"];
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
            cell.nameSettings.text = @"Change Location";

        }
        return cell;
        
    } else if (indexPath.row == 2) {
        
        RCSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyLocatin"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"SettingsTableViewCell" bundle:nil] forCellReuseIdentifier:@"settingsCell"];
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
            cell.nameSettings.text = @"My Location";
            
        }
        return cell;
    }
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        
        //self.myCyrrentCoordinateAnnotation.coordinate = myMapView.userLocation.coordinate;
        
        [myMapView removeAnnotations:myMapView.annotations];
        [myMapView removeOverlays:[myMapView overlays]];
        
        [self dissableAllButtons];
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        
        [myMapView addGestureRecognizer:tapRecognizer];
        
        self.OnRightSideBBT = NO;
        [self.rightSideBar dismissAnimated:YES];
        self.informationLabel.hidden = NO;
    }
    
    if (indexPath.row == 2) {
        
        self.informationLabel.hidden = YES;
        [myMapView removeAnnotations:myMapView.annotations];
        [myMapView removeOverlays:[myMapView overlays]];
        [myMapView removeGestureRecognizer:tapRecognizer];
        
        [self dissableAllButtons];
        
        self.myCyrrentCoordinateAnnotation.coordinate = myMapView.userLocation.coordinate;
        
        self.OnRightSideBBT = NO;
        [self.rightSideBar dismissAnimated:YES];
        [self cameraPosition];
        
    }
}

@end
