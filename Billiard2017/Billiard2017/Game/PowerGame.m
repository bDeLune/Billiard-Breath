#import "PowerGame.h"
@interface PowerGame(){
    AVAudioPlayer *audioPlayer;
}

@end
@implementation PowerGame
-(id)init
{
    if (self == [super init]) {
        self.currentBall = 0;
        self.totalBalls = 8;
        self.power = 0;
    }    
    return self;
}

@end
