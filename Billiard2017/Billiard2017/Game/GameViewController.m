#import "GameViewController.h"
#import "User.h"
#import "BilliardBallViewController.h"
#import "BilliardBall.h"
#import "Session.h"
#import "SequenceGame.h"
#import "PowerGame.h"
#import "DurationGame.h"
#import "Game.h"
#import "AddNewScoreOperation.h"
#import "UIEffectDesignerView.h"
#import "GCDQueue.h"
#import <AVFoundation/AVFoundation.h>
#import "BTLEManager.h"
#import "UserListViewController.h"

@interface GameViewController ()<BTLEManagerDelegate>
{
    int threshold;
    CADisplayLink *testDurationDisplayLink;
    gameDifficulty  currentDifficulty;
    AVAudioPlayer  *audioPlayer;
    UIEffectDesignerView *particleEffect;
    NSTimer  *effectTimer;
    bool wasExhaling;
    NSTimer *timer;
    int MyTimer;
    BOOL toggleIsON;
    float speed;
    float velocity;
    float previousVelocity;
}

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong) BilliardBallViewController  *billiardViewController;
@property(nonatomic,strong) NSOperationQueue  *addGameQueue;
@property(nonatomic) gameType  currentGameType;
@property(nonatomic,strong) Session  *currentSession;
@property(nonatomic,strong) SequenceGame  *sequenceGameController;
@property(nonatomic,strong) PowerGame  *powerGameController;
@property(nonatomic,strong) DurationGame  *durationGameController;
@property(nonatomic,strong) BTLEManager  *btleManager;
@property(nonatomic,strong) UIImageView  *btOnOfImageView;
@property(nonatomic,strong) UserListViewController  *userList;
@property(nonatomic,strong) UINavigationController *navcontroller;
@end

@implementation GameViewController

-(void)userListDismissRequest:(UserListViewController *)caller
{
    [[GCDQueue mainQueue]queueBlock:^{
        [UIView transitionFromView:self.navcontroller.view toView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished){
            self.userList.sharedPSC=self.sharedPSC;
            self.userList.delegate=self;
        }];
    }];
}

-(IBAction)goToUsersScreen:(id)sender
{
    self.userList.sharedPSC=self.sharedPSC ;
    [self.userList getListOfUsers];
    [UIView transitionFromView:self.view toView:self.navcontroller.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
        self.userList.sharedPSC = self.sharedPSC;
        self.userList.delegate = self;
    }];
}

-(void)btleManagerConnected:(BTLEManager *)manager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-CONNECTED"]];
    });
}

-(void)btleManagerDisconnected:(BTLEManager *)manager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];
    });
}

#pragma mark -
#pragma mark - Session

-(void)startSession
{
    NSLog(@"START Session");
    self.currentSession=[Session new];
    self.currentSession.sessionDate=[NSDate date];
}


#pragma mark -
#pragma mark - KVO
// observe the queue's operationCount, stop activity indicator if there is no operatation ongoing.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"numberOfSources"]) {
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.billiardViewController=[[BilliardBallViewController alloc]initWithFrame:CGRectMake(25, 260, 650, 325)];
        self.currentGameType=gameTypeSequence;

        currentDifficulty=gameDifficultyEasy;
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:currentDifficulty] forKey:@"difficulty"];
        wasExhaling = true;
        self.addGameQueue=[[NSOperationQueue alloc]init];
        self.btleManager=[BTLEManager new];
        self.btleManager.delegate=self;
        [self.btleManager startWithDeviceName:@"GroovTube" andPollInterval:0.1];
        [self.btleManager setRangeReduction:2];
        [self.btleManager setTreshold:60];
        [self startSession];

        self.btOnOfImageView=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-230, 30, 100, 100)];
        [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];
        [self.view addSubview:self.btOnOfImageView];
    }
    
    return self;
}

-(BOOL)allowBreath
{
    if ((toggleIsON == 0 && wasExhaling == 1) || (toggleIsON == 1 && wasExhaling == 0)){
        return YES;
    }else{
        return NO;
    }
    return YES;
}

