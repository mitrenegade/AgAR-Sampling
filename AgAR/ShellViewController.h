//
//  ShellViewController.h
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBarView.h"

@interface ShellViewController : UITabBarController <CustomTabBarDelegate>
{
    CustomTabBarView *tabView;
}

@end
