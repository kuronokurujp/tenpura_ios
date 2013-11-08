//
//  BaseMenuScene.m
//  tenpura
//
//  Created by y.uchida on 12/12/13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseMenuScene.h"
#import "./../Data/DataSaveGame.h"
#import "./../System/Anim/Action/AnimActionNumCounterLabelTTF.h"
#import "./../System/Sound/SoundManager.h"
#import "./../System/Common.h"
#import "./../CCBReader/CCBReader.h"

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
	DataSaveGame*	pDataSaveGame	= [DataSaveGame shared];
	NSAssert(pDataSaveGame, @"セーブデータがない");
	const SAVE_DATA_ST*	pSaveData	= [pDataSaveGame getData];
	NSAssert(pSaveData, @"セーブデータの中身がない");

	//	金額反映
	[mp_nowMoneyText setNum:pSaveData->money];

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
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[AnimActionNumCounterLabelBMT class]] )
		{
			AnimActionNumCounterLabelBMT*	pLabel	= (AnimActionNumCounterLabelBMT*)pNode;
			if( [pLabel.string isEqualToString:@"moneyNum"] )
			{
				mp_nowMoneyText	= pLabel;
				[mp_nowMoneyText setStringFormat:@"%06ld"];
				[mp_nowMoneyText setNum:pSaveData->money];
			}
			else if( [pLabel.string isEqualToString:@"scoreNum"] )
			{
				mp_nowHiScoreText	= pLabel;
				[mp_nowHiScoreText setStringFormat:@"%06ld"];
				[mp_nowHiScoreText setNum:pSaveData->score];
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
	if([ mp_nowMoneyText getCountNum] != pSaveData->money )
	{
		[mp_nowMoneyText setCountNum:pSaveData->money];
	}
}

/*
	@brief	ヘルプ画面へ遷移
*/
-(void)	onBtnHelpScene
{
	CCScene*	helpScene	= [CCBReader sceneWithNodeGraphFromFile:@"help.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:helpScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] pushScene:pTransFade];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

@end
