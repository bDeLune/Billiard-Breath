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
     BOOL chartAdded;
    CGFloat chartViewWidth;
    CGFloat chartViewHeight;
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

- (instancetype)init:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withData:(NSMutableArray *)userData withUser:(User*)user withHeight:(CGFloat)height withWidth:(CGFloat)width {
    
    NSLog(@"Instantiating graph");
    chartAdded = FALSE;
    self.user = user;
    self.userData = userData;
    self.userTitle = self.user.userName;
    currentType = @"Duration";
    
    chartViewWidth  = width;
    chartViewHeight = height;
    
    return self;
}

- (void) viewWillLayoutSubviews{

    if (chartAdded == FALSE){
    
    
    chartAdded = TRUE;
    
    self.userDataLineChart = [[AAChartView alloc]init];
    self.userDataLineChart.frame = CGRectMake(0, 0, chartViewWidth, chartViewHeight + 40);
    self.userDataLineChart.scrollEnabled = YES;
    
    
    [self.view addSubview:self.userDataLineChart];
    
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
    
    //// set the content height of aaChartView
      //self.userDataLineChart.contentHeight = chartViewHeight;
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: YES];
    NSLog(@"THIS VIEW HAS LOADED");
    //[self.userDataLineChart setNoDataText:@"You need to provide data for the chart BLAH."];
    

  
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
