//
//  FieldsViewController.m
//  AgAR
//
//  Created by Jingqing Ren on 9/6/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "FieldsViewController.h"
#import "Area.h"
#import "Field.h"
#import "Farm.h"
#import "Polyline+TransformableAttributes.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "Annotation.h"
#import "MKPolyline+Info.h"

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

    [centerPin setHidden:YES];
    [self hideAllButtons];
    [buttonCreate setHidden:NO];

    annotations = [NSMutableArray array];

    if (self.currentFarm) {
        [self setCurrentFarm:currentFarm]; // forces reload
        labelFarm.text = currentFarm.name;
    }
    else {
        shouldCenterOnUser = YES;
        labelFarm.text = @"No farm selected";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hideAllButtons {
    [buttonCreate setHidden:YES];
    [buttonCheck setHidden:YES];
    [buttonCancel setHidden:YES];
    [buttonDraw setHidden:YES];
    [buttonTrash setHidden:YES];
}

-(Farm *)newFarm {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Farm" inManagedObjectContext:_appDelegate.managedObjectContext];
    return (Farm *)object;
}

-(Field *)newField {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Field" inManagedObjectContext:_appDelegate.managedObjectContext];
    return (Field *)object;
}

-(Polyline *)newPolyline {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Polyline" inManagedObjectContext:_appDelegate.managedObjectContext];
    return (Polyline *)object;
}

#pragma mark custom setter/getter for Farm
-(Farm *)currentFarm {
    if (currentFarm)
        return currentFarm;

    NSArray *farms = [[self farmFetcher] fetchedObjects];
    if ([farms count]) {
        currentFarm = [farms firstObject];
    }

    return currentFarm;
}
-(void)setCurrentFarm:(Farm *)_currentFarm {
    currentFarm = _currentFarm;

    fieldFetcher = nil;
    [fieldFetcher performFetch:nil];

    // jumps to middle of farm
    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake([self.currentFarm.latitude doubleValue], [self.currentFarm.longitude doubleValue]);
    [self centerOnCoordinate:currentLocation];

    // add farm pin
    [self addAnnotationForFarm:self.currentFarm];

    [self drawFields];
    [self reloadMap];
}

-(void)reloadMap {
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];

    for (Annotation *annotation in annotations) {
        if (annotation.type == AnnotationTypeCurrentFieldCenter || annotation.type == AnnotationTypeOtherFieldCenter) {
            [self updateStatusForAnnotation:annotation];
            Field *field = annotation.object;
            [self addBoundaryForField:field];
        }

        [mapView addAnnotation:annotation];
    }

    if (isEditingField) {
        // jumps to middle of field
        CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake([currentField.latitude doubleValue], [currentField.longitude doubleValue]);
        [self centerOnCoordinate:currentLocation];
    }
}

-(void)addAnnotationForFarm:(Farm *)farm {
    CLLocationCoordinate2D farmCenter = CLLocationCoordinate2DMake([self.currentFarm.latitude doubleValue], [self.currentFarm.longitude doubleValue]);
    Annotation *farmAnnotation = [[Annotation alloc] init];
    farmAnnotation.type = AnnotationTypeCurrentFarmCenter;
    [farmAnnotation setCoordinate:farmCenter];
    farmAnnotation.titleString = @"Farm center";
    farmAnnotation.object = currentFarm;
    [mapView addAnnotation:farmAnnotation];

    [annotations addObject:farmAnnotation];
}

-(void)addAnnotationForField:(Field *)field {
    // draw field pin
    CLLocationCoordinate2D fieldCenter = CLLocationCoordinate2DMake([field.latitude doubleValue], [field.longitude doubleValue]);
    Annotation *fieldAnnotation = [[Annotation alloc] init];
    fieldAnnotation.coordinate = fieldCenter;
    fieldAnnotation.object = field;
    fieldAnnotation.type = AnnotationTypeOtherFieldCenter;
    [mapView addAnnotation:fieldAnnotation];

    [annotations addObject:fieldAnnotation];

    // update annotation status and title
    [self updateStatusForAnnotation:fieldAnnotation];
}

