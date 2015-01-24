//
//  YHBAddressManager.h
//  YHB_Prj
//
//  Created by yato_kami on 15/1/21.
//  Copyright (c) 2015年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YHBAddressModel;
@interface YHBAddressManager : NSObject
//获取默认地址
- (void)getDefaultAddressWithToken:(NSString *)token WithSuccess:(void(^)(YHBAddressModel *model))sBlock failure:(void(^)())fBlock;
//获取地址列表
- (void)getAddresslistWithToken:(NSString *)token WithSuccess:(void(^)(NSMutableArray *modelList))sBlock failure:(void(^)())fBlock;
//新增/编辑地址
- (void)addOrEditAddressWithAddModel:(YHBAddressModel *)model Token:(NSString *)token isNew:(BOOL)isNew WithSuccess:(void(^)())sBlock failure:(void(^)())fBlock;

//获取城市地区列表
- (void)getAreaListWithSuccess:(void(^)(NSMutableArray *areaArray))sBlock failure:(void(^)())fBlock;

//删除常用地址 delAddress.php
- (void)deleteAddressWithToken:(NSString *)token AndItemID:(int)itemid WithSuccess:(void(^)())sBlock failure:(void(^)())fBlock;

@end
