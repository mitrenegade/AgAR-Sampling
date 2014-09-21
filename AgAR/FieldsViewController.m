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
#import "ZSPinAnnotationView.h"
#import "Polyline+Helper.h"

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

    /*
    sidebar = [_storyboard instantiateViewControllerWithIdentifier:@"SideBarViewController"];
    CGRect frame = CGRectMake(320-SIDEBAR_WIDTH, 0, SIDEBAR_WIDTH, self.view.frame.size.height);
    sidebar.view.frame = frame;
    sidebar.delegate = self;
    [self.view.superview addSubview:sidebar.view];
     */

    UITapGestureRecognizer *maptap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [mapView addGestureRecognizer:maptap];
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
    [self centerOnCoordinate:currentLocation resize:YES];

    [self reloadMap];
}

-(void)reloadMap {
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];

    [annotations removeAllObjects];
    [self addAnnotationForFarm:self.currentFarm];
    [self drawFields];

    if (isEditingField && currentField) {
        // jumps to middle of field
        CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake([currentField.latitude doubleValue], [currentField.longitude doubleValue]);
        [self centerOnCoordinate:currentLocation resize:NO];
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
    Annotation *fieldAnnotation;
    for (Annotation *a in annotations) {
        if (a.object == field) {
            fieldAnnotation = a;
        }
    }
    if (!fieldAnnotation) {
        fieldAnnotation = [[Annotation alloc] init];
        [annotations addObject:fieldAnnotation];
    }

    fieldAnnotation.coordinate = fieldCenter;
    fieldAnnotation.object = field;
    fieldAnnotation.type = AnnotationTypeOtherFieldCenter;
    [mapView addAnnotation:fieldAnnotation];

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
        if (currentField) {
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
        if (field == currentField && isEditingField) {
            // currentField is replaced by a floating marker
            continue;
        }
        [self addAnnotationForField:field];
        [self addBoundaryForField:field];
    }
}

-(IBAction)didClickButton:(id)sender {
    if (sender == buttonCheck) {
        [self didClickCheck];
    }
    else if (sender == buttonCancel) {
        [self didClickCancel];
    }
    else if (sender == buttonSidebar) {
        [self toggleSidebar];
    }
}

