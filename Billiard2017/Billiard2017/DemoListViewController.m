//
//  DemoListViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "DemoListViewController.h"
#import "LineChart1ViewController.h"
#import "LineChart2ViewController.h"

@interface DemoListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *itemDefs;
@end

@implementation DemoListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Charts Demonstration";

    self.itemDefs = @[
                      @{
                          @"title": @"Line Chart",
                          @"subtitle": @"A simple demonstration of the linechart.",
                          @"class": LineChart1ViewController.class
                          },
                      @{
                          @"title": @"Line Chart (Dual YAxis)",
                          @"subtitle": @"Demonstration of the linechart with dual y-axis.",
                          @"class": LineChart2ViewController.class
                          }
                      ];
    //FIXME: Add TimeLineChart
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemDefs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *def = self.itemDefs[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = def[@"title"];
    cell.detailTextLabel.text = def[@"subtitle"];
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *def = self.itemDefs[indexPath.row];
    
    Class vcClass = def[@"class"];
    UIViewController *vc = [[vcClass alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