-(void)btleManagerBreathBegan:(BTLEManager*)manager{

    if ([self allowBreath]==NO) {
        return;
    }
    
    if ((toggleIsON == 0 && wasExhaling == 1) || (toggleIsON == 1 && wasExhaling == 0)){
        [self NoteBegan];
    }
}

-(void)btleManagerBreathStopped:(BTLEManager*)manager{
    if ([self allowBreath]==NO) {
        return;
    }

    [self NoteStopped];
}

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{
    
    wasExhaling = false;
    
    if (toggleIsON==NO) {
        return;
    }
    velocity=127.0*percentOfmax;
    speed= (fabs( velocity - previousVelocity));
    previousVelocity= velocity;
    
    [self NoteContinuing];
}

-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{

     wasExhaling = true;
    
    if (toggleIsON==YES) {
        return;
    }
    velocity=127.0*percentOfmax;
    speed= (fabs( velocity- previousVelocity));
    previousVelocity= velocity;
    [self NoteContinuing];
}

- (NSManagedObjectContext *)managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    if (self.sharedPSC != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:self.sharedPSC];
    }
    
    return _managedObjectContext;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.billiardViewController.view];
    [[NSUserDefaults standardUserDefaults]setObject:@"exhale" forKey:@"direction"];    // Do any additional setup after loading the view from its nib.
    self.userList=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
    self.userList.sharedPSC=self.sharedPSC;
    self.navcontroller=[[UINavigationController alloc]initWithRootViewController:self.userList];
    CGRect frame = [[UIScreen mainScreen] bounds]; //was self.view.frame;
    [self.navcontroller.view setFrame:frame];
}

-(void)setLabels
{
    [self managedObjectContext];
    [[GCDQueue mainQueue]queueBlock:^{
        self.currentUsersNameLabel.text=[self.gameUser valueForKey:@"userName"];
    }];
}

#pragma - UIControls

-(IBAction)exitGameScreen:(id)sender
{
    [self.delegate gameViewExitGame];
}

