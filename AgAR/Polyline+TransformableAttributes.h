//
//  Polyline+TransformableAttributes.h
//  Test
//
//  Created by Bobby Ren on 8/20/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "Polyline.h"

static char const * const MKPolylineTagKey = "MKPolylineTagKey";

@import MapKit;

@interface Polyline (TransformableAttributes)

#pragma mark transformables

-(NSArray *)coordinates;
-(void)setCoordinates:(id)coordinates;

-(MKPolyline *)polyLine;
-(void)setCoordinatesFromCoordinates:(CLLocationCoordinate2D *)coordinates totalPoints:(int)ct;
-(void)setPolyLine:(MKPolyline *)polyLine;
-(NSMutableArray *)annotations;
-(void)setAnnotations:(NSMutableArray *)annotations;
@end
