#import "SequenceGame.h"
#import <AVFoundation/AVFoundation.h>

@interface SequenceGame()
{
    BOOL gamewon;
   
    AVAudioPlayer *audioPlayer;
}

@end

@implementation SequenceGame
-(id)init
{
    if (self==[super init]) {
        
        self.currentBall=0;
        self.totalBalls=8;
        self.totalBallsRaised=0;
        self.totalBallsAttempted=0;
        gamewon=NO;
        self.saveable=NO;
        self.halt= NO;
        self.time= 0;
    }
    
    return self;
}
-(void)playHitTop
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"IMPACT RING METAL DESEND 01" ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    
    NSError *error = nil;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                               error:&error];
    audioPlayer.volume=0.3;

    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
}

-(int)nextBall
{
    self.halt=NO;
    self.currentBall++;
    self.totalBallsAttempted++;

    if (self.totalBallsRaised>=self.totalBalls) {

            if (!gamewon) {
                [self.delegate gameWon:self];
                gamewon=YES;
            }
        return -1;
    }
    
    if (!gamewon) {
        if (self.totalBallsAttempted>=self.totalBalls) {
            [self.delegate gameEnded:self];
            return -1;
        }
    }
    
    return self.currentBall;
}

@end
