//
//  Polyline+TransformableAttributes.m
//  Test
//
//  Created by Bobby Ren on 8/20/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "Polyline+TransformableAttributes.h"

@implementation Polyline (TransformableAttributes)

#pragma mark Transformables
-(NSArray *)coordinates {
    if (!self.coordinates_data)
        return nil;

    return [NSKeyedUnarchiver unarchiveObjectWithData:self.coordinates_data];
}

-(void)setCoordinates:(id)coordinates {
    NSData *coordinates_data = [NSKeyedArchiver archivedDataWithRootObject:coordinates];
    [self setValue:coordinates_data forKey:@"coordinates_data"];
}

-(MKPolyline *)polyLine {
    CLLocationCoordinate2D coordinates[[self.coordinates count]];
    int ct = 0;
    for (CLLocation *loc in self.coordinates) {
        NSLog(@"loc: %@", loc);
        coordinates[ct++] = loc.coordinate;
    }
    return [MKPolyline polylineWithCoordinates:coordinates count:ct];
}

@end
