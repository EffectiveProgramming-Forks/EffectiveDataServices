#import "EDSCoreDataServiceEngine.h"

#import <CoreData/CoreData.h>

@interface EDSCoreDataServiceManagedObjectContextMerger : NSObject

@property (nonatomic) NSManagedObjectContext *context;

- (id)initWithContext:(NSManagedObjectContext *)context;

@end

@interface EDSCoreDataServiceEngine ()

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) EDSCoreDataServiceManagedObjectContextMerger *managedObjectContextMerger;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation EDSCoreDataServiceEngine

static NSString *const kSqliteExtension = @"sqlite";

+ (instancetype)fileBasedServiceForDataModelName:(NSString *)dataModelName {
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [self
                                                                setupFileBasedPersistenceCoordinatorWithDataModelName:dataModelName];
    return [[EDSCoreDataServiceEngine alloc] initWithPersistentStoreCoordinator:persistentStoreCoordinator];
}

+ (instancetype)inMemoryServiceWithDataModelName:(NSString*)dataModelName {
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [self
                                                                setupInMemoryPersistenceCoordinatorWithDataModelName:dataModelName];
    return [[EDSCoreDataServiceEngine alloc] initWithPersistentStoreCoordinator:persistentStoreCoordinator];
}

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    self = [super init];
    if (self) {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
        self.persistentStoreCoordinator = persistentStoreCoordinator;
        self.managedObjectContext = managedObjectContext;
        self.managedObjectContextMerger = [[EDSCoreDataServiceManagedObjectContextMerger alloc] initWithContext:managedObjectContext];
    }
    return self;
}

- (void)dealloc {
    self.managedObjectContext = nil;
    self.persistentStoreCoordinator = nil;
}

#pragma mark - API

- (id)createEntityForName:(NSString *)entityName {
    return [EDSCoreDataServiceEngine createEntityForName:entityName
                                           inContext:self.managedObjectContext];
}

- (NSArray *)fetchEntitiesForName:(NSString *)entityName {
    return [EDSCoreDataServiceEngine fetchEntitiesForName:entityName
                                        withPredicate:nil
                                             sortedBy:nil
                                            inContext:self.managedObjectContext];
}

- (NSArray *)fetchEntitiesForName:(NSString *)entityName
                    withPredicate:(NSPredicate *)predicate {
    return [EDSCoreDataServiceEngine fetchEntitiesForName:entityName
                                        withPredicate:predicate
                                             sortedBy:nil
                                            inContext:self.managedObjectContext];
}

- (NSArray *)fetchEntitiesForName:(NSString *)entityName
                         sortedBy:(NSArray *)sortDescriptors {
    return [EDSCoreDataServiceEngine fetchEntitiesForName:entityName
                                        withPredicate:nil
                                             sortedBy:sortDescriptors
                                            inContext:self.managedObjectContext];
}

- (NSArray *)fetchEntitiesForName:(NSString *)entityName
                    withPredicate:(NSPredicate *)predicate
                         sortedBy:(NSArray *)sortDescriptors {
    return [EDSCoreDataServiceEngine fetchEntitiesForName:entityName
                                        withPredicate:predicate
                                             sortedBy:sortDescriptors
                                            inContext:self.managedObjectContext];
}

- (id)objectWithId:(NSManagedObjectID *)managedObjectId {
    return [self.managedObjectContext objectWithID:managedObjectId];
}

- (BOOL)isEntityDeleted:(NSManagedObject *)entity {
    return ([self.managedObjectContext existingObjectWithID:entity.objectID error:nil] == nil);
}

- (void)deleteEntity:(NSManagedObject *)entity {
    [self.managedObjectContext deleteObject:entity];
}

- (void)saveAndLogError {
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    if (!success) {
        NSLog(@"Could not save core data managed object context. %@", error);
    }
}

//- (NSManagedObjectContext *)defaultContext {
//    return defaultManagedObjectContext;
//}
//
//- (NSManagedObjectContext *)temporaryContext {
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
//    context.persistentStoreCoordinator = persistentStoreCoordinator;
//    return context;
//}

