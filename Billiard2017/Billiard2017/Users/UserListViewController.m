#import "UserListViewController.h"
#import "User.h"
#import "Game.h"
#import "HeaderView.h"
#import "GraphViewController.h"
#import "PlotItem.h"
#import "CurvedScatterPlot.h"
#import "AllGamesForDayTableVC.h"
#import "GCDQueue.h"
#import "DataChart.h"
//#import "Billiard2017-Bridging-Header.h"
#import "Billiard2017.pch"
#import "AAChartKit.h"

@interface UserListViewController()<UIActionSheetDelegate,HeaderViewProtocl>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIBarButtonItem *activityIndicator;
@property (nonatomic) NSMutableArray *userList;
@property(nonatomic,strong)GraphViewController *graph;
@property(nonatomic,strong)ChartsViewController *chart; 
@property(nonatomic,assign)User  *deleteUser;
@end

@implementation UserListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSArray*)sortedDateArrayForUser:(User*)user
{
    NSArray *alldates=[user.game allObjects];
    NSArray *sortedArray = [alldates sortedArrayUsingComparator:
                            ^(id obj1, id obj2)
                            {
                                return [(NSDate*) [obj1 valueForKey:@"gameDate" ] compare: (NSDate*)[obj2 valueForKey:@"gameDate"]];
                            }
                            ];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];
    NSMutableArray  *datesstrings=[NSMutableArray new];
    
    for (int i=0; i<[sortedArray count]; i++) {
        NSDate  *date=[[sortedArray objectAtIndex:i]valueForKey:@"gameDate"];
        [datesstrings addObject:[formatter stringFromDate:date]];
    }

    NSArray *cleanedArray = [[NSSet setWithArray:datesstrings] allObjects];
    NSMutableArray *mutable=[[NSMutableArray alloc]initWithArray:cleanedArray];
    [mutable sortUsingSelector:@selector(compare:)];
    return mutable;
}

-(int)uniquedatesForUser:(User*)user
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];
    
    NSMutableArray  *datesstrings=[NSMutableArray new];
    NSArray *alldates=[user.game allObjects];
    for (int i=0; i<[user.game count]; i++) {
        NSDate  *date=[[alldates objectAtIndex:i]valueForKey:@"gameDate"];
        [datesstrings addObject:[formatter stringFromDate:date]];
    }
    NSArray *cleanedArray = [[NSSet setWithArray:datesstrings] allObjects];
    NSMutableArray *mutable=[[NSMutableArray alloc]initWithArray:cleanedArray];
    [mutable sortUsingSelector:@selector(compare:)];
    
    return [mutable count];
}

- (void) viewWillLayoutSubviews {
    
    
  
    

    
    
    //UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    //self.navigationItem.leftBarButtonItem = backBarButtonItem;
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    ///self.navigationController.navigationBar.shadowImage = [UIImage new];
    //self.navigationController.navigationBar.translucent = YES;
    //[self.navigationController.navigationBar setAlpha:0];
    
    //self.navigationController.navigationBar.translucent = NO;
    //[self.navigationController.navigationBar setAlpha:10];
    
    //[self.view addSubview:backButtonView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
   // [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
   // self.navigationController.navigationBar.shadowImage = [UIImage new];
   // self.navigationController.navigationBar.translucent = YES;
   // [self.navigationController.navigationBar setAlpha:0];
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];

    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setAlpha:10];
    
  
}
    
- (void)viewDidLoad
{
    self.userList=[NSMutableArray new];
    [self managedObjectContext];
    [super viewDidLoad];
    
    [self getListOfUsers];
    
   // [self.view addSubview:backButton];
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(  UISwipeGestureRecognizerDirectionLeft)];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    // [backButton setBackgroundColor: [UIColor colo]];
    backButton.frame = CGRectMake(0, 0, 150, 160);
    backButton.bounds = CGRectOffset(backButton.bounds, -174, -20);
    
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(-20, 10, 3, 3)];
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 24, 97);
    [backButtonView addSubview:backButton];
    
    
    [backButton addTarget:self
                   action:@selector(goBack)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    
    
    //UIBarButtonItem *btnReload = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(goBack:)];
    //self.navigationController.topViewController.navigationItem.leftBarButtonItem = backButton;
    //btnReload.enabled=TRUE;
    //btnReload.style=UIBarButtonSystemItemRefresh;
    
    //[self.navigationController.navigationBar addSubview:backButton];
}



-(void)remove{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)goBack
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate userListDismissRequest:self];
    });
    

}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe received.");
}

-(void)getListOfUsers
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        self.userList=[NSMutableArray arrayWithArray:items];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLog(@"title");
    User  *user=[self.userList objectAtIndex:section];
    NSString  *title=[user valueForKey:@"userName"];
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int sections = [self.userList count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    User *user=[self.userList objectAtIndex:section];
    numberOfRows=[user.game count];
    return  [self uniquedatesForUser:user];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    User  *user=[self.userList objectAtIndex:indexPath.section];

    NSArray  *dates=[self sortedDateArrayForUser:user];
    dates=[[dates reverseObjectEnumerator]allObjects];
    NSString *stringFromDate =[dates objectAtIndex:indexPath.row];
    cell.textLabel.text= stringFromDate;

    return cell;
}

