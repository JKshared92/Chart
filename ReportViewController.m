//
//  ReportViewController.m
//  yixing
//
//  Created by pro on 16/6/29.
//  Copyright © 2016年 pro. All rights reserved.
//

#import "ReportViewController.h"
#import "Masonry.h"
#import "CustomPopOverView.h"
#import "UUChart.h"
#import "MBProgressHUD.h"
#import "ReportTableViewCell.h"

#define textCOLOR [UIColor colorWithRed:0/255.0 green:165/255.0 blue:189/255.0 alpha:1]

typedef NS_ENUM(NSInteger, ReportType){
    ReportTypeMonth = 0,
    ReportTypeYear
};

@interface ReportViewController ()<CustomPopOverViewDelegate,UUChartDataSource,UITableViewDelegate,UITableViewDataSource>

//月报
@property (nonatomic, strong) UILabel *mainLabel;

//月报、年报
@property (nonatomic, strong) NSArray *titleAry;

//图view
@property (nonatomic, strong) UIView *myView;

/**判断点击列表*/
@property (nonatomic, assign) BOOL isSurface;
/**判断点击折线*/
@property (nonatomic, assign) BOOL isCurve;
/**判断点击柱形*/
@property (nonatomic, assign) BOOL isColumn;
/**折线*/
@property (nonatomic, strong) UUChart *chartView;
/**柱形*/
@property (nonatomic, strong) UUChart *barView;
/**列表*/
@property (nonatomic, strong) UITableView *tableview;
/**宽(中间view)*/
@property (nonatomic, assign) CGFloat viewWidth;
/**记录信息类型*/
@property (nonatomic, assign) ReportType type;
/**月报横坐标*/
@property (nonatomic, strong) NSArray *monthHorizontal;
/**年报横坐标*/
@property (nonatomic, strong) NSArray *yearHorizontal;
/**月报数值数组*/
@property (nonatomic, strong) NSArray *monthValues;
/**年报数值数组*/
@property (nonatomic, strong) NSArray *yearValues;
/**折线纵坐标顶部值*/
@property (nonatomic, assign) CGFloat lineChartRange;
/**柱形纵坐标顶部值*/
@property (nonatomic, assign) CGFloat barChartRange;

/**单位label*/
@property (nonatomic, strong) UILabel *unitLabel;

@end

@implementation ReportViewController

- (NSArray *)monthHorizontal {
    if (!_monthHorizontal) {
        _monthHorizontal = @[@"1月", @"2月", @"3月", @"4月", @"5月", @"6月"];
        _lineChartRange = 100;
        _barChartRange = 400;
    }
    return _monthHorizontal;
}

- (NSArray *)yearHorizontal {
    if (!_yearHorizontal) {
        _yearHorizontal = @[@"2013年",@"2014年",@"2015年",@"2016年"];
    }
    return _yearHorizontal;
}

- (NSArray *)monthValues {
    if (!_monthValues) {
        _monthValues = @[@[@"95", @"50", @"25", @"75", @"12", @"38"]];
    }
    return _monthValues;
}

- (NSArray *)yearValues {
    if (!_yearValues) {
        _yearValues = @[@[@"108",@"167",@"312",@"245"]];
    }
    return _yearValues;
}

