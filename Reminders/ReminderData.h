//
//  RemindersBrain.h
//  Reminders
//
//  Created by Wilson Giese on 12/22/12.
//  Copyright (c) 2012 Wilson Giese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReminderData : NSObject {
    long long uniqueID;
    NSString *title;
    NSString *details;
    NSDate *time;
}

/* uniqueID is a long long because sqlite integers are stored with 64 bits */
@property (nonatomic, assign) long long uniqueID;  
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, copy) NSDate *time;

- (id) initWithTitle:(NSString* )newTitle details:(NSString *)newDetails time:(NSDate *)newTime;

@end
