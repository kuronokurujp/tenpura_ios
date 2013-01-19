//
//  SiireScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SiireScene.h"
#import "./../../TableCells/SampleCell.h"
#import "./../../CCBReader/CCBReader.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataNetaList.h"
#import "./../../Data/DataBaseText.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Object/Tenpura.h"
#import "./../../System/Sound/SoundManager.h"

#import "AppDelegate.h"

@interface SiireScene (PrivateMethod)

-(void)setMoneyString:(UInt32)in_num;

@end

@implementation SiireScene

enum
{
	eTAG_SHOP_TABLE_NOT_BUY_CELL	= eSW_TABLE_TAG_CELL_MAX + 1,
	eTAG_SHOP_TABLE_ITEM_ICON_OBJ,
	eTAG_SHOP_TABLE_ITEM_NUM_TEXT,
	eTAG_SHOP_TABLE_MONEY_TEXT,
};

static const char*	s_pNotBuyCellFileName	= "not_buy_cell.png";
static const SInt32	s_sireTableViewCellMax	= 6;

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

	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];	
	CCSprite*	pCellSprite	= (CCSprite*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];
	NSAssert(pCellSprite, @"");

	//	天ぷらアイコン
	{
		CCNode*	pChildNode	= [pCellSprite getChildByTag:eTAG_SHOP_TABLE_ITEM_ICON_OBJ];
		if( pChildNode == nil )
		{
			CGSize	texSize	= [pCellSprite textureRect].size;

			Tenpura*	pTenpuraObject	= [[[Tenpura alloc] init] autorelease];
			[pTenpuraObject setupToPos:*pData :ccp(70, texSize.height * 0.5f):1.f];

			[pCellSprite addChild:pTenpuraObject z:0 tag:eTAG_SHOP_TABLE_ITEM_ICON_OBJ];
		}
	}

	//	購入できない場合の対応
	{
		CCSprite*	pNotBuyCellSprite	= nil;
		CCNode*	pChildNode	= [pCellSprite getChildByTag:eTAG_SHOP_TABLE_NOT_BUY_CELL];
		if( ( pChildNode != nil ) && [pChildNode isKindOfClass:[CCSprite class]] )
		{
			pNotBuyCellSprite	= (CCSprite*)pChildNode;
		}
		else
		{
			pNotBuyCellSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", s_pNotBuyCellFileName]];
			[pCellSprite addChild:pNotBuyCellSprite z:0 tag:eTAG_SHOP_TABLE_NOT_BUY_CELL];
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
			if( [[DataSaveGame shared] getNeta:pData->no] == FALSE )
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
			NSString*	pTenpuraName	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:pData->textID]];
			[pLabel setAnchorPoint:ccp(0, 0)];
			[pLabel setPosition:ccp(130.f, 50.f)];
			[pLabel setString:pTenpuraName];
		}
	}
	
	//	購入金額表示
	{
		CCLabelTTF*	pLabel	= (CCLabelTTF*)[pCellSprite getChildByTag:eTAG_SHOP_TABLE_MONEY_TEXT];
		if( pLabel == nil )
		{
			pLabel	= [CCLabelTTF labelWithString:@"" fontName:self.textFontName fontSize:self.data.fontSize];
			[pLabel setAnchorPoint:ccp(0, 0)];
			[pLabel setPosition:ccp(130.f, 10.f)];
			[pLabel setColor:ccBLACK];

			[pCellSprite addChild:pLabel z:0 tag:eTAG_SHOP_TABLE_MONEY_TEXT];
		}

		if( pLabel != nil )
		{
			NSString*	pTitleName		= [NSString stringWithUTF8String:[pDataBaseTextShared getText:58]];
			NSString*	pStr	= [NSString stringWithFormat:@"%@:%ld", pTitleName, pData->sellMoney];
			[pLabel setString:pStr];
		}
	}

	//	所持数表示
	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getNeta:pData->no];
	{
		CCLabelTTF*	pItemNumLabel	= (CCLabelTTF*)[pCellSprite getChildByTag:eTAG_SHOP_TABLE_ITEM_NUM_TEXT];
		if( pItemNumLabel == nil )
		{
			CGSize	texSize	= [pCellSprite textureRect].size;

			pItemNumLabel	= [CCLabelTTF labelWithString:@"" fontName:self.textFontName fontSize:self.data.fontSize];
			CGPoint	pos	= ccp( texSize.width - 150.f, 10.f );
			[pItemNumLabel setPosition:pos];
			[pItemNumLabel setAnchorPoint:ccp(0.f, 0.f)];

			[pCellSprite addChild:pItemNumLabel z:0 tag:eTAG_SHOP_TABLE_ITEM_NUM_TEXT];
		}

		UInt32	itemNum	= 0;
		if( pItem != nil )
		{
			itemNum	= pItem->num;
		}
		
		if( pItemNumLabel != nil )
		{
			NSString*	pUseNameStr	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:57]];
			NSString*	pItemNumStr	= [NSString stringWithFormat:@"%@ %02ld", pUseNameStr, itemNum];
			[pItemNumLabel setString:pItemNumStr];
			[pItemNumLabel setColor:ccBLACK];
		}
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
