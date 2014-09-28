//
//  Area+Polygon.m
//  AgAR
//
//  Created by Bobby Ren on 9/27/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "Area+Polygon.h"
#import <MapKit/MapKit.h>
#import "Polyline+Helper.h"

@implementation Area (Polygon)

-(BOOL)inside {

    return YES;
}

-(MKPolygon *)polygon {
    Polyline *boundary = self.boundary;
    NSArray *coordinates = [boundary coordinates];
    CLLocationCoordinate2D coord2D[[coordinates count]];
    int ct = 0;
    for (CLLocation *loc in coordinates) {
        NSLog(@"loc: %@", loc);
        coord2D[ct++] = loc.coordinate;
    }

    // close the loop
    if ([boundary.closed boolValue]) {
        coord2D[ct++] = coord2D[0];
    }

    return [MKPolygon polygonWithCoordinates:coord2D count:ct];
}

@end
