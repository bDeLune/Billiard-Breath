#import <UIKit/UIKit.h>
#import "User.h"
#import "UserListViewController.h"

@class LoginViewController;

@protocol LoginProtocol <NSObject>

-(void)LoginSucceeded:(LoginViewController*)viewController user:(User*)user;

@end
@interface LoginViewController : UIViewController
@property (nonatomic,weak)IBOutlet  UITextField *usernameTextField;
@property (nonatomic,weak)IBOutlet UIButton     *loginButton;
@property (nonatomic,weak)IBOutlet UIButton     *signupButton;
@property (nonatomic,weak)IBOutlet UIImageView     *backGroundImage;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property (nonatomic,unsafe_unretained)id<LoginProtocol>delegate;
@property (nonatomic,strong)UserListViewController  *userList;
@property(nonatomic,weak)IBOutlet  UIButton    *viewUsersButton;

-(IBAction)goToUsersScreen:(id)sender;
-(IBAction)login:(id)sender;
-(IBAction)signup:(id)sender;
@end
