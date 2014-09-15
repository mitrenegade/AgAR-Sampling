//
//  MKPolyline+Info.m
//  AgAR
//
//  Created by Bobby Ren on 9/13/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "MKPolyline+Info.h"

#define MKPolylineStatusKey @"MKPolylineStatusKey"
@implementation MKPolyline (Info)

#pragma mark Instance variable for category
// http://oleb.net/blog/2011/05/faking-ivars-in-objc-categories-with-associative-references/
// use associative reference in order to add a new instance variable in a category

-(BoundaryStatus)status {
    NSNumber *statusObject = objc_getAssociatedObject(self, MKPolylineStatusKey);
    return [statusObject intValue];
}

-(void)setStatus:(BoundaryStatus)status {
    objc_setAssociatedObject(self, MKPolylineStatusKey, @(status), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
