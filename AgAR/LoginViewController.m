//
//  LoginViewController.m
//  BRSimpleLoginSignup
//
//  Created by Bobby Ren on 7/2/14.
//  Copyright (c) 2014 BRSimpleLoginSignup. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)didClickButton:(id)sender {
    if ((UIButton *)sender == self.buttonLogin) {
        if ([self.inputUsername.text length] == 0) {
            [UIAlertView alertViewWithTitle:@"Username needed" message:@"Please enter a username"];
            return;
        }
        if ([self.inputPassword.text length] == 0) {
            [UIAlertView alertViewWithTitle:@"Password needed" message:@"Please enter a password"];
            return;
        }

        [self login];
    }
}

-(void)login {
    [self dismissKeyboard];

    [PFUser logInWithUsernameInBackground:self.inputUsername.text password:self.inputPassword.text block:^(PFUser *user, NSError *error) {
        if (user) {
            NSString *name = user[@"name"]?:user.username;
            [UIAlertView alertViewWithTitle:@"Welcome to AgAR" message:[NSString stringWithFormat:@"Good to see you, %@", name]];
            [_appDelegate goToMainView:YES];
        }
        else {
            NSString *message = nil;
            if (error.userInfo[@"error"]) {
                message = error.userInfo[@"error"];
            }
            [UIAlertView alertViewWithTitle:@"Login failed" message:message];
        }
    }];
}

-(void)dismissKeyboard {
    [self.inputUsername resignFirstResponder];
    [self.inputPassword resignFirstResponder];
}
@end
