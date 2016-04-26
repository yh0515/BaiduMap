//
//  ViewController.m
//  BaiduMap
//
//  Created by cjy on 16/4/25.
//  Copyright © 2016年 cjy. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface ViewController ()<BMKGeneralDelegate, BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate,UITextFieldDelegate>
@property (nonatomic,strong)UITextField *startCityTF;
@property (nonatomic,strong)UITextField *startAddressTF;
@property (nonatomic,strong)UITextField *endCityTF;
@property (nonatomic,strong)UITextField *endAddressTF;
@property (nonatomic,strong)BMKMapView *mapView;
//声明定位服务对象属性 专门负责定位
@property (nonatomic,strong)BMKLocationService *locationService;
//声明地理位置搜索对象
@property (nonatomic,strong)BMKGeoCodeSearch *geoCodeSearch;

@property (nonatomic,strong)BMKRouteSearch *routeSearch;

// 开始的路线检索节点
@property(nonatomic,strong)BMKPlanNode *startNode;
//目标路线检索节点
@property(nonatomic,strong)BMKPlanNode *endNode;

@end

@implementation ViewController
-(void)dealloc{
    self.mapView.delegate = nil;
    self.locationService.delegate = nil;
    self.geoCodeSearch.delegate = nil;
    self.routeSearch.delegate = nil;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _startCityTF.delegate = self;
   _startAddressTF.delegate = self;
   _endCityTF.delegate = self;
    _endAddressTF.delegate =self;
    // Do any additional setup after loading the view, typically from a nib.
    //因为百度 sdk 引擎是用 c++ 代码写的所以我们得保证我们工程中至少有一个文件是. mm 后缀
    //创建百度地图主引擎类(使用百度地图功能之前必须启动引擎)
    BMKMapManager *manager = [[BMKMapManager alloc]init];
    //启动引擎
    [manager start:@"h37uQmCAtDuCvpT4hz76GrHt5qIcuO4d" generalDelegate:self];
    // 搭建 UI
    [self addSubViews];
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0) {
        //设置边距
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    
    //创建定位服务对象
    self.locationService = [[BMKLocationService alloc]init];
    //设置代理
        self.locationService.delegate = self;
    
    //设置在此定位的最小距离
    
    //创建地理位置搜索对象
    self.geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
    self.geoCodeSearch.delegate = self;
    
    //创建 route 搜索对象
    self.routeSearch = [[BMKRouteSearch alloc]init];
    self.routeSearch.delegate = self;
 

}
/**
 *  搭建 UI 方法
 */
- (void)addSubViews{
    
    //设置BarButtonItem
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:@"开始定位" style:UIBarButtonItemStylePlain target:self action:@selector(leftAction)];
    self.navigationItem.leftBarButtonItem = left;
    
      UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:@"关闭定位" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = right;
    
    self.startCityTF = [[UITextField alloc]initWithFrame:CGRectMake(20, 30, 100, 30)];
    [self.view addSubview:self.startCityTF];
    self.startCityTF.text = @"开始城市";
    self.startAddressTF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_startCityTF.frame)+ 30,CGRectGetMinY(_startCityTF.frame),CGRectGetWidth(_startCityTF.frame),CGRectGetHeight(_startCityTF.frame))];
    self.startAddressTF.text = @"开始地址";
    [self.view addSubview:self.startAddressTF];
    
    self.endCityTF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(_startCityTF.frame),CGRectGetMaxY(_startCityTF.frame)+10,CGRectGetWidth(_startCityTF.frame),CGRectGetWidth(_startCityTF.frame))];
    self.endCityTF.text = @"目的城市";
    [self.view addSubview:_endCityTF];
    
    self.endAddressTF =[[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_endCityTF.frame)+30,CGRectGetMaxY(_startCityTF.frame)+10,CGRectGetWidth(_startCityTF.frame),CGRectGetWidth(_startCityTF.frame))];
    self.endAddressTF.text = @"目的地址";
    [self.view addSubview:_endAddressTF];
    
    // 添加路线规划
    UIButton *routeSearch = [UIButton buttonWithType:UIButtonTypeSystem];
    [routeSearch setTitle:@"路线规划" forState: UIControlStateNormal];
    routeSearch.frame = CGRectMake(CGRectGetMaxX(_startAddressTF.frame)-20, CGRectGetMaxY(_startAddressTF.frame), 100, 30);
    //设置点击事件
    [routeSearch addTarget:self action:@selector(routeSearchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:routeSearch];
    //设置添加地图
    self.mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_endAddressTF.frame)+5, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height- CGRectGetMaxY(_endAddressTF.frame)-5)];
    
    //设置 mapView 当前的代理对象
    self.mapView.delegate = self;
    [self.view addSubview:_mapView];
}
/**
 *  开始定位
 */
- (void)leftAction{
    //开启定位服务
    [self.locationService startUserLocationService];
    //在地图上显示用户的位置
    self.mapView.showsUserLocation = YES;

}
- (void)rightAction{
    
    // 关闭定位服务
    [self.locationService stopUserLocationService ];

    // 设置地图不显示用户的位置
    self.mapView.showsUserLocation = NO;
    
    // 删除我们添加的标注对象
    [self.mapView removeAnnotation:[self.mapView.annotations lastObject]];
}

