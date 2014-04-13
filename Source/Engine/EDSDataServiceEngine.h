#import <Foundation/Foundation.h>

@protocol EDSDataServiceEngine <NSObject>

+ (instancetype)fileBasedServiceForDataModelName:(NSString *)dataModelName;
+ (instancetype)inMemoryServiceWithDataModelName:(NSString*)dataModelName;

- (id)createEntityForName:(NSString *)entityName;
- (NSArray *)fetchEntitiesForName:(NSString *)entityName;
- (NSArray *)fetchEntitiesForName:(NSString *)entityName
                    withPredicate:(NSPredicate *)predicate;
- (NSArray *)fetchEntitiesForName:(NSString *)entityName
                         sortedBy:(NSArray *)sortDescriptors;
- (NSArray *)fetchEntitiesForName:(NSString *)entityName
                    withPredicate:(NSPredicate *)predicate
                         sortedBy:(NSArray *)sortDescriptors;

- (id)objectWithId:(id)objectId;
- (BOOL)isEntityDeleted:(id)entity;
- (void)deleteEntity:(id)entity;
- (void)saveAndLogError;

@end
