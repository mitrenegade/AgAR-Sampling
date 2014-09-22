//
//  SideBarViewController.h
//  AgAR
//
//  Created by Bobby Ren on 9/15/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum SideBarModeEnum {
    SideBarModeEmpty,
    SideBarModeFarmOnly,
    SideBarModeFieldUnselected,
    SideBarModeFieldSelected,
    SideBarModeBoundarySelected, // field has a boundary
    SideBarModeBoundaryEditing, // editing field boundary
    SideBarModeGridSelected
} SideBarMode;

static NSString *const kAddFarm = @"Add farm";
static NSString *const kEditFarm = @"Edit farm";
static NSString *const kDeleteFarm = @"Delete farm";
static NSString *const kAddField = @"Add field";
static NSString *const kEditField = @"Edit field"; // for adding or selecting a field
static NSString *const kMoveField = @"Reposition field";
static NSString *const kDeleteField = @"Delete field";
static NSString *const kAddBoundary = @"Add boundary";
static NSString *const kEditBoundary = @"Edit boundary";
static NSString *const kDeleteBoundary = @"Delete boundary";
static NSString *const kAddGrid = @"Add grid";
static NSString *const kEditGrid = @"Edit grid";
static NSString *const kDeleteGrid = @"Delete grid";

@protocol SideBarDelegate <NSObject>

-(void)closeSidebar;

@end

@interface SideBarViewController : UITableViewController
{
    NSArray *options;
    NSArray *selectors;

    SideBarMode mode;
}
@property (nonatomic, weak) id delegate;

-(void)setupWithOptions:(NSArray *)optionsArray actions:(NSArray *)actionsArray;

-(void)setupWithMode:(SideBarMode)currentMode;
@end
