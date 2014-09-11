//
//  FieldsViewController.m
//  AgAR
//
//  Created by Jingqing Ren on 9/6/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "FieldsViewController.h"
#import "Field.h"
#import "Farm.h"
#import "Polyline+TransformableAttributes.h"

@interface FieldsViewController ()

@end

@implementation FieldsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
#if TESTING && 0
    NSArray *objs =  [[self fieldFetcher] fetchedObjects];
    if ([objs count] == 0) {
        for (int j = 0; j < 3; j++) {
            Farm *farm = [self newFarm];
            farm.name = [NSString stringWithFormat:@"Farm %d", j];
            for (int i=0; i<5;i++) {
                Field *field = [self newField];
                field.name = [NSString stringWithFormat:@"Field %d", i];
                field.farm = farm;
                field.farmName = farm.name;
            }
        }
        [_appDelegate saveContext];
        [[self fieldFetcher] performFetch:nil];
    }
#endif

    shouldCenterOnUser = YES;

    [self reloadMap];
}

-(Farm *)newFarm {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Farm" inManagedObjectContext:_appDelegate.managedObjectContext];
    return (Farm *)object;
}

-(Field *)newField {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Field" inManagedObjectContext:_appDelegate.managedObjectContext];
    return (Field *)object;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSFetchedResultsController *)fieldFetcher {
    if (fieldFetcher)
        return fieldFetcher;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Field"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"farmName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    
    fieldFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:@"farmName" cacheName:nil];
    [fieldFetcher performFetch:nil];
    
    return fieldFetcher;
}

-(void)reloadMap {
    Field *field = [[[self fieldFetcher] fetchedObjects] firstObject];
    if (field.boundary) {
        MKPolyline *line = [field.boundary polyLine];
        [mapView addOverlay:line];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 1.0;

    return polylineView;
}

#pragma mark MKMapViewDelegate
-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (shouldCenterOnUser) {
        [self centerOnUser];
    }
}

-(void)centerOnUser{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 0.05*METERS_PER_MILE, 0.05*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
}

-(void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    /*
     if (view.annotation == gymCenter) {
     view.selected = YES;
     }
     */
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view   {
    /*
     if (view.annotation != gymCenter) {
     view.selected = NO;
     annotationView.selected = YES;
     }
     */
}

@end
