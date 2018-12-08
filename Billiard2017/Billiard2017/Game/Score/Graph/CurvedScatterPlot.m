#import "CurvedScatterPlot.h"
#import "Game.h"
NSString *const kData   = @"Score";
NSString *const kFirst  = @"Exhale";
NSString *const kSecond = @"Inhale";

@interface CurvedScatterPlot()
{
    NSString  *currentType;
}

@property(nonatomic,strong) User   *userData;

@end

@implementation CurvedScatterPlot

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Curved Scatter Plot";
        self.section = kLinePlots;
    }
    
    return self;
}

-(void)killGraph
{
    if ( [self.graphs count] ) {
        CPTGraph *graph = [self.graphs objectAtIndex:0];
        
        if ( symbolTextAnnotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
            symbolTextAnnotation = nil;
        }
    }
    
    [super killGraph];
}

-(void)setUser:(User*)user
{
    self.userData = user;
    self.title = self.userData.userName;
}

-(void)setType:(NSString*)type
{
    currentType=type;
}

-(NSSet*)gamesWithoutSeconds:(NSArray*)array
{
    NSSet  *result = nil;
    return result;
}

-(NSArray*)noPowerArray
{
    NSArray *src=nil;
    src=[self.userData.game allObjects];
    NSMutableArray  *durationOnly=[NSMutableArray new];
    
    for (Game *agame in src) {
        if ([agame.gameType intValue]==2) {
            [durationOnly addObject:agame];
        }
    }

    return durationOnly;
}

-(void)makeDateArrayNoTimes
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMM y "];
    NSArray *array =[self noPowerArray];
    
    for (int i=0; i<[array count]; i++) {
        
        Game  *game=[array objectAtIndex:i];
        NSLog(@"type == %@",game.gameType);
        
        // game.gameDate
        NSDate *date = game.gameDate;
        NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                         fromDate:date];
        NSDate *today = [cal dateFromComponents:comps];
        NSLog(@"%@",today);
    }
}

-(void)generateData
{
    NSArray *array = [self.userData.game allObjects];
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
    
    plotData = contentArray;
}

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


-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
   
    NSArray *array = [self.userData.game allObjects];
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(Game*)a gameDate];
        NSDate *second = [(Game*)b gameDate];
        return [first compare:second];
    }];
    
    if ([sortedArray count]==0) {
        return;
    }
    
    NSLog(@"SORTED -- - %@", sortedArray);
    NSLog(@"PLOT DATA -- - %@", plotData);
    
    CGRect bounds = layerHostingView.bounds;
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    //[self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:k]];
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    //[self setPaddingDefaultsForGraph:graph withBounds:bounds];
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 1;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];
    
    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 2.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];
    
    CPTLineCap *lineCap = [CPTLineCap sweptArrowPlotLineCap];
    lineCap.size = CGSizeMake(10.0, 5.0);
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    CPTXYAxis *y = axisSet.yAxis;
    //x.labelRotation = M_PI/4;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    
   // x.orthogonalPosition = [NSNumber numberWithShort:0];
   // y.orthogonalPosition = [NSNumber numberWithShort:0];
    
    lineCap.lineStyle = x.axisLineStyle;
    CPTColor *lineColor = lineCap.lineStyle.lineColor;
    if ( lineColor ) {
        lineCap.fill = [CPTFill fillWithColor:lineColor];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMM y "];
    
    //Game  *firstgame=[sortedArray objectAtIndex:0];
    NSMutableSet *customXTickLocations=[NSMutableSet setWithCapacity:[sortedArray count] +1];
    NSMutableSet *customYTickLocations=[NSMutableSet setWithCapacity:[plotData count] +1];
    NSMutableSet *xAxisLabels=[NSMutableSet setWithCapacity:[sortedArray count] +1];
    NSMutableSet *yAxisLabels=[NSMutableSet setWithCapacity:[plotData count] + 1];
    
    CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:@""  textStyle:x.labelTextStyle];
    [customXTickLocations addObject: [NSNumber numberWithInteger:0]];
    [customYTickLocations addObject: [NSNumber numberWithInteger:0]];
    [xAxisLabels addObject: label];
    [yAxisLabels addObject: label];

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
    
    NSLog(@"customTickLocations %@", customXTickLocations);
    NSLog(@"xAxisLabels %@", xAxisLabels);
    
    x.axisLabels = xAxisLabels;
    x.majorTickLocations = customXTickLocations;
    x.majorTickLength = 15.0f;
    x.minorTickLength = 12.0f;
    x.minorTicksPerInterval = 1;
    x.borderWidth = 0;
    x.axisLineCapMax = [CPTLineCap openArrowPlotLineCap];
    x.axisLineCapMax.size = CGSizeMake(4, 4);
    y.axisLabels = yAxisLabels;
    y.minorTicksPerInterval = 3;
    y.majorTickLength = 1.0f;
    y.minorTickLength = 1.0f;
    y.axisLineCapMax = [CPTLineCap openArrowPlotLineCap];
    y.axisLineCapMax.size = CGSizeMake(8, 10);

    y.majorTickLocations = customYTickLocations;
    y.minorTicksPerInterval       = 2;
    y.preferredNumberOfMajorTicks = 4;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.alternatingBandFills        = @[[[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)], [NSNull null]];
    y.alternatingBandAnchor       = @10.0;
    x.majorIntervalLength   = @0.1; //space between lines
    x.minorTicksPerInterval = 4;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    y.preferredNumberOfMajorTicks = 4;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.alternatingBandFills        = @[[[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)], [NSNull null]];
    x.title       = @"Date";
    x.titleOffset = 90;
    
    lineCap.lineStyle = y.axisLineStyle;
    lineColor         = lineCap.lineStyle.lineColor;
    if ( lineColor ) {
        lineCap.fill = [CPTFill fillWithColor:lineColor];
    }
    y.axisLineCapMax = lineCap;
    y.axisLineCapMin = lineCap;
    
    y.title       = @"Duration";
    y.titleOffset = 60;
    
    // Set axes
    graph.axisSet.axes = @[x, y];
    graph.plotAreaFrame.paddingLeft   += 1 * CPTFloat(2.25);
    graph.plotAreaFrame.paddingTop    += 1;
    graph.plotAreaFrame.paddingRight  += 5;
