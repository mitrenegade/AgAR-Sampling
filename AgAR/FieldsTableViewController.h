//
//  FieldsTableViewController.h
//  AgAR
//
//  Created by Jingqing Ren on 9/6/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FieldsTableViewController : UITableViewController
{
    NSFetchedResultsController *fieldFetcher;
}

@property (nonatomic) BOOL isSetupMode;

-(IBAction)didClickBack:(id)sender;

@end
