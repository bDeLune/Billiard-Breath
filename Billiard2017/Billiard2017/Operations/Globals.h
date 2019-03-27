@class Game;
@class User;
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
typedef enum
{
    gameDifficultyEasy=1,
    gameDifficultMedium=2,
    gameDifficultyHard=3,
    gameDifficultyVeryHard=4
}gameDifficulty;

extern NSString * const gameUserType_toString[];

@interface Globals : NSObject
+(Globals *)sharedInstance;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;

-(void)updateCoreData;
-(void)updateUser:(User*)user;
@end
