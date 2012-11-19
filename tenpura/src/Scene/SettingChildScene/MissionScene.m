//
//  MissionScene.m
//  tenpura
//
//  Created by y.uchida on 12/11/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "MissionScene.h"

#import "./../../Data/DataGlobal.h"
#import "./../../System/GameCenter/GameKitHelper.h"

@implementation MissionScene

static const char*	sp_MissionListCellSpriteName	= "neta_cell.png";

/*
	@brief
*/
-(id)	init
{
	SW_INIT_DATA_ST	data	= { 0 };

	NSMutableDictionary*	pAchievementDescriptions	= [GameKitHelper shared].achievementDescriptions;
	if( pAchievementDescriptions != nil )
	{
		NSArray*	pAchievments	= [[GameKitHelper shared].achievementDescriptions allValues];
		data.viewMax	= [pAchievments count] < 6 ? 6 : [pAchievments count];
	}
	else
	{
		data.viewMax	= 6;
	}

	data.fontSize	= 32;

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

/*
	@brief
*/
-(void)	pressGameCenterBtn
{
	CCLOG(@"GameCenter");
	[[GameKitHelper shared] showGameCenter];
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
	
	NSMutableDictionary*	pAchievementDescriptions	= [GameKitHelper shared].achievementDescriptions;
	if( pAchievementDescriptions != nil )
	{
		NSArray*	pAchievments	= [pAchievementDescriptions allValues];
		if( idx < [pAchievments count] )
		{
			GKAchievementDescription* pAchievement	= (GKAchievementDescription*)[pAchievments objectAtIndex:idx];
			CCNode*	pNode	= [pCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];
			if( pNode != nil )
			{
				CCNode*	pNode02	= [pNode getChildByTag:eSW_TABLE_TAG_CELL_TEXT];
				if( ( pNode02 != nil ) && ( [pNode02 isKindOfClass:[CCLabelTTF class]] ) )
				{
					CCLabelTTF*	pCellTextLabel	= (CCLabelTTF*)pNode02;
					[pCellTextLabel setString:pAchievement.title];
				}
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
