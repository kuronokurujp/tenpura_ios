//
//  ItemShopScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ItemShopScene.h"
#import "./../../TableCells/SampleCell.h"
#import "./../../CCBReader/CCBReader.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataItemList.h"
#import "./../../Data/DataBaseText.h"

@implementation ItemShopScene

enum
{
	eTAG_ITEM_SHOP_TABLE_NOT_BUY_CELL	= eSW_TABLE_TAG_CELL_MAX + 1,
	eTAG_ITEM_SHOP_TABLE_MONEY_TEXT,
	eTAG_ITEM_SHOP_TABLE_CONTENT_TEXT
};

static const char*	s_pNotBuyCellFileName	= "not_buy_cell.png";

/*
	@brief	初期化
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
-(SWTableViewCell*)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	const ITEM_DATA_ST*	pData	= [[DataItemList shared] getData:idx];
	NSAssert(pData, @"アイテムデータがない");

	DataBaseText*	pDataBaseTextShared	= [DataBaseText shared];

	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];	
	CCSprite*	pCellSprite	= (CCSprite*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];
	NSAssert(pCellSprite, @"");

	//	購入できない場合の対応
	{
		CCSprite*	pNotBuyCellSprite	= nil;
		CCNode*	pChildNode	= [pCellSprite getChildByTag:eTAG_ITEM_SHOP_TABLE_NOT_BUY_CELL];
		if( ( pChildNode != nil ) && [pChildNode isKindOfClass:[CCSprite class]] )
		{
			pNotBuyCellSprite	= (CCSprite*)pChildNode;
		}
		else
		{
			pNotBuyCellSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", s_pNotBuyCellFileName]];
			[pCellSprite addChild:pNotBuyCellSprite z:0 tag:eTAG_ITEM_SHOP_TABLE_NOT_BUY_CELL];
		}

		[pNotBuyCellSprite setPosition:ccp(0, 0)];
		[pNotBuyCellSprite setAnchorPoint:ccp(0, 0)];
		[pNotBuyCellSprite setColor:ccc3(255,255,255)];
		[pNotBuyCellSprite setVisible:NO];

		[pCellSprite setColor:ccWHITE];
		if( [self isBuy:idx] == false )
		{
			//	購入できない
			[pCellSprite setColor:ccGRAY];
			if( [[DataSaveGame shared] getItem:pData->no] == FALSE )
			{
				[pNotBuyCellSprite setVisible:YES];
			}
		}		
	}

	//	アイテム名表示
	{
		CCLabelTTF*	pLabel	= (CCLabelTTF*)[pCellSprite getChildByTag:eSW_TABLE_TAG_CELL_TEXT];
		if( pLabel != nil )
		{
			NSString*	pItemName	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:pData->textID]];
			[pLabel setAnchorPoint:ccp(0, 0)];
			[pLabel setPosition:ccp(10.f, 50.f)];
			[pLabel setString:pItemName];
		}
	}
	
	//	効果内容表示
	{
		CCLabelTTF*	pLabel	= (CCLabelTTF*)[pCellSprite getChildByTag:	eTAG_ITEM_SHOP_TABLE_CONTENT_TEXT];
		if( pLabel == nil )
		{
			pLabel	= [CCLabelTTF labelWithString:@"" fontName:self.textFontName fontSize:16];
			[pLabel setAnchorPoint:ccp(0, 0)];
			[pLabel setPosition:ccp(10.f, 10.f)];
			[pLabel setColor:ccBLACK];

			[pCellSprite addChild:pLabel z:0 tag:eTAG_ITEM_SHOP_TABLE_CONTENT_TEXT];
		}

		if( pLabel != nil )
		{
			[pLabel setString:[DataBaseText getString:pData->contentTextID]];
		}
	}
	
	//	購入金額表示
	{
		CCLabelTTF*	pLabel	= (CCLabelTTF*)[pCellSprite getChildByTag:eTAG_ITEM_SHOP_TABLE_MONEY_TEXT];
		if( pLabel == nil )
		{
			pLabel	= [CCLabelTTF labelWithString:@"" fontName:self.textFontName fontSize:24];
			[pLabel setAnchorPoint:ccp(0, 0)];
			[pLabel setPosition:ccp(240.f, 50.f)];
			[pLabel setColor:ccBLACK];

			[pCellSprite addChild:pLabel z:0 tag:eTAG_ITEM_SHOP_TABLE_MONEY_TEXT];
		}

		if( pLabel != nil )
		{
			NSString*	pTitleName		= [NSString stringWithUTF8String:[pDataBaseTextShared getText:58]];
			NSString*	pStr	= [NSString stringWithFormat:@"%@:%ld", pTitleName, pData->sellMoney];
			[pLabel setString:pStr];
		}
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