-(NSArray*)gamesMatchingDate:(NSString*)date user:(User*)user
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];
    
    NSPredicate *shortNamePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Game *game=(Game*)evaluatedObject;
        NSDate *gamedate=[game gameDate] ;
        NSString  *datestring=[formatter stringFromDate:gamedate];
        return [datestring isEqualToString:date];
        return YES;
    }];
    
    NSArray *unfiltered=[user.game allObjects];
    NSArray *filtered=[unfiltered filteredArrayUsingPredicate:shortNamePredicate];
    NSMutableArray * tempcopy = [[NSMutableArray alloc] init];
    
    [tempcopy addObjectsFromArray:unfiltered];
    [tempcopy sortUsingDescriptors:
    [NSArray arrayWithObjects:
    [NSSortDescriptor sortDescriptorWithKey:@"gameDate" ascending:YES],nil]];
    
    return filtered;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user=[self.userList objectAtIndex:indexPath.section];
    NSArray  *dates=[self sortedDateArrayForUser:user];

    dates=[[dates reverseObjectEnumerator]allObjects];
    AllGamesForDayTableVC  *detailViewController=[[AllGamesForDayTableVC alloc]initWithNibName:@"AllGamesForDayTableVC" bundle:nil];
    NSArray *array = [self gamesMatchingDate:[dates objectAtIndex:indexPath.row] user:user];
    
    NSMutableArray  *durationOnly=[NSMutableArray new];
    
    for (Game *agame in array) {
        [durationOnly addObject:agame];
    }

    [detailViewController setUSerData:durationOnly];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
     NSLog(@"controllerDidChangeContent");
    [self.tableView reloadData];
}

#pragma mark - Core Data stack

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    if (self.sharedPSC != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.sharedPSC];
    }
    
    // observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    
    return _managedObjectContext;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    HeaderView *header = [[HeaderView alloc]initWithFrame:CGRectMake(30, 0, 550, 30)];
    header.section = section;
    header.user=[self.userList objectAtIndex:section];
    header.delegate=self;
    [header build];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 43;
}

-(void)deleteMember:(HeaderView *)header
{
    self.deleteUser=[self.userList objectAtIndex:header.section];
    
    NSString *message=[NSString stringWithFormat:@"Delete User ' %@ '", self.deleteUser.userName];
    UIAlertView  *alert=[[UIAlertView alloc]initWithTitle:@"Confirm" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.managedObjectContext deleteObject:self.deleteUser];
        [self.managedObjectContext save:nil];
    }
}

-(void)viewHistoricalData:(HeaderView *)header
{
    //self.graph=[[GraphViewController alloc]initWithNibName:@"GraphViewController" bundle:nil];
    User *user=[self.userList objectAtIndex:header.section];
    NSArray * src=[user.game allObjects];
    NSMutableArray  *durationOnly=[NSMutableArray new];
    
    for (Game *agame in src) {
        if ([agame.gameType intValue]==2) {
            [durationOnly addObject:agame];
        }
    }

    NSUInteger count=[[user.game allObjects]count];
    
    if (count==0) {
        UIAlertView  *alert=[[UIAlertView alloc]initWithTitle:@"No Data" message:@"No data for this user yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        return;
    }
    
    //self.chart = [[ChartsViewController alloc]initWithNibName:@"ChartsViewController" bundle:nil];
    //self.chart = [[ChartsViewController alloc]init:@"ChartsViewController" bundle:nil withData:durationOnly withUser:user];
    self.chart = [[ChartsViewController alloc]init:@"ChartsViewController" bundle:nil withData:durationOnly withUser:user withHeight:self.view.bounds.size.height withWidth:self.view.bounds.size.width];
    
    //self.dataChart=[[DataChart alloc]initWithNibName:@"DataChart" bundle:nil];
    //ChartsViewController  *plot=[[ChartsViewController alloc]init];

    //CurvedScatterPlot  *plot=[[CurvedScatterPlot alloc]init];
    //[plot setUser:user];
    
    //[[GCDQueue mainQueue]queueBlock:^{
    //    [self.graph setDetailItem:plot];
   // }];
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:Remove_CurrentView object:nil];
    
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remove) name:Remove_CurrentView object:nil];
    

    [self.navigationController pushViewController:self.chart animated:YES];
}

- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    [self getListOfUsers];
}

- (void)mergeChanges:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user=[self.userList objectAtIndex:indexPath.section];
    [self.managedObjectContext deleteObject:user];
    [self.managedObjectContext save:nil];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didEndEditingRowAtIndexPath");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
