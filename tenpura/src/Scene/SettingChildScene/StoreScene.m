//
//  StoreScene.m
//  tenpura
//
//  Created by y.uchida on 12/11/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//
#import "StoreScene.h"

#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataBaseText.h"
#import "./../../Data/DataStoreList.h"
#import "./../../CCBReader/CCBReader.h"
#import "./../../TableCells/StoreTableCell.h"
#import "./../../System/Sound/SoundManager.h"
#import "./../../Data/DataSaveGame.h"

@interface StoreScene (PrivateMethod)

-(const BOOL)   isDoCureLife;
-(void) _onPayment;

@end

@implementation StoreScene

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
        //  購入処理時に呼び出す
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            
            NSString*   pObserverName   = [NSString stringWithUTF8String:gp_paymentObserverName];
            [nc addObserver:self selector:@selector(_onPayment) name:pObserverName object:nil];
        }
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

/*
	@brief
*/
-(void)	pressBackBtn
{
	[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:g_sceneChangeTime];
	
	[[SoundManager shared] playSe:@"pressBtnClick"];
}

//	デリゲート定義
/*
	@brief	テーブルがセルにタッチしたときに呼ばれる
*/
-(void)table:(SWTableView*)table cellTouched:(SWTableViewCell *)cell
{
	[super table:table cellTouched:cell];
	
	SInt32	idx	= [cell objectID];
	StoreAppPurchaseManager*	pStoreApp	= [StoreAppPurchaseManager share];
	
	DataStoreList*	pDataStoreInst	= [DataStoreList shared];
	const STORE_DATA_ST*	pData	= [pDataStoreInst getData:idx];
	if( pData != nil )
	{
		if( pStoreApp.bLoad == false )
		{
            BOOL    bBuy    = YES;
            if( pData->no == eSTORE_ID_CURELIEF )
            {
                bBuy    = [self isDoCureLife];
            }

            if( bBuy == YES )
            {
                if( [pStoreApp isPayment] == YES )
                {
                    [pStoreApp requestProduct:[NSString stringWithUTF8String:pData->aStoreIdName]];
                }
                else
                {
                    //	機能制限でつかえない
                    UIAlertView*	pAlert	= [[[UIAlertView alloc]
                                                initWithTitle:@"" message:[DataBaseText getString:155]
                                                delegate:nil
                                                cancelButtonTitle:[DataBaseText getString:46]
                                                otherButtonTitles:nil, nil] autorelease];
                    [pAlert show];
                }                
            }
		}
	}
}

/*
	@brief	セル単位の表示設定
*/
-(SWTableViewCell*)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];

	StoreTableCell*	pCellLayout	= (StoreTableCell*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
	NSAssert(pCellLayout, @"");

	DataStoreList*	pDataStoreInst	= [DataStoreList shared];
	const STORE_DATA_ST*	pData	= [pDataStoreInst getData:idx];
	
	if( pData != nil )
	{
		//	題名
		[pCellLayout.pNameLabel setString:[DataBaseText getString:pData->textId]];

		//	金額
		[pCellLayout.pMoneyLabel setString:@""];
	}
	else
	{
		//	題名
		[pCellLayout.pNameLabel setString:@""];

		//	金額
		[pCellLayout.pMoneyLabel setString:@""];
	}

    [pCellLayout setColor:ccWHITE];
    if( pData->no == eSTORE_ID_CURELIEF )
    {
        if( [self isDoCureLife] == NO )
        {
            [pCellLayout setColor:ccGRAY];
        }
    }
	
	return pCell;
}

/*
	@brief
*/
-(void)	onEnterActive
{
	[super onEnterActive];
	
	SW_INIT_DATA_ST	data	= { 0 };

	SInt32		dataNum	= [[DataStoreList shared] dataNum];
	data.viewMax	= dataNum < 6 ? 6 : dataNum;

	strcpy(data.aCellFileName, "storeTableCell.ccbi");

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

	[super onExitTransitionDidStart];
}

-(const BOOL)   isDoCureLife
{
    const SAVE_DATA_ST* pSaveData   = [[DataSaveGame shared] getData];
    if( eSAVE_DATA_PLAY_LIEF_MAX <= pSaveData->playLife )
    {
        return NO;
    }

    return YES;
}

//  購入時に呼び出す
-(void) _onPayment
{
    //  リスト再描画
    [self reloadUpdate];
}

@end