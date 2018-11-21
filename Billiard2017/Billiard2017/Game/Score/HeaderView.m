#import "HeaderView.h"

@interface HeaderView ()
@property (nonatomic,strong) UILabel  *label;
@property (nonatomic,strong) UIButton  *deleteButton;
@property (nonatomic,strong) UIButton  *dataButton;

@end

@implementation HeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)build
{
    self.label=[[UILabel alloc]initWithFrame:CGRectMake(20,10, 430, self.bounds.size.height)];
    [self.label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
    [self.label setText:self.user.userName];
    [self addSubview:self.label];
    
    self.deleteButton=[UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteButton.frame=CGRectMake(self.bounds.size.width-100, 11, 100, self.bounds.size.height);
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton setFont:[UIFont fontWithName:@"Arial-BoldMT" size:15]];
    [self addSubview:self.deleteButton];

    self.dataButton=[UIButton buttonWithType:UIButtonTypeSystem];
    self.dataButton.frame=CGRectMake(self.deleteButton.frame.origin.x+110, 11, 100, self.bounds.size.height);
    [self.dataButton setTitle:@"Data" forState:UIControlStateNormal];
    [self.dataButton setFont:[UIFont fontWithName:@"Arial-BoldMT" size:15]];
    [self.dataButton addTarget:self action:@selector(viewHistoricalData) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.dataButton];
}

-(void)viewHistoricalData
{
    [self.delegate viewHistoricalData:self];
}

-(void)deleteAction
{
    [self.delegate deleteMember:self];
}

@end
