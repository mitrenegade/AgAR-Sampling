//
//  GridArea.h
//  AgAR
//
//  Created by Bobby Ren on 9/24/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Area.h"

@class Grid;

@interface GridArea : Area

@property (nonatomic, retain) Grid *grid;

@end
