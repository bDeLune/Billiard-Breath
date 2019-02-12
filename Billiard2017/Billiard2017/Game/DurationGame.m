#import "DurationGame.h"
#import "BilliardBall.h"

@interface DurationGame ()
{
    AVAudioPlayer *audioPlayer;
}

@property(nonatomic,strong)NSDate  *startTime;
@property(nonatomic,weak)BilliardBall  *currentBilliardBall;
@end

@implementation DurationGame
-(id)init
{
    if (self==[super init]) {        
        self.currentBall=0;
        self.totalBalls=8;
        self.secondsPerballEasy=74; //74
        self.secondsPerballMedium=50; //20
        self.secondsPerballHard=30; //8
        self.secondsPerballVeryHard=4; //NON
        self.isRunning=NO;
    }
    
    return self;
}

-(void)startGame
{
    self.startTime=[NSDate date];
    self.currentBilliardBall=[self.ballsCopy objectAtIndex:self.currentBall];
    [self.currentBilliardBall start];
    [self.currentBilliardBall blowingBegan];
}

-(void)playHitTop
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"IMPACT RING METAL DESEND 01" ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    
    NSError *error = nil;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
    audioPlayer.volume=0.3;
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

-(int)nextBall
{
    [self playHitTop];
    self.currentBall++;
    if (self.currentBall<[self.ballsCopy count]) {
        [self.currentBilliardBall stop];
        [self.currentBilliardBall blowingEnded];
        self.currentBilliardBall=[self.ballsCopy objectAtIndex:self.currentBall];
        [self.currentBilliardBall start];
        [self.currentBilliardBall blowingBegan];
        return self.currentBall;
    }else{
        return -1;
    }
}

-(void)pushBall
{
    float amount=0;
    
    gameDifficulty  difficulty=[[[NSUserDefaults standardUserDefaults]objectForKey:@"difficulty"]floatValue];

    switch (difficulty) {
        case gameDifficultyEasy:
            amount=self.secondsPerballEasy;
            break;
        case gameDifficultMedium:
            amount=self.secondsPerballMedium;
            break;
        case gameDifficultyHard:
            amount=self.secondsPerballHard;
            break;
        case gameDifficultyVeryHard:
            amount=self.secondsPerballVeryHard;
            break;
        default:
            break;
    }
    [self.currentBilliardBall setForce:amount*50];
}

-(void)endGame
{
    [self.currentBilliardBall stop];
}

@end
