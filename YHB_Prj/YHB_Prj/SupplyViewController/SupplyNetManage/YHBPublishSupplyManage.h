//
//  YHBPublishSupplyManage.h
//  YHB_Prj
//
//  Created by Johnny's on 15/1/4.
//  Copyright (c) 2015年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHBPublishSupplyManage : NSObject

- (void)publishSupplyWithItemid:(int)aItemId title:(NSString *)aTitle price:(NSString *)aPrice catid:(NSString *)aCatId typeid:(NSString *)aTypeid today:(NSString *)aToday content:(NSString *)aContent truename:(NSString *)aName mobile:(NSString *)aMobile andSuccBlock:(void(^)(int aItemId))aSuccBlock failBlock:(void(^)(void))aFailBlock;
@end