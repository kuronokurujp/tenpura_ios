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

	SW_INIT_DATA_ST	data	= { 0 };

	data.viewMax	= [self getCellMax] > s_sireTableViewCellMax ? [self getCellMax] : s_sireTableViewCellMax;
	
	strcpy(data.aCellFileName, [in_pFileName UTF8String]);
	
	data.viewPos	= ccp( TABLE_POS_X, TABLE_POS_Y );
	data.viewSize	= CGSizeMake(TABLE_SIZE_WIDTH, TABLE_SIZE_HEIGHT );

	if( self = [super initWithData:&data] )
	{
		[self reloadUpdate];

		mp_moneyTextLable	= nil;
		mp_buyItemCell	= nil;

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
								
	}

	return self;
}

-(id)	init
{
	NSAssert(0, @"");
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
	
	mp_moneyTextLable	= nil;
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
	@brief	ゲーム内の金額購入画面
*/
-(void)	pressBuyMoneyBtn
{
	CCScene*	storeScene	= [CCBReader sceneWithNodeGraphFromFile:@"store.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:storeScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] pushScene:pTransFade];

	[[SoundManager shared] playSe:@"btnClick"];
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
					CCSprite*	pCellSprite	= (CCSprite*)pChildNode;
					[pCellSprite setColor:ccGRAY];
				}
			
				[pDataSaveGameInst addSaveMoeny:-([self getSellMoney:[mp_buyItemCell objectID]])];
				[self setMoneyString:[[DataSaveGame shared] getData]->money];

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
	@brief	CCBI読み込み終了
*/
- (void) didLoadFromCCB
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( ( [pNode isKindOfClass:[CCLabelTTF class]] ) )
		{
			CCLabelTTF*	pLabelTTF	= (CCLabelTTF*)pNode;
			if( [[pLabelTTF string] isEqualToString:@"000000"] )
			{
				mp_moneyTextLable	= (CCLabelTTF*)pNode;

				[self setMoneyString:[[DataSaveGame shared] getData]->money];
			}
		}
	}
}

/*
	@brief	金額設定
*/
-(void)setMoneyString:(UInt32)in_num
{
	[mp_moneyTextLable setString:[NSString stringWithFormat:@"%06ld", in_num]];
}

/*
	@brief
*/
-(void)	onEnter
{
	[super onEnter];
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
