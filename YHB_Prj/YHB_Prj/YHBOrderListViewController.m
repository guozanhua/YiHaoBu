//
//  YHBOrderListViewController.m
//  YHB_Prj
//
//  Created by yato_kami on 15/1/18.
//  Copyright (c) 2015年 striveliu. All rights reserved.
//

#import "YHBOrderListViewController.h"
#import "YHBOrderListCell.h"
#import "YHBOrderList.h"
#import "YHBOrderShopInfoView.h"
#import "YHBOrderManager.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"
#import "YHBORslist.h"
#import "YHBUser.h"
#import "YHBPage.h"
#import "YHBStoreViewController.h"
#import "YHBOrderDetailViewController.h"
#import "YHBPublicCommentVC.h"
#import "YHBPaySuccessVC.h"
#import <AlipaySDK/AlipaySDK.h>
#import "YHBOrderActionModel.h"
//#import "YHBOrderManager.h"
#define kPageSize 30
@interface YHBOrderListViewController ()<UITableViewDataSource,UITableViewDelegate,YHBOrderListCellDelegte,YHBOrderShopInfoDelegte>
{
    NSString *_headIdentifer;
    NSString *_payMoneyInfo;
}
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) YHBOrderList *listModel;
@property (strong, nonatomic) YHBOrderManager *orderManger;

@end
@implementation YHBOrderListViewController

- (YHBOrderManager *)orderManger
{
    if (!_orderManger) {
        _orderManger = [YHBOrderManager sharedManager];
    }
    return _orderManger;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-20-44) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = kViewBackgroundColor;
        _tableView.delegate  = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的订单";
    self.view.backgroundColor = kViewBackgroundColor;
    [self.view addSubview:self.tableView];
    _headIdentifer = @"head";
    [self.tableView registerClass:[YHBOrderShopInfoView class] forHeaderFooterViewReuseIdentifier:_headIdentifer];
    [SVProgressHUD showWithStatus:@"拼命加载中.." cover:YES offsetY:0];
    [self getDataWithPageID:1];
    [self addTableViewTragWithTableView:self.tableView];
    
}

#pragma mark - 网络请求
- (void)getDataWithPageID:(NSInteger)pageID
{
    __weak YHBOrderListViewController *weakself = self;
    [self.orderManger getOrderListWithToken:[YHBUser sharedYHBUser].token PageID:pageID PageSize:kPageSize Success:^(YHBOrderList *listModel) {
        [SVProgressHUD dismiss];
        if (pageID == 1) {
            weakself.listModel = listModel;
        }else{
            [weakself.listModel.rslist arrayByAddingObjectsFromArray:listModel.rslist];
            weakself.listModel.page = listModel.page;
        }
        
        [self.tableView reloadData];
    } failure:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error cover:YES offsetY:0];
    }];
}

#pragma mark 上拉下拉
- (void)addTableViewTragWithTableView:(UITableView *)tableView
{
    __weak YHBOrderListViewController *weakself = self;
    __weak UITableView *weakTableView = tableView;
    [tableView addPullToRefreshWithActionHandler:^{
        int16_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [weakTableView.pullToRefreshView stopAnimating];
            [weakself getDataWithPageID:1];
        });
    }];
    
     [tableView addInfiniteScrollingWithActionHandler:^{
     
         YHBPage *page = weakself.listModel.page;
         NSMutableArray *array = weakself.listModel.rslist;
         if (page && (int)page.pageid * kPageSize <= (int)page.pagetotal && array.count >= kPageSize) {
             int16_t delayInSeconds = 2.0;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
             dispatch_after(popTime, dispatch_get_main_queue(), ^{
                 [weakTableView.infiniteScrollingView stopAnimating];
                 [weakself getDataWithPageID:(int)page.pageid+1];
         });
         }else
             [weakTableView.infiniteScrollingView stopAnimating];
     }];
}

#pragma mark - 数据源方法
#pragma mark 数据行数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listModel.rslist.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YHBORslist *model = self.listModel.rslist[indexPath.section];
    return [self getCellHeightWithStatus:(NSInteger)model.status];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kShopHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    YHBOrderShopInfoView *head = [tableView dequeueReusableCellWithIdentifier:_headIdentifer];
    if (!head) {
        head = [[YHBOrderShopInfoView alloc] init];
        head.contentView.backgroundColor = [UIColor whiteColor];
        head.delegate = self;
    }
    YHBORslist *model = self.listModel.rslist[section];
    [head setUIWithCompany:model.sellcom statusDes:model.dstatus ItemID:(NSInteger)model.sellid];
    return head;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listModel.rslist.count?1:0;
}

#pragma mark 每行显示内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    YHBOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[YHBOrderListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }

    YHBORslist *model = self.listModel.rslist[indexPath.section];
    [cell setUIWithStatus:(NSInteger)model.status Title:model.title price:model.money number:model.number amount:model.amount itemID:(int)model.itemid NextAction:model.naction shopID:(NSInteger)model.sellid thumb:model.thumb];
    
    return cell;
}

