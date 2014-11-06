//
//  ProfileTableViewController.m
//  AgAR
//
//  Created by Bobby Ren on 9/9/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "ProfileTableViewController.h"
#import <Parse/Parse.h>

@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController

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
    // todo: add sections for Profile and fields
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int row = 0;
    switch(section) {
        case 0:
            row = 2;
            break;
            
        case 1:
            row = 7;
            break;
            
        case 2:
            row = 5;
            break;
            
       defaut:
            row = 0;
            break;
    }
    return row;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *head;
    switch (section) {
        case 0:
            head = @"Login info";
            break;
            
        case 1:
            head = @"Profile";
            break;

        case 2:
            head = @"Customer type";
            break;
    }
    return head;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.font = FONT_REGULAR(14);
    cell.textLabel.textColor = [UIColor blackColor];
    
    // Configure the cell...
    NSString *title;
    NSString *detail;
    int section = indexPath.section;
    int row = indexPath.row;
    
    switch( section) {
        case 0:
           switch(row) {
                case 0:
                    title = @"Email";
                    detail = _currentUser.email;
                    break;
                case 1:
                    title = @"Password";
                    break;
            }
            break;
        case 1:
            switch(row) {
                case 0:
                    title = @"Name";
                    detail = _currentUser.username;
                    break;
                    
                case 1:
                    title = @"Address";
                    
                    _currentUser[@"address"]=@"331 Felspar Way";
                    [_currentUser saveInBackground];
                    break;
                    
                case 2:
                    title = @"Address2";
                    break;
                    
                case 3:
                    title = @"City";
                    break;
                    
                case 4:
                    title = @"State";
                    break;
                    
                case 5:
                    title = @"Zip";
                    break;
                    
                case 6:
                    title = @"County";
                    break;
                    
                default:
                    break;
            }
            break;
        case 2:
            switch(row) {
                case 0:
                    title = @"Customer type";
                    //detail = _currentUser.;
                    break;
                case 1:
                    title = @"Field size";
                    break;
                    
                case 2:
                    title = @"Grid size";
                    break;
                    
                case 3:
                    title = @"Log out";
                    break;
                    
                case 4:
                    title = @"";
                    break;
                    
                default:
                    break;
           }
            break;
        default:
            break;
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    switch (row) {
        case 0:
        {
            NSLog(@"Email");
            // todo: build UserInfoViewController to edit every field for a user
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Your email is %@", _currentUser.email] message:@"Change your email? This will also update your login." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
            break;
            
        case 1:
        {
            NSLog(@"Password");
            // todo: build UserInfoViewController to edit every field for a user
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[NSString stringWithFormat:@""]
                                  message:@"Enter new password:"
                                  delegate:self cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Update", nil];
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
            break;
            
        case 9:
            [_appDelegate logout];
            break;
            
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"index 0 - cancel");
    }
    else {
        NSLog(@"else");
        UITextField * text = [alertView textFieldAtIndex:0];
        _currentUser.email = text.text;
        _currentUser.username = text.text;
        [_currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Saved");
                [UIAlertView alertViewWithTitle:@"Login and email updated" message:[NSString stringWithFormat:@"Your login and email have been updated to %@", _currentUser.username]];
            }
            else {
                NSString *message = nil;
                if (error.userInfo[@"error"])
                    message = error.userInfo[@"error"];
                if (error.code == 101) {
                    [_appDelegate logout];
                    message = @"Your user could not be found. Please login again.";
                }
                [UIAlertView alertViewWithTitle:@"Error updating user info" message:message];
            }
        }];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 UINavigationController *nav = [segue destinationViewController];
 // Pass the selected object to the new view controller.
 }
 */
@end
