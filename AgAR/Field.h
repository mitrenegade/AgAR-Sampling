//
//  Field.h
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Area.h"

@class Farm;

@interface Field : Area

@property (nonatomic, retain) NSString * farmName;
@property (nonatomic, retain) Farm *farm;

@end
