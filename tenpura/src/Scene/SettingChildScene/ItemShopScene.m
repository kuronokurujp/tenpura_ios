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
#import "./../../Data/DataBaseText.h"

//	内部関数
@interface ItemShopScene (PrivateMethod)

//	セル選択可能か
-(BOOL)	_isCellSelect:(SInt32)in_idx;

@end

@implementation ItemShopScene

/*
	@brief	初期化
*/
-(id)	init
{
    //  購入できるアイテムリスト作成
    {
        memset(ma_itemList, 0, sizeof(ma_itemList));
        
        int num = 0;
        DataItemList*   pDataItemListInst   = [DataItemList shared];
        for( SInt32 i = 0; i < pDataItemListInst.dataNum; ++i )
        {
            const ITEM_DATA_ST*	pData	= [pDataItemListInst getData:i];
            if( 0 <= pData->sellMoney )
            {
                ma_itemList[num]    = *pData;
                ++num;
            }
        }
        
        m_itemNum   = num;
    }

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
	const ITEM_DATA_ST*	pData	= &ma_itemList[idx];

	DataBaseText*	pDataBaseTextShared	= [DataBaseText shared];

	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	ItemShopTableCell*	pItemCell	= (ItemShopTableCell*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
	NSAssert(pItemCell, @"");

	[pItemCell.pUnknowLabel setString:@""];
	
    DataSaveGame*	pDataSaveGameInst	= [DataSaveGame shared];

    [pItemCell setColor:ccWHITE];

	//	選択可能かチェック
	if( [self _isCellSelect:idx] == NO )
	{
		//	アイテム名表示
		{
			NSString*	pItemName	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:156]];
			[pItemCell.pUnknowLabel setString:pItemName];
		}

		[pItemCell setColor:ccGRAY];

		return pCell;
	}

	//	購入できない場合の対応
	{
        [pItemCell setEnableSoldOut:NO];

		if( [self isBuy:idx] == false )
		{
			//	購入できない
            const SAVE_DATA_ITEM_ST*	pItemData	= [[DataSaveGame shared] getItem:pData->no];
            if( ( pItemData == NULL ) || ( pItemData->num < eSAVE_DATA_ITEM_USE_MAX ) )
            {
                [pItemCell setColor:ccGRAY];
            }
            else
            {
                [pItemCell setEnableSoldOut:YES];
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
		NSString*	pFormat	= [DataBaseText getString:pData->contentTextID];
		[pItemCell.pDataLabel setString:[NSString stringWithFormat:pFormat, pData->value]];
	}
	
	//	購入金額表示
	{
		NSString*	pTitleName		= [NSString stringWithUTF8String:[pDataBaseTextShared getText:58]];
		NSString*	pStr	= [NSString stringWithFormat:@"%@:%ld", pTitleName, pData->sellMoney];
		[pItemCell.pMoneyLabel setString:pStr];
	}
    
    //  所有数表示
    {
        const SAVE_DATA_ITEM_ST*    pItemData   = [pDataSaveGameInst getItem:pData->no];
        if( pItemData != NULL )
        {
            [pItemCell.pNumLabel setVisible:YES];
            [pItemCell.pNumLabel setString:[NSString stringWithFormat:@"%d", pItemData->num]];
        }
        else
        {
            [pItemCell.pNumLabel setVisible:NO];
        }
    }

	return pCell;
}

/*
	@brief	セル最大数
*/
-(SInt32)	getCellMax
{
	return m_itemNum;
}

/*
	@brief	購入金額
*/
-(SInt32)	getSellMoney:(SInt32)in_idx
{
	const ITEM_DATA_ST*	pData	= &ma_itemList[in_idx];
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
    
	const ITEM_DATA_ST*	pData	= &ma_itemList[in_idx];

    if( [pDataSaveGameInst addItem:pData->no] )
    {
        {
            DataItemList*   pDataItemListInst   = [DataItemList shared];

            SInt32  max = pDataItemListInst.dataNum;
            for( SInt32 i = 0; i < max; ++i )
            {
                const ITEM_DATA_ST*	pUnlockItemChkData   = [pDataItemListInst getData:i];
                if( pUnlockItemChkData->unlockItemNo == pData->no )
                {
                    //  購入成功したので、ロック解除
                    [pDataSaveGameInst unlockItem:pUnlockItemChkData->no];
                }
            }
        }
        
        return YES;
    }

	return NO;
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
	
	const ITEM_DATA_ST*	pData	= &ma_itemList[in_idx];
	const SAVE_DATA_ITEM_ST*	pItemData	= [[DataSaveGame shared] getItem:pData->no];
	if( ( pItemData == NULL ) || ( pItemData->num < eSAVE_DATA_ITEM_USE_MAX ) )
	{
		return ( sellMoney <= nowMoney );
	}

	return false;
}

/*
	@brief	セル選択可能か
*/
-(BOOL)	_isCellSelect:(SInt32)in_idx
{
	const ITEM_DATA_ST*	pData	= &ma_itemList[in_idx];
	if( pData->unlockItemNo == -1 )
	{
		return YES;
	}
	
	return  [[DataSaveGame shared] isLockItem:pData->no];
}

@end
