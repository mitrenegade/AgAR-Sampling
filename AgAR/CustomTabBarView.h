//
//  CustomTabBarView.h
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomTabBarDelegate <NSObject>

-(void)didClickActionAtIndex:(int)index;
-(NSArray *)actionsAvailable;
@end

typedef enum TabButtonEnum {
    TabButtonFields,
    TabButtonAction,
    TabButtonProfile,
    TabButtonMax
} TabButtonPosition;

@interface CustomTabBarView : UIView
{
    CALayer *opaqueBackground;
    UIImageView *tabBG;

    IBOutlet UIButton *buttonFields;
    IBOutlet UIButton *buttonAction;
    IBOutlet UIButton *buttonProfile;
    NSArray *tabButtons;

    int lastTab;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *actionTitles;

-(void)setup;
-(IBAction)didClickButton:(id)sender;

@end
