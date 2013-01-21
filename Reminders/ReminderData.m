//
//  RemindersBrain.m
//  Reminders
//
//  Created by Wilson Giese on 12/22/12.
//  Copyright (c) 2012 Wilson Giese. All rights reserved.
//


/*
 * This is a wrapper class for the data that will be held inside of the
 * SQLite database/table(reminders/reminder)
 */
#import "ReminderData.h"

@implementation ReminderData

@synthesize uniqueID, title, details, time;

- (id) initWithTitle:(NSString* )newTitle details:(NSString *)newDetails time:(NSDate *)newTime
{
    self = [super init];
    if(self) {
        self.title = newTitle;
        self.details = newDetails;
        self.time = newTime;
    }
    
    return self;
}

@end
