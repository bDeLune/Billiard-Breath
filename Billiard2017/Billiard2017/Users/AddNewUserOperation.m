#import "AddNewUserOperation.h"
#import "User.h"
NSString *kAddNewUserOperationUserExistsError = @"ExistsError";
NSString *kAddNewUserOperationUserError = @"GeneralError";
NSString *kAddNewUserOperationUserAdded = @"UserAdded";

@interface AddNewUserOperation ()
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,strong)NSString *username;
@end

@implementation AddNewUserOperation
- (id)initWithData:(NSString *)username sharedPSC:(NSPersistentStoreCoordinator *)psc
{
    self = [super init];
    if (self) {
      
     self.sharedPSC = psc;
        self.username=username;
    }
    return self;

}

- (void)main {

    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    [self addTheUser];
}

-(void)addTheUser
{
    User* newTask = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [newTask setUserName:self.username];
    NSError  *error;
    
    if ([self.managedObjectContext hasChanges]) {
        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
