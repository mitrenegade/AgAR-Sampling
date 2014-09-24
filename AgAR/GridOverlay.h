//
//  GridOverlay.h
//  AgAR
//
//  Created by Bobby Ren on 9/24/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Polyline+Helper.h"
#import <CoreLocation/CoreLocation.h>

@class Grid;
@protocol GridOverlayDelegate <NSObject>

-(void)didSelectGridTopLeft:(CGPoint)topLeft;
-(void)didSelectGridBottomRight:(CGPoint)bottomRight;
-(BOOL)clickOnButton:(CGPoint)touch;
-(CLLocationCoordinate2D)locationForPoint:(CGPoint)point;

@end

@interface GridOverlay : UIView <UIGestureRecognizerDelegate>
{
    CGPoint topLeft;
    CGPoint bottomRight;

    BOOL passThroughTouch;

    NSMutableArray *boxes; // array of quads of cgpoints - coordinate is in pixels
    Grid *grid;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) Polyline *boundary;

-(void)setupGridFrame;
-(void)createGridlines;
-(void)saveGrid;
@end