#pragma mark - Private

+ (NSURL*)localDocumentsURL {
    NSURL *directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject];
	return directory;
}

+ (NSPersistentStoreCoordinator*)setupInMemoryPersistenceCoordinatorWithDataModelName:(NSString*)dataModelName {
    
	// errors
	NSError *error = nil;
    
	// data model
    NSURL *dataModelURL = [[NSBundle mainBundle] URLForResource:dataModelName withExtension:@"momd"];
	NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:dataModelURL];
    
	// data store
	NSPersistentStoreCoordinator *coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
	NSPersistentStore *store = [coord addPersistentStoreWithType:NSInMemoryStoreType
												   configuration:nil
															 URL:nil
														 options:nil
														   error:&error];
    
	// check for errors
	if (store == nil) {
//        NSLog(@"ERROR: could not create datastore: %@", error);
//        NSString *title = NSLocalizedString(@"EDSCoreDataService.Error.CouldNotCreate.Title", nil):
//        NSString *message = NSLocalizedString(@"EDSCoreDataService.Error.CouldNotCreate.Message", nil);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:nil];
//        [alert show];
	}
    
	return coord;
}

+ (NSPersistentStoreCoordinator*)setupFileBasedPersistenceCoordinatorWithDataModelName:(NSString*)dataModelName {
    
	// errors
	NSError *error = nil;
    
	// data model
    NSURL *dataModelURL = [[NSBundle mainBundle] URLForResource:dataModelName withExtension:@"momd"];
	NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:dataModelURL];
	
	// data store
    NSURL *documentsURL = [self localDocumentsURL];
    NSURL *dataStoreURL = [documentsURL URLByAppendingPathComponent:dataModelName];
    dataStoreURL = [dataStoreURL URLByAppendingPathExtension:kSqliteExtension];
	NSPersistentStoreCoordinator *coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @(YES), NSMigratePersistentStoresAutomaticallyOption,
							 @(YES), NSInferMappingModelAutomaticallyOption, nil];
	NSPersistentStore *store = [coord addPersistentStoreWithType:NSSQLiteStoreType
												   configuration:nil
															 URL:dataStoreURL
														 options:options
														   error:&error];
    
	// check for errors
	if (store == nil) {
//        ELOG(error, @"ERROR: could not create datastore.");
//        NSString *title = NSLocalizedString(@"EDSCoreDataService.Error.CouldNotCreate.Title", nil);
//        NSString *message = NSLocalizedString(@"EDSCoreDataService.Error.CouldNotCreate.Message", nil);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:nil];
//        [alert show];
	}
    
	return coord;
}

+ (id)createEntityForName:(NSString *)entityName
                inContext:(NSManagedObjectContext *)context {
    id entity = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                              inManagedObjectContext:context];
    return entity;
}

+ (NSArray *)fetchEntitiesForName:(NSString *)entityName
                    withPredicate:(NSPredicate *)predicate
                         sortedBy:(NSArray *)sortDescriptors
                        inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if (predicate) {
        fetchRequest.predicate = predicate;
    }
    if (sortDescriptors) {
        fetchRequest.sortDescriptors = sortDescriptors;
    }
    NSError *error = nil;
    NSArray *entities = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"ERROR: (%@) %s [Line %d] Could not fetch entities of class'%@'", error, __PRETTY_FUNCTION__, __LINE__, entities);
    }
    return entities;
}

@end

@implementation EDSCoreDataServiceManagedObjectContextMerger

- (id)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
	if (self) {
        self.context = context;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(mergeChanges:)
													 name:NSManagedObjectContextDidSaveNotification
												   object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mergeChanges:(NSNotification *)notification {
    NSManagedObjectContext *notificationContext = notification.object;
    if (notificationContext != self.context) {
        if ([notificationContext.persistentStoreCoordinator isEqual:self.context.persistentStoreCoordinator]) {
            [self.context performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                           withObject:notification
                                        waitUntilDone:YES];
        }
    }
}

@end
