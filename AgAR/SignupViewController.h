//
//  SignupViewController.h
//  BRSimpleLoginSignup
//
//  Created by Bobby Ren on 7/2/14.
//  Copyright (c) 2014 BRSimpleLoginSignup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputUsername;
@property (weak, nonatomic) IBOutlet UITextField *inputPassword;
@property (weak, nonatomic) IBOutlet UITextField *inputConfirmation;
@property (weak, nonatomic) IBOutlet UITextField *inputType;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

- (IBAction)didClickButton:(id)sender;

@end
