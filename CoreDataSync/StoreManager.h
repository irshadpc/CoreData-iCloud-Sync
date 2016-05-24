//
//  StoreManager.h
//
//  Created by IRSHAD PC on 24/05/16.
//  Copyright © 2016 IRSHAD PC. All rights reserved.
//

@import CoreData;

/**
 * Manager for Core Data Store
 */
@interface StoreManager : NSObject

//------------------------------------------------------------------------------
/// @name Properties
//------------------------------------------------------------------------------
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *model;
@property (strong, nonatomic) NSString *store;
@property BOOL iCloud;

//------------------------------------------------------------------------------
/// @name Methods
//------------------------------------------------------------------------------
/** Singleton instance
 * @return An instance of the core data stack helper
 */
+ (instancetype)sharedStoreManager;

/**
 * Create the Core Data stack
 */
- (void)setupManagedObjectContext;

- (void)setUpStore:(NSString*)store model:(NSString*)model iCloud:(BOOL)iCloud;

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
