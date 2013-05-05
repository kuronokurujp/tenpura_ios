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
#import "./../../Data/DataSaveGame.h"

/*
	@brief	非公開用
*/
@interface StoreScene (PrivateMethod)

//	ストアのエラー時の処理
-(void)	_error:(NSString*)in_pErrorMessage;
//	ストアの終了処理
-(void)	_end;

@end

@implementation StoreScene

/*
	@brief	購入処理
*/
+(void)	payment:(NSString*)in_pProducts
{
	UIAlertView*	pAlert	= [[[UIAlertView alloc]
								initWithTitle:@"" message:[DataBaseText getString:114]
								delegate:nil
								cancelButtonTitle:[DataBaseText getString:46]
								otherButtonTitles:nil, nil] autorelease];
	//	購入内容によって設定する
	DataStoreList*	pStoreInst	= [DataStoreList shared];
	if( pStoreInst != nil )
	{
		for( int i = 0; i < pStoreInst.dataNum; ++i )
		{
			const STORE_DATA_ST*	pData	= [pStoreInst getData:i];
			if( pData != nil )
			{
				NSString*	pStr	= [NSString stringWithUTF8String:pData->aStoreIdName];
				if([pStr isEqualToString:in_pProducts])
				{
					switch( pData->no )
					{
					case eSTORE_ID_CUTABS:
					{
						[[DataSaveGame shared] saveCutAdsFlg];
						
						//	バナー非表示通知
						{
							NSString*	pBannerHideName	= [NSString stringWithUTF8String:gp_bannerHideObserverName];
							NSNotification *n = [NSNotification notificationWithName:pBannerHideName object:nil];
							NSAssert(n, @"");
							[[NSNotificationCenter defaultCenter] postNotification:n];
						}
						break;
					}
					case eSTORE_ID_MONEY_3000:		{ [[DataSaveGame shared] addSaveMoeny:3000]; break; }
					case eSTORE_ID_MONEY_9000:		{ [[DataSaveGame shared] addSaveMoeny:9000]; break; }
					case eSTORE_ID_MONEY_80000:		{ [[DataSaveGame shared] addSaveMoeny:80000]; break; }
					case eSTORE_ID_MONEY_400000:	{ [[DataSaveGame shared] addSaveMoeny:400000]; break; }
					case eSTORE_ID_MONEY_900000:	{ [[DataSaveGame shared] addSaveMoeny:900000]; break; }
					}
				}
			}
		}
	}
	
	[pAlert show];
}

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
	
	[StoreAppPurchaseManager share].delegate	= self;
	mp_grayView	= nil;
	mp_indicator	= nil;

	//	ストア処理中のアラート
	{
		mp_storeBuyCheckAlerView	= [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
	}

	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	[mp_storeBuyCheckAlerView release];
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

/*
	@brief	トランザクションの開始
*/
-(void)	onStartTransaction:(const STORE_REQUEST_TYPE_ENUM)in_type
{
	NSString*	pAlerTitleStr	= nil;
	if( in_type == eSTORE_REQUEST_TYPE_PAY )
	{
		pAlerTitleStr	= [DataBaseText getString:118];
	}
	else if( in_type == eSTORE_REQUEST_TYPE_RESTORE )
	{
		pAlerTitleStr	= [DataBaseText getString:119];
	}
	else if( in_type == eSTORE_REQUEST_TYPE_RESTART )
	{
		pAlerTitleStr	= [DataBaseText getString:120];
	}

	if( pAlerTitleStr != nil )
	{
		[mp_storeBuyCheckAlerView setTitle:pAlerTitleStr];
		[mp_storeBuyCheckAlerView setMessage:[DataBaseText getString:121]];
		[mp_storeBuyCheckAlerView show];
	}
}

/*
	@brief	トランザクションの終了
*/
-(void)	onEndTransaction
{
	[self _end];
}

/*
	@brief	購入決済終了
*/
-(void)	onPaymentPurchased:(NSString*)in_pProducts
{
	[StoreScene payment:in_pProducts];
}

/*
	@brief	リストア完了
*/
-(void)	onPaymentRestore:(NSString*)in_pProducts
{
	
}

/*
	@brief	決済途中キャンセル
*/
-(void)	onPaymentFailed:(NSError*)in_pError
{
	NSString*	pMessageStr	= [in_pError localizedDescription];

	//	購入失敗通知
	switch( in_pError.code )
	{
		case SKErrorClientInvalid:
		{
			//	不正なクライアント
			break;
		}
		case SKErrorPaymentCancelled:
		{
			//	購入がキャンセル
			pMessageStr	= [DataBaseText getString:115];
			break;
		}
		case SKErrorPaymentInvalid:
		{
			//	不正な購入
			break;
		}
		case SKErrorPaymentNotAllowed:
		{
			//	購入が許可されていない
			pMessageStr	= [DataBaseText getString:116];
			break;
		}
		case SKErrorStoreProductNotAvailable:
		{
			//	プロダクトが使えない
			break;
		}
		case SKErrorUnknown:
		{
			//	未知のエラー
		}
		default:
		{
			break;
		}
	}
	
	[self _error:pMessageStr];
}

/*
	@brief	リクエスト開始
*/
-(void)	onRequest
{
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
	
	UIView*	pView	= [CCDirector sharedDirector].view;

	CGSize	winSize	= [CCDirector sharedDirector].winSize;
	//	通信状態を表示
	[UIApplication sharedApplication].networkActivityIndicatorVisible	= YES;
	
	UIView*	pGrayView	= [[UIView alloc] initWithFrame:CGRectMake(0,0,winSize.width,winSize.height)];
	[pGrayView setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f]];
	pGrayView.tag	= 21;
	[pView addSubview:pGrayView];

	UIActivityIndicatorView*	pIndicator	= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[pIndicator setCenter:ccp(winSize.width * 0.5f, winSize.height * 0.5f)];
	[pGrayView addSubview:pIndicator];
	[pIndicator startAnimating];

	mp_grayView	= pGrayView;
	mp_indicator	= pIndicator;	
}

/*
	@brief	リクエスト失敗
*/
-(void)	onErrorRequest:(NSError *)in_pError
{
	[self _end];
	
	NSString*	pMessage	= nil;
	if( in_pError != nil )
	{
		pMessage	= [in_pError localizedDescription];
	}
	
	if( (pMessage == nil) || ([pMessage isEqualToString:@""]) )
	{
		pMessage	= [DataBaseText getString:1000];
	}
	
	[self _error:pMessage];
}

/*
	@brief	ストアのエラー時の処理
*/
-(void)	_error:(NSString*)in_pErrorMessage
{
	UIAlertView*	pAlert	= [[[UIAlertView alloc]
								initWithTitle:@"" message:in_pErrorMessage
								delegate:nil
								cancelButtonTitle:[DataBaseText getString:46]
								otherButtonTitles:nil, nil] autorelease];
	[pAlert show];
}

/*
	@brief	ストアの終了処理
*/
-(void)	_end
{
	[mp_storeBuyCheckAlerView dismissWithClickedButtonIndex:0 animated:YES];

	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];

	if( mp_indicator )
	{
		[mp_indicator removeFromSuperview];
		mp_indicator	= nil;
	}
	
	if( mp_grayView )
	{
		[mp_grayView removeFromSuperview];
		mp_grayView	= nil;
	}

	[UIApplication sharedApplication].networkActivityIndicatorVisible	= NO;

}

@end
