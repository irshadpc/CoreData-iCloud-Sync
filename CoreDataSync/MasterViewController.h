//
//  MasterViewController.h
//  CoreDataSync
//
//  Created by IRSHAD PC on 24/05/16.
//  Copyright © 2016 IRSHAD PC. All rights reserved.
//


#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
