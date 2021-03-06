//
//  YHBBuyDetailViewController.m
//  YHB_Prj
//
//  Created by Johnny's on 14/12/21.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import "YHBBuyDetailViewController.h"
#import "YHBBuyDetailManage.h"
#import "SVProgressHUD.h"
#import "YHBContactView.h"
#import "YHBBuyDetailView.h"
#import "YHBVariousImageView.h"
#import "YHBContactView.h"
#import "PushPriceViewController.h"
#import "YHBPublishBuyViewController.h"
#import "YHBStoreViewController.h"
#import "NetManager.h"
#import "YHBUser.h"
#import "YHBBuyDetailAlbum.h"
#import "YHBMySupplyViewController.h"
#import "JubaoViewController.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"

#define kContactViewHeight 60
@interface YHBBuyDetailViewController ()
{
    UIScrollView *scrollView;
    YHBBuyDetailView *buyDetailView;
    YHBVariousImageView *variousImageView;
    BOOL isModal;
    int itemId;
    YHBBuyDetailData *myModel;
    BOOL isMine;
    YHBContactView *contactView;
    NSArray *uploadPhotoArray;
    BOOL needUpload;
    NSDictionary *itemDict;
    
    int uploadIndex;
    UIActivityIndicatorView *activityView;
    BOOL isWeb;
    
    UIButton *pushPriceBtn;
    UIButton *watchStoreBtn;
}
@property(nonatomic, strong) YHBBuyDetailManage *manage;
@end

@implementation YHBBuyDetailViewController

- (instancetype)initWithItemId:(int)aItemId andIsMine:(BOOL)aIsMine isModal:(BOOL)aIsModal
{
    if (self = [super init]) {
        isModal = aIsModal;
        itemId = aItemId;
        isMine = aIsMine;
        needUpload = NO;
    }
    return self;
}

- (instancetype)initWithItemId:(int)aItemId itemDict:(NSDictionary *)aDict uploadPhotoArray:(NSArray *)aArray isWebArray:(BOOL)aBool
{
    if (self = [super init]) {
        isModal = YES;
        isMine = YES;
        itemId = aItemId;
        uploadPhotoArray = aArray;
        needUpload = YES;
        itemDict = aDict;
        isWeb = aBool;
    }
    
    return self;
}


- (instancetype)init
{
    if (self = [super init]) {
        isModal = YES;
        [self dismissFlower];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBCOLOR(241, 241, 241);
    self.title = @"求购详情";
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-kContactViewHeight-62)];
    [self.view addSubview:scrollView];
    
    variousImageView = [[YHBVariousImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 120) andPhotoArray:[NSArray new]];
    [scrollView addSubview:variousImageView];
    
    buyDetailView = [[YHBBuyDetailView alloc] initWithFrame:CGRectMake(0, variousImageView.bottom, kMainScreenWidth, 235+38*2)];
    [scrollView addSubview:buyDetailView];
    
    [self setLeftButton:[UIImage imageNamed:@"back"] title:nil target:self action:@selector(dismissSelf)];
    
    UIView *navRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 22)];
    UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(navRightView.right-25, 0, 25, 21)];
    [shareBtn setImage:[UIImage imageNamed:@"detailShareImg"] forState:UIControlStateNormal];
    [shareBtn addTarget:self  action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [navRightView addSubview:shareBtn];
    
    if (isMine && needUpload != YES)
    {
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [editBtn setImage:[UIImage imageNamed:@"editImg"] forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
        [navRightView addSubview:editBtn];
    }
    else
    {
        UIButton *jubaoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 24)];
        [jubaoBtn setImage:[UIImage imageNamed:@"jubao"] forState:UIControlStateNormal];
        [jubaoBtn addTarget:self action:@selector(touchjubao) forControlEvents:UIControlEventTouchUpInside];
        [navRightView addSubview:jubaoBtn];
    }
    
    UIBarButtonItem *navRightBarItem = [[UIBarButtonItem alloc] initWithCustomView:navRightView];
    self.navigationItem.rightBarButtonItem = navRightBarItem;
   
    [self showFlower];
    