-(void)didClickCheck {
    if (isAddingField) {
        // field center set, start creating boundary
        [self updateField:YES];
        [centerPin setHidden:YES];
        isAddingField = NO;

        [self addBoundary];
    }
    else if (currentField) {
        if (isEditingField) {
            [self hideAllButtons];
            [centerPin setHidden:YES];
            [self updateField:NO];

            isEditingField = NO;
            currentField = nil;
            [self reloadMap];
        }
        else if (isDrawingMode) {
            // boundary set, stop drawing
            isDrawingMode = NO;
            isEditingField = NO;

            [centerPin setHidden:YES];
            [self hideAllButtons];
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
        [self createFarm:farmName];
    }
}

-(void)didClickCancel {
    // cancel edit
    [centerPin setHidden:YES];
    [self hideAllButtons];
    [buttonCreate setHidden:NO];

    isEditingField = NO;
    isAddingField = NO;
    isEditingFarm = NO;
    isDrawingMode = NO;
    isDraggingPin = NO;

    fieldCoordinateCount = 0;

    currentField = nil;
    [self.fieldFetcher performFetch:nil];

    [self reloadMap];
}

-(void)didClickTrash {
    if (isEditingField) {
        // delete current field
        [UIAlertView alertViewWithTitle:@"Delete field" message:@"Are you sure you want to delete the current field?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Delete"] onDismiss:^(int buttonIndex) {

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

-(void)didClickDraw {
    if (isEditingField) {
        if (currentField.boundary) {
            [UIAlertView alertViewWithTitle:@"Redraw boundary" message:@"Are you sure you want to delete the current field's boundary and redraw it?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Redraw"] onDismiss:^(int buttonIndex) {
                [_appDelegate.managedObjectContext deleteObject:currentField.boundary];
                currentField.boundary = nil;
                [self reloadMap];
                [self addBoundary];
            } onCancel:nil];
        }
        else {
            [self addBoundary];
        }
    }
}

-(void)createFarm:(NSString *)name {
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

-(void)updateField:(BOOL)newField {
    if (!self.currentFarm) {
        [UIAlertView alertViewWithTitle:@"Invalid farm" message:@"Uh oh, for some reason there is no current farm. Please add a farm first."];
        return;
    }

    CLLocationCoordinate2D currentCoordinate = [mapView centerCoordinate];
    CLLocationCoordinate2D oldCoordinate;
    if (newField) {
        currentField = [self newField];
        oldCoordinate = currentCoordinate;
    }
    else {
        oldCoordinate = CLLocationCoordinate2DMake([currentField.latitude floatValue], [currentField.longitude floatValue]);
        float latChange = currentCoordinate.latitude - oldCoordinate.latitude;
        float lonChange = currentCoordinate.longitude - oldCoordinate.longitude;
        if (currentField.boundary) {
            [currentField.boundary shiftCoordinatesByLatitude:latChange longitude:lonChange];
        }
    }

    currentField.latitude = @(currentCoordinate.latitude);
    currentField.longitude = @(currentCoordinate.longitude);
    currentField.farm = [self currentFarm];
    currentField.farmName = self.currentFarm.name;

    [_appDelegate.managedObjectContext save:nil];
    [[self fieldFetcher] performFetch:nil];
}

#pragma mark MKMapViewDelegate
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = (MKPolyline *)overlay;
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.lineWidth = 4;
        if ([polyline status] == BoundaryStatusNormal)
            renderer.strokeColor = BoundaryColorNormal;
        else if ([polyline status] == BoundaryStatusNew)
            renderer.strokeColor = BoundaryColorSelected;
        else if ([polyline status] == BoundaryStatusDimmed)
            renderer.strokeColor = BoundaryColorEditing;

        renderer.lineCap = kCGLineCapRound;
        return renderer;
    }
    return nil;
}

-(void) mapView:(MKMapView *)_mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (shouldCenterOnUser) {
        [self centerOnCoordinate:mapView.userLocation.coordinate resize:YES];
    }
}

-(void)centerOnCoordinate:(CLLocationCoordinate2D)coordinate resize:(BOOL)resize {
    MKCoordinateRegion viewRegion;
    MKCoordinateRegion adjustedRegion;
    if (resize) {
        viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 0.05*METERS_PER_MILE, 0.05*METERS_PER_MILE);
        adjustedRegion = [mapView regionThatFits:viewRegion];
        [mapView setRegion:adjustedRegion animated:YES];
    }
    else {
        [mapView setCenterCoordinate:coordinate];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[Annotation class]]) {
        Annotation *a = (Annotation *)annotation;

        ZSPinAnnotationView * annotationView = (ZSPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[ZSPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
            label.font = FONT_REGULAR(12);
            label.textAlignment = NSTextAlignmentCenter;
            [label setTag:1];
            [annotationView addSubview:label];
        }
        annotationView.annotation = a;
        annotationView.draggable = NO;
        annotationView.enabled = YES;
        annotationView.canShowCallout = NO;

        a.annotationView = annotationView;

        UILabel *label = (UILabel *)[annotationView viewWithTag:1];
        if (a.type == AnnotationTypeCurrentFarmCenter) {
            annotationView.annotationType = ZSPinAnnotationTypeStandard;
            annotationView.annotationColor = AnnotationColorCurrentFarm;
            if (isEditingField)
                annotationView.annotationColor = AnnotationColorDim;
            label.text = @"Farm center";
        }
        else if (a.type == AnnotationTypeCurrentFieldCenter) {
            annotationView.annotationType = ZSPinAnnotationTypeTag;
            annotationView.annotationColor = AnnotationColorCurrentField;
            if (a.titleString)
                label.text = a.titleString;
        }
        else if (a.type == AnnotationTypeOtherFieldCenter) {
            annotationView.annotationType = ZSPinAnnotationTypeStandard;
            annotationView.annotationColor = AnnotationColorOtherField;
            if (isEditingField)
                annotationView.annotationColor = AnnotationColorDim;
            if (a.titleString)
                label.text = a.titleString;
        }

        // must set label center last after view frame is set
        label.center = CGPointMake(annotationView.frame.size.width/2, annotationView.frame.size.height/2+15);
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
        [self didClickCancel];
        return;
    }

    isDrawingMode = NO;
    if (!currentField) {
        if (annotation.type == AnnotationTypeOtherFieldCenter) {
            // select field as current field
            currentField = annotation.object;
            [self reloadMap];
        }
    }
    else {
        if (annotation.object != currentField) {
            // switch current field
            currentField = annotation.object;
            [self reloadMap];
        }
        else {
            // second click on the current field centers it
            CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake([currentField.latitude doubleValue], [currentField.longitude doubleValue]);
            [self centerOnCoordinate:currentLocation resize:NO];
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
-(void)handleGesture:(UITapGestureRecognizer *)gesture {
    if (isDrawingMode) {
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
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SideBarSegue"]) {
        sidebar = (SideBarViewController *)[segue destinationViewController];
        [sidebar setupWithOptions:nil actions:nil];
        sidebar.delegate = self;
    }
}

#pragma mark sidebar
-(void)toggleSidebar {
    CGRect frame = viewBG.frame;
    if (frame.origin.x == 0) {
        frame.origin.x = -SIDEBAR_WIDTH;
        [self setupSidebar]; // setup sidebar
    }
    else {
        frame.origin.x = 0;
    }
    [UIView animateWithDuration:.25 animations:^{
        viewBG.frame = frame;
        [buttonSidebar setAlpha:(frame.origin.x==0)?1:0];
    } completion:^(BOOL finished) {
    }];
}

-(void)closeSidebar {
    [self toggleSidebar];
}

-(void)setupSidebar{
    if (!currentFarm) {
        [sidebar setupWithMode:SideBarModeEmpty];
    }
    else if (![currentFarm.fields count]) {
        [sidebar setupWithMode:SideBarModeFarmOnly];
    }
    else if (!currentField) {
        [sidebar setupWithMode:SideBarModeFieldUnselected];
    }
    else if (!currentField.boundary) {
        [sidebar setupWithMode:SideBarModeFieldSelected];
    }
    else if (currentField.boundary) { //(!currentField.grid) {
        [sidebar setupWithMode:SideBarModeBoundarySelected];
    }
    else {
        [sidebar setupWithMode:SideBarModeGridSelected];
    }
}

#pragma mark Sidebar delegate
-(void)addFarm {
    UIAlertView __block *alertView = [UIAlertView alertViewWithInputWithTitle:@"Please enter farm name" message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Create farm"] onDismiss:^(int buttonIndex) {
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
    } onCancel:nil];
}

-(void)editFarm {
    UIAlertView __block *alertView = [UIAlertView alertViewWithInputWithTitle:@"Please enter farm name" message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Create farm"] onDismiss:^(int buttonIndex) {
        // edit farm name
        NSString *name = [[alertView textFieldAtIndex:0] text];
        if (name.length == 0) {
            [UIAlertView alertViewWithTitle:@"Invalid farm name" message:@"You must enter a valid name."];
            return;
        }
        currentFarm.name = name;
        [_appDelegate saveContext];
    } onCancel:nil];
}

-(void)deleteFarm {
    [UIAlertView alertViewWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Do you really want to delete the farm %@?", currentFarm.name] cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Delete"] onDismiss:^(int buttonIndex) {
        [_appDelegate.managedObjectContext deleteObject:currentFarm];
        currentFarm = nil;
        [_appDelegate saveContext];

        isEditingFarm = NO;
        [self reloadMap];
    } onCancel:nil];
}

