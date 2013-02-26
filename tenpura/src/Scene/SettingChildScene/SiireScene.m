//
//  SiireScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SiireScene.h"
#import "./../../TableCells/SampleCell.h"
#import "./../../TableCells/SiireTableCell.h"
#import "./../../CCBReader/CCBReader.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataNetaList.h"
#import "./../../Data/DataBaseText.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Object/TenpuraIcon.h"
#import "./../../System/Sound/SoundManager.h"

#import "AppDelegate.h"

@interface SiireScene (PrivateMethod)

-(void)setMoneyString:(UInt32)in_num;

@end

@implementation SiireScene

enum
{
	eTAG_SHOP_TABLE_NOT_BUY_CELL	= eSW_TABLE_TAG_CELL_MAX + 1,
};

static const char*	s_pNotBuyCellFileName	= "not_buy_cell.png";
static const SInt32	s_sireTableViewCellMax	= 6;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super initWithCellDataFileName:@"siireTableCell.ccbi"] )
	{
	}

	return self;
}

/*
	@breif
*/
-(void)dealloc
{
	[super dealloc];
}

//	デリゲート定義
/*
	@brief
*/
-(SWTableViewCell*)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	const NETA_DATA_ST*	pData	= [[DataNetaList shared] getData:idx];
	NSAssert(pData, @"ネタデータがない");

	DataBaseText*	pDataBaseTextShared	= [DataBaseText shared];

	SWTableViewCell*	pCell	= [table dequeueCell];
	if( pCell == nil )
	{
		pCell	= [[[SampleCell alloc] init] autorelease];
	}
	
	CCNode*	pNode	= [pCell getChildByTag:10];
	SiireTableCell*	pItemCell	= nil;
	if( pNode == nil )
	{
		CCNode*	pCellScene	= [CCBReader nodeGraphFromFile:@"siireTableCell.ccbi"];
		NSAssert([pCellScene isKindOfClass:[SiireTableCell class]], @"");
		
		[pCell addChild:pCellScene z:1 tag:10];
				
		pItemCell	= (SiireTableCell*)pCellScene;
		[pItemCell setAnchorPoint:ccp(0, 0)];
		[pItemCell setPosition:ccp(0, 0)];
	}
	else
	{
		pItemCell	= (SiireTableCell*)pNode;
	}

	//	天ぷらアイコン
	{
		TenpuraBigIcon*	pIcon	= pItemCell.pTenpuraIcon;
		if( pIcon )
		{
			[pIcon setup:pData];
		}
	}
	
	//	購入できない場合の対応
	{
		CCSprite*	pNotBuyCellSprite	= nil;
		CCNode*	pChildNode	= [pItemCell getChildByTag:eTAG_SHOP_TABLE_NOT_BUY_CELL];
		if( ( pChildNode != nil ) && [pChildNode isKindOfClass:[CCSprite class]] )
		{
			pNotBuyCellSprite	= (CCSprite*)pChildNode;
		}
		else
		{
			pNotBuyCellSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", s_pNotBuyCellFileName]];
			[pItemCell addChild:pNotBuyCellSprite z:0 tag:eTAG_SHOP_TABLE_NOT_BUY_CELL];
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
			if( [[DataSaveGame shared] getNeta:pData->no] == FALSE )
			{
		//		[pNotBuyCellSprite setVisible:YES];
			}
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
		NSString*	pStr	= [NSString stringWithFormat:@"%@:%ld", pTitleName, pData->sellMoney];
		[pItemCell.pMoneyLabel setString:pStr];
	}

	//	所持数表示
	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getNeta:pData->no];
	{
		UInt32	itemNum	= 0;
		if( pItem != nil )
		{
			itemNum	= pItem->num;
		}
		
		NSString*	pUseNameStr	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:57]];
		NSString*	pItemNumStr	= [NSString stringWithFormat:@"%@ %02ld", pUseNameStr, itemNum];
		[pItemCell.pPossessionLabel setString:pItemNumStr];
	}

	return pCell;
}

/*
	@brief	セル最大数
*/
-(SInt32)	getCellMax
{
	DataNetaList*	pData	= [DataNetaList shared];
	return pData.dataNum;
}

/*
	@brief	購入金額
*/
-(SInt32)	getSellMoney:(SInt32)in_idx
{
	const NETA_DATA_ST*	pData	= [[DataNetaList shared] getData:in_idx];
	if( pData != nil )
	{
		return	pData->sellMoney;
	}
	
	return 0;
}

/*
	@brief	購入
*/
-(BOOL)	buy:(SInt32)in_idx
{
	DataSaveGame*	pDataSaveGameInst	= [DataSaveGame shared];
	
	const NETA_DATA_ST*	pData	= [[DataNetaList shared] getData:in_idx];
	
	return [pDataSaveGameInst addNeta:pData->no];
}

/*
	@brief	購入チェック
*/
-(BOOL)	isBuy:(SInt32)in_idx
{
	SInt32	sellMoney	= [self getSellMoney:in_idx];
	UInt32	nowMoney	= [[DataSaveGame shared] getData]->money;
	
	const NETA_DATA_ST*	pData	= [[DataNetaList shared] getData:in_idx];
	const SAVE_DATA_ITEM_ST*	pNetaData	= [[DataSaveGame shared] getNeta:pData->no];
	if( ( pNetaData == NULL ) || ( pNetaData->num < eNETA_USE_MAX ) )
	{
		return ( sellMoney <= nowMoney );
	}

	return false;
}

@end
