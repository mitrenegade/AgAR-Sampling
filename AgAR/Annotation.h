//
//  Annotation.h
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}

@end