//    if (isModal==NO)
//    {
        self.manage = [[YHBBuyDetailManage alloc] init];
        [self.manage getBuyDetailWithItemid:itemId SuccessBlock:^(YHBBuyDetailData *aModel)
         {
             myModel = aModel;
             if (!myModel.amount>0)
             {
                 CGRect frame = buyDetailView.frame;
                 frame.size.height -= 38;
                 buyDetailView.frame = frame;
             }
             int userid = [YHBUser sharedYHBUser].userInfo.userid;
             if (userid && userid==myModel.userid && !needUpload)
             {
                 isMine = YES;
                 contactView.hidden = YES;
                 pushPriceBtn.hidden = YES;
                 watchStoreBtn.hidden = YES;
             }
             if (!isMine)
             {
                 pushPriceBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, buyDetailView.bottom+20, kMainScreenWidth/2-20, 40)];
                 pushPriceBtn.backgroundColor = KColor;
                 [pushPriceBtn addTarget:self action:@selector(pushPriceBtn) forControlEvents:UIControlEventTouchUpInside];
                 [pushPriceBtn setTitle:@"我要报价" forState:UIControlStateNormal];
                 [pushPriceBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
                 pushPriceBtn.layer.cornerRadius = 2.5;
                 [scrollView addSubview:pushPriceBtn];
                 
                 watchStoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(pushPriceBtn.right+20, pushPriceBtn.top, kMainScreenWidth/2-20, 40)];
                 watchStoreBtn.backgroundColor = KColor;
                 [watchStoreBtn addTarget:self action:@selector(watchStoreBtn) forControlEvents:UIControlEventTouchUpInside];
                 [watchStoreBtn setTitle:@"他的采购" forState:UIControlStateNormal];
                 watchStoreBtn.layer.cornerRadius = 2.5;
                 [watchStoreBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
                 [scrollView addSubview:watchStoreBtn];
                 
                 if (pushPriceBtn.bottom+20>kMainScreenHeight-62-kContactViewHeight+1)
                 {
                     scrollView.contentSize = CGSizeMake(kMainScreenWidth, pushPriceBtn.bottom+20);
                 }
                 else
                 {
                     scrollView.contentSize = CGSizeMake(kMainScreenWidth, kMainScreenHeight-62-kContactViewHeight+1);
                 }
                 
                 contactView = [[YHBContactView alloc] initWithFrame:CGRectMake(0, scrollView.bottom, kMainScreenWidth, kContactViewHeight) isSupply:NO];
                 contactView.backgroundColor = [UIColor whiteColor];
                 [self.view addSubview:contactView];
             }
             [buyDetailView setDetailWithModel:aModel];
             if (needUpload==YES)
             {
                 
             }
             else
             {
                 [variousImageView setMyWebPhotoArray:aModel.album canEdit:NO];
             }
             if (!isMine) {
                 NSArray *array = aModel.album;
                 NSString *picUrl;
                 if (array.count>0)
                 {
                     YHBBuyDetailAlbum *picmodel = [array objectAtIndex:0];
                     picUrl = picmodel.thumb;
                 }
                 else
                 {
                     picUrl=nil;
                 }
                 [contactView setPhoneNumber:aModel.mobile storeName:aModel.truename itemId:itemId isVip:aModel.vip imgUrl:picUrl Title:myModel.title andType:@"buy" userid:myModel.userid smsText:myModel.smstpl];
             }
             [self dismissFlower];
             if (needUpload && uploadPhotoArray.count>0)
             {
                 [variousImageView setMyWebPhotoArray:uploadPhotoArray canEdit:NO];
                 uploadIndex = 0;
                 [SVProgressHUD showWithStatus:@"上传图片中" cover:YES offsetY:kMainScreenHeight/2.0];
                 [self uploadImage];
             }
         } andFailBlock:^(NSString *aStr) {
             [self dismissFlower];
//             [self.navigationController popViewControllerAnimated:YES];
             [SVProgressHUD showErrorWithStatus:aStr cover:YES offsetY:kMainScreenHeight/2.0];
         }];
//    }
}

- (void)uploadImage
{
    if (uploadIndex<uploadPhotoArray.count)
    {
        id obj = [uploadPhotoArray objectAtIndex:uploadIndex];
        if (![obj isKindOfClass:[UIImage class]])
        {
            uploadIndex++;
            if (uploadIndex == uploadPhotoArray.count)
            {
                [SVProgressHUD dismiss];
            }
            [self uploadImage];
        }
        else
        {
            [self upload];
        }
    }
}

- (void)upload
{
    NSString *uploadPhototUrl = nil;
    kYHBRequestUrl(@"upload.php", uploadPhototUrl);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[YHBUser sharedYHBUser].token,@"token",[NSString stringWithFormat:@"%d", uploadIndex],@"order",@"album",@"action",[NSString stringWithFormat:@"%d",itemId],@"itemid",[itemDict objectForKey:@"moduleid"],@"mid", nil];
    UIImage *uploadImage = (UIImage *)[uploadPhotoArray objectAtIndex:uploadIndex];
    [NetManager uploadImg:uploadImage parameters:dic uploadUrl:uploadPhototUrl uploadimgName:nil parameEncoding:AFJSONParameterEncoding progressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    } succ:^(NSDictionary *successDict) {
        MLOG(@"%@", successDict);
        NSString *result = [successDict objectForKey:@"result"];
        if ([result intValue] != 1)
        {
            MLOG(@"%@", [successDict objectForKey:@"error"]);
        }
        else
        {
            
        }
        uploadIndex++;
        if (uploadIndex<uploadPhotoArray.count)
        {
            [self upload];
        }
        else
        {
            [SVProgressHUD dismiss];
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
        MLOG(@"%@", [failDict objectForKey:@"error"]);
    }];
    
}

#pragma mark 分享
- (void)share
{
    MLOG(@"分享");
     [UMSocialWechatHandler setWXAppId:kShareWEIXINAPPID appSecret:kShareWEIXINAPPSECRET url:kWeChatOpenUrl];
    [UMSocialSnsService presentSnsIconSheetView:self appKey:kUMENG_APPKEY shareText:@"#【快布】#  全球首款专业装饰布在线交易平台上线啦！买布卖布，1键搞定！行业资讯，1手掌控！线上交易，方便快捷！猛戳了解：http://www.51kuaibu.com/app" shareImage:[UIImage imageNamed:@"ShareIcon"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,nil] delegate:nil];
}

#pragma mark 编辑
- (void)edit
{
    YHBPublishBuyViewController *vc = [[YHBPublishBuyViewController alloc] initWithModel:myModel];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark 举报
- (void)touchjubao
{
    JubaoViewController *vc = [[JubaoViewController alloc] initWithItemid:myModel.itemid isSupply:NO];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 浏览商城
- (void)pushPriceBtn
{
    PushPriceViewController *vc = [[PushPriceViewController alloc] initWithItemId:myModel.itemid];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)watchStoreBtn
{
    YHBMySupplyViewController *vc = [[YHBMySupplyViewController alloc] initWithUserid:(int)myModel.userid];
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)dismissSelf
{
    [self dismissFlower];
    if (isModal)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self dismissFlower];
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
