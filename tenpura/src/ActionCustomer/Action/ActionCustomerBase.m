//
//  ActionCustomerBase.m
//  tenpura
//
//  Created by y.uchida on 12/12/01.
//
//

#import "ActionCustomerBase.h"

@implementation ActionCustomerBase

/*
	@brief	初期化
*/
-(void)	initialize:(Customer*)in_pOnwer
{
	NSAssert(in_pOnwer, @"オーナーが設定されていない");
	mp_onwer	= in_pOnwer;
	[self scheduleUpdate];
}

/*
	@brief	終了処理
*/
-(void)	finalize
{
	mp_onwer	= nil;
	[self unscheduleUpdate];
}

/*
	@brief	更新
*/
-(void)	update:(ccTime)dat;
{
}

@end