- (NSArray *)titleAry {
    if (!_titleAry) {
        _titleAry = @[@"财务月报", @"财务年报"];
    }
    return _titleAry;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"财务信息";
    
    _isColumn = NO;
    _isSurface = NO;
    _isCurve = YES;
    self.type = ReportTypeMonth;
    
    _mainLabel = [[UILabel alloc]init];
    _mainLabel.text = @"财务月报";
    _mainLabel.textAlignment = NSTextAlignmentCenter;
    _mainLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_mainLabel];
    [_mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(30);
        make.height.mas_equalTo(20);
    }];
    
    UIImageView *chooseImageView = [[UIImageView alloc]init];
    chooseImageView.image = [UIImage imageNamed:@"choos"];
    chooseImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:chooseImageView];
    [chooseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_mainLabel.mas_centerY);
        make.size.mas_equalTo(15);
        make.left.mas_equalTo(_mainLabel.mas_right).mas_equalTo(5);
    }];
    
    UIButton *chooseBtn = [[UIButton alloc]init];
    [chooseBtn addTarget:self action:@selector(clickChooseBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chooseBtn];
    [chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_mainLabel.mas_centerY);
        make.width.mas_equalTo(85);
        make.left.mas_equalTo(_mainLabel.mas_left);
        make.height.mas_equalTo(20);
    }];
    
    CGFloat rightMargin = 0;
    CGFloat width = 70;
    CGFloat leftMargin = 10;
    if (KSCREEN_HEIGHT <= IPHONE5S_HEIGHT) {
        rightMargin = 0;
        width = 70;
        leftMargin = 5;
    }
    UIButton *columnBtn = [[UIButton alloc]init];
    [columnBtn setImage:[UIImage imageNamed:@"column"] forState:UIControlStateNormal];
    [columnBtn setTitle:@"柱形" forState:UIControlStateNormal];
    [columnBtn setTitleColor:textCOLOR forState:UIControlStateNormal];
    columnBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [columnBtn setTitleEdgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
    [self.view addSubview:columnBtn];
    [columnBtn addTarget:self action:@selector(clickColumnBtn) forControlEvents:UIControlEventTouchUpInside];
    [columnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_mainLabel.mas_bottom).mas_equalTo(50);
        make.rightMargin.mas_equalTo(-rightMargin);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *curveBtn = [[UIButton alloc]init];
    [curveBtn setImage:[UIImage imageNamed:@"curve"] forState:UIControlStateNormal];
    [curveBtn setTitle:@"折线" forState:UIControlStateNormal];
    [curveBtn setTitleColor:textCOLOR forState:UIControlStateNormal];
    curveBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [curveBtn setTitleEdgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
    [self.view addSubview:curveBtn];
    [curveBtn addTarget:self action:@selector(clickCurveBtn) forControlEvents:UIControlEventTouchUpInside];
    [curveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(columnBtn.mas_centerY);
        make.rightMargin.mas_equalTo(columnBtn.mas_left).mas_equalTo(-leftMargin);
        make.width.mas_equalTo(columnBtn.mas_width);
        make.height.mas_equalTo(columnBtn.mas_height);
    }];
    
    UIButton *surfaceBtn = [[UIButton alloc]init];
    [surfaceBtn setImage:[UIImage imageNamed:@"surface"] forState:UIControlStateNormal];
    surfaceBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [surfaceBtn setTitle:@"列表" forState:UIControlStateNormal];
    [surfaceBtn setTitleColor:textCOLOR forState:UIControlStateNormal];
    surfaceBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [surfaceBtn setTitleEdgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
    [self.view addSubview:surfaceBtn];
    [surfaceBtn addTarget:self action:@selector(clickSurfaceBtn) forControlEvents:UIControlEventTouchUpInside];
    [surfaceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(columnBtn.mas_centerY);
        make.rightMargin.mas_equalTo(curveBtn.mas_left).mas_equalTo(-leftMargin);
        make.width.mas_equalTo(columnBtn.mas_width);
        make.height.mas_equalTo(columnBtn.mas_height);
    }];
    
    _myView = [[UIView alloc]init];
    _myView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_myView];
    CGFloat viewWidth = KSCREEN_WIDTH-60;
    if (KSCREEN_HEIGHT <= IPHONE5S_HEIGHT) {
        viewWidth = KSCREEN_WIDTH-40;
    }
    self.viewWidth = viewWidth;
    [_myView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(surfaceBtn.mas_bottom).mas_equalTo(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(self.viewWidth);
        make.height.mas_equalTo(KSCREEN_HEIGHT/3);
    }];
    
    _unitLabel = [[UILabel alloc]init];
    _unitLabel.text = @"单位:万元";
    _unitLabel.font = [UIFont systemFontOfSize:12];
    _unitLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:_unitLabel];
    [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KSCREEN_HEIGHT<=IPHONE5S_HEIGHT?15:25);
        make.height.mas_equalTo(15);
        make.bottom.mas_equalTo(_myView.mas_top).mas_equalTo(-5);
    }];
    
    self.chartView = [[UUChart alloc]initWithFrame:CGRectMake(0, 0, self.viewWidth, KSCREEN_HEIGHT/3) dataSource:self style:UUChartStyleLine];
    [self.chartView showInView:_myView];
}

#pragma mark - 点击选择财务类型按钮
- (void)clickChooseBtn {
    CustomPopOverView *view = [[CustomPopOverView alloc]initWithBounds:CGRectMake(0, 0, 90, 68) titleMenus:self.titleAry];
    view.delegate = self;
    [view showFrom:_mainLabel alignStyle:CPAlignStyleCenter];
}

#pragma mark - 点击列表按钮
- (void)clickSurfaceBtn {
    if (!_isSurface) {
        _unitLabel.hidden = YES;
        if (self.chartView) {
            [self.chartView removeFromSuperview];
            self.chartView = nil;
        }else if (self.barView) {
            [self.barView removeFromSuperview];
            self.barView = nil;
        }
        self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.viewWidth, KSCREEN_HEIGHT/3) style:UITableViewStylePlain];
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        NSInteger count = self.monthHorizontal.count > self.yearHorizontal.count ? self.monthHorizontal.count : self.yearHorizontal.count;
        if ((count + 1) * 25 > KSCREEN_HEIGHT/3) {
            self.tableview.scrollEnabled = YES;
            self.tableview.showsVerticalScrollIndicator = NO;
        }else {
            self.tableview.scrollEnabled = NO;
        }
        [_myView addSubview:self.tableview];
        [self.tableview registerNib:[UINib nibWithNibName:@"ReportTableViewCell" bundle:nil] forCellReuseIdentifier:@"report"];
        _isColumn = NO;
        _isSurface = YES;
        _isCurve = NO;
    }
}