-(void)updateStatusForAnnotation:(Annotation *)annotation {
    if (annotation.type == AnnotationTypeCurrentFarmCenter) {
        return;
    }

    // changes the display color and label based on current map editing status
    if (!currentField) {
        annotation.type = AnnotationTypeOtherFieldCenter;
        annotation.titleString = @"Field center";
    }
    else {
        if (annotation.object == currentField) {
            annotation.type = AnnotationTypeCurrentFieldCenter;
            annotation.titleString = @"Current field";
        }
        else {
            annotation.type = AnnotationTypeOtherFieldCenter;
            annotation.titleString = @"";
        }
    }
}

-(void)addBoundaryForField:(Field *)field {
    // draw field boundary
    if (field.boundary) {
        MKPolyline *line = [field.boundary polyLine];
        if (isEditingField) {
            if (isDrawingMode)
                [line setStatus:BoundaryStatusDimmed];
            else {
                if (field == currentField) {
                    [line setStatus:BoundaryStatusNew];
                }
                else {
                    [line setStatus:BoundaryStatusNormal];
                }
            }
        }
        [mapView addOverlay:line];
    }
}

-(void)drawFields {
    NSArray *fields = [[self fieldFetcher] fetchedObjects];
    for (Field *field in fields) {
        [self addAnnotationForField:field];
        [self addBoundaryForField:field];
    }
}

#pragma mark editing
-(IBAction)didClickButton:(id)sender {
    if (sender == buttonCreate) {
        [self didClickEdit];
    }
    else if (sender == buttonCheck) {
        [self didClickCheck];
    }
    else if (sender == buttonCancel) {
        [self didClickCancel];
    }
    else if (sender == buttonTrash) {
        [self didClickTrash];
    }
}

-(void)didClickEdit {
    if (!isEditingField && !isEditingFarm) {
        // for now, use actionsheet
        if ([[[self farmFetcher] fetchedObjects] count] == 0) {
            [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"Add a farm"] showInView:_appDelegate.window onDismiss:^(int buttonIndex) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter farm name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create farm", nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                alert.tag = 2;
                [alert show];
            } onCancel:^{

            }];
        }
        else /* if ([[[self fieldFetcher] fetchedObjects] count] == 0) */ {
            [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[@"Edit farm", @"Add a field"] showInView:_appDelegate.window onDismiss:^(int buttonIndex) {
                if (buttonIndex == 0) {
                    // update farm
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter farm name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update farm", nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alert.tag = 1;
                    [alert show];
                }
                else if (buttonIndex == 1) {
                    // add a field
                    isEditingField = YES;
                    [self hideAllButtons];
                    [centerPin setHidden:NO];
                    [buttonCheck setHidden:NO];
                    [buttonCancel setHidden:NO];
                    [UIAlertView alertViewWithTitle:@"Set the location of your field" message:@"Move the map until the blue pin matches the center of your field, then click the check mark"];
                }
            } onCancel:^{
                
            }];
        }
    }
}

-(void)didClickCheck {
    if (isEditingField || isEditingFarm) {
        if (isEditingField) {
            if (!isDrawingMode) {
                // field center set, start creating boundary
                [self addField];
            }
            else {
                // boundary set, stop drawing
                isDrawingMode = NO;
                isEditingField = NO;

                [centerPin setHidden:YES];
                [self hideAllButtons];
                [buttonCreate setHidden:NO];
                for (UIGestureRecognizer *gesture in mapView.gestureRecognizers)
                    [mapView removeGestureRecognizer:gesture];

                if (!currentField.boundary) {
                    currentField.boundary = [self newPolyline];
                }
                // close the loop
                if (fieldCoordinateCount > 0) {
                    fieldCoordinates[fieldCoordinateCount++] = fieldCoordinates[0];
                }
                [currentField.boundary setCoordinatesFromCoordinates:fieldCoordinates totalPoints:fieldCoordinateCount];
                [_appDelegate saveContext];

                currentField = nil;
                [self.fieldFetcher performFetch:nil];
                [self reloadMap];
            }
        }
        else if (isEditingFarm) {
            // end edit
            [centerPin setHidden:YES];
            [self hideAllButtons];
            [buttonCreate setHidden:NO];

            isEditingFarm = NO;
            [self addFarm:farmName];
        }
    }
}

