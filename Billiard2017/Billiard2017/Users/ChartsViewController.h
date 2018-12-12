#import <UIKit/UIKit.h>
#import "User.h"
#import "Game.h"
#import "HeaderView.h"

@class ChartsViewController;
@protocol ChartsProtocol <NSObject>

-(void) chartsDismissRequest:(ChartsViewController*)caller;

@end

@protocol ChartRemoveProtocol <NSObject>

-(void) userListDismissRequest:(ChartsViewController*)caller;

@end



@interface ChartsViewController : UIViewController

@property(nonatomic,unsafe_unretained)id<ChartsProtocol>delegate;
- (instancetype)init:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withData:(NSMutableArray *)userData withUser:(User*)user withHeight:(CGFloat)height withWidth:(CGFloat)width;
@property(nonatomic,unsafe_unretained)id<ChartRemoveProtocol>delegate1;
@end
