#import "Globals.h"
#import "Game.h"
#import "User.h"
@interface Globals()
@property (strong) NSManagedObjectContext *managedObjectContext;

@end
@implementation Globals
static Globals *sharedGlobal = nil;
dispatch_semaphore_t sema;

+ (Globals *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedGlobal = [[Globals alloc] init];
        
        [sharedGlobal setup];
    });
    
    return sharedGlobal;
}

-(void)setup
{

}

-(void)updateCoreData
{
    
    if ([self.managedObjectContext hasChanges]) {
        
        if (![self.managedObjectContext save:nil]) {
            NSLog(@"ABORTING");
        }
    }
}

-(void)updateUser:(User*)user
{
    if (!self.managedObjectContext) {
        self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    }
   
    NSString   *name=user.userName;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        User  *found=[items objectAtIndex:0];
        [found setUserAbilityType:user.userAbilityType];
    }
    
    [self updateCoreData];
}

-(NSManagedObjectID*)gameIDForUser:(User*)user breathDirection:(int)direction hilltype:(int)hilltype
{
    NSManagedObjectContext *managedObjectContext =[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    NSString   *name=user.userName;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        User  *user=[items objectAtIndex:0];
        NSSet  *game=user.game;
        NSArray  *games=[game allObjects];
        
        for (Game *game in games)
        {
            if ([game.gameHillType intValue]==hilltype) {
                
                if ([game.gameDirectionInt intValue]==direction) {
                    NSLog(@"direction == %@",game.gameDirectionInt);

                    return game.objectID;
                }
            }
        }
    }
    
    return nil;
}

-(Game*)gameForUser:(User*)user breathDirection:(int)direction hilltype:(int)hilltype
{
    NSManagedObjectContext *managedObjectContext =[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    NSString   *name=user.userName;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        User  *user=[items objectAtIndex:0];
        NSSet  *game=user.game;
        NSArray  *games=[game allObjects];
    
        for (Game *game in games)
        {
            NSLog(@"direction == %@",game.gameDirectionInt);
            if ([game.gameHillType intValue]==hilltype) {
                
                if ([game.gameDirectionInt intValue]==direction) {
                    return game;
                }
            }
        }
    }
    return nil;
}

@end
