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
@import Charts;

@interface ChartsViewController : UIViewController <ChartViewDelegate>{
     NSString  *currentType;
     NSString *lastDate;
}
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

- (instancetype)init:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withData:(NSMutableArray *)userData withUser:(User*)user {
    
    NSLog(@"Instantiating graph");
    
    self.user = user;
    self.userData = userData;
    self.userTitle = self.user.userName;
    currentType = @"Duration";
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"THIS VIEW HAS LOADED");
    //[self.userDataLineChart setNoDataText:@"You need to provide data for the chart BLAH."];
    
    self.title =self.userTitle;
    
    CGFloat chartViewWidth  = self.view.frame.size.width/1.10;
    CGFloat chartViewHeight = self.view.frame.size.height/1.18;
    self.userDataLineChart = [[AAChartView alloc]init];
    self.userDataLineChart.frame = CGRectMake(-20, 0, chartViewWidth, chartViewHeight);
    self.userDataLineChart.scrollEnabled = YES;
    //// set the content height of aaChartView
    //self.userDataLineChart.contentHeight = chartViewHeight;
    [self.view addSubview:self.userDataLineChart];
    
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
    .subtitleSet(@"f")
    //.categoriesSet(@[@"Java",@"Swift",@"Python",@"Ruby", @"PHP",@"Go",@"C",@"C#",@"C++"])
    .categoriesSet(dates)
    .yAxisTitleSet(@"Duration")
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"Inhale")
                 .dataSet(durationVals ),
                 //.dataSet(@[@7.0, @6.9, @9.5, @14.5, @18.2, @21.5, @25.2, @26.5, @23.3, @18.3, @13.9, @9.6]),
                 AAObject(AASeriesElement)
                 .nameSet(@"Exhale")
                 //.dataSet(@[@0.2, @0.8, @5.7, @11.3, @17.0, @22.0, @24.8, @24.1, @20.1, @14.1, @8.6, @2.5]),
                 //AAObject(AASeriesElement)
                 //.nameSet(@"2019")
                 //.dataSet(@[@0.9, @0.6, @3.5, @8.4, @13.5, @17.0, @18.6, @17.9, @14.3, @9.0, @3.9, @1.0]),
                 //AAObject(AASeriesElement)
                 //.nameSet(@"2020")
                 //.dataSet(@[@3.9, @4.2, @5.7, @8.5, @11.9, @15.2, @17.0, @16.6, @14.2, @10.3, @6.6, @4.8]),
                 ])
    ;
    
    [self.userDataLineChart aa_drawChartWithChartModel:aaChartModel];
    
    /*
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
        CPTAxisLabel *xlabel = [[CPTAxisLabel alloc] initWithText:stringFromDate  textStyle:x.labelTextStyle];
        NSNumber *myXIndex = @(i);
        xlabel.tickLocation = myXIndex;
        xlabel.offset = x.titleOffset + x.majorTickLength;
        xlabel.rotation = M_PI/3;
        xlabel.tickLocation = myXIndex;
        [customXTickLocations addObject:myXIndex];
        [xAxisLabels addObject:xlabel];
        
        lastDate = [formatter stringFromDate:date]  ;
        /// }
    }
    
    for (int b=0; b<15; b++) {
        //NSDictionary  *plotPoint =[plotData objectAtIndex:b];
        //NSNumber *yValue = [plotPoint objectForKey:@"y"];
        NSNumber *yValue = [NSNumber numberWithInt: b];
        NSString *myString = [yValue stringValue];
        myString = [myString substringToIndex: MIN(3, [myString length])];
        CPTAxisLabel *ylabel = [[CPTAxisLabel alloc] initWithText:myString  textStyle:y.labelTextStyle];
        ylabel.tickLocation = yValue;
        ylabel.offset = 4;
        [customYTickLocations addObject:yValue];
        [yAxisLabels addObject:ylabel];
    }
     */
    
    
    
    /*self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleFilled", @"label": @"Toggle Filled"},
                     @{@"key": @"toggleCircles", @"label": @"Toggle Circles"},
                     @{@"key": @"toggleCubic", @"label": @"Toggle Cubic"},
                     @{@"key": @"toggleHorizontalCubic", @"label": @"Toggle Horizontal Cubic"},
                     @{@"key": @"toggleIcons", @"label": @"Toggle Icons"},
                     @{@"key": @"toggleStepped", @"label": @"Toggle Stepped"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     ];
   
    self.userDataLineChart.delegate = self;
    
    self.userDataLineChart.chartDescription.enabled = NO;
    
    self.userDataLineChart.dragEnabled = YES;
    [self.userDataLineChart setScaleEnabled:YES];
    self.userDataLineChart.pinchZoomEnabled = YES;
    self.userDataLineChart.drawGridBackgroundEnabled = NO;
    
    // x-axis limit line
    ChartLimitLine *llXAxis = [[ChartLimitLine alloc] initWithLimit:10.0 label:@"Index 10"];
    llXAxis.lineWidth = 4.0;
    llXAxis.lineDashLengths = @[@(10.f), @(10.f), @(0.f)];
    llXAxis.labelPosition = ChartLimitLabelPositionRightBottom;
    llXAxis.valueFont = [UIFont systemFontOfSize:10.f];
    
    //[_chartView.xAxis addLimitLine:llXAxis];
    
    self.userDataLineChart.xAxis.gridLineDashLengths = @[@10.0, @10.0];
    self.userDataLineChart.xAxis.gridLineDashPhase = 0.f;
    
    ChartLimitLine *ll1 = [[ChartLimitLine alloc] initWithLimit:150.0 label:@"Upper Limit"];
    ll1.lineWidth = 4.0;
    ll1.lineDashLengths = @[@5.f, @5.f];
    ll1.labelPosition = ChartLimitLabelPositionRightTop;
    ll1.valueFont = [UIFont systemFontOfSize:10.0];
    
    ChartLimitLine *ll2 = [[ChartLimitLine alloc] initWithLimit:-30.0 label:@"Lower Limit"];
    ll2.lineWidth = 4.0;
    ll2.lineDashLengths = @[@5.f, @5.f];
    ll2.labelPosition = ChartLimitLabelPositionRightBottom;
    ll2.valueFont = [UIFont systemFontOfSize:10.0];
    
    ChartYAxis *leftAxis = self.userDataLineChart.leftAxis;
    [leftAxis removeAllLimitLines];
    [leftAxis addLimitLine:ll1];
    [leftAxis addLimitLine:ll2];
    leftAxis.axisMaximum = 200.0;
    leftAxis.axisMinimum = -50.0;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    
    self.userDataLineChart.rightAxis.enabled = NO;
    
    //[_chartView.viewPortHandler setMaximumScaleY: 2.f];
    //[_chartView.viewPortHandler setMaximumScaleX: 2.f];
    
    self.userDataLineChart.legend.form = ChartLegendFormLine;*/
    
    //_sliderX.value = 45.0;
   // _sliderY.value = 100.0;
    //[self slidersValueChanged:nil];
    
    //[self.userDataLineChart animateWithXAxisDuration:2.5];
}


