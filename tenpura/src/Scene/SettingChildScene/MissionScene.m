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
#import "./../../System/GameCenter/GameKitHelper.h"

@implementation MissionScene

static const char*	sp_MissionListCellSpriteName	= "neta_cell.png";

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
		CCSprite*	pCellSp	= (CCSprite*)pNode;
		//	ミッション名
		CCNode*	pNode02	= [pNode getChildByTag:eSW_TABLE_TAG_CELL_TEXT];
		if( ( pNode02 != nil ) && ( [pNode02 isKindOfClass:[CCLabelTTF class]] ) )
		{
			CCLabelTTF*	pCellTextLabel	= (CCLabelTTF*)pNode02;
			[pCellTextLabel setString:[pMissionInst getMissonName:idx]];
		}
		
		//	達成しているミッションがあるかチェック
		[pCellSp setColor:ccWHITE];
		if( [pMissionInst isSuccess:idx] == YES )
		{
			//	使用中はセルの色を変える
			[pCellSp setColor:ccGRAY];
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
