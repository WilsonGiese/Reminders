//
//  DatabaseBrain.h
//  Reminders
//
//  Created by Wilson Giese on 12/26/12.
//  Copyright (c) 2012 Wilson Giese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"
#import "ReminderData.h"


@interface DatabaseBrain : NSObject {
    sqlite3 *database;
}

+ (DatabaseBrain *) getDatabase;
- (NSArray *) getAllEntries;
- (long long) insertEntry:(ReminderData *) newData;
- (void) deleteEntryWithUniqueID:(int) uniqueID;
- (void) updateEntryData:(ReminderData *) data;
- (void) closeDatabase; 

@end
