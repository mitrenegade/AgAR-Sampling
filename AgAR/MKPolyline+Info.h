//
//  MKPolyline+Info.h
//  AgAR
//
//  Created by Bobby Ren on 9/13/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <objc/runtime.h>

typedef enum BoundaryStatusEnum {
    BoundaryStatusNormal,
    BoundaryStatusNew,
    BoundaryStatusDimmed,
    BoundaryStatusGrid
} BoundaryStatus;

@interface MKPolyline (Info)

-(void)setStatus:(BoundaryStatus)status;
-(BoundaryStatus)status;

@end
