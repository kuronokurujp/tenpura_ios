//
//  ItemShopScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ItemShopScene.h"
#import "./../../TableCells/SampleCell.h"
#import	"./../../TableCells/ItemShopTableCell.h"
#import "./../../CCBReader/CCBReader.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataItemList.h"
#import "./../../Data/DataBaseText.h"

@implementation ItemShopScene

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super initWithCellDataFileName:@"itemShopTableCell.ccbi"] )
	{
	}

	return self;
}

/*
	@brief
*/
-(SWTableViewCell*)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	const ITEM_DATA_ST*	pData	= [[DataItemList shared] getData:idx];
	NSAssert(pData, @"アイテムデータがない");

	DataBaseText*	pDataBaseTextShared	= [DataBaseText shared];

	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	ItemShopTableCell*	pItemCell	= (ItemShopTableCell*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
	NSAssert(pItemCell, @"");

	//	購入できない場合の対応
	{
		[pItemCell setColor:ccWHITE];
		if( [self isBuy:idx] == false )
		{
			//	購入できない
			[pItemCell setColor:ccGRAY];
		}		
	}

	//	アイテム名表示
	{
		NSString*	pItemName	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:pData->textID]];
		[pItemCell.pNameLabel setString:pItemName];
	}
	
	//	効果内容表示
	{
		NSString*	pFormat	= [DataBaseText getString:pData->contentTextID];
		[pItemCell.pDataLabel setString:[NSString stringWithFormat:pFormat, pData->value]];
	}
	
	//	購入金額表示
	{
		NSString*	pTitleName		= [NSString stringWithUTF8String:[pDataBaseTextShared getText:58]];
		NSString*	pStr	= [NSString stringWithFormat:@"%@:%ld", pTitleName, pData->sellMoney];
		[pItemCell.pMoneyLabel setString:pStr];
	}

	return pCell;
}

/*
	@brief	セル最大数
*/
-(SInt32)	getCellMax
{
	DataItemList*	pData	= [DataItemList shared];
	return pData.dataNum;
}

/*
	@brief	購入金額
*/
-(SInt32)	getSellMoney:(SInt32)in_idx
{
	const ITEM_DATA_ST*	pData	= [[DataItemList shared] getData:in_idx];
	if( pData != nil )
	{
		return	pData->sellMoney;
	}

	return 0;
}

/*
	@brief	購入チェック
*/
-(BOOL)	buy:(SInt32)in_idx
{
	DataSaveGame*	pDataSaveGameInst	= [DataSaveGame shared];
	
	const ITEM_DATA_ST*	pData	= [[DataItemList shared] getData:in_idx];

	return [pDataSaveGameInst addItem:pData->no];
}

/*
	@brief	購入チェック
*/
-(BOOL)	isBuy:(SInt32)in_idx
{
	SInt32	sellMoney	= [self getSellMoney:in_idx];
	UInt32	nowMoney	= [[DataSaveGame shared] getData]->money;
	
	const ITEM_DATA_ST*	pData	= [[DataItemList shared] getData:in_idx];
	const SAVE_DATA_ITEM_ST*	pItemData	= [[DataSaveGame shared] getItem:pData->no];
	if( ( pItemData == NULL ) || ( pItemData->num < 1 ) )
	{
		return ( sellMoney <= nowMoney );
	}

	return false;
}

@end
