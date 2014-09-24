//
//  Grid.h
//  AgAR
//
//  Created by Bobby Ren on 9/24/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GridArea, Polyline;

@interface Grid : NSManagedObject

@property (nonatomic, retain) Polyline *boundary;
@property (nonatomic, retain) NSSet *areas;
@end

@interface Grid (CoreDataGeneratedAccessors)

- (void)addAreasObject:(GridArea *)value;
- (void)removeAreasObject:(GridArea *)value;
- (void)addAreas:(NSSet *)values;
- (void)removeAreas:(NSSet *)values;

@end
