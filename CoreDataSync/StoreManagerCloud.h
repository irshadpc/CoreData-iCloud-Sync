//
//  StoreManagerCloud.h
//
//  Created by IRSHAD PC on 24/05/16.
//  Copyright © 2016 IRSHAD PC. All rights reserved.
//


@import CoreData;

/**
 * Manager for Core Data Store 
 */
@interface StoreManagerCloud : NSObject

//------------------------------------------------------------------------------
/// @name Properties
//------------------------------------------------------------------------------


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//------------------------------------------------------------------------------
/// @name Methods
//------------------------------------------------------------------------------

/** Singleton instance
 * @return An instance of the core data stack helper
 */
+ (instancetype)sharedStoreManagerCloud;

/**
 * Create the Core Data stack 
 */
- (void)setupManagedObjectContext;

/**
 * Returns the URL to the application's Documents directory
 * @return An NSURL of the path
 */
- (NSURL*)modelURL;

/**
 *
 */
- (void)saveContext;

@end
