//
//  ChartsViewController.m
//  Billiard2017
//
//  Created by Brian Dillon on 08/12/2018.
//  Copyright © 2018 ROCUDO. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Billiard2017-Bridging-Header.h"
#import "AAChartKit.h"
#import "User.h"
#import "Game.h"
#import "HeaderView.h"

@interface ChartsViewController : UIViewController <HeaderViewProtocl>{
    NSString  *currentType;
    NSString *lastDate;
    BOOL chartAdded;
    CGFloat chartViewWidth;
    CGFloat chartViewHeight;
}
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *graphTitle;
@property (weak, nonatomic) IBOutlet UIView *userLineChart;
@property (strong, nonatomic) IBOutlet AAChartView *userDataLineChart;
@property (strong, nonatomic) IBOutlet ChartsViewController *chartsView;
@property (nonatomic, strong) NSArray* options;
//@property (nonatomic, strong) IBOutlet LineChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;
@property (nonatomic, strong) NSMutableArray* userData;
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) NSString * userTitle;
@property (nonatomic, strong) NSArray *plotData;

@end

@implementation ChartsViewController

- (instancetype)init:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withData:(NSMutableArray *)userData withUser:(User*)user withHeight:(CGFloat)height withWidth:(CGFloat)width {
    
    NSLog(@"Instantiating graph");
    chartAdded = FALSE;
    self.user = user;
    self.userData = userData;
    self.userTitle = self.user.userName;
    self.graphTitle.text = self.user.userName;
   // self.graphTitle. = self.user.userName;
    currentType = @"Duration";
    
    //CGFloat topBar = self.navigationController.navigationBar.frame.size.height;
    //chartViewWidth  = width;
    //chartViewHeight = height;

    return self;
}
- (IBAction)backButtonPressed:(id)sender {
    
    NSLog(@"back please");
[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) viewWillLayoutSubviews{

    //if (chartAdded == FALSE){
    
    chartAdded = TRUE;
    
    //CGFloat navheight = self.navigationController.view.frame.size.height;
    //CGFloat height = chartViewHeight - navheight;

    self.title =self.userTitle;
    
    NSArray *array = [self.user.game allObjects];
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(Game*)a gameDate];
        NSDate *second = [(Game*)b gameDate];
        return [first compare:second];
    }];
    
    //if ([sortedArray count]==0) {
    //    return;
    //}
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMM y "];
    
    NSLog(@"SORTED -- - %@", sortedArray);
    //NSLog(@"PLOT DATA -- - %@", plotData);
    
    NSMutableArray *dates = [NSMutableArray array];
    NSMutableArray *markerColours = [NSMutableArray array];
    for (int i=0; i<[sortedArray count]; i++) {
        NSLog(@"DATE PLACER i %d", i);
        NSLog(@"sortedArray %lu", (unsigned long)[sortedArray count]);
        
        Game *game=[sortedArray objectAtIndex:i];
        NSDate *date = game.gameDate;
        NSString *stringFromDate=[formatter stringFromDate:date];
        NSLog(@"last date %@", lastDate);
        NSLog(@"current date %@", stringFromDate);
        
        if ([lastDate isEqualToString: stringFromDate]){
            stringFromDate = @"";
            NSLog(@"skipping date label - same as previous");
        }
        
        [dates addObject: stringFromDate];
        lastDate = [formatter stringFromDate:date] ;
        
        if ([game.gameDirection isEqualToString:@"exhale"]) {
           [markerColours addObject: @"#35b31c"];
            
        }else if ([game.gameDirection isEqualToString:@"inhale"])
        {
            [markerColours addObject: @"#ef3118"];
        }
    }
    
    // For the y-axis
    NSMutableArray *durationVals = [NSMutableArray array];
    for (int b=0; b< [sortedArray count]; b++) {
        Game *game=[sortedArray objectAtIndex:b];
        NSNumber * duration = game.duration;
        [durationVals addObject: duration];
    }
    
    

    AAChartModel *aaChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeSpline)
    .titleSet(@"")
    .subtitleSet(@"")
    //.categoriesSet(@[@"Java",@"Swift",@"Python",@"Ruby", @"PHP",@"Go",@"C",@"C#",@"C++"])
    .categoriesSet(dates)
    .colorsThemeSet(markerColours)
    .yAxisTitleSet(@"Duration")
    .categoriesSet(durationVals)
    .colorsThemeSet(markerColours)
    .dataLabelEnabledSet(FALSE)
    .markerSymbolSet(@"circle")
    .markerSymbolStyleSet(AAChartSymbolStyleTypeInnerBlank)
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"Exhale")
                 .dataSet(durationVals)
                 .showInLegendSet(true)
                 .markerSet(AAMarker.new
                            //.fillColorSet(@"#FF0000")
                            .lineWidthSet(@6)
                            .symbolSet(@"circle")
                            ),
                 AAObject(AASeriesElement)
                 .nameSet(@"Inhale")
                 .dataSet(durationVals )
                 .showInLegendSet(false)
                 .colorByPointSet(markerColours)
                 .dataLabelsSet(AADataLabels.new
                                .enabledSet(YES)
                                .styleSet(AAStyle.new
                                          .colorSet(@"#000000")
                                          .fontSizeSet(@"10px")
                                          )
                                )
                 .markerSet(AAMarker.new
                            //.fillColorSet(@"#FF0000")
                            .lineWidthSet(@6)
                            .symbolSet(@"circle")
                            .radiusSet(@6)
                            ),
                 //.markerSet(AAMarker.new
                 //           .fillColorSet(@"#FF0000")
                 //           .lineWidthSet(@6)
                 //           ),

                 @{
                     @"data" : @"",
                     @"name" : @"Inhale",
                     @"namesSet" : @"Inhale",
                     //@"colorByPoint" : @true,
                     @"markerRadius" : @25,
                     @"markerSymbol" : @"circle",
                     @"showInLegendSet" : @true,
                     @"showInLegend" : @true,
                //     @"legendSymbol" : @"circle",
                //     @"symbolStyle" : @"circle",
                     @"marker": @{
                            @"fillColor": @"white",
                             @"symbol": @"circle",
                             @"lineWidth": @6,
                             @"lineColor": @"#FF0000"
                             }
                   }
                 
    /*
     @"marker": @{
     @"fillColor": @"white",
     @"symbol": @"circle",
     @"lineWidth": @3,
     @"lineColor": @"#FF0000"
     }
     
     .nameSet(@"Inhale")
     .dataSet(durationVals ),
     AAObject(AASeriesElement)
     .nameSet(@"Inhale")
     .dataSet(durationVals ),
     AAObject(AASeriesElement)
     .nameSet(@"Exhale")
                 .lineWidthSet(@8)
                 .lineWidthSet(@3)

                 .zoneAxisSet(@"x")
                 .zonesSet(@[@{@"value": @4,
                               @"color":@"rgba(220,20,60,1)",//猩红色
                               @"fillColor": gradientColorDic1  // 1,
                               },@{
                                 @"color":@"rgba(30,144,255,1)",//道奇蓝
                                 @"fillColor": gradientColorDic2 // 2
                                 }, ])
                 
                  */
                ]);
    
    
    //aaChartModel.colorsThemeSet(@[@"#35b31c",@"#35b31c",@"#35b31c",@"#35b31c",@"#35b31c",@"#35b31c",@"#35b31c",@"#ef3118",@"#35b31c",@"#ef3118",@"#ef3118", @"#35b31c",@"#ef3118"]);
    aaChartModel.colorsThemeSet(markerColours);
    aaChartModel.categoriesSet(dates);
    //aaChartModel.seriesSet();
    
    [self.userDataLineChart aa_drawChartWithChartModel:aaChartModel];
    
    //// set the content height of aaChartView
   // self.userDataLineChart.contentHeight = chartViewHeight;
   // }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: YES];
    NSLog(@"THIS VIEW HAS LOADED");
    self.userDataLineChart = [[AAChartView alloc]init];
    self.userDataLineChart.frame = CGRectMake(0, 70, self.view.bounds.size.width,  700);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.userDataLineChart];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setAlpha:0];
    
    self.graphTitle.text = self.user.userName;

}


@end
