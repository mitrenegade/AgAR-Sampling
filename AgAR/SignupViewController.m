//
//  SignupViewController.m
//  BRSimpleLoginSignup
//
//  Created by Bobby Ren on 7/2/14.
//  Copyright (c) 2014 BRSimpleLoginSignup. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>

@interface SignupViewController ()

@end

@implementation SignupViewController

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

    picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    [picker reloadAllComponents];
    self.inputType.inputView = picker;

    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* button1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleBordered target:self.inputType action:@selector(resignFirstResponder)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:button1, nil]];

    if (IS_ABOVE_IOS6) {
        [keyboardDoneButtonView setTintColor:[UIColor whiteColor]];
    }

    self.inputType.inputAccessoryView = keyboardDoneButtonView;
    [self pickerView:(UIPickerView *)self.inputType.inputView didSelectRow:0 inComponent:0]; // select by default
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickButton:(id)sender {
    if ([self.inputUsername.text length] == 0) {
        [UIAlertView alertViewWithTitle:@"Username needed" message:@"Please enter a username"];
        return;
    }
    if ([self.inputUsername.text length] == 0) {
        [UIAlertView alertViewWithTitle:@"Password needed" message:@"Please enter a password"];
        return;
    }
    if ([self.inputConfirmation.text length] == 0) {
        [UIAlertView alertViewWithTitle:@"Confirmation needed" message:@"Please enter your password twice"];
        return;
    }
    if (![self.inputConfirmation.text isEqualToString:self.inputConfirmation.text]) {
        [UIAlertView alertViewWithTitle:@"Invalid password" message:@"Password and confirmation do not match"];
        return;
    }

    [self signup];
}

-(void)signup {
    [self dismissKeyboard];
    PFUser *user = [PFUser user];
    user[@"name"] = self.inputUsername.text;
    user.username = self.inputEmail.text;
    user.password = self.inputPassword.text;
    user.email = self.inputEmail.text;
    user[@"customerType"] = @([picker selectedRowInComponent:0]);

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [UIAlertView alertViewWithTitle:@"Welcome to AgAR" message:[NSString stringWithFormat:@"Your login is %@", user.username]];
            [_appDelegate goToMainView:YES];
        }
        else {
            NSString *message = nil;
            if (error.userInfo[@"error"]) {
                message = error.userInfo[@"error"];
            }
            [UIAlertView alertViewWithTitle:@"Signup failed" message:message];
        }
    }];
}

-(void)dismissKeyboard {
    [self.inputUsername resignFirstResponder];
    [self.inputPassword resignFirstResponder];
    [self.inputConfirmation resignFirstResponder];
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

#pragma mark PickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0)
        return @"Commercial grower";
    else
        return @"Residential";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString * title = [self pickerView:pickerView titleForRow:row forComponent:component];
    [self.inputType setText:title];
}

#pragma mark TextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.inputType) {
        if ([textField.text length] == 0)
            [self pickerView:(UIPickerView *)textField.inputView didSelectRow:0 inComponent:0];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
