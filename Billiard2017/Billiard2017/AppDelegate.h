#import <UIKit/UIKit.h>
#import "SplashViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SplashViewController *initialSplash;
- (void)removeSplash;

@end
