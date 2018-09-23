//
//  AddNewUserOperation.m
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

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
    
    // Creating context in main function here make sure the context is tied to current thread.
    // init: use thread confine model to make things simpler.
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
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during development. If it is not possible to recover from the error, display an alert
            // panel that instructs the user to quit the application by pressing the Home button.
            //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }


}

-(void)addUserFailed:(NSString*)withMessage
{

}
-(void)addUserSucceeded
{

}
@end
