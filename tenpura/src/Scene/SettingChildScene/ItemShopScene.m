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

enum
{
	eTAG_ITEM_SHOP_TABLE_NOT_BUY_CELL	= eSW_TABLE_TAG_CELL_MAX + 1,
};

static const char*	s_pNotBuyCellFileName	= "not_buy_cell.png";

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

	SWTableViewCell*	pCell	= [table dequeueCell];
	if( pCell == nil )
	{
		pCell	= [[[SampleCell alloc] init] autorelease];
	}
	
	CCNode*	pNode	= [pCell getChildByTag:10];
	ItemShopTableCell*	pItemCell	= nil;
	if( pNode == nil )
	{
		CCNode*	pCellScene	= [CCBReader nodeGraphFromFile:@"itemShopTableCell.ccbi"];
		NSAssert([pCellScene isKindOfClass:[ItemShopTableCell class]], @"");
		
		[pCell addChild:pCellScene z:1 tag:10];
				
		pItemCell	= (ItemShopTableCell*)pCellScene;
		[pItemCell setAnchorPoint:ccp(0, 0)];
		[pItemCell setPosition:ccp(0, 0)];
	}
	else
	{
		pItemCell	= (ItemShopTableCell*)pNode;
	}
	
	//	購入できない場合の対応
	{
		CCSprite*	pNotBuyCellSprite	= nil;
		CCNode*	pChildNode	= [pItemCell getChildByTag:eTAG_ITEM_SHOP_TABLE_NOT_BUY_CELL];
		if( ( pChildNode != nil ) && [pChildNode isKindOfClass:[CCSprite class]] )
		{
			pNotBuyCellSprite	= (CCSprite*)pChildNode;
		}
		else
		{
			pNotBuyCellSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", s_pNotBuyCellFileName]];
			[pItemCell addChild:pNotBuyCellSprite z:0 tag:eTAG_ITEM_SHOP_TABLE_NOT_BUY_CELL];
		}

		[pNotBuyCellSprite setPosition:ccp(0, 0)];
		[pNotBuyCellSprite setAnchorPoint:ccp(0, 0)];
		[pNotBuyCellSprite setColor:ccc3(255,255,255)];
		[pNotBuyCellSprite setVisible:NO];

		[pItemCell setColor:ccWHITE];
		if( [self isBuy:idx] == false )
		{
			//	購入できない
			[pItemCell setColor:ccGRAY];
			if( [[DataSaveGame shared] getItem:pData->no] == FALSE )
			{
		//		[pNotBuyCellSprite setVisible:YES];
			}
		}		
	}

	//	アイテム名表示
	{
		NSString*	pItemName	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:pData->textID]];
		[pItemCell.pNameLabel setString:pItemName];
	}
	
	//	効果内容表示
	{
		[pItemCell.pDataLabel setString:[DataBaseText getString:pData->contentTextID]];
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
