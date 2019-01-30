#import "CorePlot-CocoaTouch.h"
#import "PlotItem.h"
#import <UIKit/UIKit.h>
@interface GraphViewController : UIViewController
{
@private
    
    PlotItem *_detailItem;
}

@property (nonatomic, retain) PlotItem *detailItem;
@property (nonatomic, retain) IBOutlet UIView *hostingView;
@property(nonatomic,retain)IBOutlet  UIButton *typeButton;

-(IBAction)typeButtonSelected:(id)sender;
@end
