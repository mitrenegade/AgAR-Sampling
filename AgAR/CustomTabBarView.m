//
//  CustomTabBarView.m
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "CustomTabBarView.h"
#import "UIActionSheet+MKBlockAdditions.h"

#define BUTTON_COLOR_UNSELECTED [UIColor whiteColor]
#define BUTTON_COLOR_SELECTED [UIColor colorWithWhite:243.0/255.0 alpha:1]
@implementation CustomTabBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];

        //Just in case the size is different (you may or may not want this)
        mainView.frame = self.bounds;

        [self addSubview:mainView];
    }
    return self;
}

-(void)setupWithActions:(NSArray *)actions {
    // background
    opaqueBackground = [CALayer layer];
    CGRect frame = _appDelegate.window.bounds;
    frame.size.height -= self.frame.size.height;
    [opaqueBackground setFrame:frame];
    opaqueBackground.backgroundColor = [[UIColor blackColor] CGColor];
    [self.layer addSublayer:opaqueBackground];
    opaqueBackground.opacity = 0;

    tabButtons = @[buttonFields, buttonAction, buttonProfile];
    self.actionTitles = actions;

    lastTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"tab:lastOpen"];
    [self didClickButton:tabButtons[lastTab]];
}

-(IBAction)didClickButton:(id)sender {
    int pos = ((UIButton *)sender).tag;
    if (pos == TabButtonFields || pos == TabButtonProfile) {
        [buttonFields setBackgroundColor:pos==TabButtonFields?BUTTON_COLOR_SELECTED:BUTTON_COLOR_UNSELECTED];
        [buttonProfile setBackgroundColor:pos==TabButtonProfile?BUTTON_COLOR_SELECTED:BUTTON_COLOR_UNSELECTED];
        [self.delegate setSelectedIndex:pos]; // switch to the correct view

        lastTab = pos;
        [[NSUserDefaults standardUserDefaults] setInteger:lastTab forKey:@"tab:lastOpen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (pos == TabButtonAction) {
        [UIActionSheet actionSheetWithTitle:nil message:nil buttons:self.actionTitles showInView:self.superview onDismiss:^(int buttonIndex) {
            NSLog(@"Button index: %d", buttonIndex);
            [self.delegate didClickActionAtIndex:buttonIndex];
        } onCancel:^{
            // no nil cancel block
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
