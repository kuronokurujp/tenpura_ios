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
#import "./../../CCBReader/CCBReader.h"
#import "./../../TableCells/SampleCell.h"
#import "./../../TableCells/MissionTableCell.h"
#import "./../../System/Sound/SoundManager.h"

@implementation MissionScene

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

	CCNode*	pCellScene	= [CCBReader nodeGraphFromFile:@"missionTableCell.ccbi"];
	NSAssert([pCellScene isKindOfClass:[CCSprite class]], @"");

	CCSprite*	pTmpSp	= (CCSprite*)pCellScene;
	data.cellSize	= [pTmpSp contentSize];
	data.viewPos	= ccp( TABLE_POS_X, TABLE_POS_Y );
	
	data.viewSize	= CGSizeMake(TABLE_SIZE_WIDTH, TABLE_SIZE_HEIGHT );

	if( self = [super initWithData:&data] )
	{
		[self reloadUpdate];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	pressBackBtn
{
	[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:g_sceneChangeTime];
	
	[[SoundManager shared] playSe:@"pressBtnClick"];
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
	DataMissionList*	pMissionInst	= [DataMissionList shared];
	NSAssert(pMissionInst, @"ミッションリストデータがない");

	SWTableViewCell*	pCell	= [table dequeueCell];
	if( pCell == nil )
	{
		pCell	= [[[SampleCell alloc] init] autorelease];
	}
	
	CCNode*	pNode	= [pCell getChildByTag:10];
	MissionTableCell*	pItemCell	= nil;
	if( pNode == nil )
	{
		CCNode*	pCellScene	= [CCBReader nodeGraphFromFile:@"missionTableCell.ccbi"];
		NSAssert([pCellScene isKindOfClass:[MissionTableCell class]], @"");
		
		[pCell addChild:pCellScene z:1 tag:10];
				
		pItemCell	= (MissionTableCell*)pCellScene;
		[pItemCell setAnchorPoint:ccp(0, 0)];
		[pItemCell setPosition:ccp(0, 0)];
	}
	else
	{
		pItemCell	= (MissionTableCell*)pNode;
	}

	//	ミッション名
	CCLabelTTF*	pCellTextLabel	= pItemCell.pNameLabel;
	[pCellTextLabel setString:[pMissionInst getMissonName:idx]];

	//	ミッション達成のON/OFF
	[pItemCell.pChkBoxOn setVisible:NO];
	[pItemCell.pChkBoxOn setVisible:NO];
	
	if( [pMissionInst isSuccess:idx] == YES )
	{
		[pItemCell.pChkBoxOn setVisible:YES];
	}
	else
	{
		[pItemCell.pChkBoxOn setVisible:YES];
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
