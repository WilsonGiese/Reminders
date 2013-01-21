//
//  RemindersViewController.m
//  Reminders
//
//  Created by Wilson Giese on 12/21/12.
//  Copyright (c) 2012 Wilson Giese. All rights reserved.
//

#import "RemindersViewController.h"
#import "EditViewController.h"
#import "DatabaseBrain.h"
#import "ReminderData.h" 

@interface RemindersViewController ()
@property (weak, nonatomic) DatabaseBrain *db;
@property (weak, nonatomic) ReminderData  *sendData;
@end

@implementation RemindersViewController

#define STORYBOARD_IDENTITY @"MainStoryboard"
#define EDIT_VIEW_IDENTITY  @"EditView"

@synthesize listItems = _listItems;
@synthesize db        = _db;


#pragma mark - RemindersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.db = [DatabaseBrain getDatabase];
    self.listItems = [self.db getAllEntries];
}

#pragma mark - UITableView Delegates

/* Delagates for UITableView */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listItems count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ci = @"Cell";
    
    /* Create and add cells to the table */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ci];

    if(cell == nil) {   
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ci];
    }

    ReminderData *data = [self.listItems objectAtIndex: [indexPath row]];
    cell.textLabel.text = data.title;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReminderData *data = [self.listItems objectAtIndex:indexPath.row];
    [self presentViewWithData:data]; 
    
}


#pragma mark - Actions

/* New reminder */ 
- (IBAction) newReminderButtonPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_IDENTITY bundle:nil];
    
    EditViewController *evc = [storyboard instantiateViewControllerWithIdentifier:EDIT_VIEW_IDENTITY];
    
    [self presentViewController:evc animated:YES completion:nil];
}

/* Updating/Viewing reminder */ 
- (void) presentViewWithData:(ReminderData *) data
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_IDENTITY bundle:nil];
    
    EditViewController *evc = [storyboard instantiateViewControllerWithIdentifier:EDIT_VIEW_IDENTITY];
    [evc setReminderData:data]; 
    
    [self presentViewController:evc animated:YES completion:nil];
}

@end
