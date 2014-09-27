//
//  GridOverlay.m
//  AgAR
//
//  Created by Bobby Ren on 9/24/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "GridOverlay.h"
#import "Area.h"
#import "Polyline+TransformableAttributes.h"
#import "GridArea.h"
#import "Grid.h"
#import "Polyline+Helper.h"

@interface Box : NSObject

@property float x0;
@property float y0;
@property float x1;
@property float y1;

@end

@implementation Box {

}

@end

@implementation GridOverlay

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        topLeft = CGPointZero;
        bottomRight = CGPointZero;
    }
    return self;
}

-(void)setupGridFrameInMap:(MKMapView *)mapView {
    topLeft = CGPointZero;
    bottomRight = CGPointZero;

    // auto generate grid
    CGRect bounds = [self.boundary boundingRectangleInMap:mapView];
    topLeft = bounds.origin;
    bottomRight = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
    [self updateGridFrame:YES];
}

-(void)updateGridFrame:(BOOL)final {
    // draw box from top left to bottom right
    [self setNeedsDisplay];

    if (final) {
        [self createGridlines];
        [self.delegate didSelectGrid];
    }
}

-(void)createGridlines {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }

    // allow user to move the map and rotate
    passThroughTouch = YES;

    // draw grid lines
    if (!boxes) {
        boxes = [NSMutableArray array];
    }
    [boxes removeAllObjects];

    float x0 = MIN(topLeft.x, bottomRight.x);
    float x1 = MAX(topLeft.x, bottomRight.x);
    float y0 = MIN(topLeft.y, bottomRight.y);
    float y1 = MAX(topLeft.y, bottomRight.y);

    int pixelsPerGrid = floor((x1-x0)/4);
    for (int x = x0; x < x1; x += pixelsPerGrid) {
        for (int y = y0; y < y1; y +=pixelsPerGrid) {
            float width = MIN(x1, x + pixelsPerGrid) - x;
            float height = MIN(y1, y + pixelsPerGrid) - y;
            if (width < pixelsPerGrid/3 || height < pixelsPerGrid/3)
                continue;
            
            Box *box = [[Box alloc] init];
            box.x0 = x;
            box.y0 = y;
            box.x1 = MIN(x1, x + pixelsPerGrid);
            box.y1 = MIN(y1, y + pixelsPerGrid);

            [boxes addObject:box];
        }
    }
    // todo: trim boxes on the edge that are too small

    [self setNeedsDisplay];
}

-(void)saveGrid {
    if (!grid) {
        grid = [NSEntityDescription insertNewObjectForEntityForName:@"Grid" inManagedObjectContext:_appDelegate.managedObjectContext];
    }
    grid.boundary = self.boundary;

    CLLocationCoordinate2D coordinates[5];
    for (Box *box in boxes) {
        GridArea *area = [NSEntityDescription insertNewObjectForEntityForName:@"GridArea" inManagedObjectContext:_appDelegate.managedObjectContext];
        area.boundary = [NSEntityDescription insertNewObjectForEntityForName:@"Polyline" inManagedObjectContext:_appDelegate.managedObjectContext];

        coordinates[0] = [self.delegate locationForPoint:(CGPointMake(box.x0, box.y0))];
        coordinates[1] = [self.delegate locationForPoint:(CGPointMake(box.x1, box.y0))];
        coordinates[2] = [self.delegate locationForPoint:(CGPointMake(box.x1, box.y1))];
        coordinates[3] = [self.delegate locationForPoint:(CGPointMake(box.x0, box.y1))];
        coordinates[4] = [self.delegate locationForPoint:(CGPointMake(box.x0, box.y0))];
        [area.boundary setCoordinatesFromCoordinates:coordinates totalPoints:5];

        CGPoint center = CGPointMake((box.x0+box.x1)/2, (box.y0+box.y1)/2);
        CLLocationCoordinate2D centerCoord = [self.delegate locationForPoint:center];
        area.latitude = @(centerCoord.latitude);
        area.longitude = @(centerCoord.longitude);

        area.grid = grid;
    }

    [_appDelegate.managedObjectContext save:nil];
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
    float x0 = MIN(topLeft.x, bottomRight.x);
    float x1 = MAX(topLeft.x, bottomRight.x);
    float y0 = MIN(topLeft.y, bottomRight.y);
    float y1 = MAX(topLeft.y, bottomRight.y);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextSetLineWidth(context, 5);

    // draw circles at tap corners
    CGPoint center = CGPointMake(x0, y0);
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

    if ([boxes count]) {
        for (Box *box in boxes)
            [self drawBox:box rect:rect xmin:x0 ymin:y0];
    }
}

-(void)drawBox:(Box *)box rect:(CGRect)rect xmin:(float)xmin ymin:(float)ymin {
    float x0 = box.x0;
    float y0 = box.y0;
    float x1 = box.x1;
    float y1 = box.y1;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextSetLineWidth(context, 3);

    // draw boundary line
    CGContextBeginPath(context);
    if (x0  > xmin) {
        CGContextMoveToPoint(context, x0, y0);
        CGContextAddLineToPoint(context, x0, y1);
    }
    if (y0 > ymin) {
        CGContextMoveToPoint(context, x0, y0);
        CGContextAddLineToPoint(context, x1, y0);
    }

    CGContextStrokePath(context);
}

#pragma mark gestures
-(void)manualGrid {
    // not used

    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    //    [self addGestureRecognizer:tap];
    //    tap.delegate = self;

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self addGestureRecognizer:pan];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    /*
     CGPoint location = [touch locationInView:self.superview];
     if ([self.delegate clickOnButton:location])
     return NO;
     */
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

#pragma mark hittest
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.delegate clickOnButton:point])
        return NO;

    return !passThroughTouch;
}

@end