-(void)didClickCancel {
    if (isEditingFarm || isEditingField) {
        // cancel edit
        [centerPin setHidden:YES];
        [self hideAllButtons];
        [buttonCreate setHidden:NO];

        isEditingField = NO;
        isEditingFarm = NO;
        isDrawingMode = NO;

        for (UIGestureRecognizer *gesture in mapView.gestureRecognizers) {
            [mapView removeGestureRecognizer: gesture];
        }
        fieldCoordinateCount = 0;

        currentField = nil;
        [self.fieldFetcher performFetch:nil];

        [self reloadMap];
    }
}

-(void)didClickTrash {
    if (isEditingField) {
        // delete current field
        [UIAlertView alertViewWithTitle:@"Delete field" message:@"Are you sure you want to delete the current field?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Delete"] onDismiss:^(int buttonIndex) {

            for (Annotation *a in annotations) {
                if (a.object == currentField)
                    [annotations removeObject:a];
            }
            if (currentField.boundary) {
                [_appDelegate.managedObjectContext deleteObject:currentField.boundary];
            }
            [_appDelegate.managedObjectContext deleteObject:currentField];
            [_appDelegate.managedObjectContext save:nil];
            
            [[self fieldFetcher] performFetch:nil];

            currentField = nil;
            isEditingField = NO;
            [self hideAllButtons];
            [buttonCreate setHidden:NO];
            [self reloadMap];
        } onCancel:nil];
    }
}

-(void)addFarm:(NSString *)name {
    if (name.length == 0) {
        [UIAlertView alertViewWithTitle:@"Invalid farm name" message:@"You must enter a name for your new farm."];
        return;
    }

    Farm *farm = [self newFarm];
    farm.name = name;

    CLLocationCoordinate2D currentCoordinate = [mapView centerCoordinate];;
    farm.latitude = @(currentCoordinate.latitude);
    farm.longitude = @(currentCoordinate.longitude);

    [_appDelegate.managedObjectContext save:nil];

    [[self farmFetcher] performFetch:nil];
    [self setCurrentFarm:farm];
}

-(void)addField {
    if (!self.currentFarm) {
        [UIAlertView alertViewWithTitle:@"Invalid farm" message:@"Uh oh, for some reason there is no current farm. Please add a farm first."];
        return;
    }

    currentField = [self newField];

    CLLocationCoordinate2D currentCoordinate = [mapView centerCoordinate];
    currentField.latitude = @(currentCoordinate.latitude);
    currentField.longitude = @(currentCoordinate.longitude);
    currentField.farm = [self currentFarm];
    currentField.farmName = self.currentFarm.name;

    [_appDelegate.managedObjectContext save:nil];

    [UIAlertView alertViewWithTitle:@"Add field boundary" message:@"Use the mouse to click on points along your field's boundary. Click the check mark to save."];
    isDrawingMode = YES;
    [centerPin setHidden:YES];
    [[self fieldFetcher] performFetch:nil];

    [self addAnnotationForField:currentField];
    [self reloadMap];

    // start drawing
    // todo: make mouse look different to look like a boundary drawing
    UITapGestureRecognizer *maptap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapGesture:)];
    [mapView addGestureRecognizer:maptap];
    fieldCoordinateCount = 0;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // cancel
        return;
    }

    if (alertView.tag == 1) {
        // edit farm name
        NSString *name = [[alertView textFieldAtIndex:0] text];
        if (name.length == 0) {
            [UIAlertView alertViewWithTitle:@"Invalid farm name" message:@"You must enter a valid name."];
            return;
        }
        currentFarm.name = name;
        [_appDelegate saveContext];
    }
    if (alertView.tag == 2) {
        // create new farm
        // edit farm name
        NSString *name = [[alertView textFieldAtIndex:0] text];
        if (name.length == 0) {
            [UIAlertView alertViewWithTitle:@"Invalid farm name" message:@"You must enter a valid name."];
            return;
        }
        isEditingFarm = YES;
        farmName = name;
        [self hideAllButtons];
        [centerPin setHidden:NO];
        [buttonCheck setHidden:NO];
        [UIAlertView alertViewWithTitle:@"Set the location of your farm" message:@"Move the map until the blue pin matches the center of your farm, then click the check mark"];
    }
}

#pragma mark MKMapViewDelegate
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = (MKPolyline *)overlay;
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.lineWidth = 4;
        if ([polyline status] == BoundaryStatusNormal)
            renderer.strokeColor = [UIColor redColor];
        else if ([polyline status] == BoundaryStatusNew)
            renderer.strokeColor = [UIColor greenColor];
        else if ([polyline status] == BoundaryStatusDimmed)
            renderer.strokeColor = [UIColor grayColor];

        renderer.lineCap = kCGLineCapRound;
        return renderer;
    }
    return nil;
}

