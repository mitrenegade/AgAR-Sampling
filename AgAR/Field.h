//
//  Field.h
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Farm, Polyline;

@interface Field : NSManagedObject

@property (nonatomic, retain) NSString * farmName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Farm *farm;
@property (nonatomic, retain) Polyline *boundary;

@end
