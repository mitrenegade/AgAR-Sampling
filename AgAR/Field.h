//
//  Field.h
//  AgAR
//
//  Created by Jingqing Ren on 9/6/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Farm;

@interface Field : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * farmName;
@property (nonatomic, retain) Farm *farm;

@end
