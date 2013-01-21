//
//  DatabaseBrain.m
//  Reminders
//
//  Created by Wilson Giese on 12/26/12.
//  Copyright (c) 2012 Wilson Giese. All rights reserved.
//

#import "DatabaseBrain.h"
#import "ReminderData.h" 

@implementation DatabaseBrain

#define DATABASE @"remindersDB"

static DatabaseBrain *database;


#pragma mark - DatabaseBrain
/* A single instance of Database will be used */ 
+ (DatabaseBrain *) getDatabase;
{
    if(!database) {
        database = [[DatabaseBrain alloc] init]; 
    }
    return database;
}

- (id) init
{
    self = [super init];
    if(self) {
        NSString *sqliteDB = [[NSBundle mainBundle] pathForResource:DATABASE ofType:@"sqlite3"];
        
        if(sqlite3_open([sqliteDB UTF8String], &database) != SQLITE_OK) {
            NSLog(@"Failed to open SQLite DB");
        }
    }
    
    return self;
}


#pragma mark - Database Interaction Functions

- (NSArray *) getAllEntries
{
    sqlite3_stmt *statement;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    char *selectCommand = "SELECT * FROM reminder";
    
    int e = sqlite3_prepare_v2(database, selectCommand, -1, &statement, nil);
    if(e == SQLITE_OK) {
        while (sqlite3_step(statement) ==  SQLITE_ROW) {
            int uniqueID = sqlite3_column_int(statement, 0);
            int time = sqlite3_column_int(statement, 3);
            
            /* Note: sqlite3_column_text returns standard C arrays */ 
            NSString *title = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
            NSString *details = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            
            ReminderData *data = [[ReminderData alloc] initWithTitle:title details:details time:[[NSDate alloc] initWithTimeIntervalSince1970:time]];
            data.uniqueID = uniqueID; 
            [array addObject:data];
        }
    } else {
        NSLog(@"Problem with getAllEntries");
        NSLog(@"Error Code: %d, message '%s'", e, sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    
    return array;
}

/* Use this method to add a new entry */
/* DB table format: (uniqueID integer autoincrement, title text not null, details text, time integer) */ 
- (long long) insertEntry:(ReminderData *)newData
{
    sqlite3_stmt *statement;
    char *insertCommand = "INSERT INTO reminder VALUES(null,?,?,?)"; /* First value is an autoinc id */
    
    int e = sqlite3_prepare_v2(database, insertCommand, -1, &statement, nil); 
    if(e != SQLITE_OK) {
        NSLog(@"Problem with insertEntry");
        NSLog(@"Error Code: %d, message '%s'", e, sqlite3_errmsg(database)); 
        return 0;
    }
    
    /* Bind values insert string */
    sqlite3_bind_text(statement, 1, [newData.title UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [newData.details UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 3, [newData.time timeIntervalSince1970]);
    
    /* Insert data */
    if(sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"Problems inserting data into reminder"); 
    } 
    
    /* Finished */ 
    sqlite3_finalize(statement);
    
    /* Return the uniqueID; the only unknown of newData */ 
    return sqlite3_last_insert_rowid(database);
}

- (void) deleteEntryWithUniqueID:(int)uniqueID
{
    sqlite3_stmt *statement;
    char *deleteCommand = "DELETE FROM reminder WHERE uniqueID = ?";
    
    int e = sqlite3_prepare_v2(database, deleteCommand, -1, &statement, nil);
    if(e != SQLITE_OK) {
        NSLog(@"Problem with deleteEntryWithUniqueID"); 
        NSLog(@"Error Code: %d, message '%s'", e, sqlite3_errmsg(database)); 
        return;
    } 
    
    sqlite3_bind_int(statement, 1, uniqueID);
    
    if(sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"Problems deleting entry from reminder");
    }
    
    /* Finished */ 
    sqlite3_finalize(statement);
}

/* Updates an entry in the DB */ 
- (void) updateEntryData:(ReminderData *)data
{
    sqlite3_stmt *statement; 
    char *updateCommand = "UPDATE reminder SET title = ?, details = ?, time = ? WHERE uniqueID = ?";
    
    int e = sqlite3_prepare_v2(database, updateCommand, -1, &statement, nil);
    if(e != SQLITE_OK) {
        NSLog(@"Problem with updateEntryWithUniqueID");
        NSLog(@"Error Code: %d, message '%s'", e, sqlite3_errmsg(database));
        return;
    }
    
    sqlite3_bind_text(statement, 1, [data.title UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [data.details UTF8String], -1, SQLITE_TRANSIENT); 
    sqlite3_bind_int(statement, 3, [data.time timeIntervalSince1970]);
    sqlite3_bind_int(statement, 4, data.uniqueID);
    
    if(sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"Problems updating entry in reminder");
    }
    
    /* Finished */ 
    sqlite3_finalize(statement);
}

- (void) closeDatabase
{
    sqlite3_close(database);
    database = nil; 
}

@end
