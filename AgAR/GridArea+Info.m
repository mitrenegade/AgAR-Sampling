//
//  GridArea+Info.m
//  AgAR
//
//  Created by Bobby Ren on 9/27/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "GridArea+Info.h"
#import "Grid.h"
#import "Polyline.h"

@implementation GridArea (Info)

-(BOOL)inside {
    Polyline *boundary = self.grid.boundary;
    
    return YES;
}

@end
