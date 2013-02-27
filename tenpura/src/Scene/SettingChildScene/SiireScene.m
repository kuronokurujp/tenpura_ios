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

	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	SiireTableCell*	pItemCell	= (SiireTableCell*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
	NSAssert(pItemCell, @"");

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
		[pItemCell setColor:ccWHITE];
		if( [self isBuy:idx] == false )
		{
			//	購入できない
			[pItemCell setColor:ccGRAY];
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
