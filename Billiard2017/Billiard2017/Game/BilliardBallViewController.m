#import <AVFoundation/AVFoundation.h>
#import "BilliardBallViewController.h"
#import "BilliardBall.h"
#import "GCDQueue.h"

#define NUM_BALLS  8
#define BALL_RADIUS  80

@interface BilliardBallViewController ()<UICollisionBehaviorDelegate>
{
    CGPoint  topPoint;
    NSMutableArray *activeBallsForPower;
    int ballGameCount;
    AVAudioPlayer *audioPlayer;
}

@property(nonatomic,strong)    NSMutableArray  *balls;
@property(nonatomic,strong)NSMutableArray  *animators;
@property int currentBallININdex;
@end

@implementation BilliardBallViewController

- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    [(UIView*)item setTintColor:[UIColor lightGrayColor]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super init];
    if (self) {
        //887 * 100
        UIView  *view=[[UIView alloc]initWithFrame:frame];
        self.view=view;
        self.view.backgroundColor=[UIColor  clearColor];
        self.balls=[NSMutableArray new];
        self.animators=[NSMutableArray new];
    }
    return self;
}

-(void)makeBalls
{
    self.currentBallININdex=0;
   __block int  startx=0;
    for (int i=0; i<8; i++) {
        
        BilliardBall *ball=[[BilliardBall alloc]initWithFrame:CGRectMake(startx, 0, BALL_RADIUS, BALL_RADIUS)];
            
        [self.balls addObject:ball];
        ball.gaugeHeight=self.view.bounds.size.height;
        ball.delegate=self;
        [self.view addSubview:ball];
        startx+=BALL_RADIUS+10;
    }

    [self animateBallStart];
}

-(void)animateBallStart
{
    for (ItemCount i=0; i<[self.balls count]; i++) {
        BilliardBall  *ball=[self.balls objectAtIndex:i];
        ball.alpha=0;
        CALayer *layer= ball.layer;
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.750] forKey:kCATransactionAnimationDuration];
        CGPoint targetCenter=CGPointMake(ball.center.x,self.view.bounds.size.height-BALL_RADIUS/2 );
        ball.animation = [self dockBounceAnimationWithIconHeight:150];
        
        ball.targetPoint=targetCenter;
        [ball.animation setDelegate:ball];
        ball.animation.beginTime = CACurrentMediaTime()+(0.1*i); ///WAS 0.1
        
        [layer addAnimation:ball.animation forKey:@"position"];
        
       [CATransaction commit];
       [ball setCenter:targetCenter];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)reset
{
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Croquet ball drop bounce cement_BLASTWAVEFX_29317" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer setNumberOfLoops:1];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=0.3;
        [audioPlayer play];
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
    
    for (BilliardBall *ball in self.balls) {
        [ball stop];
        [ball blowingEnded];
        [ball removeFromSuperview];
    }
    
    [self.balls removeAllObjects];
    [self makeBalls];
}