#pragma mark - 点击柱形按钮
- (void)clickColumnBtn {
    if (!_isColumn) {
        _unitLabel.hidden = NO;
        if (self.chartView) {
            [self.chartView removeFromSuperview];
            self.chartView = nil;
        }else if (self.tableview) {
            [self.tableview removeFromSuperview];
            self.tableview = nil;
        }
        self.barView = [[UUChart alloc]initWithFrame:CGRectMake(0, 0, self.viewWidth, KSCREEN_HEIGHT/3) dataSource:self style:UUChartStyleBar];
        [self.barView showInView:_myView];
        _isColumn = YES;
        _isSurface = NO;
        _isCurve = NO;
    }
}

#pragma mark - 点击折线按钮
- (void)clickCurveBtn {
    if (!_isCurve) {
        _unitLabel.hidden = NO;
        if (self.barView) {
            [self.barView removeFromSuperview];
            self.barView = nil;
        }else if (self.tableview) {
            [self.tableview removeFromSuperview];
            self.tableview = nil;
        }
        self.chartView = [[UUChart alloc]initWithFrame:CGRectMake(0, 0, self.viewWidth, KSCREEN_HEIGHT/3) dataSource:self style:UUChartStyleLine];
        [self.chartView showInView:_myView];
        _isColumn = NO;
        _isSurface = NO;
        _isCurve = YES;
    }
}

#pragma mark - 下拉代理
- (void)popOverView:(CustomPopOverView *)pView didClickMenuIndex:(NSInteger)index {
    if (![self.titleAry[index] isEqualToString:_mainLabel.text]) {
        _mainLabel.text = self.titleAry[index];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            
            sleep(2.);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                
                if (self.type == ReportTypeMonth) {
                    self.type = ReportTypeYear;
                }else {
                    self.type = ReportTypeMonth;
                }
                [self.chartView removeFromSuperview];
                self.chartView = nil;
                self.chartView = [[UUChart alloc]initWithFrame:CGRectMake(0, 0, self.viewWidth, KSCREEN_HEIGHT/3) dataSource:self style:UUChartStyleLine];
                [self.chartView showInView:_myView];
                _isColumn = NO;
                _isSurface = NO;
                _isCurve = YES;
            });
        });
    }
}

#pragma mark - 折线、柱形 delegate
//横坐标数组
- (NSArray *)chartConfigAxisXLabel:(UUChart *)chart {
    if (self.type == ReportTypeMonth) {
        return self.monthHorizontal;
    }else {
        return self.yearHorizontal;
    }
}
//数组数组
- (NSArray *)chartConfigAxisYValue:(UUChart *)chart {
    if (self.type == ReportTypeMonth) {
        return self.monthValues;
    }else {
        return self.yearValues;
    }
}
//颜色数组
- (NSArray *)chartConfigColors:(UUChart *)chart {
    return @[textCOLOR];
}
//纵坐标区域
- (CGRange)chartRange:(UUChart *)chart {
    if (self.type == ReportTypeMonth) {
        return CGRangeMake(self.lineChartRange, 0);
    }else {
        return CGRangeMake(self.barChartRange, 0);
    }
}
//高亮区域
- (CGRange)chartHighlightRangeInLine:(UUChart *)chart {
    return CGRangeZero;
}
//是否显示横线
- (BOOL)chart:(UUChart *)chart showHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}
//是否显示最大最小值
- (BOOL)chart:(UUChart *)chart showMaxMinAtIndex:(NSInteger)index
{
    return NO;
}
//是否显示值(line)
- (BOOL)UUChartShowValues:(UUChart *)chart {
    return YES;
}
//是否显示值(bar)
- (BOOL)UUChartShowBarValues:(UUChart *)chart {
    return YES;
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.type == ReportTypeMonth ? self.monthHorizontal.count + 1 : self.yearHorizontal.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"report"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor lightGrayColor];
        cell.yearLabel.text = @"年份";
        cell.moneyLabel.text = @"金额(万元)";
    }else {
        cell.backgroundColor = [UIColor whiteColor];
        if (self.type == ReportTypeMonth) {
            NSArray *ary = self.monthValues[0];
            cell.yearLabel.text = self.monthHorizontal[indexPath.row-1];
            cell.moneyLabel.text = ary[indexPath.row-1];
        }else if (self.type == ReportTypeYear){
            NSArray *ary = self.yearValues[0];
            cell.yearLabel.text = self.yearHorizontal[indexPath.row-1];
            cell.moneyLabel.text = ary[indexPath.row-1];
        }
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 25;
}

@end
