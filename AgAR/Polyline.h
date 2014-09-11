//
//  Polyline.h
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Area;

@interface Polyline : NSManagedObject

@property (nonatomic, retain) NSNumber * closed;
@property (nonatomic, retain) id coordinates;
@property (nonatomic, retain) NSData * coordinates_data;
@property (nonatomic, retain) Area *area;

@end
