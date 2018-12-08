//
//  DataChart.m
//  Billiard2017
//
//  Created by Brian Dillon on 08/12/2018.
//  Copyright © 2018 ROCUDO. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Charts;
#import "Billiard2017-Bridging-Header.h"
#import "DataChart.h"

@interface DataChart () <ChartViewDelegate>
@property (strong, nonatomic) IBOutlet LineChartView *userDataLineChart;
//@property (nonatomic, strong) IBOutlet LineChartView *chartView;
//@property (nonatomic, strong) IBOutlet UISlider *sliderX;
//@property (nonatomic, strong) IBOutlet UISlider *sliderY;
//@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
//@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;
@end

@implementation DataChart

- (void)viewDidLoad
{
    //[super viewDidLoad];
    NSLog(@"THIS VIEW HAS LOADED");
    [self.userDataLineChart setNoDataText:@"You need to provide data for the chart BLAH."];
    
    //self.title = @"Line Chart 1";
    
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
     */
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
    
    self.userDataLineChart.legend.form = ChartLegendFormLine;
    
    //_sliderX.value = 45.0;
    // _sliderY.value = 100.0;
    [self slidersValueChanged:nil];
    
    [self.userDataLineChart animateWithXAxisDuration:2.5];
}

- (void)didReceiveMemoryWarning
{
   // [super didReceiveMemoryWarning];
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
    
    LineChartDataSet *set1 = nil;
    if (self.userDataLineChart.data.dataSetCount > 0)
    {
        //    set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        //    set1.values = values;
        //    [_chartView.data notifyDataChanged];//
        ///    [_chartView notifyDataSetChanged];
    }
    else
    {
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





