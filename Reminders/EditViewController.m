//
//  EditViewController.m
//  Reminders
//
//  Created by Wilson Giese on 12/27/12.
//  Copyright (c) 2012 Wilson Giese. All rights reserved.
//

#import "EditViewController.h"
#import "RemindersViewController.h" 
#import "DatabaseBrain.h"

@interface EditViewController () {}

@property DatabaseBrain *database;
@property NSDate *time;
@property (nonatomic, weak) ReminderData *reminder;
@property (nonatomic) BOOL updating;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField; /* Hidden */
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker; /* dateTextField keyboard */

@end

@implementation EditViewController

#define STORYBOARD_INDENTITY     @"MainStoryboard"
#define REMINDERS_VIEW_INDENTITY @"RemindersView"
#define LOCAL_NOTIFCATION_ID     @"ID"

@synthesize dateTextField    = _dateTextField;
@synthesize titleTextField   = _titleTextField;
@synthesize detailsTextField = _detailsTextField;
@synthesize datePicker       = _datePicker;
@synthesize dateButton       = _dateButton;
@synthesize deleteButton     = _deleteButton; 
@synthesize reminder         = _reminder;
@synthesize updating         = _updating;
@synthesize database         = _database;
@synthesize time             = _time; 


#pragma mark - EditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAllTextFields];
    
    if(self.updating) {
        self.titleTextField.text = self.reminder.title;
        self.detailsTextField.text = self.reminder.details;
        self.time = self.reminder.time;
        [self.dateButton setTitle:[NSString stringWithFormat:@"%@", self.reminder.time] forState:UIControlStateNormal];
        
        /* Fix offset for date picker */
        NSInteger offset = [self getGMTOffsetForDate:self.reminder.time];
        self.datePicker.date = [self.reminder.time dateByAddingTimeInterval:offset * -1];
    } else {
        [self setTimeToCurrentTime];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction) saveButtonPressed:(id)sender
{
    
    if(self.database == nil) {
        self.database = [DatabaseBrain getDatabase];
    }
    ReminderData *newData = [self createDataFromFields];
    
    if(self.updating) {
        /* Update SQLite entry  */
        newData.uniqueID = self.reminder.uniqueID;
        [self.database updateEntryData:newData];
        
        /* Update alarm */
        [self updateLocalNotificationForReminder:newData]; 
    } else {
        /* Add new SQLite entry */
        newData.uniqueID = [self.database insertEntry:newData];
        
        /* Add alarm */ 
        [self setLocalNotificationForReminder:newData];
    }
    [self presentReminderView];
}

/* Action for TextField keyboard "Done"
 * Note: This method is NOT for the DatePicker */
- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

/* This method is specifically for the UIDatePicker */
- (void)datePickerDoneEditing:(id)sender
{
    [self.dateTextField resignFirstResponder];
}

/* Button will launch date picker that was set to the text field */
- (IBAction)timeButtonPressed:(id)sender
{
    [self.dateTextField becomeFirstResponder];
}

- (IBAction) doneButtonPressed:(id)sender {
    [self presentReminderView];
}

/* When date has been changed */
- (void) dateHasChanged:(id)sender
{
    self.time = [self getGMTDateFromDatePicker];
    [self.dateButton setTitle: [NSString stringWithFormat:@"%@", self.time] forState:UIControlStateNormal];
}

- (IBAction)deleteButtonPressed:(id)sender
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Confirm"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Delete"
                                           otherButtonTitles: nil];
    [as showInView:self.view]; 
}

 
#pragma Delegates

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) { 
        case 0: /* Delete Button */ 
            if(self.database == nil) {
                self.database = [DatabaseBrain getDatabase];
            }
        
            /* Only attempt to delete if we're actually updating */
            if(self.updating) {
                [self.database deleteEntryWithUniqueID:self.reminder.uniqueID];
            
                /* Cancel Alarm */
                [self cancelLocalNotificationForReminder:self.reminder];
            }
        
            [self presentReminderView];
            break; 
        case 1: /* Cancel Button */
            [actionSheet dismissWithClickedButtonIndex:1 animated:YES]; 
            break; 
    }
}


#pragma mark - Utility Functions

