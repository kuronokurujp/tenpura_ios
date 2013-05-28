//
//  UseSelectNetaScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "UseSelectNetaScene.h"

#import "./../../CCBReader/CCBReader.h"
#import	"./../../TableCells/SampleCell.h"
#import	"./../../TableCells/SiireTableCell.h"
#import "./../../Data/DataNetaPackList.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataBaseText.h"
#import "./../../System/Sound/SoundManager.h"

#import "./../SettingScene.h"

@interface UseSelectNetaScene (PriveteMethod)

-(const UInt32)getNotUsenetaNum:(SInt32)in_idx;

@end

@implementation UseSelectNetaScene

static const SInt32	s_netaTableViewCellMax	= 6;

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
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
	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getNetaPackOfIndex:idx];
	if( (pItem != nil) && (0 < NotUsenetaNum) )
	{
		[self actionCellTouch:cell];

		const NETA_PACK_DATA_ST*	pNetaPackData	= [[DataNetaPackList shared] getDataSearchId:pItem->no];
		[mp_settingItemBtn settingItem:eITEM_TYPE_NETA:pNetaPackData->textID:pNetaPackData->no];

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
	SiireTableCell*	pItemCell	= (SiireTableCell*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
	NSAssert(pItemCell, @"");
	
	[pItemCell setColor:ccGRAY];

	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getNetaPackOfIndex:idx];
	if( pItem == nil )
	{
		return pCell;
	}

	const NETA_PACK_DATA_ST*	pData	= [[DataNetaPackList shared] getDataSearchId:pItem->no];
	if( pData == NULL )
	{
		return pCell;
	}
	
	DataBaseText*	pDataBaseTextShared	= [DataBaseText shared];
	
	//	すでに使用設定中か
	const UInt32 NotUsenetaNum	= [self getNotUsenetaNum:idx];
	if( 0 < NotUsenetaNum )
	{
		[pItemCell setColor:ccWHITE];
	}

	//	天ぷらアイコン/ネタ名表示
	{
		int	num	= sizeof(pData->aNetaId) / sizeof(pData->aNetaId[0]);
		for( int i = 0; i < num; ++i )
		{
			const	NETA_DATA_ST*	pNetaData	= [[DataNetaList shared] getDataSearchId:pData->aNetaId[i]];
			TenpuraIcon*	pIcon	= [pItemCell getNetaIconObj:i];
			CCLabelBMFont*		pName	= [pItemCell getNetaNameLabel:i];
			
			[pName setString:@""];
			if( pNetaData != nil )
			{
				[pName setString:[DataBaseText getString:pNetaData->textID]];
				[pIcon setup:pNetaData];
				
				[pName setVisible:YES];
				[pIcon setVisible:YES];
			}
			else
			{
				[pIcon setVisible:NO];
				[pName setVisible:NO];
			}
		}
		
		//	アイテム名表示
		{
			NSString*	pTenpuraName	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:pData->textID]];
			[pItemCell.pNameLabel setString:pTenpuraName];
		}
	
		//	購入金額表示
		{
			NSString*	pTitleName		= [NSString stringWithUTF8String:[pDataBaseTextShared getText:58]];
			NSString*	pStr	= [NSString stringWithFormat:@"%@:%ld", pTitleName, pData->money];
			[pItemCell.pMoneyLabel setString:pStr];
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
	
	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getNetaPackOfIndex:in_idx];
	if( pItem == nil )
	{
		return 0;
	}

	UInt32	useNum	= 0;
	const NETA_PACK_DATA_ST*	pNetaData	= [[DataNetaPackList shared] getDataSearchId:pItem->no];

	SettingItemBtn*	pItemBtn	= nil;
	CCARRAY_FOREACH(mp_useItemNoList, pItemBtn)
	{
		if( pItemBtn.type != eITEM_TYPE_NETA )
		{
			continue;
		}

		if( pItemBtn.itemNo == pNetaData->no )
		{
			//	使用中
			++useNum;
		}
	}
	
	//	現在選択中のボタンで設定されている天ぷらと同じ天ぷらなら設定個数を一つ外す
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
	@brief
*/
-(void)	onEnterActive
{
	[super onEnterActive];
	
	SW_INIT_DATA_ST	data	= { 0 };

	const SAVE_DATA_ST*	pData	= [[DataSaveGame shared] getData];
	data.viewMax	= pData->netaNum > s_netaTableViewCellMax ? pData->netaNum : s_netaTableViewCellMax;

	strcpy(data.aCellFileName, "siireTableCell.ccbi");
	
	data.viewPos	= ccp( TABLE_POS_X, TABLE_POS_Y );
	data.viewSize	= CGSizeMake(TABLE_SIZE_WIDTH, TABLE_SIZE_HEIGHT );

	[self setup:&data];
	[self reloadUpdate];
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