-(void)generateData
{
    NSArray *array = [self.user.game allObjects];
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(Game*)a gameDate];
        NSDate *second = [(Game*)b gameDate];
        return [first compare:second];
    }];
    
    if ([array count]==0) {
        return;
    }
    
    NSMutableArray *contentArray = [NSMutableArray array];
    
    for ( NSUInteger i = 0; i < [sortedArray count]; i++ ) {
        
        NSNumber  *dateNumber=[NSNumber numberWithInt:i];
        NSNumber  *yvalue=0;
        
        if ([currentType isEqualToString:@"Power"]) {
            yvalue=[[sortedArray objectAtIndex:i]valueForKey:@"power"];
            [contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:dateNumber, @"x", yvalue, @"y", nil]];
        }else if([currentType isEqualToString:@"Duration"])
        {
            yvalue=[[sortedArray objectAtIndex:i]valueForKey:@"duration"];
            [contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:dateNumber, @"x", yvalue, @"y", nil]];
        }else
        {
            yvalue=[[sortedArray objectAtIndex:i]valueForKey:@"power"];
        }
    }
    
    self.plotData = contentArray;
}

/*
-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)idx
{
    NSArray *array = [self.userData.game allObjects];
    
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(Game*)a gameDate];
        NSDate *second = [(Game*)b gameDate];
        return [first compare:second];
    }];
    
    Game  *game=[sortedArray objectAtIndex:idx];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    
    if ([game.gameDirection isEqualToString:@"exhale"]) {
        plotSymbol.fill = [CPTFill fillWithColor:[[CPTColor redColor] colorWithAlphaComponent:1]];
        
    }else if ([game.gameDirection isEqualToString:@"inhale"])
    {
        plotSymbol.fill = [CPTFill fillWithColor:[[CPTColor blueColor] colorWithAlphaComponent:1]];
    }
    
    plotSymbol.size  = CGSizeMake(1.0, 5.0);
    
    return plotSymbol;
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData
{
    // if (self.shouldHideData)
    //{
    //    _chartView.data = nil;
    //     return;
    // }
    
    // [self setDataCount:_sliderX.value range:_sliderY.value];
}

- (void)setDataCount:(int)count range:(double)range
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        double val = arc4random_uniform(range) + 3;
        [values addObject:[[ChartDataEntry alloc] initWithX:i y:val icon: [UIImage imageNamed:@"icon"]]];
    }
    
   // LineChartDataSet *set1 = nil;
    //if (self.userDataLineChart.data.dataSetCount > 0)
   // {
    //    set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
    //    set1.values = values;
    //    [_chartView.data notifyDataChanged];//
    ///    [_chartView notifyDataSetChanged];
   // }
   // else
   // {
    /*
        set1 = [[LineChartDataSet alloc] initWithValues:values label:@"DataSet 1"];
        
        set1.drawIconsEnabled = NO;
        
        set1.lineDashLengths = @[@5.f, @2.5f];
        set1.highlightLineDashLengths = @[@5.f, @2.5f];
        [set1 setColor:UIColor.blackColor];
        [set1 setCircleColor:UIColor.blackColor];
        set1.lineWidth = 1.0;
        set1.circleRadius = 3.0;
        set1.drawCircleHoleEnabled = NO;
        set1.valueFont = [UIFont systemFontOfSize:9.f];
        set1.formLineDashLengths = @[@5.f, @2.5f];
        set1.formLineWidth = 1.0;
        set1.formSize = 15.0;
        
        NSArray *gradientColors = @[
                                    (id)[ChartColorTemplates colorFromString:@"#00ff0000"].CGColor,
                                    (id)[ChartColorTemplates colorFromString:@"#ffff0000"].CGColor
                                    ];
        CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
        
        set1.fillAlpha = 1.f;
        set1.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
        set1.drawFilledEnabled = YES;
        
        CGGradientRelease(gradient);
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        
        self.userDataLineChart.data = data;
    }
     */
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    //_sliderTextX.text = [@((int)_sliderX.value) stringValue];
    //_sliderTextY.text = [@((int)_sliderY.value) stringValue];
    
    [self updateChartData];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}


@end
