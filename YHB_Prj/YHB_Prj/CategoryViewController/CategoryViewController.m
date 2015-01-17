//
//  CategoryViewController.m
//  YHB_Prj
//
//  Created by Johnny's on 15/1/15.
//  Copyright (c) 2015年 striveliu. All rights reserved.
//

#import "CategoryViewController.h"
#import "SVProgressHUD.h"
#import "YHBCatManage.h"
#import "YHBCatData.h"
#import "YHBCatSubcate.h"
#define space 7
#define btnHeight 30

@interface CategoryViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    YHBCatManage *manage;
    NSMutableArray *chooseArray;
}

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *tableViewArray;
@property(nonatomic, strong) void(^ myBlock)(NSArray *aArray);
@end

@implementation CategoryViewController

+ (CategoryViewController *)sharedInstancetype
{
    static CategoryViewController *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

- (void)setBlock:(void(^)(NSArray *aArray))aBlock
{
    self.myBlock = aBlock;
}

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.tableViewArray.count==0)
    {
        [self showFlower];
        manage = [[YHBCatManage alloc] init];
        [manage getDataArraySuccBlock:^(NSMutableArray *aArray) {
            [self dismissFlower];
            self.tableViewArray = aArray;
            chooseArray = [NSMutableArray new];
//            for (int i=0; i<self.tableViewArray.count; i++)
//            {
//                YHBCatData *dataModel = [self.tableViewArray objectAtIndex:i];
//                NSArray *array = dataModel.subcate;
//                YHBCatSubcate *subModel = [array objectAtIndex:0];
//                [chooseArray addObject:subModel];;
//            }
            [self.tableView reloadData];
        } andFailBlock:^{
            [self dismissFlower];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBCOLOR(236, 236, 236);
    self.title = @"主营类别";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
}

#pragma mark 菊花
- (void)showFlower
{
    [SVProgressHUD show:YES offsetY:kMainScreenHeight/2.0];
}

- (void)dismissFlower
{
    [SVProgressHUD dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section!=self.tableViewArray.count)
    {
        YHBCatData *catModel = [self.tableViewArray objectAtIndex:indexPath.section];
        NSArray *array = catModel.subcate;
        int count = (int)array.count;
        int row = count%4==0?count/4:count/4+1;
        int height = 20+(btnHeight+space)*row+space*2;
        return height;
    }
    else
    {
        return 50;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableViewArray.count>0)
    {
        return self.tableViewArray.count+1;
    }
    else
    {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section!=self.tableViewArray.count)
    {
        cell.backgroundColor = [UIColor whiteColor];
        YHBCatData *catModel = [self.tableViewArray objectAtIndex:indexPath.section];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, space, kMainScreenWidth-20, 20)];
        titleLabel.text = catModel.catname;
        titleLabel.font = kFont18;
        [cell addSubview:titleLabel];
        float btnWidth = (kMainScreenWidth-50)/4.0;
        NSArray *array = catModel.subcate;
        for (int i=0; i<array.count; i++)
        {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10+i%4*(10+btnWidth), 20+space*2+i/4*(btnHeight+space), btnWidth, btnHeight)];
            btn.tag = (indexPath.section+1)*100+i;
            btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            btn.layer.borderWidth = 0.5;
            btn.layer.cornerRadius = 2.5;
            YHBCatSubcate *model = [array objectAtIndex:i];
            [btn setTitle:model.catname forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            btn.titleLabel.font = kFont15;
            [btn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
//            if (i==0)
//            {
//                [btn setTitleColor:KColor forState:UIControlStateNormal];
//                btn.layer.borderColor = [KColor CGColor];
//            }
            [cell addSubview:btn];
        }
    }
    else
    {
        cell.backgroundColor = [UIColor clearColor];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, kMainScreenWidth-20, 40)];
        btn.backgroundColor = KColor;
        btn.layer.cornerRadius = 2.5;
        [btn setTitle:@"确认" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
        [btn addTarget:self action:@selector(touchYesBtn) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
    }
    return cell;
}

- (void)touchBtn:(UIButton *)aBtn
{
    int section = (int)aBtn.tag/100;
    YHBCatData *dataModel = [self.tableViewArray objectAtIndex:section-1];
    NSArray *temArray = dataModel.subcate;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section-1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    for (int i=0; i<temArray.count; i++)
    {
        UIButton *btn = (UIButton *)[cell viewWithTag:section*100+i];
        btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    [aBtn setTitleColor:KColor forState:UIControlStateNormal];
    aBtn.layer.borderColor = [KColor CGColor];
//    [chooseArray removeObjectAtIndex:section-1];
    int index = (int)aBtn.tag%100;
    YHBCatSubcate *subModel = (YHBCatSubcate *)[temArray objectAtIndex:index];
    for (YHBCatSubcate *temModel in chooseArray)
    {
        for (YHBCatSubcate *anTemModel in temArray)
        {
            if (temModel.catid == anTemModel.catid)
            {
                [chooseArray removeObject:temModel];
                break;
            }
        }
    }
    [chooseArray addObject:subModel];
//    [chooseArray insertObject:subModel atIndex:section-1];
}

- (void)touchYesBtn
{
    self.myBlock(chooseArray);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self dismissFlower];
    for (int section=0; section<self.tableViewArray.count; section++)
    {
        YHBCatData *dataModel = [self.tableViewArray objectAtIndex:section];
        NSArray *temArray = dataModel.subcate;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        UIButton *aBtn = (UIButton *)[cell viewWithTag:(section+1)*100];
        for (int i=0; i<temArray.count; i++)
        {
            UIButton *btn = (UIButton *)[cell viewWithTag:(section+1)*100+i];
            btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
//        [aBtn setTitleColor:KColor forState:UIControlStateNormal];
//        aBtn.layer.borderColor = [KColor CGColor];
    }
    chooseArray = [NSMutableArray new];
//    for (int i=0; i<self.tableViewArray.count; i++)
//    {
//        YHBCatData *dataModel = [self.tableViewArray objectAtIndex:i];
//        NSArray *array = dataModel.subcate;
//        YHBCatSubcate *subModel = [array objectAtIndex:0];
//        [chooseArray addObject:subModel];;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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