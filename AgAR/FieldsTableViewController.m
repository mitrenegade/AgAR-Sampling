//
//  FieldsTableViewController.m
//  AgAR
//
//  Created by Jingqing Ren on 9/6/14.
//  Copyright (c) 2014 BobbyRen. All rights reserved.
//

#import "FieldsTableViewController.h"
#import "Field.h"
#import "Farm.h"

@interface FieldsTableViewController ()

@end

@implementation FieldsTableViewController

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
#if TESTING
    NSArray *objs =  [[self fieldFetcher] fetchedObjects];
    if ([objs count] == 0) {
        for (int j = 0; j < 3; j++) {
            Farm *farm = [self newFarm];
            farm.name = [NSString stringWithFormat:@"Farm %d", j];
            for (int i=0; i<5;i++) {
                Field *field = [self newField];
                field.name = [NSString stringWithFormat:@"Field %d", i];
                field.farm = farm;
                field.farmName = farm.name;
            }
        }
        [_appDelegate saveContext];
        [[self fieldFetcher] performFetch:nil];
        [self.tableView reloadData];
    }
#endif

    if (self.isSetupMode) {
        self.title = @"Edit fields";
    }
}

-(Farm *)newFarm {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Farm" inManagedObjectContext:_appDelegate.managedObjectContext];
    return (Farm *)object;
}

-(Field *)newField {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Field" inManagedObjectContext:_appDelegate.managedObjectContext];
    return (Field *)object;
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
    NSArray *sections = [[self fieldFetcher] sections];
    if (self.isSetupMode)
        return [sections count] + 1;
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *sections = [[self fieldFetcher] sections];
    if (section < [sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fieldFetcher] sections] objectAtIndex:section];
        if (self.isSetupMode)
            return [sectionInfo numberOfObjects] + 1;
        return [sectionInfo numberOfObjects];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    int row = indexPath.row;
    int section = indexPath.section;
    NSArray *sections = [[self fieldFetcher] sections];
    if (indexPath.section < [sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fieldFetcher] sections] objectAtIndex:section];
        if (row < [sectionInfo numberOfObjects]) {
            Field *field = [[self fieldFetcher] objectAtIndexPath:indexPath];
            cell.textLabel.font = FONT_REGULAR(14);
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = field.name;
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            cell.textLabel.font = FONT_LIGHT(12);
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.text = @"Add a new field";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else {
        cell.textLabel.font = FONT_LIGHT(12);
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.text = @"Add a new farm";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *sections = [[self fieldFetcher] sections];
    if (section == [sections count]) {
        return @"New farm";
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fieldFetcher] sections] objectAtIndex:section];
    return [sectionInfo name];
}

-(NSFetchedResultsController *)fieldFetcher {
    if (fieldFetcher)
        return fieldFetcher;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Field"];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"farmName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    
    fieldFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:@"farmName" cacheName:nil];
    [fieldFetcher performFetch:nil];
    
    return fieldFetcher;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    // Configure the cell...
    int row = indexPath.row;
    int section = indexPath.section;
    NSArray *sections = [[self fieldFetcher] sections];
    if (indexPath.section < [sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fieldFetcher] sections] objectAtIndex:section];
        if (row < [sectionInfo numberOfObjects]) {
            if (self.isSetupMode) {
                [UIAlertView alertViewWithTitle:@"Edit field" message:@"Clicking this row will edit the field"];
            }
            else {
                [UIAlertView alertViewWithTitle:@"Go to map" message:@"Clicking this row will go to the map"];
            }
        }
        else {
            [UIAlertView alertViewWithTitle:@"Add a field" message:@"Clocking this row will add a new field"];
        }
    }
    else {
        [UIAlertView alertViewWithTitle:@"Add a farm" message:@"Clocking this row will add a new farm"];
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

-(IBAction)didClickBack:(id)sender {
    if (self.isSetupMode) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
