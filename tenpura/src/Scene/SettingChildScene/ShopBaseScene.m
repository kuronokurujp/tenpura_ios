//
//  ShopBaseScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShopBaseScene.h"
#import "./../../TableCells/SampleCell.h"
#import "./../../CCBReader/CCBReader.h"
#import "./../../Data/DataBaseText.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Object/Tenpura.h"
#import "./../../System/Sound/SoundManager.h"
#import "./../../System/Common.h"

#import "AppDelegate.h"

@interface ShopBaseScene (PrivateMethod)

-(void)setMoneyString:(UInt32)in_num;

@end

@implementation ShopBaseScene

static const SInt32	s_sireTableViewCellMax	= 6;

/*
	@brief	初期化
*/
-(id)	initWithCellDataFileName:(NSString*)in_pFileName
{
	NSAssert(in_pFileName, @"");
	if( self = [super init] )
	{
		mp_cellFileName	= nil;
		mp_buyAlertView	= nil;
		mp_buyCheckAlertView	= nil;
		mp_buyItemCell	= nil;

		mp_cellFileName	= [in_pFileName retain];	
	}

	return self;
}

/*
	@breif
*/
-(void)dealloc
{
	if( mp_buyCheckAlertView != nil )
	{
		[mp_buyCheckAlertView release];
		mp_buyCheckAlertView	= nil;
	}
		
	if( mp_buyAlertView != nil )
	{
		[mp_buyAlertView release];
		mp_buyAlertView	= nil;
	}
	
	mp_buyItemCell		= nil;

	[super dealloc];
}

//	デリゲート定義
/*
	@brief	テーブルがセルにタッチしたときに呼ばれる
*/
-(void)table:(SWTableView*)table cellTouched:(SWTableViewCell *)cell
{
	[super table:table cellTouched:cell];

	UInt32	idx	= [cell objectID];
	
	//	購入チェック
	{
		if( [self isBuy:idx] == true )
		{
			[self actionCellTouch:cell];

			mp_buyItemCell	= cell;
			[mp_buyCheckAlertView show];

			[[SoundManager shared] playSe:@"btnClick"];
		}
	}
}
/*
	@brief	元の画面に戻る
*/
-(void)	pressSinagakiBtn
{
	[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:g_sceneChangeTime];

	[[SoundManager shared] playSe:@"pressBtnClick"];
}

/*
	@brief	購入するか決定
*/
-(void)	alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[[SoundManager shared] playSe:@"btnClick"];

	if( alertView == mp_buyCheckAlertView )
	{
		if( buttonIndex == 1 )
		{
			//	購入しない
		}
		else
		{
			//	購入
			DataSaveGame*	pDataSaveGameInst	= [DataSaveGame shared];
			if( [self buy:[mp_buyItemCell objectID]] )
			{
				CCNode*	pChildNode	= [mp_buyItemCell getChildByTag:eSW_TABLE_TAG_CELL_LAYOUT];
				if( [pChildNode isKindOfClass:[CCSprite class]] )
				{
		//			CCSprite*	pCellSprite	= (CCSprite*)pChildNode;
		//			[pCellSprite setColor:ccGRAY];
				}
			
				[pDataSaveGameInst addSaveMoeny:-([self getSellMoney:[mp_buyItemCell objectID]])];

				//	スクロールビュー描画更新
				[self reloadUpdate];
				
				[mp_buyAlertView show];
			}
			else
			{
				//	購入失敗
			}
		}
	}

	mp_buyItemCell	= nil;
}

/*
	@brief
*/
-(void)	onEnterActive
{
	[super onEnterActive];

	SW_INIT_DATA_ST	data	= { 0 };

	data.viewMax	= [self getCellMax] > s_sireTableViewCellMax ? [self getCellMax] : s_sireTableViewCellMax;
	
	strcpy(data.aCellFileName, [mp_cellFileName UTF8String]);
	
	data.viewPos	= ccp( TABLE_POS_X, TABLE_POS_Y );
	data.viewSize	= CGSizeMake(TABLE_SIZE_WIDTH, TABLE_SIZE_HEIGHT );
    
	[self setup:&data];

	//	アラートを出す
	mp_buyCheckAlertView	= [[UIAlertView alloc]	initWithTitle:[DataBaseText getString:45]
											message:[DataBaseText getString:49]
											delegate:self
											cancelButtonTitle:[DataBaseText getString:46]
											otherButtonTitles:[DataBaseText getString:47], nil];
								
	mp_buyAlertView	= [[UIAlertView alloc]	initWithTitle:[DataBaseText getString:50]
											message:[DataBaseText getString:48]
											delegate:self
											cancelButtonTitle:[DataBaseText getString:46]
											otherButtonTitles:nil];
				

	[self reloadUpdate];
    
    {
        CGSize  size    = CGSizeMake(1.f, 1.f);
        [self setScaleX:converSizeVariableDevice(size).width];
    }
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
	@brief	セル最大数
*/
-(SInt32)	getCellMax
{
	return 0;
}

/*
	@brief	購入金額
*/
-(SInt32)	getSellMoney:(SInt32)in_idx
{
	return 0;
}

/*
	@brief	購入
*/
-(BOOL)	buy:(SInt32)in_idx
{
	return false;
}

/*
	@brief	購入チェック
*/
-(BOOL)	isBuy:(SInt32)in_idx
{
	return false;
}

@end
