//
//  Area+Polygon.h
//  AgAR
//
//  Created by Bobby Ren on 9/27/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "Area.h"

@class MKPolygon;
@interface Area (Polygon)

-(BOOL)inside;
-(MKPolygon *)polygon;

@end
