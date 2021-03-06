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
#import "./../../System/Common.h"

@implementation MissionScene

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
	}
	
	return self;
}

/*
	@brief
*/
-(void)	onEnterActive
{
	[super onEnterActive];

	SW_INIT_DATA_ST	data	= { 0 };
	DataMissionList*	pMissionInst	= [DataMissionList shared];
	NSAssert(pMissionInst, @"ミッションリストデータがない");

	data.viewMax	= pMissionInst.dataNum;

	strcpy(data.aCellFileName, "missionTableCell.ccbi");

	data.viewPos	= ccp( TABLE_POS_X, TABLE_POS_Y );
	data.viewSize	= CGSizeMake(TABLE_SIZE_WIDTH, TABLE_SIZE_HEIGHT );

	[self setup:&data];
	[self reloadUpdate];
    
    CGSize  size    = CGSizeMake(1.f, 1.f);
    [self setScaleX:converSizeVariableDevice(size).width];
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

	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	MissionTableCell*	pItemCell	= (MissionTableCell*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
	NSAssert(pItemCell, @"");

	//	ミッション名
	CCLabelBMFont*	pCellTextLabel	= pItemCell.pNameLabel;
	[pCellTextLabel setString:[pMissionInst getMissonName:idx]];

	BOOL	bSuccess	= [pMissionInst isSuccess:idx];
	//	ミッション達成のON/OFF
	if( pItemCell.pChkBoxOn != nil )
	{
		[pItemCell.pChkBoxOn setVisible:NO];
		if( bSuccess == YES )
		{
			[pItemCell.pChkBoxOn setVisible:YES];
		}
	}
	
	if( pItemCell.pChkBoxOff != nil )
	{
		[pItemCell.pChkBoxOff setVisible:NO];
	
		if( bSuccess == NO )
		{
			[pItemCell.pChkBoxOff setVisible:YES];
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