graph.plotAreaFrame.paddingBottom += 5;
    graph.plotAreaFrame.masksToBorder  = NO;
    graph.plotAreaFrame.plotArea.delegate = self;
    plotSpace.delegate              = self;
    
   // x.axisLabels =  [NSSet setWithArray:customLabels];
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = kData;
    
    // Make the data source line use curved interpolation
   dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
    // First derivative
    CPTScatterPlot *firstPlot = [[CPTScatterPlot alloc] init];
    firstPlot.identifier    = kFirst;
    lineStyle.lineWidth     = 2.0;
    lineStyle.lineColor     = [CPTColor redColor];
    firstPlot.dataLineStyle = lineStyle;
    firstPlot.dataSource    = self;
    [graph addPlot:firstPlot];
    
    // Second derivative
    CPTScatterPlot *secondPlot = [[CPTScatterPlot alloc] init];
    secondPlot.identifier    = kSecond;
    lineStyle.lineColor      = [CPTColor blueColor];
    secondPlot.dataLineStyle = lineStyle;
    secondPlot.dataSource    = self;
    
    [graph addPlot:secondPlot];
    
    // Auto scale the plot space to fit the plot data
    //[plotSpace scaleToFitEntirePlots:[graph allPlots]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    
    // Expand the ranges to put some space around the plot
   /// [xRange expandRangeByFactor:@1.025];
   // xRange.location = plotSpace.xRange.location;
   // [yRange expandRangeByFactor:@1.05];
   // x.visibleAxisRange = xRange;
   // y.visibleAxisRange = yRange;
    
   // [xRange expandRangeByFactor:@3.0];
   // [yRange expandRangeByFactor:@3.0];
   // plotSpace.globalXRange = xRange;
   // plotSpace.globalYRange = yRange;
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill               = [CPTFill fillWithColor:[[CPTColor blueColor] colorWithAlphaComponent:0.5]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(5.0, 5.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;
    
    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self;
    //dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0;
    
    // Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.numberOfRows    = 1;
    graph.legend.textStyle       = x.titleTextStyle;
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake( 0.0, 1 * CPTFloat(2.0) );
}

-(BOOL)plotSpace:(CPTPlotSpace *)willChangePlotRangeTo:(CGFloat)forCoordinate{
    return YES;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger numRecords = 0;
    NSString *identifier  = (NSString *)plot.identifier;
    
    if ( [identifier isEqualToString:kData] ) {
        numRecords = plotData.count;
    }
    else if ( [identifier isEqualToString:kFirst] ) {
        numRecords = plotData1.count;
    }
    else if ( [identifier isEqualToString:kSecond] ) {
        numRecords = plotData2.count;
    }
    
    return numRecords;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num        = nil;
    NSString *identifier = (NSString *)plot.identifier;
    
    if ( [identifier isEqualToString:kData] ) {
        num = [[plotData objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }
    else if ( [identifier isEqualToString:kFirst] ) {
        num = [[plotData1 objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }
    else if ( [identifier isEqualToString:kSecond] ) {
        num = [[plotData2 objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }
    
    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)space.graph.axisSet;
    
    CPTMutablePlotRange *changedRange = [newRange mutableCopy];//ADDED
    
    switch ( coordinate ) {
        case CPTCoordinateX:
            [changedRange expandRangeByFactor:[NSNumber numberWithDouble: 1.025]];
            changedRange.location          = newRange.location;
            axisSet.xAxis.visibleAxisRange = changedRange;
            break;
            
        case CPTCoordinateY:
            [changedRange expandRangeByFactor:[NSNumber numberWithDouble: 1.025]];
            axisSet.yAxis.visibleAxisRange = changedRange;
            break;
            
        default:
            break;
    }
    
    return newRange;
}

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    CPTXYGraph *graph = [self.graphs objectAtIndex:0];
    
    if ( symbolTextAnnotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        symbolTextAnnotation = nil;
    }
    
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontSize = 20.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSNumber *x          = [[plotData objectAtIndex:index] valueForKey:@"x"];
    NSNumber *y          = [[plotData objectAtIndex:index] valueForKey:@"y"];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];
    
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
    symbolTextAnnotation              = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    symbolTextAnnotation.contentLayer = textLayer;
    symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];
}

@end
