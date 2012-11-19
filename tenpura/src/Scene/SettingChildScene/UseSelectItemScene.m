//
//  UseSelectItemScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "UseSelectItemScene.h"

#import "./../../CCBReader/CCBReader.h"
#import	"./../../Data/DataNetaList.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataBaseText.h"

#import "./../SettingScene.h"

@interface UseSelectItemScene (PriveteMethod)

-(BOOL)isUseItem:(SInt32)in_idx;

@end

@implementation UseSelectItemScene

static const char*	s_pNetaCellFileName	= "neta_cell.png";
static const SInt32	s_netaTableViewCellMax	= 6;

/*
	@brief
*/
-(id)	init
{
	SW_INIT_DATA_ST	data	= { 0 };

	const SAVE_DATA_ST*	pData	= [[DataSaveGame shared] getData];
	data.viewMax	= pData->itemNum > s_netaTableViewCellMax ? pData->itemNum : s_netaTableViewCellMax;
	data.fontSize	= 30;

	strcpy(data.aCellFileName, s_pNetaCellFileName);

	CCSprite*	pTmpSp	= [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", data.aCellFileName]];
	data.cellSize	= [pTmpSp contentSize];
	data.viewPos	= ccp( 0, data.cellSize.height + 10.f );
	
	CGSize	winSize	= [[CCDirector sharedDirector] winSize];
	data.viewSize	= CGSizeMake(winSize.width, winSize.height - data.viewPos.y );

	if( self = [super initWithData:&data] )
	{
		mp_settingItemBtn	= nil;
		mp_useItemNoList	= nil;
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	mp_settingItemBtn	= nil;
	mp_useItemNoList	= nil;

	[super dealloc];
}

/*
	@brief	初期化後に行う必須設定
	@note	更新前にしないとハングする。
*/
-(void)	setup:(SettingItemBtn*)in_pItemBtn:(CCArray*)in_pUseItemNoList
{
	NSAssert(in_pItemBtn, @"アイテム設定項目がnil");
	NSAssert(in_pUseItemNoList, @"設定中のアイテムリストがnil");

	mp_settingItemBtn	= in_pItemBtn;
	mp_useItemNoList	= in_pUseItemNoList;

	[self reloadUpdate];
}

//	デリゲート定義
/*
	@brief	テーブルがセルにタッチしたときに呼ばれる
*/
-(void)		table:(SWTableView*)table cellTouched:(SWTableViewCell *)cell
{
	[super table:table cellTouched:cell];
	
	UInt32	idx	= [cell objectID];
	if( [self isUseItem:idx] == NO )
	{
		[self actionCellTouch:cell];

		const SAVE_DATA_ST*	pData	= [[DataSaveGame shared] getData];
		const NETA_DATA_ST*	pNetaData	= [[DataNetaList shared] getDataSearchId:pData->aItems[idx]];
		[mp_settingItemBtn settingItem:pNetaData];

		[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:2];
	}
}

/*
	@brief
*/
-(SWTableViewCell*)	table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	CCSprite *pSprite = (CCSprite*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];
	
	//	すでに使用設定中か
	if( [self isUseItem:idx] )
	{
		if( pSprite != nil )
		{
			//	使用中はセルの色を変える
			[pSprite setColor:ccGRAY];
		}
	}

	NSString*	pStr	= @"";
	const SAVE_DATA_ST*	pData	= [[DataSaveGame shared] getData];
	if( pData->aItems[ idx ] != 0 )
	{
		const NETA_DATA_ST*	pNetaData	= [[DataNetaList shared] getDataSearchId:pData->aItems[idx]];
		pStr	= [NSString stringWithUTF8String:[[DataBaseText shared] getText:pNetaData->textID]];

		[pSprite setColor:ccWHITE];
	}

	CCLabelTTF*	pLabel	= (CCLabelTTF*)[pSprite getChildByTag:eSW_TABLE_TAG_CELL_TEXT];
	if( pLabel != nil )
	{
		[pLabel setString:pStr];
	}

	return pCell;
}

/*
	@brief
*/
-(BOOL)	isUseItem:(SInt32)in_idx
{
	if( mp_useItemNoList == nil )
	{
		return NO;
	}
	
	const SAVE_DATA_ST*	pData	= [[DataSaveGame shared] getData];
	if( pData->aItems[in_idx] == 0 )
	{
		return YES;
	}
	
	const NETA_DATA_ST*	pNetaData	= [[DataNetaList shared] getDataSearchId:pData->aItems[in_idx]];

	SettingItemBtn*	pItemBtn	= nil;
	CCARRAY_FOREACH(mp_useItemNoList, pItemBtn)
	{
		if( pItemBtn.itemNo == pNetaData->no )
		{
			//	使用中
			return YES;
		}
	}

	return NO;
}

/*
	@brief	前の戻る
*/
-(void)	pressSinagakiBtn
{
	[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:2];
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
