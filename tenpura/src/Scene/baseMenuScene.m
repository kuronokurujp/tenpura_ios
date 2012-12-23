//
//  BaseMenuScene.m
//  tenpura
//
//  Created by y.uchida on 12/12/13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseMenuScene.h"
#import "./../Data/DataSaveGame.h"

@implementation BaseMenuScene

/*
	@brief
*/
-(id)init
{
	if( self = [super init] )
	{
		mp_nowHiScoreText	= nil;
		mp_nowMoneyText		= nil;
		
		[self scheduleUpdate];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	onEnter
{
	[self update:0];

	[super onEnter];
}

/*
	@brief
*/
-(void)	didLoadFromCCB
{
	DataSaveGame*	pDataSaveGame	= [DataSaveGame shared];
	const SAVE_DATA_ST*	pSaveData	= [pDataSaveGame getData];

	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[CCLabelTTF class]] )
		{
			CCLabelTTF*	pLabel	= (CCLabelTTF*)pNode;
			if( [pLabel.string isEqualToString:@"moneyNum"] )
			{
				mp_nowMoneyText	= pLabel;
				[mp_nowMoneyText setString:[NSString stringWithFormat:@"%06ld", pSaveData->money]];
			}
			else if( [pLabel.string isEqualToString:@"scoreNum"] )
			{
				mp_nowHiScoreText	= pLabel;
				[mp_nowHiScoreText setString:[NSString stringWithFormat:@"%06lld", pSaveData->score]];
			}
		}
	}
}

/*
	@brief	更新
*/
-(void)	update:(ccTime)del
{
	DataSaveGame*	pDataSaveGame	= [DataSaveGame shared];
	NSAssert(pDataSaveGame, @"セーブデータがない");
	const SAVE_DATA_ST*	pSaveData	= [pDataSaveGame getData];
	NSAssert(pSaveData, @"セーブデータの中身がない");

	//	金額反映
	[mp_nowMoneyText setString:[NSString stringWithFormat:@"%06ld", pSaveData->money]];
}

@end
