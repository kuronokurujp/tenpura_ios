//
//  UseSelectNetaScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "UseSelectNetaScene.h"

#import "./../../CCBReader/CCBReader.h"
#import	"./../../Data/DataNetaList.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataBaseText.h"
#import "./../../System/Sound/SoundManager.h"

#import "./../SettingScene.h"

@interface UseSelectNetaScene (PriveteMethod)

-(const UInt32)getNotUsenetaNum:(SInt32)in_idx;

@end

@implementation UseSelectNetaScene

static const char*	s_pNetaCellFileName	= "neta_cell.png";
static const SInt32	s_netaTableViewCellMax	= 6;

enum
{
	eTAG_USE_SELECT_TABLE_USE_ITEM_NUM_TEXT	= eSW_TABLE_TAG_CELL_MAX + 1,
	eTAG_USE_SELECT_TABLE_USE_ITEM_ICON_SPRITE,
};

/*
	@brief
*/
-(id)	init
{
	SW_INIT_DATA_ST	data	= { 0 };

	const SAVE_DATA_ST*	pData	= [[DataSaveGame shared] getData];
	data.viewMax	= pData->netaNum > s_netaTableViewCellMax ? pData->netaNum : s_netaTableViewCellMax;
	data.fontSize	= 30;

	strcpy(data.aCellFileName, s_pNetaCellFileName);

	CCSprite*	pTmpSp	= [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", data.aCellFileName]];
	data.cellSize	= [pTmpSp contentSize];
	data.viewPos	= ccp( 0, data.cellSize.height + 10.f );
	
	data.viewSize	= CGSizeMake(data.cellSize.width, SCREEN_SIZE_HEIGHT - data.viewPos.y );

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
	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getNetaOfIndex:idx];
	if( (pItem != nil) && (0 < NotUsenetaNum) )
	{
		[self actionCellTouch:cell];

		const NETA_DATA_ST*	pNetaData	= [[DataNetaList shared] getDataSearchId:pItem->no];
		[mp_settingItemBtn settingItem:eITEM_TYPE_NETA:pNetaData->textID:pNetaData->no];

		[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:2];
		
		[[SoundManager shared] playSe:@"btnClick"];
	}
}

/*
	@brief
*/
-(SWTableViewCell*)	table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	CCSprite *pCellSp = (CCSprite*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];
	CGSize	cellTexSize	= [pCellSp textureRect].size;

	DataBaseText*	pDataBaseText	= [DataBaseText shared];
	
	//	すでに使用設定中か
	const UInt32 NotUsenetaNum	= [self getNotUsenetaNum:idx];
	if( NotUsenetaNum <= 0 )
	{
		//	使用中はセルの色を変える
		[pCellSp setColor:ccGRAY];
	}
	else
	{
		[pCellSp setColor:ccWHITE];
	}

	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getNetaOfIndex:idx];
	if( pItem != nil )
	{
		const NETA_DATA_ST*	pNetaData	= [[DataNetaList shared] getDataSearchId:pItem->no];
		NSAssert(pNetaData, @"");
		//	所持数表示
		{
			NSString*	pUseNameStr	= [NSString stringWithUTF8String:[pDataBaseText getText:57]];
			NSString*	pNetaNumStr	= [NSString stringWithFormat:@"%@ %02ld", pUseNameStr, NotUsenetaNum];

			CCLabelTTF*	pNetaNumLabel	= (CCLabelTTF*)[pCellSp getChildByTag:eTAG_USE_SELECT_TABLE_USE_ITEM_NUM_TEXT];
			if( pNetaNumLabel == nil )
			{
				pNetaNumLabel	= [CCLabelTTF labelWithString:pNetaNumStr fontName:self.textFontName fontSize:self.data.fontSize];
				CGPoint	pos	= ccp( cellTexSize.width - 150.f, cellTexSize.height * 0.5f );
				[pNetaNumLabel setPosition:pos];
				CGPoint	anchorPoint	= pNetaNumLabel.anchorPoint;
				[pNetaNumLabel setAnchorPoint:ccp(0.f, anchorPoint.y)];

				[pCellSp addChild:pNetaNumLabel z:0 tag:eTAG_USE_SELECT_TABLE_USE_ITEM_NUM_TEXT];
			}

			if( pNetaNumLabel != nil )
			{
				[pNetaNumLabel setString:pNetaNumStr];
				[pNetaNumLabel setColor:ccc3(0, 0, 0)];
			}
		}

		//	アイテム名
		{
			CCLabelTTF*	pLabel	= (CCLabelTTF*)[pCellSp getChildByTag:eSW_TABLE_TAG_CELL_TEXT];
			NSString*	pStr	= [NSString stringWithUTF8String:[[DataBaseText shared] getText:pNetaData->textID]];
			[pLabel setString:pStr];

			CGPoint	anchorPos	= pLabel.anchorPoint;
			[pLabel setAnchorPoint:ccp(0,anchorPos.y)];
			[pLabel setPosition:ccp(129, cellTexSize.height * 0.5f)];
		}
		
		//	アイコン
		{
			CCSprite*	pItemIconSp	= (CCSprite*)[pCellSp getChildByTag:eTAG_USE_SELECT_TABLE_USE_ITEM_ICON_SPRITE];
			if( pItemIconSp == nil )
			{
				NSString*	pFileName	= [NSString stringWithFormat:@"cust_%s.png", pNetaData->fileName];
				pItemIconSp	= [CCSprite spriteWithFile:pFileName];
				
				[pItemIconSp setPosition:ccp(64, cellTexSize.height * 0.5f)];
				[pCellSp addChild:pItemIconSp z:0 tag:eTAG_USE_SELECT_TABLE_USE_ITEM_ICON_SPRITE];
			}
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
	
	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getNetaOfIndex:in_idx];
	if( pItem == nil )
	{
		return 0;
	}

	UInt32	useNum	= 0;
	const NETA_DATA_ST*	pNetaData	= [[DataNetaList shared] getDataSearchId:pItem->no];

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
	[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:2];
	
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
