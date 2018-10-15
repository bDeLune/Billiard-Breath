#import "PlotItem.h"

@interface PlotGallery : NSObject
{
    @private
    NSMutableArray *plotItems;
    NSCountedSet *plotSections;
}

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger numberOfSections;
@property (nonatomic, readonly, retain) NSArray *sectionTitles;

+(PlotGallery *)sharedPlotGallery;

-(void)addPlotItem:(PlotItem *)plotItem;

-(void)sortByTitle;

-(PlotItem *)objectInSection:(NSInteger)section atIndex:(NSUInteger)index;
-(NSInteger)numberOfRowsInSection:(NSInteger)section;

@end
