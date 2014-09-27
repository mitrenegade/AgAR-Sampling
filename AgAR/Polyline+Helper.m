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
#import <MapKit/MapKit.h>

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

-(void)getBoundingLatitude:(float[2])latitudes longitude:(float[2])longitudes {
    NSArray *coordinates = self.coordinates;
    float maxlat = ((CLLocation *)coordinates[0]).coordinate.latitude;
    float minlat = maxlat;
    float maxlong = ((CLLocation *)coordinates[0]).coordinate.longitude;
    float minlong = maxlong;

    for (int i=0; i<coordinates.count; i++) {
        float lat = ((CLLocation *)coordinates[i]).coordinate.latitude;
        float lon = ((CLLocation *)coordinates[i]).coordinate.longitude;
        maxlat = MAX(maxlat, lat);
        minlat = MIN(minlat, lat);
        maxlong = MAX(maxlong, lon);
        minlong = MIN(minlong, lon);
    }
    latitudes[0] = minlat;
    latitudes[1] = maxlat;
    longitudes[0] = minlong;
    longitudes[1] = maxlong;
}

-(CGRect)boundingRectangleInMap:(MKMapView *)mapView {
    float latitudeRange[2];
    float longitudeRange[2];
    [self getBoundingLatitude:latitudeRange longitude:longitudeRange];

    CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(latitudeRange[0], longitudeRange[0]);
    CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(latitudeRange[1], longitudeRange[1]);

    CGPoint tl = [mapView convertCoordinate:topLeft toPointToView:mapView];
    CGPoint br = [mapView convertCoordinate:bottomRight toPointToView:mapView];

    float width = br.x - tl.x;
    float height = br.y - tl.y;
    CGRect bounding = CGRectMake(tl.x, tl.y, width, height);
    return bounding;
}

-(BOOL)isFieldBoundary {
    if (self.grid) {
        return YES;
    }
    return NO;
}

-(BOOL)isGridAreaBoundary {
    if (self.area) {
        return YES;
    }
    return NO;
}

@end
