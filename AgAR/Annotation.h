//
//  Annotation.h
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum AnnotationTypeEnum {
    AnnotationTypeCurrentFarmCenter,
    AnnotationTypeOtherFarmCenter,
    AnnotationTypeCurrentFieldCenter,
    AnnotationTypeOtherFieldCenter,
    AnnotationTypeBorder
} AnnotationType;

@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) AnnotationType type;
@property (nonatomic) NSString *titleString;
@property (nonatomic) id object;
@end
