#import <UIKit/UIKit.h>

@interface ChartsViewController : UIViewController

- (instancetype)init:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withData:(NSMutableArray *)userData withUser:(User*)user withHeight:(CGFloat)height withWidth:(CGFloat)width;

@end
