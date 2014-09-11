//
//  FieldsViewController.h
//  AgAR
//
//  Created by Jingqing Ren on 9/6/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FieldsViewController : UIViewController <MKMapViewDelegate>
{
    NSFetchedResultsController *fieldFetcher;
    IBOutlet MKMapView *mapView;

    BOOL shouldCenterOnUser;
}

@end
