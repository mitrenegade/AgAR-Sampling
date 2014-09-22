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
    AnnotationTypeBorder,
    AnnotationTypeBorderSelected
} AnnotationType;

#define AnnotationColorCurrentFarm [UIColor greenColor]
#define AnnotationColorOtherFarm [UIColor colorWithRed:0 green:128.0/255.0 blue:0 alpha:1]
#define AnnotationColorCurrentField [UIColor blueColor]
#define AnnotationColorOtherField [UIColor colorWithRed:0 green:0 blue:128.0/255.0 alpha:1]
#define AnnotationColorDim [UIColor lightGrayColor]
#define AnnotationColorCurrentBoundary [UIColor blueColor]
#define AnnotationColorEditingBoundary [UIColor greenColor]

#define BoundaryColorNormal [UIColor grayColor]
#define BoundaryColorSelected [UIColor greenColor]
#define BoundaryColorEditing [UIColor redColor]

@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) AnnotationType type;
@property (nonatomic) NSString *titleString;
@property (nonatomic) id object;
@property (nonatomic) MKAnnotationView *annotationView;

@end
