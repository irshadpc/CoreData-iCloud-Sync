//
//  StoreManagerCloud.m
//
//  Created by IRSHAD PC on 24/05/16.
//  Copyright © 2016 IRSHAD PC. All rights reserved.
//


@import CoreData;
#import "StoreManagerCloud.h"

static NSString* const kCoreDataModel = @"CoreDataSync";
static NSString* const kCoreDataStore = @"coredatasync.sql";

//------------------------------------------------------------------------------
#pragma mark - Class Extension
//------------------------------------------------------------------------------
@interface StoreManagerCloud ()
@end


@implementation StoreManagerCloud
//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------
+ (instancetype)sharedStoreManagerCloud
{
    static dispatch_once_t pred;
    static StoreManagerCloud *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init
{
    if ( self = [super init] ) {
        [self registerForiCloudNotifications];
        [self setupManagedObjectContext];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//------------------------------------------------------------------------------
#pragma mark - Paths
//------------------------------------------------------------------------------
- (NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource:kCoreDataModel withExtension:@"momd"];
}

- (NSURL*)storeURL
{
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager]
                                             URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]
                                            lastObject];
    return [applicationDocumentsDirectory URLByAppendingPathComponent:kCoreDataStore];
}

- (NSDictionary *)iCloudPersistentStoreOptions
{
    return @{NSPersistentStoreUbiquitousContentNameKey: @"iCloudStore"};
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
    self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                       configuration:nil
                                                                                 URL:[self storeURL]
                                                                             options:[self iCloudPersistentStoreOptions]
                                                                               error:&error];
    CDLog([error localizedDescription],@"Error: %@",[error localizedDescription]);
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    
}


//------------------------------------------------------------------------------
#pragma mark - iCloud Notification Observers
//------------------------------------------------------------------------------

- (void)registerForiCloudNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
    // The store will change from iCloud account change
    [notificationCenter addObserver:self
                           selector:@selector(storesWillChange:)
                               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                             object:self.persistentStoreCoordinator];
    
    // The store has been configured and is ready for use (also called from iCloud account change)
    [notificationCenter addObserver:self
                           selector:@selector(storesDidChange:)
                               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                             object:self.persistentStoreCoordinator];
    
    // iCloud is enable and is sending/retreiving data
    [notificationCenter addObserver:self
                           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                             object:self.persistentStoreCoordinator];
    
   
}


//------------------------------------------------------------------------------
# pragma mark - iCloud Support Notification Selectors
//------------------------------------------------------------------------------

// /github.com/mluisbrown/iCloudCoreDataStack/blob/master/iCloudCoreDataStack/PersistentStack.m
- (void) persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)changeNotification
{
    CDLog(YES,@"%s", __PRETTY_FUNCTION__);
    CDLog(YES,@"%@", changeNotification.userInfo.description);
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:changeNotification];
        
        // For demonstration purposes, log out the changes
        NSDictionary *changes = changeNotification.userInfo;
        NSMutableSet *allChanges = [NSMutableSet new];
        [allChanges unionSet:changes[NSInsertedObjectsKey]];
        [allChanges unionSet:changes[NSUpdatedObjectsKey]];
        [allChanges unionSet:changes[NSDeletedObjectsKey]];
        
        for (NSManagedObjectID *objID in allChanges) {
            // do whatever you need to with the NSManagedObjectID
            // you can retrieve the object from with [moc objectWithID:objID]
            CDLog(YES, @"Object Changed from iCloud: %@",[self.managedObjectContext objectWithID:objID]);
        }
        
    }];
}

// Subscribe to NSPersistentStoreCoordinatorStoresWillChangeNotification
// most likely to be called if the user enables / disables iCloud
// (either globally, or just for your app) or if the user changes
// iCloud accounts.
- (void)storesWillChange:(NSNotification *)notification
{
    CDLog(nil,@"StoreWillChange");
    NSManagedObjectContext *context = self.managedObjectContext;
	
    [context performBlockAndWait:^{
        NSError *error;
        if ([context hasChanges]) {
            BOOL success = [context save:&error];
            
            if (!success && error) {
                // perform error handling
                CDLog([error localizedDescription],@"%@",[error localizedDescription]);
            }
        }
        [context reset];
    }];
    
    // now reset your UI to be prepared for a totally different
    // set of data (eg, popToRootViewControllerAnimated:)
    // but don't load any new data yet.
}

// Subscribe to NSPersistentStoreCoordinatorStoresDidChangeNotification
- (void)storesDidChange:(NSNotification *)notification
{
    CDLog(YES,@"iCloud store did change with notfication:%@",notification);
    // here is when you can refresh your UI and load new data from the new store
}


- (void)iCloudAccountAvailabilityChanged:(NSNotification*)note
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.alertBody = [NSString stringWithFormat:@"Background"];
        localNotif.alertAction = NSLocalizedString(@"Read Message", nil);
        localNotif.soundName = @"alarmsound.caf";
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}



//------------------------------------------------------------------------------
#pragma mark - Migrate iCloud To Local
//------------------------------------------------------------------------------

- (void)migrateiCloudStoreToLocalStore
{
    // assuming you only have one store.
    NSPersistentStore *store = [[self.persistentStoreCoordinator persistentStores] firstObject];
    NSMutableDictionary *localStoreOptions = [[self iCloudPersistentStoreOptions] mutableCopy];
    [localStoreOptions setObject:@YES forKey:NSPersistentStoreRemoveUbiquitousMetadataOption];
    NSPersistentStore *newStore =  [self.persistentStoreCoordinator migratePersistentStore:store
                                                                                     toURL:[self storeURL]
                                                                                   options:localStoreOptions
                                                                                  withType:NSSQLiteStoreType error:nil];
    [self reloadStore:newStore];
}

- (void)rebuildFromiCloud
{
    NSMutableDictionary *localStoreOptions = [[self iCloudPersistentStoreOptions] mutableCopy];
    [localStoreOptions setObject:@YES forKey:NSPersistentStoreRebuildFromUbiquitousContentOption];
}

- (void)startOver
{
    CDLog(YES,@"Removing old store");
    NSError *error;
    [NSPersistentStoreCoordinator removeUbiquitousContentAndPersistentStoreAtURL:[self storeURL]
                                                                         options:[self iCloudPersistentStoreOptions] error:&error];
    //NSAssert(error,@"The persistent store couldn't be removed");
    CDLog(error, @"ERROR | -startOver %@",[error localizedDescription]);
}

- (void)reloadStore:(NSPersistentStore *)store
{
    if (store) {
        [self.persistentStoreCoordinator removePersistentStore:store error:nil];
    }
    
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:[self storeURL]
                                                        options:[self iCloudPersistentStoreOptions]
                                                          error:nil];
}

@end