/* This function adds done buttons and swaps the time keyboard with a UIDatePicker. */
- (void) setupAllTextFields
{
    /* Setup custom keyboard */
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker sizeToFit];
    self.datePicker.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.datePicker.timeZone = [NSTimeZone localTimeZone];
    
    /* Date Value change handle */
    [self.datePicker addTarget:self action:@selector(dateHasChanged:)forControlEvents:UIControlEventValueChanged];
    
    /* Set dates text field to the date picker */
    self.dateTextField.inputView = self.datePicker;
    
    /* Add done toolbar & button for the date picker */
    UIToolbar* datePickerButtonView = [[UIToolbar alloc] init];
    datePickerButtonView.translucent = YES;
    [datePickerButtonView sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(datePickerDoneEditing:)];
    [datePickerButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    /* Add the done button to the text field */
    self.dateTextField.inputAccessoryView = datePickerButtonView;
    
    /* Add done buttons to keyboards */
    self.titleTextField.returnKeyType = UIReturnKeyDone;
    self.detailsTextField.returnKeyType = UIReturnKeyDone;
    self.dateTextField.returnKeyType = UIReturnKeyDone;
    [self.titleTextField addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.detailsTextField addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
}

/* This method will be used if a reminder from the list is selected.
 * Nothing will be used if the "add" button is selected. */
- (void) setReminderData:(ReminderData *)data
{
    self.reminder = data;
    self.updating = YES;
}

- (ReminderData *) createDataFromFields
{
    NSString *title = self.titleTextField.text;
    NSString *details = self.detailsTextField.text;
    ReminderData *newData = [[ReminderData alloc] initWithTitle:title details:details time:self.time];
    
    return newData;
}

- (void) presentReminderView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: STORYBOARD_INDENTITY bundle:nil];
    RemindersViewController *rvc = [storyboard instantiateViewControllerWithIdentifier:REMINDERS_VIEW_INDENTITY];
    
    [self presentViewController:rvc animated:YES completion:nil];
}


#pragma mark - Time Modification Functions

/* This will set the date text field to the current date */
- (void) setTimeToCurrentTime
{
    self.time = [self getGMTDateFromDatePicker];
    [self.dateButton setTitle:[NSString stringWithFormat:@"%@", self.time] forState:UIControlStateNormal];
}

/* This function returns the correct date stored in the DatePicker because it does not
 * account for timezones. This function works for any timezone as long as the system time zone
 * is correct. */
- (NSDate *) getGMTDateFromDatePicker
{
    NSInteger offset = [self getGMTOffsetForDate: [self.datePicker date]];
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:offset sinceDate:[self.datePicker date]];
    
    return destinationDate;
}


/* Returns offset for specific date and system timezone */
- (NSInteger) getGMTOffsetForDate:(NSDate *) date
{
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    
    return destinationGMTOffset;
}


#pragma mark - Local Notification Functions

- (void) setLocalNotificationForReminder:(ReminderData *) data
{
    UILocalNotification *newNotification = [[UILocalNotification alloc] init];
    
    /* Set up notification */
    NSInteger destinationGMTOffset = [self getGMTOffsetForDate:data.time];
    newNotification.fireDate = [data.time dateByAddingTimeInterval:destinationGMTOffset * -1];
    newNotification.timeZone = [NSTimeZone defaultTimeZone];
    newNotification.alertBody = data.title;
    
    /* Use a uniqueID to indentify our notification if it needs to be canceled or updated */
    NSString *objID = [NSString stringWithFormat:@"%lld", data.uniqueID];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:objID forKey:LOCAL_NOTIFCATION_ID];
    newNotification.userInfo = userInfo;
    
    /* Set alarm */
    [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
    
}

- (void) updateLocalNotificationForReminder:(ReminderData *) data
{
    NSString *objID = [NSString stringWithFormat:@"%lld", data.uniqueID];
    for(UILocalNotification *ln in [[UIApplication sharedApplication]scheduledLocalNotifications]) {
        id ID = [ln.userInfo objectForKey:LOCAL_NOTIFCATION_ID];
        if([ID isKindOfClass:[NSString class]]) {
            if([ID isEqualToString:objID]) {
                ln.fireDate = data.time; 
                return; 
            }
        }
    }

    /* Alarm has fired; create new alarm */
    [self setLocalNotificationForReminder:data];
}

- (void) cancelLocalNotificationForReminder:(ReminderData *) data
{
    NSString *objID = [NSString stringWithFormat:@"%lld", data.uniqueID];
    for(UILocalNotification *ln in [[UIApplication sharedApplication]scheduledLocalNotifications]) {
        id ID = [ln.userInfo objectForKey:LOCAL_NOTIFCATION_ID];
        if([ID isKindOfClass:[NSString class]]) {
            if([ID isEqualToString:objID]) {
                [[UIApplication sharedApplication] cancelLocalNotification:ln]; 
            }
        }
    }
    
}

@end
