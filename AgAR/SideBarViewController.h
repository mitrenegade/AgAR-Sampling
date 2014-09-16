//
//  SideBarViewController.h
//  AgAR
//
//  Created by Bobby Ren on 9/15/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SideBarDelegate <NSObject>

-(void)closeSidebar;

@end

@interface SideBarViewController : UITableViewController

@property (nonatomic, weak) id delegate;
@end
