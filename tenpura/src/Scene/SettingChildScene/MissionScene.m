//
//  MissionScene.m
//  tenpura
//
//  Created by y.uchida on 12/11/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "MissionScene.h"

#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataMissionList.h"
#import "./../../System/Sound/SoundManager.h"

@implementation MissionScene

static const char*	sp_MissionListCellSpriteName	= "neta_cell.png";
static NSString*	sp_MissionChkBoxOffSpriteName	= @"checkoff.png";
static NSString*	sp_MissionChkBoxOnSpriteName	= @"checkon.png";

enum
{
	eTAG_MISSION_TABLE_CHK_BOX_ON	= eSW_TABLE_TAG_CELL_MAX + 1,
	eTAG_MISSION_TABLE_CHK_BOX_OFF,
};

/*
	@brief
*/
-(id)	init
{
	SW_INIT_DATA_ST	data	= { 0 };
	DataMissionList*	pMissionInst	= [DataMissionList shared];
	NSAssert(pMissionInst, @"ミッションリストデータがない");

	data.viewMax	= pMissionInst.dataNum < 6 ? 6 : pMissionInst.dataNum;
	data.fontSize	= 24;

	strcpy(data.aCellFileName, sp_MissionListCellSpriteName);
	
	CCSprite*	pTmpSp	= [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", data.aCellFileName]];
	data.cellSize	= [pTmpSp contentSize];
	data.viewPos	= ccp( 0, data.cellSize.height + 10.f );
	
	CGSize	winSize	= [[CCDirector sharedDirector] winSize];
	data.viewSize	= CGSizeMake(winSize.width, winSize.height - data.viewPos.y );

	if( self = [super initWithData:&data] )
	{
	}
	
	return self;
}

/*
	@brief
*/
-(void)	pressBackBtn
{
	[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:2];
	
	[[SoundManager shared] play:eSOUND_CLICK04];
}

//	デリゲート定義
/*
	@brief	テーブルがセルにタッチしたときに呼ばれる
*/
-(void)table:(SWTableView*)table cellTouched:(SWTableViewCell *)cell
{
	[super table:table cellTouched:cell];
}

/*
	@brief
*/
-(SWTableViewCell*)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	
	DataMissionList*	pMissionInst	= [DataMissionList shared];
	NSAssert(pMissionInst, @"ミッションリストデータがない");

	CCNode*	pNode	= [pCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];
	if( pNode != nil )
	{
		//	ミッション名
		CCNode*	pNode02	= [pNode getChildByTag:eSW_TABLE_TAG_CELL_TEXT];
		if( ( pNode02 != nil ) && ( [pNode02 isKindOfClass:[CCLabelTTF class]] ) )
		{
			CCLabelTTF*	pCellTextLabel	= (CCLabelTTF*)pNode02;
			[pCellTextLabel setString:[pMissionInst getMissonName:idx]];
		}

		//	チェックボックス
		{
			CGSize	cellSize	= self.data.cellSize;
			CGPoint	pos	= ccp(20.f, cellSize.height * 0.5f);

			CCSprite*	pChkBoxOn	= (CCSprite*)[pNode getChildByTag:eTAG_MISSION_TABLE_CHK_BOX_ON];
			if( pChkBoxOn == nil )
			{
				pChkBoxOn	= [CCSprite spriteWithFile:sp_MissionChkBoxOnSpriteName];
				[pChkBoxOn setPosition:pos];
				[pCell addChild:pChkBoxOn];
			}
			[pChkBoxOn setVisible:NO];

			CCSprite*	pChkBoxOff	= (CCSprite*)[pCell getChildByTag:eTAG_MISSION_TABLE_CHK_BOX_OFF];
			if( pChkBoxOff == nil )
			{
				pChkBoxOff	= [CCSprite spriteWithFile:sp_MissionChkBoxOffSpriteName];
				[pChkBoxOff setPosition:pos];
				[pCell addChild:pChkBoxOff];
			}
			[pChkBoxOff setVisible:NO];

			if( [pMissionInst isSuccess:idx] == YES )
			{
				[pChkBoxOn setVisible:YES];
			}
			else
			{
				[pChkBoxOff setVisible:YES];
			}
		}
	}
		
	return pCell;
}

/*
	@brief	変移演出終了
*/
-(void)	onEnterTransitionDidFinish
{
	//	バナー表示通知
	{
		NSString*	pBannerShowName	= [NSString stringWithUTF8String:gp_bannerShowObserverName];
		NSNotification *n = [NSNotification notificationWithName:pBannerShowName object:nil];
		NSAssert(n, @"");
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}

	[super onEnterTransitionDidFinish];
}

/*
	@brief	シーン終了(変移開始)
*/
-(void)	onExitTransitionDidStart
{
	//	バナー非表示通知
	{
		NSString*	pBannerHideName	= [NSString stringWithUTF8String:gp_bannerHideObserverName];
		NSNotification *n = [NSNotification notificationWithName:pBannerHideName object:nil];
		NSAssert(n, @"");
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}

	[super onExitTransitionDidStart];
}

@end
