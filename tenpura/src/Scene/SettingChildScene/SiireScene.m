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

@interface SiireScene (PrivateMethod)

-(void)setMoneyString:(UInt32)in_num;

@end

@implementation SiireScene

enum
{
	eTAG_MONEY_TEXT_LABLE	= 3,
	eTAG_CELL_NOT_BUY_SPRITE	= eSW_TABLE_TAG_CELL_MAX + 1,
};

static const char*	s_pSireCellFileName		= "sire_cell.png";
static const char*	s_pNotBuyCellFileName	= "not_buy_cell.png";
static const SInt32	s_sireTableViewCellMax	= 6;

/*
	@brief	初期化
*/
-(id)	init
{
	SW_INIT_DATA_ST	data	= { 0 };

	DataNetaList*	pData	= [DataNetaList shared];
	data.viewMax	= pData.dataNum > s_sireTableViewCellMax ? pData.dataNum : s_sireTableViewCellMax;
	data.fontSize	= 32;

	strcpy(data.aCellFileName, s_pSireCellFileName);
	
	CCSprite*	pTmpSp	= [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", data.aCellFileName]];
	data.cellSize	= [pTmpSp contentSize];
	data.viewPos	= ccp( 0, data.cellSize.height * 0.5f );
	
	CGSize	winSize	= [[CCDirector sharedDirector] winSize];
	data.viewSize	= CGSizeMake(winSize.width, winSize.height - data.cellSize.height * 0.5f );

	if( self = [super initWithData:&data] )
	{
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
	
	const NETA_DATA_ST*	pData	= [[DataNetaList shared] getData:idx];
	if( pData != nil )
	{
		UInt32	nowMoney	= [[DataSaveGame shared] getData]->money;
		if( pData->buyMoney <= nowMoney )
		{
			[self actionCellTouch:cell];

			mp_buyItemCell	= cell;
			[mp_buyCheckAlertView show];
		}
	}
}

/*
	@brief
*/
-(SWTableViewCell*)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx
{
	const NETA_DATA_ST*	pData	= [[DataNetaList shared] getData:idx];
	UInt32	nowMoney	= [[DataSaveGame shared] getData]->money;

	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];
	
	CCSprite*	pCellSprite	= (CCSprite*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];

	//	購入できない場合の対応
	{
		CCSprite*	pNotBuyCellSprite	= nil;
		CCNode*	pChildNode	= [pCellSprite getChildByTag:eTAG_CELL_NOT_BUY_SPRITE];
		if( ( pChildNode != nil ) && [pChildNode isKindOfClass:[CCSprite class]] )
		{
			pNotBuyCellSprite	= (CCSprite*)pChildNode;
		}
		else
		{
			pNotBuyCellSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", s_pNotBuyCellFileName]];
			[pCellSprite addChild:pNotBuyCellSprite z:0 tag:eTAG_CELL_NOT_BUY_SPRITE];
		}

		[pNotBuyCellSprite setPosition:ccp(0, 0)];
		[pNotBuyCellSprite setAnchorPoint:ccp(0, 0)];
		[pNotBuyCellSprite setColor:ccc3(255,255,255)];
		[pNotBuyCellSprite setVisible:NO];

		if( pData != nil )
		{
			if( nowMoney < pData->buyMoney )
			{
				//	購入できない
				[pCellSprite setColor:ccGRAY];
				
				if( [[DataSaveGame shared] isItem:pData->no] == FALSE )
				{
					[pNotBuyCellSprite setVisible:YES];
				}
			}
		}		
	}

	{
		CCLabelTTF*	pLabel	= (CCLabelTTF*)[pCellSprite getChildByTag:eSW_TABLE_TAG_CELL_TEXT];
		if( pData != nil )
		{
			NSString*	pTenpuraName	= [NSString stringWithUTF8String:[[DataBaseText shared] getText:pData->textID]];
			NSString*	pStr	= [NSString stringWithFormat:@"%@ 金額:%ld", pTenpuraName, pData->buyMoney];
			[pLabel setString:pStr];
		}
	}

	return pCell;
}

/*
	@brief	品書きに戻る
*/
-(void)	pressSinagakiBtn
{
	[[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:2];
}

/*
	@brief	購入するか決定
*/
-(void)	alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( alertView == mp_buyCheckAlertView )
	{
		if( buttonIndex == 1 )
		{
			//	購入しない
		}
		else
		{
			//	購入
			const NETA_DATA_ST*	pData	= [[DataNetaList shared] getData:[mp_buyItemCell objectID]];

			DataSaveGame*	pDataSaveGameInst	= [DataSaveGame shared];
			if( [pDataSaveGameInst addItem:pData->no] == TRUE )
			{
				CCNode*	pChildNode	= [mp_buyItemCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];
				if( [pChildNode isKindOfClass:[CCSprite class]] )
				{
					CCSprite*	pCellSprite	= (CCSprite*)pChildNode;
					[pCellSprite setColor:ccGRAY];
				}
				
				pDataSaveGameInst.addMoney	= -pData->buyMoney;
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

@end
