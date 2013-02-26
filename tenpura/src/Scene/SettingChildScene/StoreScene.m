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
#import "./../../Data/DataMissionList.h"
#import "./../../Data/DataStoreList.h"
#import "./../../CCBReader/CCBReader.h"
#import "./../../TableCells/SampleCell.h"
#import "./../../TableCells/StoreTableCell.h"
#import "./../../System/Sound/SoundManager.h"

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
		//	ストア購入のアラート表示位置
		{
			CGSize	winSize	= [CCDirector sharedDirector].winSize;
			CGPoint	pos	= ccp(winSize.width * 0.5f, winSize.height * 0.5f);
			mp_storeViewCtrl	= [[StoreAppPurchaseViewController alloc] initToData:pos:winSize];
			mp_storeViewCtrl.delegate	= self;
		}

		[self reloadUpdate];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	if( mp_storeViewCtrl != nil )
	{
		[mp_storeViewCtrl release];
		mp_storeViewCtrl	= nil;
	}
	
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
	
#if 0
	//	テスト
	UIView*	pView	= [CCDirector sharedDirector].view;
	pView.userInteractionEnabled	= NO;
	[[CCDirector sharedDirector] pause];

	NSString*	pIdName	= [NSString stringWithUTF8String:[[DataBaseText shared] getText:59]];
	[mp_storeViewCtrl requestPurchase:pIdName];

	[pView addSubview:mp_storeViewCtrl.view];
#endif
}

/*
	@brief	セル単位の表示設定
*/
-(SWTableViewCell*)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];

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
	@brief	ビュー終了
*/
-(void)	onEndView
{
	[[CCDirector sharedDirector] resume];

	UIView*	pView	= [CCDirector sharedDirector].view;
	pView.userInteractionEnabled	= YES;

	if( [mp_storeViewCtrl.view isDescendantOfView:pView] == YES )
	{
		[mp_storeViewCtrl.view removeFromSuperview];
	}
}

/*
	@brief	エラー
*/
-(void)	onError:(STORE_ERROR_STATE_ENUM)in_state
{
}

/*
	@brief	購入決済終了
*/
-(void)	onPaymentPurchased
{
}

/*
	@brief	決済途中キャンセル
*/
-(void)	onPaymentFailed
{
}

@end
