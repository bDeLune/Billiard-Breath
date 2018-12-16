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
    int totalGames;
    NSArray *sortedArray;
}
@property (weak, nonatomic) IBOutlet UIButton *backFromChart;
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
    UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [self.graphTitle setFont:boldFont];
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
    
    
    //if ([sortedArray count]==0) {
    //    return;
    //}
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMM y "];
    
    //NSLog(@"SORTED -- - %@", sortedArray);
    //NSLog(@"PLOT DATA -- - %@", plotData);
    
    NSMutableArray *dates = [NSMutableArray array];
    NSMutableArray *markerColours = [NSMutableArray array];
    for (int i=0; i<[sortedArray count]; i++) {
        //NSLog(@"DATE PLACER i %d", i);
        //NSLog(@"sortedArray %lu", (unsigned long)[sortedArray count]);
        
        Game *game=[sortedArray objectAtIndex:i];
        NSDate *date = game.gameDate;
        NSString *stringFromDate=[formatter stringFromDate:date];
        //NSLog(@"last date %@", lastDate);
        //NSLog(@"current date %@", stringFromDate);
        
        if ([lastDate isEqualToString: stringFromDate]){
            stringFromDate = @"";
        //    NSLog(@"skipping date label - same as previous");
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
    
    totalGames =  [sortedArray count];
    NSLog(@"total games: %d", totalGames);
    
    // For the y-axis
    NSMutableArray *durationVals = [NSMutableArray array];
    for (int b=0; b< [sortedArray count]; b++) {
        Game *game=[sortedArray objectAtIndex:b];
        NSNumber * duration = game.duration;
        
        //NSLog(@"Should be %@", duration);
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        [formatter setRoundingMode: NSNumberFormatterRoundUp];
        
        NSString *numberString = [formatter stringFromNumber:duration];
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:numberString];
        
        //NSLog(@"Actually Is %@", myNumber);
        
        [durationVals addObject: myNumber];
    }
    
    
    AAChartZoomType AAChartZoomTypeX;
    
    AAChartModel *aaChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeSpline)
    .titleSet(@"")
    .subtitleSet(@"")
    //.categoriesSet(@[@"Java",@"Swift",@"Python",@"Ruby", @"PHP",@"Go",@"C",@"C#",@"C++"])
    .categoriesSet(dates)
    .colorsThemeSet(markerColours)
    .yAxisTitleSet(@"Duration")
    .tooltipEnabledSet(FALSE)
    .categoriesSet(durationVals)
    .colorsThemeSet(markerColours)
    .dataLabelEnabledSet(FALSE)
    .markerSymbolSet(@"circle")
    //.zoomTypeSet(AAChartZoomTypeX)
    //.yAxisMaxSet(@10)
    .zoomTypeSet(AAChartZoomTypeX)
    //.xAxisVisibleSet(TRUE)
    .markerSymbolStyleSet(AAChartSymbolStyleTypeInnerBlank)
    .seriesSet(@[
                 //MAIN
                 AAObject(AASeriesElement)
                 .nameSet(@"Exhale")
                 .dataSet(durationVals)
                 .showInLegendSet(true)
                 .markerSet(AAMarker.new
                            .fillColorSet(@"#35b31c")
                            .lineWidthSet(@2)
                            .symbolSet(@"circle")
                            ),
                 
                 //RED MARKERS
                 AAObject(AASeriesElement)
                 .nameSet(@"Inhale")
                 .dataSet(durationVals )
                 .showInLegendSet(false)
                 .colorByPointSet(markerColours)
                 .dataLabelsSet(AADataLabels.new
                                .enabledSet(YES)
                                .styleSet(AAStyle.new
                                          .colorSet(@"#000000")
                                          .fontSizeSet(@"12px")
                                          )
                                )
                 .markerSet(AAMarker.new
                            .fillColorSet(@"#35b31c")
                            .lineWidthSet(@6)
                            .symbolSet(@"circle")
                            .radiusSet(@3)
                            ),
                //SECOND MARKER
                 @{
                     @"data" : @"",
                     @"name" : @"Inhale",
                     @"namesSet" : @"Inhale",
                     @"colorByPoint" : @true,
                     @"markerRadius" : @15,
                     @"markerSymbol" : @"circle",
                     @"showInLegendSet" : @true,
                     @"showInLegend" : @true,
                //     @"legendSymbol" : @"circle",
                //     @"symbolStyle" : @"circle",
                     @"marker": @{
                             @"fillColor": @"#ef3118",
                             @"symbol": @"circle",
                             @"lineWidth": @2,
                             @"lineColor": @"#ef3118"
                             }
                   }
        
                ]);

    aaChartModel.colorsThemeSet(markerColours);
    aaChartModel.categoriesSet(dates);
    
    [self.userDataLineChart aa_drawChartWithChartModel:aaChartModel];
    self.userDataLineChart.scrollEnabled = true;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: YES];
    NSLog(@"THIS VIEW HAS LOADED");
    self.userDataLineChart = [[AAChartView alloc]init];
    self.userDataLineChart.frame = CGRectMake(0, 70, self.view.bounds.size.width,  700);
    self.userDataLineChart.scrollEnabled = YES;
    //self.userDataLineChart.contentHeight = self.view.frame.size.height;
    
    NSArray *array = [self.user.game allObjects];
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(Game*)a gameDate];
        NSDate *second = [(Game*)b gameDate];
        return [first compare:second];
    }];
    
    totalGames = [sortedArray count];
    
    if (totalGames > 20){
        
        int add_pixels_above_limit = totalGames * 10;
        NSLog(@"totalGames %d", totalGames);
        NSLog(@"totalGames %d", totalGames / 2);
        
        NSLog(@"totalGames %f", self.view.frame.size.width);
        NSLog(@"totalGames %f", self.view.frame.size.width + add_pixels_above_limit);
        self.userDataLineChart.contentWidth = self.view.frame.size.width + add_pixels_above_limit;
    }else{
        self.userDataLineChart.contentWidth = self.view.frame.size.width;
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.userDataLineChart];
    
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setAlpha:0];
    
    
    [self.backFromChart setFont:[UIFont fontWithName:@"Arial-BoldMT" size:15]];
    
    self.graphTitle.text = self.user.userName;

}


@end
