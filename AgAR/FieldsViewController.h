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
@interface FieldsViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate>
{
    NSFetchedResultsController *fieldFetcher;
    NSFetchedResultsController *farmFetcher;

    IBOutlet MKMapView *mapView;
    IBOutlet UILabel *labelFarm;
    IBOutlet UIButton *buttonEdit;

    BOOL shouldCenterOnUser;
    BOOL isEditMode;

    Farm *currentFarm;
}
@property (nonatomic, readonly) Farm *currentFarm;

-(IBAction)didClickEdit:(id)sender;

@end