-(IBAction)toggleDirection:(id)sender
{
    switch (toggleIsON) {
        case 0:
            toggleIsON=YES;
            //  midiController.currentdirection=midiinhale;
            [self.toggleDirectionButton setBackgroundImage:[UIImage imageNamed:@"BreathDirectionINHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];
            wasExhaling = false;
            break;
        case 1:
            toggleIsON=NO;
            [self.toggleDirectionButton setBackgroundImage:[UIImage imageNamed:@"BreathDirectionEXHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"exhale" forKey:@"direction"];
            wasExhaling = true;
            break;
            
        default:
            break;
    }
}

-(IBAction)toggleGameMode:(id)sender
{
    int mode=self.currentGameType;
    
    mode++;
    
    if (mode>2) {
        mode=gameTypeSequence;
    }
    
    self.currentGameType=mode;
    self.billiardViewController.currentGameType=  self.currentGameType;
    [self.toggleGameModeButton setBackgroundImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
    
    
    NSLog(@"changing modesetting difficulty or %d", threshold);
    int setDifficulty = [[[NSUserDefaults standardUserDefaults] objectForKey:@"difficulty"] intValue];
    [self setThreshold:setDifficulty];
    
    [self resetGame:nil];
}

-(NSString*)stringForMode:(int)mode
{
    NSString  *modeString;
    
    switch (mode) {
        case gameTypeDurationMode:
            modeString=@"ModeButtonDURATION";
            break;
            
        case gameTypePowerMode:
            modeString=@"ModeButtonPOWER";
            break;
            
        case gameTypeSequence:
            modeString=@"ModeButtonSEQUENCE";
            break;
            
        default:
            break;
    }
    
    return modeString;
}

-(IBAction)presentSettings:(id)sender
{
    int mode=currentDifficulty;
    
    mode++;
    
    NSLog(@"set mode %d", mode);
    
    if (mode > 3) {
        mode=gameDifficultyEasy;
    }
    
    currentDifficulty=mode;
    int setDifficulty = [[[NSUserDefaults standardUserDefaults] objectForKey:@"difficulty"] intValue];

    if (setDifficulty == 3 || setDifficulty > 3){
        setDifficulty = 0;
    }else{
        setDifficulty++;
    }
    
    NSLog(@"set setDifficulty %d", setDifficulty);
    
    switch (setDifficulty) {
        case 0:
            [self setThreshold:0];
             NSLog(@"set SMALL");
            break;
            
        case 1:
          [self setThreshold:1];
             NSLog(@"set MEDIUM");

            break;
        case 2:
          [self setThreshold:2];
             NSLog(@"set LARGE");
            break;
        
        case 3:
            [self setThreshold:3];
            NSLog(@"set VERY LARGE");
            break;
        
        default:
            break;
    }
}

-(IBAction)resetGame:(id)sender
{
    self.sequenceGameController=[SequenceGame new];
    self.sequenceGameController.delegate=self;
    self.powerGameController=[PowerGame new];
    self.powerGameController.delegate=self;
    self.durationGameController=[DurationGame new];
    self.durationGameController.delegate=self;
    [self.billiardViewController reset];
}

-(void)NoteBegan
{
    if ((toggleIsON == 0 && wasExhaling == 1) || (toggleIsON == 1 && wasExhaling == 0)){
    
    [self.sequenceGameController startTimer];

    switch (self.currentGameType) {
        case gameTypeDurationMode:
            self.durationGameController.isRunning=YES;
            self.billiardViewController.currentGameType=gameTypeDurationMode;
            [self NoteBeganForDuration];
            break;
        case gameTypePowerMode:
            [self NoteBeganForPower];
            self.billiardViewController.currentGameType=gameTypePowerMode;
            break;
        case gameTypeSequence:
            [self NoteBeganForSequence];
            self.billiardViewController.currentGameType=gameTypeSequence;
            break;
        default:
            break;
        }
     }
}

-(void)NoteStopped
{
    if ((toggleIsON == false && wasExhaling == true) || (toggleIsON == true && wasExhaling == false)){

        switch (self.currentGameType) {
            case gameTypeDurationMode:
                self.durationGameController.isRunning=NO;
                [self NoteStoppedForDuration];
                break;
            case gameTypePowerMode:
                [self NoteStoppedForPower];
                break;
            case gameTypeSequence:
                [self NoteStoppedForSequence];
                break;
            default:
                break;
        }
    }
}

-(void)NoteContinuing
{
    if (velocity==127) {
        return;
    }

    if (velocity>[self.currentSession.sessionStrength floatValue]) {
        
        if (velocity!=127) {
            self.currentSession.sessionStrength=[NSNumber numberWithFloat:velocity];
        }
    }
    
    if (self.currentGameType==gameTypeDurationMode)
    {
        if (self.durationGameController.isRunning) {
            self.currentSession.sessionDuration=[NSNumber numberWithDouble:self.sequenceGameController.time];

        }
    }else
    {
        self.currentSession.sessionDuration=[NSNumber numberWithDouble:self.sequenceGameController.time];

    }
    
    self.currentSession.sessionSpeed=[NSNumber numberWithFloat:speed];
    NSString  *durationtext=[NSString stringWithFormat:@"%0.1f",self.sequenceGameController.time];
    
    if (velocity>self.powerGameController.power) {
        self.powerGameController.power=velocity;
    }
    
    [[GCDQueue mainQueue]queueBlock:^{
        switch (self.currentGameType) {
            case gameTypeDurationMode:
                [self NoteContinuingForDuration];
                [self.durationLabel setText:durationtext];
                [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.01f",velocity]];
                break;
            case gameTypePowerMode:
                [self NoteContinuingForPower];
                [self.durationLabel setText:durationtext];
                //ß[self.strenghtLabel setText:[NSString stringWithFormat:@"%i",self.powerGameController.power]];
                [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.0f",velocity]];
                break;
            case gameTypeSequence:
                [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.0f",velocity]];
                [self NoteContinuingForSequence];
                break;
            default:
                break;
        }
    }];
}

#pragma - Sequence

-(void)NoteBeganForSequence
{
    self.sequenceGameController.currentSpeed=-1;
    [self.sequenceGameController startTimer];
}

-(void)NoteStoppedForSequence
{
    [self.sequenceGameController nextBall];
}
-(void)NoteContinuingForSequence
{
    self.sequenceGameController.currentSpeed=speed;
    gameDifficulty  difficulty=[[[NSUserDefaults standardUserDefaults]objectForKey:@"difficulty"]intValue];

        switch (difficulty) {
            case 0:
                [self.sequenceGameController setAllowNextBall:YES];
                break;
            case 1:
                if (self.sequenceGameController.currentSpeed>10) {
                    [self.sequenceGameController setAllowNextBall:YES];
                }else
                {
                    [self.sequenceGameController setAllowNextBall:NO];
                }
                break;
            case 2:
                if (self.sequenceGameController.currentSpeed>40) {
                    [self.sequenceGameController setAllowNextBall:YES];
                }else{
                    [self.sequenceGameController setAllowNextBall:NO];
                }
                break;
            case 3:
                if (self.sequenceGameController.currentSpeed>50) {
                    [self.sequenceGameController setAllowNextBall:YES];
                }else{
                    [self.sequenceGameController setAllowNextBall:NO];
                }
                break;
            
            default:
                break;
        }
    
        if (self.sequenceGameController.halt) {
            return;
        }
        
        if (self.sequenceGameController.allowNextBall) {
            self.sequenceGameController.halt=YES;

            [[GCDQueue mainQueue]queueBlock:^{
                NSString  *durationtext=[NSString stringWithFormat:@"%0.1f",self.sequenceGameController.time];
                [self.durationLabel setText:durationtext];
                
                if (velocity!=127) {
                    [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.0f",velocity]];
                }
                
                 if (speed!=0) {
                     [self.billiardViewController shootBallToTop:self.sequenceGameController.currentBall withAcceleration:speed];
                     self.sequenceGameController.totalBallsRaised++;
                     [self.sequenceGameController playHitTop];
                 }
            }];
        }
}

#pragma - Duration
-(void)NoteBeganForDuration
{
    self.billiardViewController.durationGame=self.durationGameController;
    [self.billiardViewController startDurationPowerGame];
}

-(void)NoteStoppedForDuration
{
    [[GCDQueue mainQueue]queueBlock:^{
        [self.billiardViewController endDurationPowerGame];
        [self resetGame:nil];
    }];
    
    [self saveCurrentSession];
    
    MyTimer = 0;
}

-(void)NoteContinuingForDuration
{
    [[GCDQueue mainQueue]queueBlock:^{
        [self.durationGameController pushBall];
    }];
}

#pragma - Power

-(void)NoteBeganForPower
{
    self.billiardViewController.powerGame=self.powerGameController;
    [self.billiardViewController startBallsPowerGame];
}

-(void)NoteStoppedForPower
{
    if ((toggleIsON == false && wasExhaling == true) || (toggleIsON == true && wasExhaling == false)){
      
        [[GCDQueue mainQueue]queueBlock:^{
            [self.billiardViewController endBallsPowerGame];

           ///  [self saveCurrentSession];
            [self resetGame:nil];
        }];
    }
}

-(void)NoteContinuingForPower
{
    float  vel=velocity;

    if (vel<threshold) {
        return;
    }
 
    [[GCDQueue mainQueue]queueBlock:^{
        [self.billiardViewController pushBallsWithVelocity:vel];
    }];
}

-(void)sendLogToOutput:(NSString*)log
{
    [[GCDQueue  mainQueue]queueBlock:^{
        [self.debugtext setText:log];
    }];
}

-(void)setThreshold:(int)pvalue
{
    
    NSLog(@"Threshold set!");
    switch (pvalue) {
        case 0:
            
            if (self.currentGameType==gameTypePowerMode) {
                NSLog(@"Power mode %d", threshold);
                threshold=2;  //was 18
            }else{
                threshold=2;  //was 18
            }
            
            NSLog(@"SETTING DIFFICULTY THRESHOLD TO 0 or %d", threshold);
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"difficulty"];
            [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"DifficultyButtonLOW"] forState:UIControlStateNormal];
            break;
        case 1:
            
            if (self.currentGameType==gameTypePowerMode) {
                NSLog(@"Power mode %d", threshold);
                threshold=2;  //was 18
            }else{
                threshold=18;  //was 18
            }
            
             NSLog(@"SETTING DIFFICULTY THRESHOLD TO 1 or %d", threshold);
            [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"DifficultyButtonMEDIUM"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"difficulty"];
            break;
        case 2:
            if (self.currentGameType==gameTypePowerMode) {
                threshold=2;  //was 18
                NSLog(@"Power mode %d", threshold);
            }else{
                threshold=25;  //was 18
            }
             NSLog(@"SETTING DIFFICULTY THRESHOLD TO 2 or %d", threshold);
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"difficulty"];
            [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"DifficultyButtonHIGH"] forState:UIControlStateNormal];
            break;
        case 3:
            if (self.currentGameType==gameTypePowerMode) {
                threshold=2;  //was 18
                NSLog(@"Power mode %d", threshold);
            }else{
                threshold=25;  //was 18
            }
            NSLog(@"SETTING DIFFICULTY THRESHOLD TO 3 or %d", threshold);
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:3] forKey:@"difficulty"];
            [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"DifficultyButtonVERYHIGH"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)gameEnded:(AbstractGame *)game
{
    self.durationGameController.isRunning=NO;

    [[GCDQueue mainQueue]queueBlock:^{
        [self resetGame:nil];
    }];
    
    [self saveCurrentSession];
    [self.sequenceGameController killTimer];
}

-(void)gameWonDuration
{
    if (particleEffect) {
        return;
    }

    [[GCDQueue mainQueue]queueBlock:^{
        [self playSound];
        [self startEffects];
    }];
    
    [self.sequenceGameController killTimer];
}

-(void)gameWon:(AbstractGame *)game
{
    if (self.currentGameType==gameTypeDurationMode) {
        
        [self gameWonDuration];
        return;
    }
    
    if (particleEffect) {
        return;
    }
    
    self.durationGameController.isRunning=NO;
    
    [[GCDQueue mainQueue]queueBlock:^{
        [self playSound];
        [self startEffects];
        [self resetGame:nil];

    }];
    
    if (self.currentGameType==gameTypePowerMode) {
       [[GCDQueue mainQueue]queueBlock:^{
        [self saveCurrentSession];  //added kung
           }];
        return;
    }
    
    [self.sequenceGameController killTimer];
}

-(void)startEffects
{
    particleEffect = [UIEffectDesignerView effectWithFile:@"billiardwin.ped"];
    particleEffect.frame=self.view.frame;
    CGRect frame=particleEffect.frame;
    frame.origin.x+=100;
    frame.origin.y-=50;
    particleEffect.frame=frame;
    [self.view addSubview:particleEffect];
    effectTimer=[NSTimer timerWithTimeInterval:2 target:self selector:@selector(killSparks) userInfo:nil repeats:NO];///timer was 2
    [[NSRunLoop mainRunLoop] addTimer:effectTimer forMode:NSDefaultRunLoopMode];
}

-(void)killSparks
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [particleEffect removeFromSuperview];
        particleEffect=nil;
        [effectTimer invalidate];
        effectTimer=nil;
    });
}

-(void)saveCurrentSession
{
    NSLog(@"Save Current Session");
    NSLog(@"%u ", self.currentGameType);
    NSLog(@"%u ", self.currentGameType);
    
    self.currentSession.sessionType=[NSNumber numberWithInt:self.currentGameType];
    AddNewScoreOperation  *operation=[[AddNewScoreOperation alloc]initWithData:self.gameUser session:self.currentSession sharedPSC:self.sharedPSC];
    [self.addGameQueue addOperation:operation];
    [self startSession];
}

-(void)setTargetScore
{
    NSString   *name=self.gameUser.userName;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
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

        float highestNumber=0;
        
        for (Game *game in games)
        {
            if ([game.power floatValue] > highestNumber) {
                highestNumber = [game.power floatValue];
            }
        }
        
        float value=highestNumber;
        [[GCDQueue mainQueue]queueBlock:^{
            [self.targetLabel setText:[NSString stringWithFormat:@"%0.0f",value]];
        }];
    }
}

-(void)animateForTestDuration
{
    [self NoteContinuingForPower];
}

-(void) playSound {
    
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Crowd_cheer6" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=1.0;
        [audioPlayer play];
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
}

@end
