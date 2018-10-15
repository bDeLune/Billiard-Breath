#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game;

@interface User : NSManagedObject
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *game;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGameObject:(Game *)value;
- (void)removeGameObject:(Game *)value;
- (void)addGame:(NSSet *)values;
- (void)removeGame:(NSSet *)values;

@end
