//
//  ShellViewController.m
//  AgAR
//
//  Created by Bobby Ren on 9/11/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "ShellViewController.h"
#import "SideBarViewController.h"
#import "FieldsViewController.h"

@interface ShellViewController ()

@end

@implementation ShellViewController

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

    tabView = [[CustomTabBarView alloc] init];
    tabView.delegate = self;
    tabView.frame = CGRectMake(0, self.view.frame.size.height-60, 320, 60);
    tabView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:tabView];

    [tabView setup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)actionsAvailable {
    FieldsViewController *fieldController = self.viewControllers[TabButtonFields];
    return [fieldController actionsAvailable];
}

-(void)didClickActionAtIndex:(int)index {
    NSLog(@"Index: %d", index);
    // always come back to fields
    [self setSelectedIndex:TabButtonFields];

    FieldsViewController *fieldController = self.viewControllers[TabButtonFields];

    if (index == 0) {
        // add grid
        [fieldController actionAddGrid];
    }
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

@end
