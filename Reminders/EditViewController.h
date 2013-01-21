//
//  EditViewController.h
//  Reminders
//
//  Created by Wilson Giese on 12/27/12.
//  Copyright (c) 2012 Wilson Giese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderData.h"

@interface EditViewController : UIViewController <UIActionSheetDelegate> {
    IBOutlet UITextField  *titleTextField;
    IBOutlet UITextField  *detailsTextField;
    IBOutlet UIButton     *dateButton;
    IBOutlet UIButton     *deleteButton; 
    
}

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *detailsTextField;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

/* This is the only function that need to be used by other classes */ 
- (void) setReminderData:(ReminderData *) data;
@end
