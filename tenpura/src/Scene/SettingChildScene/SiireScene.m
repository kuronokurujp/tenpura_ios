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
#import "./../../Object/Tenpura.h"

@interface SiireScene (PrivateMethod)

-(void)setMoneyString:(UInt32)in_num;

@end

@implementation SiireScene

enum
{
	eTAG_SHOP_TABLE_NOT_BUY_CELL	= eSW_TABLE_TAG_CELL_MAX + 1,
	eTAG_SHOP_TABLE_ITEM_ICON_OBJ,
	eTAG_SHOP_TABLE_ITEM_NUM_TEXT,
	eTAG_SHOP_TABLE_MONEY_TEXT,
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
	DataBaseText*	pDataBaseTextShared	= [DataBaseText shared];

	SWTableViewCell*	pCell	= [super table:table cellAtIndex:idx];	
	CCSprite*	pCellSprite	= (CCSprite*)[pCell getChildByTag:eSW_TABLE_TAG_CELL_SPRITE];
	NSAssert(pCellSprite, @"");

	//	天ぷらアイコン
	{
		CCNode*	pChildNode	= [pCellSprite getChildByTag:eTAG_SHOP_TABLE_ITEM_ICON_OBJ];
		if( pChildNode == nil )
		{
			CGSize	texSize	= [pCellSprite textureRect].size;

			Tenpura*	pTenpuraObject	= [[[Tenpura alloc] init] autorelease];
			[pTenpuraObject setupToPos:*pData :ccp(70, texSize.height * 0.5f)];

			[pCellSprite addChild:pTenpuraObject z:0 tag:eTAG_SHOP_TABLE_ITEM_ICON_OBJ];
		}
	}

	//	購入できない場合の対応
	{
		CCSprite*	pNotBuyCellSprite	= nil;
		CCNode*	pChildNode	= [pCellSprite getChildByTag:eTAG_SHOP_TABLE_NOT_BUY_CELL];
		if( ( pChildNode != nil ) && [pChildNode isKindOfClass:[CCSprite class]] )
		{
			pNotBuyCellSprite	= (CCSprite*)pChildNode;
		}
		else
		{
			pNotBuyCellSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%s", s_pNotBuyCellFileName]];
			[pCellSprite addChild:pNotBuyCellSprite z:0 tag:eTAG_SHOP_TABLE_NOT_BUY_CELL];
		}

		[pNotBuyCellSprite setPosition:ccp(0, 0)];
		[pNotBuyCellSprite setAnchorPoint:ccp(0, 0)];
		[pNotBuyCellSprite setColor:ccc3(255,255,255)];
		[pNotBuyCellSprite setVisible:NO];

		[pCellSprite setColor:ccWHITE];
		if( (pData != nil) && (nowMoney < pData->buyMoney) )
		{
			//	購入できない
			[pCellSprite setColor:ccGRAY];
			if( [[DataSaveGame shared] getItem:pData->no] == FALSE )
			{
				[pNotBuyCellSprite setVisible:YES];
			}
		}		
	}

	//	アイテム名表示
	{
		CCLabelTTF*	pLabel	= (CCLabelTTF*)[pCellSprite getChildByTag:eSW_TABLE_TAG_CELL_TEXT];
		if( pLabel != nil )
		{
			NSString*	pTenpuraName	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:pData->textID]];
			[pLabel setAnchorPoint:ccp(0, 0)];
			[pLabel setPosition:ccp(130.f, 50.f)];
			[pLabel setString:pTenpuraName];
		}
	}
	
	//	購入金額表示
	{
		CCLabelTTF*	pLabel	= (CCLabelTTF*)[pCellSprite getChildByTag:eTAG_SHOP_TABLE_MONEY_TEXT];
		if( pLabel == nil )
		{
			pLabel	= [CCLabelTTF labelWithString:@"" fontName:self.textFontName fontSize:self.data.fontSize];
			[pLabel setAnchorPoint:ccp(0, 0)];
			[pLabel setPosition:ccp(130.f, 10.f)];
			[pLabel setColor:ccBLACK];

			[pCellSprite addChild:pLabel z:0 tag:eTAG_SHOP_TABLE_MONEY_TEXT];
		}

		if( pLabel != nil )
		{
			NSString*	pTitleName		= [NSString stringWithUTF8String:[pDataBaseTextShared getText:58]];
			NSString*	pStr	= [NSString stringWithFormat:@"%@:%04ld", pTitleName, pData->buyMoney];
			[pLabel setString:pStr];
		}
	}

	//	所持数表示
	const SAVE_DATA_ITEM_ST*	pItem	= [[DataSaveGame shared] getItem:pData->no];
	{
		CCLabelTTF*	pItemNumLabel	= (CCLabelTTF*)[pCellSprite getChildByTag:eTAG_SHOP_TABLE_ITEM_NUM_TEXT];
		if( pItemNumLabel == nil )
		{
			CGSize	texSize	= [pCellSprite textureRect].size;

			pItemNumLabel	= [CCLabelTTF labelWithString:@"" fontName:self.textFontName fontSize:self.data.fontSize];
			CGPoint	pos	= ccp( texSize.width - 150.f, 10.f );
			[pItemNumLabel setPosition:pos];
			[pItemNumLabel setAnchorPoint:ccp(0.f, 0.f)];

			[pCellSprite addChild:pItemNumLabel z:0 tag:eTAG_SHOP_TABLE_ITEM_NUM_TEXT];
		}

		UInt32	itemNum	= 0;
		if( pItem != nil )
		{
			itemNum	= pItem->num;
		}
		
		if( pItemNumLabel != nil )
		{
			NSString*	pUseNameStr	= [NSString stringWithUTF8String:[pDataBaseTextShared getText:57]];
			NSString*	pItemNumStr	= [NSString stringWithFormat:@"%@ %02ld", pUseNameStr, itemNum];
			[pItemNumLabel setString:pItemNumStr];
			[pItemNumLabel setColor:ccBLACK];
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
				
				[pDataSaveGameInst addSaveMoeny:-pData->buyMoney];
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
