//
//  Polyline+Helper.h
//  AgAR
//
//  Created by Bobby Ren on 9/20/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "Polyline.h"

@interface Polyline (Helper)

-(void)shiftCoordinatesByLatitude:(float)latitudeChange longitude:(float)longitudeChange;
@end
