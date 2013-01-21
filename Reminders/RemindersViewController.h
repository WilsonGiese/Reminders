//
//  RemindersViewController.h
//  Reminders
//
//  Created by Wilson Giese on 12/21/12.
//  Copyright (c) 2012 Wilson Giese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemindersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSArray *listItems; 
}

@property (strong, nonatomic) NSArray *listItems;

@end
