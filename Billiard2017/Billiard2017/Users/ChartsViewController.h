#import <UIKit/UIKit.h>
@class ChartsViewController;
@protocol ChartsProtocol <NSObject>

-(void) chartsDismissRequest:(ChartsViewController*)caller;

@end


@interface ChartsViewController : UIViewController

@property(nonatomic,unsafe_unretained)id<ChartsProtocol>delegate;
- (instancetype)init:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withData:(NSMutableArray *)userData withUser:(User*)user withHeight:(CGFloat)height withWidth:(CGFloat)width;

@end