#pragma mark 点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YHBORslist *model = self.listModel.rslist[indexPath.section];
    //订单详情
    MLOG(@"touch cell");
    YHBOrderDetailViewController *vc = [[YHBOrderDetailViewController alloc] initWithItemId:(NSInteger)model.itemid];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action
#pragma mark 点击head，进入shop
- (void)touchShopWithItemID:(NSInteger)itemID
{
    YHBStoreViewController *vc = [[YHBStoreViewController alloc] initWithShopID:(int)itemID];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 点击按钮
- (void)touchActionButtonWithItemID:(NSInteger)itemid actionStr:(NSString *)action
{
    MLOG(@"touch btn----itemid: %d",itemid );
    if ([action isEqualToString:@"评价"]) {
        [SVProgressHUD showWithStatus:@"加载中.." cover:YES offsetY:0];
        [self.orderManger getOrderDetailWithToken:([YHBUser sharedYHBUser].token ? :@"") ItemID:itemid Success:^(YHBOrderDetail *model) {
            [SVProgressHUD dismiss];
            YHBPublicCommentVC *vc = [[YHBPublicCommentVC alloc] initWithOrderDetailModel:model];
            [vc setPublishSuccessHandler:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        } failure:^(NSString *error) {
            [SVProgressHUD dismissWithError:error];
        }];

    }else if ([action isEqualToString:@"付款"]) {
        //支付
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aliPayresult:) name:kAlipayOrderResultMessage object:nil];
        [self.orderManger getPayInfoWithToken:[YHBUser sharedYHBUser].token ItemID:itemid Success:^(NSString *info, NSString *ordermoney, NSString *overmoney, NSString *realmoney) {
            _payMoneyInfo = [NSString stringWithFormat:@"订单总金额:%@ 余额支付:%@ 实际支付金额:%@",ordermoney,overmoney,realmoney];
            //MLOG(@"info:%@",info);
            if(!overmoney) overmoney = @"0";
            if ([overmoney integerValue] > 0) {
                [YHBUser sharedYHBUser].statusIsChanged = YES;
            }
            if ([realmoney isEqualToString:@"0.00"]) {
                //余额支付
                YHBPaySuccessVC *sVc = [[YHBPaySuccessVC alloc] initWithAppendInfo:_payMoneyInfo];
                [self.navigationController pushViewController:sVc animated:YES];
            }else if (info) {
                static NSString *strSchem = @"com.yibu.kuaibu";
                [[AlipaySDK defaultService] payOrder:info fromScheme:strSchem callback:^(NSDictionary *resultDic) {
                    MLOG(@"%@",resultDic);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAlipayOrderResultMessage object:resultDic];
                }];
            }
        } failure:^(NSString *error) {
            [SVProgressHUD showErrorWithStatus:error cover:YES offsetY:0];
        }];
    }else{
        NSString *actionStr = [YHBOrderActionModel getNextActionStrWithTitle:action];
        [SVProgressHUD showWithStatus:@"操作中..." cover:YES offsetY:0];
        __weak YHBOrderListViewController *weakself = self;
        [self.orderManger changeOrderStatusWithToken:([YHBUser sharedYHBUser].token ? :@"") ItemID:(NSInteger)itemid Action:actionStr?:@"" Success:^{
            [SVProgressHUD showWithStatus:@"操作成功,正在重新加载订单信息.." cover:YES offsetY:0];
            [weakself getDataWithPageID:1];
        } failure:^(NSString *error) {
            [SVProgressHUD dismissWithError:error];
        }];
    }

}

#pragma mark - 支付结果处理
- (void)aliPayresult:(NSNotification *)aNotification
{
    //MLOG(@"resultDic :  %@",aNotification);
    MLOG(@"litcontroller had do");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAlipayOrderResultMessage object:nil];
    NSDictionary *resultDic = [aNotification object];
    
    if(resultDic && resultDic.count)
    {
        MLOG(@"notificationDict = %@",resultDic);
        int resultStatus = [[resultDic objectForKey:@"resultStatus"] intValue];
        NSString *resultDesc = [resultDic objectForKey:@"result"];
        if(resultStatus == 9000)///支付成功
        {
            YHBPaySuccessVC *sVc = [[YHBPaySuccessVC alloc] initWithAppendInfo:_payMoneyInfo];
            [self.navigationController pushViewController:sVc animated:YES];
            
        }
        else if(resultStatus == 8000)///正在处理
        {
            YHBPaySuccessVC *sVc = [[YHBPaySuccessVC alloc] initWithAppendInfo:_payMoneyInfo];
            [self.navigationController pushViewController:sVc animated:YES];
            
        }
        else///支付失败
        {
            [SVProgressHUD showErrorWithStatus:@"支付失败，请重新支付" cover:YES offsetY:kMainScreenHeight/2.0];
            // [[NSNotificationCenter defaultCenter] postNotificationName:kPayFail object:self];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//获取cell高度
- (CGFloat)getCellHeightWithStatus:(NSInteger)status
{
    if (status == 0 || status == 2 || status == 5 || status == 6 || status == 8 || status == 9) {
        return kpriceHeight+75.0;
    }else{
        return kpriceHeight+kBtnViewHeight+75.0;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
