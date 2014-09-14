//
//  FieldsViewController.h
//  AgAR
//
//  Created by Jingqing Ren on 9/6/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Farm;
@class Field;
@class Polyline;
@interface FieldsViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate>
{
    NSFetchedResultsController *fieldFetcher;
    NSFetchedResultsController *farmFetcher;

    IBOutlet MKMapView *mapView;
    IBOutlet UILabel *labelFarm;
    IBOutlet UIImageView *centerPin;

    IBOutlet UIButton *buttonEdit;
    IBOutlet UIButton *buttonCancel;
    IBOutlet UIButton *buttonCheck;
    IBOutlet UIButton *buttonDraw;
    IBOutlet UIButton *buttonTrash;

    BOOL shouldCenterOnUser;
    BOOL isEditingFarm;
    NSString *farmName;
    BOOL isEditingField;

    CLLocationCoordinate2D fieldCoordinates[1000];
    int fieldCoordinateCount;

    BOOL isDrawingMode;

    Farm *currentFarm;
    Field *currentField; // being edited for coordinates

    NSMutableArray *annotations;
}

@property (nonatomic, readonly) Farm *currentFarm;

-(IBAction)didClickButton:(id)sender;
@end
