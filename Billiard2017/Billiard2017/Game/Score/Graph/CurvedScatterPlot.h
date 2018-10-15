#import "PlotItem.h"
#import "User.h"
@interface CurvedScatterPlot : PlotItem<CPTPlotSpaceDelegate,
                                        CPTPlotDataSource,
                                        CPTScatterPlotDelegate>
{
    @private
    CPTPlotSpaceAnnotation *symbolTextAnnotation;

    NSArray *plotData;
    NSArray *plotData1;
    NSArray *plotData2;
    NSArray *testPlotData;
    NSString *lastDate;
}

-(void)setUser:(User*)user;
-(void)setType:(NSString*)type;
@end
