//
//  Farm.h
//  AgAR
//
//  Created by Jingqing Ren on 9/6/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Field;

@interface Farm : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *fields;
@end

@interface Farm (CoreDataGeneratedAccessors)

- (void)addFieldsObject:(Field *)value;
- (void)removeFieldsObject:(Field *)value;
- (void)addFields:(NSSet *)values;
- (void)removeFields:(NSSet *)values;

@end
