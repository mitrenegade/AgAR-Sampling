//
//  Polyline+Helper.m
//  AgAR
//
//  Created by Bobby Ren on 9/20/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "Polyline+Helper.h"
#import "Polyline+TransformableAttributes.h"
#import "Annotation.h"

@implementation Polyline (Helper)

-(void)shiftCoordinatesByLatitude:(float)latitudeChange longitude:(float)longitudeChange {
    CLLocationCoordinate2D coordinates[[self.coordinates count]];
    int ct = 0;
    for (CLLocation *loc in self.coordinates) {
        NSLog(@"loc: %@", loc);
        coordinates[ct] = loc.coordinate;
        coordinates[ct].latitude += latitudeChange;
        coordinates[ct].longitude += longitudeChange;
        ct++;
    }
    [self setCoordinatesFromCoordinates:coordinates totalPoints:ct];
}

-(void)updateCoordinateForAnnotation:(Annotation *)annotation {
    NSMutableArray *annotations = self.annotations;
    NSMutableArray *coordinates = self.coordinates;

    for (int i=0; i<annotations.count; i++) {
        Annotation *a = annotations[i];
        if (a == annotation) {
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:a.coordinate.latitude longitude:a.coordinate.longitude];
            [coordinates replaceObjectAtIndex:i withObject:loc];
            break;
        }
    }
    [self setCoordinates:coordinates];
    [self setPolyLine:nil];
}
@end
