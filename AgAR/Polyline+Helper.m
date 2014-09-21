//
//  Polyline+Helper.m
//  AgAR
//
//  Created by Bobby Ren on 9/20/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "Polyline+Helper.h"
#import "Polyline+TransformableAttributes.h"
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
@end
