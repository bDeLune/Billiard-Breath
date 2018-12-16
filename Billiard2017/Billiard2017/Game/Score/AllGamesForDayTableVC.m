#import "AllGamesForDayTableVC.h"
#import "Game.h"

@interface AllGamesForDayTableVC ()
{
    NSArray  *data;
    User *currentUser;
}

@end

@implementation AllGamesForDayTableVC

-(void)setUSerData:(NSArray*)games
{
    data=games;
    
    [self.tableView reloadData];
}

-(void)setUSerInfo:(User*)user{
    
    currentUser = user;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Game *game=[data objectAtIndex:indexPath.row];
    NSDate  *date=game.gameDate;
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    [dateFormat1 setDateFormat:@"d MMM y"];
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"H:mm:ss"];
    
    NSString *attemptDateString1 = [dateFormat1 stringFromDate:date];
    NSString *attemptDateString2 = [dateFormat2 stringFromDate:date];
    
    int gameType=[game.gameType intValue];
    
    NSString  *typeString;
    NSString  *directionstring;
    
    if (gameType==0) {
        typeString=@"Sequence Game";
    }else if (gameType==1)
    {
        typeString=@"Power Game";
    }else if (gameType==2)
    {
        typeString=@"Duration Game";
    }
    
    if ([game.gameDirection isEqual:@"exhale"])
    {
        directionstring = @"Exhale";
    }else if ([game.gameDirection  isEqual: @"inhale"]){
        directionstring = @"Inhale";
    }
    
     //viewTitle = currentUser.userName;

     NSString  *duration=[NSString stringWithFormat:@"%f",[game.duration floatValue]];
     NSLog(@"plotting %@ ", duration);
     //cell.textLabel.text=[NSString stringWithFormat:@"%@ - %@ (%@)", typeString, attemptDateString , directionstring];
     cell.textLabel.text=[NSString stringWithFormat:@"%@, %@ (%@)", attemptDateString1 ,attemptDateString2, directionstring];
     cell.detailTextLabel.text=[NSString stringWithFormat:@"Duration: %@",duration];
    
    return cell;
}

@end