- (CAKeyframeAnimation *)dockBounceAnimationWithIconHeight:(CGFloat)iconHeight
{
    CGFloat factors[32] = {0, 32, 60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32,
        0, 24, 42, 54, 62, 64, 62, 54, 42, 24, 0, 18, 28, 32, 28, 18, 0};
    
    NSMutableArray *values = [NSMutableArray array];
    
    for (int i=0; i<32; i++)
    {
        CGFloat positionOffset = factors[i]/128.0f * iconHeight;
        
        CATransform3D transform = CATransform3DMakeTranslation(0, -positionOffset, 0);
        [values addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.repeatCount = 1;
    animation.duration = 32.0f/30.0f;///32.0f/30.0f;
    animation.fillMode = kCAFillModeForwards;
    animation.values = values;
    animation.removedOnCompletion = YES; // final stage is equal to starting stage
    animation.autoreverses = NO;
    
    return animation;
}

-(void)shootBallToTop:(int)ballIndex withAcceleration:(float)acceleration
{
    if (ballIndex>=[self.balls count]) {
        return;
    }
    
    BilliardBall  *ball=[self.balls objectAtIndex:ballIndex];
    CGPoint  point=CGPointMake(ball.center.x,BALL_RADIUS/2);
    
    if(acceleration<0.1)
    {
        acceleration=0.05;
    }
    [UIView animateWithDuration:0.1 animations:^{
        [ball setCenter:point];
    }];
}

-(void)pushBallsWithVelocity:(float)velocity
{
    float maxVelocity=30;
    
    NSString * difficulty=[[NSUserDefaults standardUserDefaults]objectForKey:@"difficulty"];
    int difficultyAsInt = [difficulty intValue];
    
    switch (difficultyAsInt) {
        case 0:
            maxVelocity=15;
            NSLog(@"POWER small");
           break;
        case 1:
            maxVelocity=60;
            NSLog(@"POWER medium");
           break;
        case 2:
            maxVelocity=70;
            NSLog(@"POWER hard");
          break;
        case 3:
            maxVelocity=90;
            NSLog(@"POWER very hard");
            break;
            
        default:
            break;
    }

    NSLog(@"maxVelocity %f", maxVelocity);
    NSLog(@"velocity %f", velocity);
    
    
    if (velocity>maxVelocity) {
        velocity=maxVelocity;
    }
    
    NSLog(@"velocity %f", velocity);
    
    int  perBall=maxVelocity/8;

    float perBallCount=0;

    
    int numberOfBallsToMove=(velocity/maxVelocity)*8;
    
    NSLog(@"numberOfBallsToMove %d", numberOfBallsToMove);
    
    for (int i=0; i<numberOfBallsToMove; i++) {

        
        if (perBallCount<=maxVelocity) {
            BilliardBall  *ball=[self.balls objectAtIndex:i];
            [ball blowingBegan];
            [ball setForce:velocity*90];
            perBallCount+=perBall;
        }
    }
    
    for (int i=numberOfBallsToMove; i<[self.balls count]; i++) {
        BilliardBall  *ball=[self.balls objectAtIndex:i];
        [ball blowingEnded];
    }
}

-(void)startBallsPowerGame
{
    ballGameCount=0;
    
    for (int i=0; i<[self.balls count]; i++) {
        BilliardBall  *ball=[self.balls objectAtIndex:i];
        [ball start];
        [ball blowingBegan];
    }
}

-(void)endBallsPowerGame
{
    for (int i=0; i<[self.balls count]; i++) {
        BilliardBall  *ball=[self.balls objectAtIndex:i];
        [ball blowingEnded];
    }
}

-(void)startDurationPowerGame
{    
    NSLog(@"STARTING DURATION GAME");
    self.durationGame.ballsCopy=[self.balls mutableCopy];
    [self.durationGame startGame];
}

-(void)endDurationPowerGame
{
    NSLog(@"END ");
    
    for (int i=0; i<[self.balls count]; i++) {
        BilliardBall  *ball=[self.balls objectAtIndex:i];
        [ball stop];
        [ball blowingEnded];
        
    }
    [self.durationGame endGame];
}

-(void)playHitTop
{
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"IMPACT RING METAL DESEND 01" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=0.3;
        [audioPlayer play];
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
    @finally {
        
    }
}
-(void)ballReachedFinalTarget:(BilliardBall *)ball

{
    [self playHitTop];
    ballGameCount++;
    
    if (self.currentGameType==gameTypePowerMode) {
        if (ballGameCount>=[self.balls count]) {
            [self.powerGame.delegate gameWon:self.powerGame];
        }
    }else if (self.currentGameType==gameTypeDurationMode)
    {
       int result= [self.durationGame nextBall];
        
        if (result==-1) {
            NSLog(@"COMPLETED DURATION MODE");
            [self.durationGame.delegate gameWon:self.durationGame];
        }
    }
}
@end
