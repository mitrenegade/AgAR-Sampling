//
//  Polyline+Helper.h
//  AgAR
//
//  Created by Bobby Ren on 9/20/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "Polyline.h"

@class Annotation;
@class MKMapView;
@interface Polyline (Helper)

-(void)shiftCoordinatesByLatitude:(float)latitudeChange longitude:(float)longitudeChange;
-(void)updateCoordinateForAnnotation:(Annotation *)annotation;

-(void)getBoundingLatitude:(float[2])latitudes longitude:(float[2])longitudes;
-(CGRect)boundingRectangleInMap:(MKMapView *)mapView;

@end
