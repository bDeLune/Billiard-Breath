#import "ViewController.h"
#import "AddNewUserOperation.h"
#import "User.h"
#import "Game.h"
#import "GameViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic,strong) LoginViewController *loginViewController;
@property (nonatomic,strong) GameViewController *gameViewController;
@property (nonatomic,strong) User  *currentUser;
@property (nonatomic,strong) Game  *currentGame;
@property (nonatomic,strong) UIImageView *startupImageView;
@property (nonatomic,strong) UIImageView *btOnOfImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self managedObjectContext];
    [self addUserLoginViewController];
}

-(void)removeStartupImage:(NSTimer*)timer
{
    [timer invalidate];
    timer=nil;
    
    [UIView animateWithDuration:3.0 animations:^{
        _startupImageView.alpha=0.0;
    } completion:^(BOOL finished){
        [_startupImageView removeFromSuperview];
        _startupImageView=nil;
    }];
}

-(void)addUserLoginViewController
{
    if (!self.loginViewController) {
        self.loginViewController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    }
    
    [self.view addSubview:self.loginViewController.view];
    self.loginViewController.sharedPSC=self.persistentStoreCoordinator;
    self.loginViewController.delegate=self;
}

#pragma mark -
#pragma mark - Add User Notifications

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - Core Data

- (NSString *)applicationDocumentsDirectory {
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BilliardBreath" withExtension:@"mom"]; //was mom
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"BilliardBreath.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"Please remove current version of Billiard Breath and reinstall" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    
    if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

#pragma mark -
#pragma mark - Orientation
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return (UIInterfaceOrientationMaskLandscape);
}

#pragma mark -
#pragma mark - Login Delegate

-(void)LoginSucceeded:(LoginViewController*)viewController user:(User*)user
{
    self.currentUser=user;
    
    if (!self.gameViewController) {
        self.gameViewController=[[GameViewController alloc]initWithNibName:@"GameViewController" bundle:nil];
        self.gameViewController.delegate=self;
    }
    
    [UIView transitionFromView:self.loginViewController.view toView:self.gameViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished){
        self.gameViewController.gameUser=user;
        [self.gameViewController setLabels];
        self.gameViewController.sharedPSC=self.persistentStoreCoordinator;
        [self.gameViewController resetGame:nil];
        
    }];
}

-(void)gameViewExitGame
{
    [UIView transitionFromView:self.gameViewController.view toView:self.loginViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished){
        
    }];
}
@end
