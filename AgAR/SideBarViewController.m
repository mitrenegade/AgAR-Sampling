//
//  SideBarViewController.m
//  AgAR
//
//  Created by Bobby Ren on 9/15/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "SideBarViewController.h"

static NSDictionary *iconsForOption;
static NSDictionary *actionsForOption;

@interface SideBarViewController ()

@end

@implementation SideBarViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    iconsForOption = @{kAddFarm:@"add",
                       kEditFarm:@"hand",
                       kDeleteFarm:@"trash",
                       kAddField:@"add",
                       kEditField:@"hand",
                       kMoveField:@"hand",
                       kDeleteField:@"trash",
                       kAddBoundary:@"draw",
                       kEditBoundary:@"edit",
                       kDeleteBoundary:@"trash",
                       kAddGrid:@"draw",
                       kEditGrid:@"edit",
                       kDeleteGrid:@"trash"};
    actionsForOption = @{kAddFarm:@"addFarm",
                         kEditFarm:@"editFarm",
                         kDeleteFarm:@"deleteFarm",
                         kAddField:@"addField",
                         kEditField:@"editField",
                         kMoveField:@"editField",
                         kDeleteField:@"deleteField",
                         kAddBoundary:@"addBoundary",
                         kEditBoundary:@"editBoundary",
                         kDeleteBoundary:@"deleteBoundary",
                         kAddGrid:@"addGrid",
                         kEditGrid:@"editGrid",
                         kDeleteGrid:@"deleteGrid"};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [options count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UIImageView *icon = (UIImageView *)[cell viewWithTag:1];
    UILabel *label = (UILabel *)[cell viewWithTag:2];

    // Configure the cell...
    if (indexPath.row == 0) {
        label.text = @"Close";
        icon.image = [UIImage imageNamed:@"arrowLeft"];

        // todo: also add center and deselect options
    }
    else {
        label.text = options[indexPath.row-1];
        icon.image = [UIImage imageNamed:iconsForOption[label.text]];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0) {
        [self.delegate closeSidebar];
    }
    else {
        NSString *option = options[indexPath.row - 1];
        [self.delegate closeSidebar];
        [self.delegate performSelector:NSSelectorFromString(actionsForOption[option]) withObject:nil afterDelay:0];
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)setupWithOptions:(NSArray *)optionsArray actions:(NSArray *)actionsArray {
    options = optionsArray;
    selectors = actionsArray;

    [self.tableView reloadData];
}

-(void)setupWithMode:(SideBarMode)currentMode {
    mode = currentMode;

    switch (mode) {
        case SideBarModeEmpty:
            options = @[kAddFarm];
            break;

        case SideBarModeFarmOnly:
            options = @[kEditFarm, kDeleteFarm, kAddField];
            break;

        case SideBarModeFieldUnselected:
            options = @[kEditFarm, kDeleteFarm, kAddField, kEditField, kDeleteField];
            break;

        case SideBarModeFieldSelected:
            options = @[kMoveField, kDeleteField, kAddBoundary];
            break;

        case SideBarModeBoundarySelected:
            options = @[kMoveField, kDeleteField, kEditBoundary, kDeleteBoundary, kAddGrid];
            break;

        case SideBarModeGridSelected:
            options = @[kEditGrid, kDeleteGrid];
            break;

        default:
            break;
    }

    [self.tableView reloadData];
}
@end
