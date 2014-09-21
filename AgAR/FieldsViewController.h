//
//  FieldsViewController.h
//  AgAR
//
//  Created by Jingqing Ren on 9/6/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SideBarViewController.h"

@class Farm;
@class Field;
@class Polyline;
@interface FieldsViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate, SideBarDelegate>
{
    NSFetchedResultsController *fieldFetcher;
    NSFetchedResultsController *farmFetcher;

    IBOutlet UIView *viewBG;
    IBOutlet MKMapView *mapView;
    IBOutlet UILabel *labelFarm;
    IBOutlet UIImageView *centerPin;

    IBOutlet UIButton *buttonCreate;
    IBOutlet UIButton *buttonCancel;
    IBOutlet UIButton *buttonCheck;
    IBOutlet UIButton *buttonDraw;
    IBOutlet UIButton *buttonTrash;
    IBOutlet UIButton *buttonSidebar;

    BOOL shouldCenterOnUser;
    BOOL isEditingFarm;
    NSString *farmName;
    BOOL isAddingField; // creating a new field
    BOOL isEditingField; // moving the current selected field

    CLLocationCoordinate2D fieldCoordinates[1000];
    int fieldCoordinateCount;

    BOOL isDrawingMode;
    BOOL isDraggingPin;

    Farm *currentFarm;
    Field *currentField; // being edited for coordinates

    NSMutableArray *annotations;

    SideBarViewController *sidebar;
}

@property (nonatomic, readonly) Farm *currentFarm;

-(IBAction)didClickButton:(id)sender;
@end
