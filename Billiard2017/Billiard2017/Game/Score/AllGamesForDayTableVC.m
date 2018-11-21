#import "AllGamesForDayTableVC.h"
#import "Game.h"

@interface AllGamesForDayTableVC ()
{
    NSArray  *data;
}

@end

@implementation AllGamesForDayTableVC

-(void)setUSerData:(NSArray*)games
{
    data=games;
    [self.tableView reloadData];
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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d MMM y H:mm:ss"];
    NSString *attemptDateString = [dateFormat stringFromDate:date];
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

     NSString  *duration=[NSString stringWithFormat:@"%f",[game.duration floatValue]];
     NSLog(@"plotting %@ ", duration);
     cell.textLabel.text=[NSString stringWithFormat:@"%@ - %@ (%@)", typeString, attemptDateString , directionstring];
     cell.detailTextLabel.text=[NSString stringWithFormat:@"Duration: %@",duration];
    
    return cell;
}

@end
