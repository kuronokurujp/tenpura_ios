//
//  StoreScene.m
//  tenpura
//
//  Created by y.uchida on 12/11/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

//	TODO	セルのレイアウトをcocosBulderで設定できるようにする

#import "StoreScene.h"

#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataBaseText.h"
#import "./../../Data/DataStoreList.h"
#import "./../../CCBReader/CCBReader.h"
#import "./../../TableCells/StoreTableCell.h"
#import "./../../System/Sound/SoundManager.h"
#import "./../../System/Store/StoreAppPurchaseManager.h"

@implementation StoreScene

/*
	@brief
*/
-(id)	init
{
	SW_INIT_DATA_ST	data	= { 0 };

	SInt32		dataNum	= [[DataStoreList shared] dataNum];
	data.viewMax	= dataNum < 6 ? 6 : dataNum;

	strcpy(data.aCellFileName, "storeTableCell.ccbi");

	data.viewPos	= ccp( TABLE_POS_X, TABLE_POS_Y );
	data.viewSize	= CGSizeMake(TABLE_SIZE_WIDTH, TABLE_SIZE_HEIGHT );

	if( self = [super initWithData:&data] )
	{
		[self reloadUpdate];
	}
	
	//	ストア購入後の表示
	{
		mp_buyEndAlertView	= nil;
		mp_buyEndAlertView	= [[UIAlertView alloc] initWithTitle:
													@""
													message:@""
													delegate:self
													cancelButtonTitle:[DataBaseText getString:46]
													otherButtonTitles:nil, nil];
	}
	
	return self;
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
	if( (pData != nil) && ([pStoreApp isPayment]) )
	{
		if( pStoreApp.bLoad == false )
		{
			[pStoreApp requestProduct:[NSString stringWithUTF8String:pData->aStoreIdName]];
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
	
	return pCell;
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

/*
	@brief	購入結果表示
*/
-(void)	alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[[SoundManager shared] playSe:@"btnClick"];
	
	UIView*	pView	= [CCDirector sharedDirector].view;
	pView.userInteractionEnabled	= YES;
	[[CCDirector sharedDirector] resume];
}

@end
