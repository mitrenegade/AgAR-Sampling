//
//  GridOverlay.h
//  AgAR
//
//  Created by Bobby Ren on 9/24/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GridOverlayDelegate <NSObject>

-(void)didSelectGridTopLeft:(CGPoint)topLeft;
-(void)didSelectGridBottomRight:(CGPoint)bottomRight;
-(BOOL)clickOnButton:(CGPoint)touch;

@end

@interface GridOverlay : UIView <UIGestureRecognizerDelegate>
{
    CGPoint topLeft;
    CGPoint bottomRight;

    BOOL passThroughTouch;
}

@property (nonatomic, weak) id delegate;

-(void)setupGridFrame;
-(void)createGridlines;
@end