-(void) mapView:(MKMapView *)_mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (shouldCenterOnUser) {
        [self centerOnCoordinate:mapView.userLocation.coordinate];
    }
}

-(void)centerOnCoordinate:(CLLocationCoordinate2D)coordinate{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 0.05*METERS_PER_MILE, 0.05*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[Annotation class]]) {
        Annotation *a = (Annotation *)annotation;

        MKPinAnnotationView * annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
            label.font = FONT_REGULAR(12);
            label.textAlignment = NSTextAlignmentCenter;
            label.center = CGPointMake(annotationView.frame.size.width/2, annotationView.frame.size.height+5);
            [label setTag:1];
            [annotationView addSubview:label];
        }
        annotationView.annotation = a;
        annotationView.draggable = NO;
        annotationView.enabled = YES;
        annotationView.canShowCallout = NO;
        UILabel *label = (UILabel *)[annotationView viewWithTag:1];
        if (a.type == AnnotationTypeCurrentFarmCenter) {
            ((MKPinAnnotationView*)annotationView).pinColor = MKPinAnnotationColorPurple;
            label.text = @"Farm center";
        }
        else if (a.type == AnnotationTypeCurrentFieldCenter) {
            ((MKPinAnnotationView*)annotationView).pinColor = MKPinAnnotationColorRed;
            if (a.titleString)
                label.text = a.titleString;
        }
        else if (a.type == AnnotationTypeOtherFieldCenter) {
            ((MKPinAnnotationView*)annotationView).pinColor = MKPinAnnotationColorGreen;
            if (a.titleString)
                label.text = a.titleString;
        }
        return annotationView;
    }
    return nil;
}

-(void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    /*
     if (view.annotation == gymCenter) {
     view.selected = YES;
     }
     */
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    Annotation *annotation = view.annotation;
    [mapView deselectAnnotation:annotation animated:NO];

    if (isDrawingMode) {
        return;
    }
    if (annotation.type == AnnotationTypeCurrentFarmCenter) {
        currentField = nil;
        isEditingField = NO;

        [self hideAllButtons];
        [buttonCreate setHidden:NO];

        [self reloadMap];
        return;
    }

    if (!currentField) {
        if (annotation.type == AnnotationTypeOtherFieldCenter) {
            // start editing field
            isEditingField = YES;
            isDrawingMode = NO;
            currentField = annotation.object;
            [self reloadMap];

            [self hideAllButtons];
            [buttonDraw setHidden:NO];
            [buttonTrash setHidden:NO];
        }
    }
    else {
        if (annotation.object == currentField) {
            // cancel editing field
            isEditingField = NO;
            isDrawingMode = NO;
            currentField = nil;

            [self hideAllButtons];
            [buttonCreate setHidden:NO];
            [self reloadMap];
        }
        else {
            // switch current field
            currentField = annotation.object;
            [self reloadMap];
        }
    }
}

#pragma mark Fetcher
-(NSFetchedResultsController *)fieldFetcher {
    if (fieldFetcher)
        return fieldFetcher;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Field"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"farmName = %@", self.currentFarm.name];
    [request setPredicate:predicate];

    fieldFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [fieldFetcher performFetch:nil];

    return fieldFetcher;
}

-(NSFetchedResultsController *)farmFetcher {
    if (farmFetcher)
        return farmFetcher;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Farm"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor1]];

    farmFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [farmFetcher performFetch:nil];

    return farmFetcher;
}

#pragma mark Gesture
-(void)handleMapGesture:(UITapGestureRecognizer *)gesture {
    CGPoint touch = [gesture locationInView:mapView];
    CLLocationCoordinate2D coord = [mapView convertPoint:touch toCoordinateFromView:mapView];
    fieldCoordinates[fieldCoordinateCount++] = coord;
    if (fieldCoordinateCount == 1) {
        // add a second point to show the first point as a dot
        fieldCoordinates[fieldCoordinateCount++] = coord;
    }

    [mapView removeOverlays:mapView.overlays];
    [self drawFields];

    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:fieldCoordinates count:fieldCoordinateCount];
    [polyline setStatus:BoundaryStatusNew];
    [mapView addOverlay:polyline];
}
@end
