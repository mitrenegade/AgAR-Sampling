//
//  CustomTabBarView.m
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "CustomTabBarView.h"

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
        [self setup];
    }
    return self;
}

-(void)setup {
    // background
    opaqueBackground = [CALayer layer];
    CGRect frame = _appDelegate.window.bounds;
    frame.size.height -= self.frame.size.height;
    [opaqueBackground setFrame:frame];
    opaqueBackground.backgroundColor = [[UIColor blackColor] CGColor];
    [self.layer addSublayer:opaqueBackground];
    opaqueBackground.opacity = 0;
}

-(IBAction)didClickButton:(id)sender {
    int pos = ((UIButton *)sender).tag;
    // when center button is pressed, programmatically send the tab bar that command
    [buttonFields setSelected:pos==TabButtonFields];
    [buttonProfile setSelected:pos==TabButtonProfile];

    if (pos == TabButtonFields || pos == TabButtonProfile)
        [self.delegate setSelectedIndex:pos]; // switch to the correct view

    lastTab = pos;
    [[NSUserDefaults standardUserDefaults] setObject:@(lastTab) forKey:@"tab:lastOpen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
