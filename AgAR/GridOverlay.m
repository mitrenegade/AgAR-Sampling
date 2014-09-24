//
//  GridOverlay.m
//  AgAR
//
//  Created by Bobby Ren on 9/24/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "GridOverlay.h"

@implementation GridOverlay

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        topLeft = CGPointZero;
        bottomRight = CGPointZero;
    }
    return self;
}

-(void)setupGridFrame {
    topLeft = CGPointZero;
    bottomRight = CGPointZero;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self addGestureRecognizer:tap];
    tap.delegate = self;

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self addGestureRecognizer:pan];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self.superview];
    if ([self.delegate clickOnButton:location])
        return NO;
    return YES;
}

-(void)handleGesture:(id)sender {
    UIGestureRecognizer *recognizer = (UIGestureRecognizer *)sender;
    CGPoint touch = [recognizer locationInView:self];
    if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (CGPointEqualToPoint(CGPointZero, topLeft) || !CGPointEqualToPoint(CGPointZero, bottomRight)) {
            // first tap
            topLeft = touch;
            bottomRight = CGPointZero;
            [self updateGridFrame:NO];
            [self.delegate didSelectGridTopLeft:topLeft];
        }
        else if (CGPointEqualToPoint(CGPointZero, bottomRight)) {
            // second tap
            bottomRight = touch;
            [self updateGridFrame:YES];
        }
    }
    else if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            topLeft = touch;
            bottomRight = CGPointZero;
            [self.delegate didSelectGridTopLeft:topLeft];
        }
        else if (recognizer.state == UIGestureRecognizerStateChanged) {
            bottomRight = touch;
            [self updateGridFrame:NO];
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded) {
            bottomRight = touch;
            [self updateGridFrame:YES];
        }
    }
}

-(void)updateGridFrame:(BOOL)final {
    // draw box from top left to bottom right
    [self setNeedsDisplay];

    if (final) {
        [self.delegate didSelectGridBottomRight:bottomRight];
    }
}

-(void)createGridlines {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }

    passThroughTouch = YES;

    NSLog(@"Create grid lines and allow user to rotate");
}

-(void)dealloc {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (CGPointEqualToPoint(CGPointZero, topLeft))
        return;


    // (y1 - y0) = m(x1 - x0) + b
    float x0 = topLeft.x;
    float x1 = bottomRight.x;
    float y0 = topLeft.y;
    float y1 = bottomRight.y;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextSetLineWidth(context, 5);

    // draw circles at tap corners
    CGPoint center = topLeft;
    CGFloat radius = 8; // little scaling needed
    CGFloat startAngle = -((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = ((2 * (float)M_PI) + startAngle);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFillPath(context);

    if (CGPointEqualToPoint(CGPointZero, bottomRight))
        return;

    // draw circles at tap corners
    center = CGPointMake(x0, y1);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFillPath(context);
    center = CGPointMake(x1, y1);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFillPath(context);
    center = CGPointMake(x1, y0);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextFillPath(context);

    // draw boundary line
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x0, y0);

    CGContextAddLineToPoint(context, x0, y1);
    CGContextAddLineToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x1, y0);
    CGContextAddLineToPoint(context, x0, y0);

    CGFloat dash1[] = {10.0, 5.0};
    CGContextSetLineDash(context, 0.0, dash1, 2);
    CGContextStrokePath(context);

    CGContextStrokePath(context);
}

#pragma mark hittest
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.delegate clickOnButton:point])
        return NO;

    return !passThroughTouch;
}

@end
