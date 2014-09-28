//
//  Polyline+TransformableAttributes.m
//  Test
//
//  Created by Bobby Ren on 8/20/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "Polyline+TransformableAttributes.h"
#import <objc/runtime.h>
#import "Annotation.h"

@implementation Polyline (TransformableAttributes)

#pragma mark Transformables
-(NSArray *)coordinates {
    // returns an NSArray of CLLocation objects
    if (!self.coordinates_data)
        return nil;

    NSArray *results = [NSKeyedUnarchiver unarchiveObjectWithData:self.coordinates_data];
    return results;
}

-(void)setCoordinates:(id)newCoordinates {
    // coordinates should be an NSArray of CLLocation objects
    NSData *coordinates_data = [NSKeyedArchiver archivedDataWithRootObject:newCoordinates];
    [self setValue:coordinates_data forKey:@"coordinates_data"];
}

-(void)setCoordinatesFromCoordinates:(CLLocationCoordinate2D *)coordinates totalPoints:(int)ct {
    // coordinates is CLLocationCoordinate2D[ct]
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:ct];
    for (int i=0; i<ct; i++) {
        CLLocationCoordinate2D coord = coordinates[i];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        [array addObject:loc];
    }
    [self setCoordinates:array];
    [self setPolyLine:nil];
    [self setAnnotations:nil];
}

#pragma mark Instance variable for category
// http://oleb.net/blog/2011/05/faking-ivars-in-objc-categories-with-associative-references/
// use associative reference in order to add a new instance variable in a category

-(MKPolyline *)polyLine {
    MKPolyline *polyLine = objc_getAssociatedObject(self, @"PolylineKey");
    if (!polyLine) {
        CLLocationCoordinate2D coordinates[[self.coordinates count]];
        int ct = 0;
        for (CLLocation *loc in self.coordinates) {
            NSLog(@"loc: %@", loc);
            coordinates[ct++] = loc.coordinate;
        }

        // close the loop
        if ([self.closed boolValue]) {
            coordinates[ct++] = coordinates[0];
        }

        polyLine = [MKPolyline polylineWithCoordinates:coordinates count:ct];
        [self setPolyLine:polyLine];
    }
    return polyLine;
}

-(void)setPolyLine:(MKPolyline *)polyLine {
    objc_setAssociatedObject(self, @"PolylineKey", polyLine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray *)annotations {
    NSMutableArray *annotations = objc_getAssociatedObject(self, @"BoundaryAnnotationsKey");
    if (!annotations) {
        annotations = [NSMutableArray array];
        [self setAnnotations:annotations];
    }
    return annotations;
}

-(void)setAnnotations:(NSMutableArray *)annotations {
    objc_setAssociatedObject(self, @"BoundaryAnnotationsKey", annotations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