/**
 *  路线规划的点击事件
 */
- (void)routeSearchAction:(UIButton *)sender{
    //完成准确正向地理编码
    //创建正向地理编码对象
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    //给想进行正相地理编码的地理位置赋值
    geoCodeSearchOption.city = self.startCityTF.text;
    geoCodeSearchOption.address = self.startAddressTF.text;
    //执行编码
    [self.geoCodeSearch geoCode:geoCodeSearchOption];


}
#pragma mark - BMKlocationService 代理方法

- (void)willStartLocatingUser{

    NSLog(@"开始定位");
}
- (void)didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"%@定位失败",error);

}

/**
 *  定位成功之后次定位
 *
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    
    //完成地理反编码
    //创建反向地理编码选项对象
    BMKReverseGeoCodeOption *reverseOption = [[BMKReverseGeoCodeOption alloc]init];
    //给反向地理编码对象的坐标点赋值
    reverseOption.reverseGeoPoint = userLocation.location.coordinate;
    //执行反向地理编码操作
    [self.geoCodeSearch reverseGeoCode:reverseOption];
    
  
}


#pragma mark BMKGeoCodeSearch 的代理方法
//反向地理编码

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{

    //定义大头针标柱
    BMKPointAnnotation *annotataion = [[BMKPointAnnotation alloc]init];
    //设置标注坐标
    annotataion.coordinate = result.location;
    annotataion.title = result.address;
    //添加到地图里
    [self.mapView addAnnotation:annotataion];
    
    //设置地图显示到该区域
    [self.mapView setCenterCoordinate:result.location animated:YES];
    
    
    

    


}
//正向第地理编码
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{

    if ([result.address isEqualToString:_startAddressTF.text]) {
        //说明当前编码的对象是开始节点
        self.startNode = [[BMKPlanNode alloc]init];
        //给节点的坐标赋值
        _startNode.pt = result.location;
        
        // 发起对目标节点地理编码
        //创建正向地理编码选项对象
        BMKGeoCodeSearchOption *geoOption = [[BMKGeoCodeSearchOption alloc]init];
        geoOption.city = self.endCityTF.text;
        geoOption.address = self.endAddressTF.text;
        //执行正向编码
        [self.geoCodeSearch geoCode:geoOption];
        
        //
        self.endNode = nil;
        
    }else{
    
        self.endNode = [[BMKPlanNode alloc]init];
        _endNode.pt = result.location;
        
    
    
    }
    
    if (_startNode != nil &&_endNode != nil) {
        // 开始进行路线规划
        //创建驾车路线规划
        BMKDrivingRoutePlanOption *drivingRoutePlanOption = [[BMKDrivingRoutePlanOption alloc]init];
        drivingRoutePlanOption.from = _startNode;
        drivingRoutePlanOption.to = _endNode;
        [self.routeSearch drivingSearch:drivingRoutePlanOption];
    }

}

- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error{
    //删除原来的覆盖物
    NSArray *array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    // 删除 overlays(原来的轨迹)
    
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeAnnotations:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        //从中获取所有路线中得的一条
        BMKDrivingRouteLine *plan = [result.routes objectAtIndex:0];
        //计算离线方案中的数目
        NSUInteger size = [plan.steps count];
        
        //声明一个变量用来计算所有轨迹点的总数
        int planPointCounts = 0;
        for (int i = 0 ; i< size; i++) {
            
            //获取路线中的路段
            BMKDrivingStep *step = plan.steps[i];
            if (i == 0 ) {
                //地图显示经纬度区域
                [self.mapView setRegion:BMKCoordinateRegionMake(step.entrace.location, BMKCoordinateSpanMake(0.001, 0.001))];
                
            }
            //累计轨迹点总数
            planPointCounts += step.pointsCount;
            
        }
        //声明一个结构体用来保存所有的轨迹点(每一个轨迹点都是一个结构体)
        //轨迹点结构体的名称为 BMKMapPoint
        BMKMapPoint *temppoints = new
        BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j<size; j++) {
            BMKDrivingStep *transitStep = [plan.steps objectAtIndex:j];
            int k = 0;
            for (k = 0; k<transitStep.pointsCount; k++) {
                
                //获取每个轨迹点的 x,y放入数组中
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
                
            }
        }
        //通过轨迹点构造 BMKPolyline(折线)
        BMKPolyline *polyline = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        //添加到 mapView 上
        //我们想要在地图上显示轨迹,只能先添加 overlay 对象(类比大头针的标注),添加好之后,地图就会根据你设置overlay 显示
        [self.mapView addOverlay:polyline];
    
    }

}


#pragma mark - mapView 的代理方法
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{

    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        //创建要显示的折线
        BMKPolylineView *polineView = [[BMKPolylineView alloc]initWithOverlay:overlay];
        //设置该线条的填充颜色
//        polineView.fillColor = [UIColor redColor];
        //设置线条的颜色
        polineView.strokeColor = [UIColor redColor];
        //线条宽度
        polineView.lineWidth = 10.0;
        return polineView;
    }
    return nil;

}

// 点击空白区域,回收键盘
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    /**释放第一响应*/
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
