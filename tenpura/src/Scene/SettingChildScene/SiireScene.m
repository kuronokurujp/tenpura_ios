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
#import "./../../Data/DataNetaPackList.h"
#import "./../../Data/DataNetaList.h"
#import "./../../Data/DataBaseText.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Object/TenpuraIcon.h"
#import "./../../System/Sound/SoundManager.h"

#import "AppDelegate.h"

@interface SiireScene (PrivateMethod)

-(BOOL)	_isCellSelect:(SInt32)in_idx;

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
	const NETA_PACK_DATA_ST*	pData	= [[DataNetaPackList shared] getData:idx];
	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	SiireTableCell*	pItemCell	= (SiireTableCell*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
	NSAssert(pItemCell, @"");

	if( pData == NULL )
	{
		return pCell;
	}
	
	DataBaseText*	pDataBaseTextShared	= [DataBaseText shared];

	[pItemCell.pUnknowLabel setString:@""];

    [pItemCell setColor:ccWHITE];

	//	選択可能かチェック
	if( [self _isCellSelect:idx] == NO )
	{
		//	アイテム名表示
		{
			NSString*	pTenpuraName	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:156]];
			[pItemCell.pUnknowLabel setString:pTenpuraName];
		}

        [pItemCell setColor:ccGRAY];

		return pCell;
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
	}
	
	//	購入できない場合の対応
	{
		if( [self isBuy:idx] == NO )
		{
			//	購入できない
			const NETA_PACK_DATA_ST*	pData	= [[DataNetaPackList shared] getData:idx];
			const SAVE_DATA_NETA_ST*	pNetaPackData	= [[DataSaveGame shared] getNetaPack:pData->no];
			if( ( pNetaPackData != NULL ) && ( 0 < pNetaPackData->num ) )
			{
				[pItemCell setEnableSoldOut:YES];
			}
			else
			{
				[pItemCell setColor:ccGRAY];
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
		NSString*	pStr	= [NSString stringWithFormat:@"%@:%ld", pTitleName, pData->money];
		[pItemCell.pMoneyLabel setString:pStr];
	}

	return pCell;
}

/*
	@brief	セル最大数
*/
-(SInt32)	getCellMax
{
	DataNetaPackList*	pData	= [DataNetaPackList shared];
	return pData.dataNum;
}

/*
	@brief	購入金額
*/
-(SInt32)	getSellMoney:(SInt32)in_idx
{
	const NETA_PACK_DATA_ST*	pData	= [[DataNetaPackList shared] getData:in_idx];
	if( pData != nil )
	{
		return	pData->money;
	}
	
	return 0;
}

/*
	@brief	購入
*/
-(BOOL)	buy:(SInt32)in_idx
{
	DataSaveGame*	pDataSaveGameInst	= [DataSaveGame shared];
	
	const NETA_PACK_DATA_ST*	pData	= [[DataNetaPackList shared] getData:in_idx];
	
	return [pDataSaveGameInst addNetaPack:pData->no];
}

/*
	@brief	購入チェック
*/
-(BOOL)	isBuy:(SInt32)in_idx
{
	if( [self _isCellSelect:in_idx] == NO )
	{
		return NO;
	}

	SInt32	sellMoney	= [self getSellMoney:in_idx];
	UInt32	nowMoney	= [[DataSaveGame shared] getData]->money;
	
	const NETA_PACK_DATA_ST*	pData	= [[DataNetaPackList shared] getData:in_idx];
	const SAVE_DATA_NETA_ST*	pNetaPackData	= [[DataSaveGame shared] getNetaPack:pData->no];
	if( ( pNetaPackData == NULL ) || ( pNetaPackData->num == 0 ) )
	{
		return ( sellMoney <= nowMoney );
	}

	return NO;
}

/*
	@brief	選択可能かチェック
*/
-(BOOL)	_isCellSelect:(SInt32)in_idx
{
	if( 0 < in_idx )
	{
		//	選択するアイテムのリスト前のアイテムを持っているか
		SInt32	backIdx	= in_idx - 1;
		const NETA_PACK_DATA_ST*	pData	= [[DataNetaPackList shared] getData:backIdx];
		const SAVE_DATA_NETA_ST*	pNetaPackData	= [[DataSaveGame shared] getNetaPack:pData->no];
		return ( pNetaPackData != nil );
	}
	
	return YES;
}

@end
