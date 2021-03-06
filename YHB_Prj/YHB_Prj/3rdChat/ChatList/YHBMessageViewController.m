//
//  YHBMessageViewController.m
//  YHB_Prj
//
//  Created by Johnny's on 15/1/29.
//  Copyright (c) 2015年 striveliu. All rights reserved.
//

#import "YHBMessageViewController.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "YHBDataService.h"
#import "YHBGetPushSyslist.h"
#import "SVPullToRefresh.h"

@interface YHBMessageViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL isFirstLoad;
}
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation YHBMessageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void)scrollViewToBottom
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"系统消息"];
    self.view.backgroundColor = RGBCOLOR(245, 245, 245);
    isFirstLoad = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = RGBCOLOR(245, 245, 245);
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.dataSource = [NSMutableArray new];
    
    YHBDataService *dataService = [YHBDataService sharedYHBDataSevice];
    NSArray *syslist = [dataService getSyslist];
    NSArray *resultList = [NSArray new];
    if (syslist.count>10)
    {
        NSRange range = NSMakeRange(syslist.count-10, 10);
        resultList = [syslist subarrayWithRange:range];
    }
    else
    {
        resultList = syslist;
    }
    for (YHBGetPushSyslist *model in resultList)
    {
        NSString *time = model.adddate;
        [self.dataSource addObject:time];
        MessageModel *messageModel = [MessageModel new];
        messageModel.isSender = NO;
        messageModel.type = eMessageBodyType_Text;
        messageModel.content = model.title;
        messageModel.headImageName = @"Icon";
        [self.dataSource addObject:messageModel];
    }
    
    [self addTableViewTrag];
}

#pragma mark 增加上拉下拉
- (void)addTableViewTrag
{
    __weak YHBMessageViewController *weakself = self;
    [weakself.tableView addPullToRefreshWithActionHandler:^{
        YHBDataService *dataService = [YHBDataService sharedYHBDataSevice];
        NSArray *syslist = [dataService getSyslist];
        int numberOfData = (int)self.dataSource.count;
        if (numberOfData>0 && numberOfData%20==0)
        {
            if (syslist.count>numberOfData/2)
            {
                [weakself.tableView.pullToRefreshView stopAnimating];
                NSArray *resultList = [NSArray new];
                if (syslist.count>numberOfData/2+10)
                {
                    NSRange range = NSMakeRange(syslist.count-10, 10);
                    resultList = [syslist subarrayWithRange:range];
                }
                else
                {
                    resultList = syslist;
                }
                for (int i=0; i<resultList.count; i++)
                {
                    YHBGetPushSyslist *model = [resultList objectAtIndex:i];
                    NSString *time = model.adddate;
                    [self.dataSource insertObject:time atIndex:i*2];
                    MessageModel *messageModel = [MessageModel new];
                    messageModel.isSender = NO;
                    messageModel.type = eMessageBodyType_Text;
                    messageModel.content = model.title;
                    messageModel.headImageName = @"Icon";
                    [self.dataSource insertObject:messageModel atIndex:i*2+1];
                }
                [self.tableView reloadData];
            }
            else
            {
                [weakself.tableView.pullToRefreshView stopAnimating];
            }
        }
        else
        {
            [weakself.tableView.pullToRefreshView stopAnimating];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = (int)indexPath.row;
    NSObject *obj = [self.dataSource objectAtIndex:row];
    if ([obj isKindOfClass:[NSString class]])
    {
        return 40;
    }
    else
    {
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = (int)indexPath.row;
    if (row < self.dataSource.count)//|| row==self.dataSource.count)
    {
//        if (self.tableView.contentSize.height > self.tableView.frame.size.height && isFirstLoad)
//        {
//            [self scrollViewToBottom];
//            isFirstLoad = NO;
//        }
        id obj = [self.dataSource objectAtIndex:row];
        if ([obj isKindOfClass:[NSString class]])
        {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            timeCell.textLabel.text = (NSString *)obj;
            
            return timeCell;
        }
        else
        {
            MessageModel *model = (MessageModel *)obj;
            NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
            EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil)
            {
                cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageModel = model;
            
            return cell;
        }
    }
    return nil;
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
