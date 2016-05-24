//
//  StoreManager.m
//
//  Created by IRSHAD PC on 24/05/16.
//  Copyright © 2016 IRSHAD PC. All rights reserved.
//


@import CoreData;

#import "StoreManager.h"

//------------------------------------------------------------------------------
#pragma mark - Class Extension
//------------------------------------------------------------------------------
@interface StoreManager ()
@end


@implementation StoreManager

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

+ (instancetype)sharedStoreManager
{
    static dispatch_once_t pred;
    static StoreManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    if ( self = [super init] ) {}
    return self;
}

- (void)setUpStore:(NSString*)store model:(NSString*)model iCloud:(BOOL)iCloud
{
    _model = model;
    _store = store;
    _iCloud = iCloud;
    [self setupManagedObjectContext];
}

//------------------------------------------------------------------------------
#pragma mark - Paths
//------------------------------------------------------------------------------

- (NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource:self.model withExtension:@"momd"];
}

- (NSURL*)storeURL
{
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [applicationDocumentsDirectory URLByAppendingPathComponent:self.store];
}


//------------------------------------------------------------------------------
#pragma mark - Core Data Stack
//------------------------------------------------------------------------------

- (void)setupManagedObjectContext
{
    NSError *error;
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self modelURL]];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                       configuration:nil
                                                                                 URL:[self storeURL]
                                                                             options:nil
                                                                               error:&error];
    CDLog([error localizedDescription],@"Error: %@",[error localizedDescription]);
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            CDLog(error,@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    
}

@end