-(void)addField {
    // add a field
    isAddingField = YES;
    [self hideAllButtons];
    [centerPin setHidden:NO];
    [buttonCheck setHidden:NO];
    [buttonCancel setHidden:NO];
    [UIAlertView alertViewWithTitle:@"Set the location of your field" message:@"Move the map until the blue pin matches the center of your field, then click the check mark"];

    [self reloadMap];
}

-(void)editField {
    if (currentField) {
        isEditingField = YES;
        [self reloadMap];

        CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake([currentField.latitude doubleValue], [currentField.longitude doubleValue]);
        [self centerOnCoordinate:currentLocation resize:NO];

        [self hideAllButtons];
        [centerPin setHidden:NO];
        [buttonCancel setHidden:NO];
        [buttonCheck setHidden:NO];
    }
    else {
        // todo: add message to select a field to edit with the pointer
        [UIAlertView alertViewWithTitle:@"Select a field to edit" message:@"Click on the center pin of the field you want to edit."];
    }
}

-(void)deleteField {
    if (currentField) {
        [UIAlertView alertViewWithTitle:@"Are you sure?" message:@"Do you really want to delete the currently selected field?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Delete"] onDismiss:^(int buttonIndex) {
            [_appDelegate.managedObjectContext deleteObject:currentField];
            currentField = nil;
            [_appDelegate saveContext];

            isEditingField = NO;
            [self reloadMap];
        } onCancel:nil];
    }
    else {
        // todo: display a message to select a field to delete with the pointer
    }

}

-(void)addBoundary {
    [self hideAllButtons];
    [buttonCheck setHidden:NO];
    [buttonCancel setHidden:NO];

    [UIAlertView alertViewWithTitle:@"Add field boundary" message:@"Use the mouse to click on points along your field's boundary. Click the check mark to save."];
    isDrawingMode = YES;
    isEditingField = NO;

    [self reloadMap];
    [self addAnnotationForField:currentField];

    // start drawing
    // todo: make mouse look different to look like a boundary drawing
    fieldCoordinateCount = 0;
}

-(void)editBoundary {

}

-(void)deleteBoundary {
    [UIAlertView alertViewWithTitle:@"Are you sure?" message:@"Do you really want to delete the current field's boundary?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Delete"] onDismiss:^(int buttonIndex) {
        [_appDelegate.managedObjectContext deleteObject:currentField.boundary];
        currentField.boundary = nil;
        [_appDelegate saveContext];

        [self reloadMap];
    } onCancel:nil];
}

-(void)addGrid {

}

-(void)editGrid {

}

-(void)deleteGrid {

}
@end
