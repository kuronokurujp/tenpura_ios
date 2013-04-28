//
//  UseSelectItemScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "UseSelectItemScene.h"

#import "./../../CCBReader/CCBReader.h"
#import "./../../TableCells/SampleCell.h"
#import "./../../TableCells/UseSelectItemTableCell.h"
#import	"./../../Data/DataItemList.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataBaseText.h"
#import "./../../System/Sound/SoundManager.h"

#import "./../SettingScene.h"

@interface UseSelectItemScene (PriveteMethod)

-(const UInt32)getNotUsenetaNum:(SInt32)in_idx;

@end

@implementation UseSelectItemScene

static const SInt32	s_netaTableViewCellMax	= 6;

/*
	@brief
*/
-(id)	init
{
	SW_INIT_DATA_ST	data	= { 0 };

	const SAVE_DATA_ST*	pData	= [[DataSaveGame shared] getData];
	data.viewMax	= pData->itemNum > s_netaTableViewCellMax ? pData->itemNum : s_netaTableViewCellMax;

	strcpy(data.aCellFileName, "useSelectItemTableCell.ccbi");

	data.viewPos	= ccp( TABLE_POS_X, TABLE_POS_Y );
	data.viewSize	= CGSizeMake(TABLE_SIZE_WIDTH, TABLE_SIZE_HEIGHT );

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
-(void)	setup:(SettingItemBtn*)in_pItemBtn :(CCArray*)in_pUseItemNoList
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
	const UInt32 NotUsenetaNum	= [self getNotUsenetaNum:idx];
	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getItemOfIndex:idx];
	if( (pItem != nil) && (0 < NotUsenetaNum) )
	{
		[self actionCellTouch:cell];

		const ITEM_DATA_ST*	pItemData	= [[DataItemList shared] getDataSearchId:pItem->no];
		[mp_settingItemBtn settingItem:eITEM_TYPE_OPTION:pItemData->textID:pItemData->no];

		[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:g_sceneChangeTime];
		
		[[SoundManager shared] playSe:@"btnClick"];
	}
}

/*
	@brief
*/
-(SWTableViewCell*)	table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	UseSelectItemTableCell*	pItemCell	= (UseSelectItemTableCell*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
	NSAssert(pItemCell, @"");

	//	すでに使用設定中か
	const UInt32 NotUsenetaNum	= [self getNotUsenetaNum:idx];
	if( NotUsenetaNum <= 0 )
	{
		//	使用中はセルの色を変える
		[pItemCell setColor:ccGRAY];
	}
	else
	{
		[pItemCell setColor:ccWHITE];
	}

	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getItemOfIndex:idx];
	if( pItem != nil )
	{
		const ITEM_DATA_ST*	pItemData	= [[DataItemList shared] getDataSearchId:pItem->no];
		NSAssert(pItemData, @"");

		//	アイテム名
		{
			CCLabelTTF*	pLabel	= pItemCell.pNameLabel;
			NSString*	pStr	= [NSString stringWithUTF8String:[[DataBaseText shared] getText:pItemData->textID]];
			[pLabel setString:pStr];
		}
		
		//	効果内容
		{
			NSString*	pStr	= [NSString stringWithUTF8String:[[DataBaseText shared] getText:pItemData->contentTextID]];

			CCLabelTTF*	pLabel	= pItemCell.pDataLabel;
			[pLabel setString:pStr];
		}
	}

	return pCell;
}

/*
	@brief
*/
-(const UInt32)	getNotUsenetaNum:(SInt32)in_idx
{
	if( mp_useItemNoList == nil )
	{
		return NO;
	}
	
	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getItemOfIndex:in_idx];
	if( pItem == nil )
	{
		return 0;
	}

	UInt32	useNum	= 0;
	const ITEM_DATA_ST*	pItemData	= [[DataItemList shared] getDataSearchId:pItem->no];

	SettingItemBtn*	pItemBtn	= nil;
	CCARRAY_FOREACH(mp_useItemNoList, pItemBtn)
	{
		if( pItemBtn.type != eITEM_TYPE_OPTION )
		{
			continue;
		}

		if( pItemBtn.itemNo == pItemData->no )
		{
			//	使用中
			++useNum;
		}
	}
	
	//	現在選択中のボタンで設定されている物と同じなら設定個数を一つ外す
	if( mp_settingItemBtn.itemNo == pItem->no )
	{
		--useNum;
	}

	return	(pItem->num - useNum);
}

/*
	@brief	前の戻る
*/
-(void)	pressSinagakiBtn
{
	[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:g_sceneChangeTime];
	
	[[SoundManager shared] playSe:@"pressBtnClick"];
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
	
	[mp_settingItemBtn setVisible:YES];

	[super onExitTransitionDidStart];
}

@end
