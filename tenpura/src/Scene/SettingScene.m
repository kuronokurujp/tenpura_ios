//
//  SettingScene.m
//  tenpura
//
//  Created by y.uchida on 12/11/01.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingScene.h"
#import "GameScene.h"

#import "./../../libs/CCControlExtension/CCControlExtension.h"
#import "./../CCBReader/CCBReader.h"
#import "./../Data/DataSettingTenpura.h"
#import "./../Data/DataBaseText.h"
#import "./../Data/DataGlobal.h"
#import "./../Data/DataSaveGame.h"
#import "./SettingChildScene/UseSelectItemScene.h"

@implementation SettingScene

@synthesize useItemNoList	= mp_useItemNoList;

/*
	@brief
*/
-(id)init
{
	if( self = [super init] )
	{
		mp_useItemNoList	= [[CCArray alloc] init];
	}
	
	return self;
}

/*
	@brief
*/
-(void)dealloc
{
	mp_nowHiScoreText	= nil;
	mp_nowMoneyText	= nil;

	if( mp_useItemNoList != nil )
	{
		[mp_useItemNoList release];
	}
	mp_useItemNoList	= nil;

	[super dealloc];
}

/*
	@brief
*/
-(void)	onEnter
{
	//	受け渡しためのデータリスト作成
	SettingItemBtn*	pSettingItemBtn	= nil;
	CCARRAY_FOREACH(mp_useItemNoList, pSettingItemBtn)
	{
		if( 0 < pSettingItemBtn.itemNo  )
		{
			[mp_gameStartBtn setVisible:YES];
			break;
		}
	}

	[super onEnter];
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
	@brief	ゲームスタート
*/
-(void)	pressGameBtn
{
	CCLOG(@"GameStart");

	CCArray*	pDataSettingTenpura	= [[[CCArray alloc] init] autorelease];
	//	受け渡しためのデータリスト作成
	{
		SettingItemBtn*	pSettingItemBtn	= nil;
		CCARRAY_FOREACH(mp_useItemNoList, pSettingItemBtn)
		{
			if( 0 < pSettingItemBtn.itemNo  )
			{
				DataSettingTenpura*	pSettingData	= [[[DataSettingTenpura alloc] init] autorelease];
				pSettingData.no	= pSettingItemBtn.itemNo;
				[pDataSettingTenpura addObject:pSettingData];
			}
		}
	}

	//	データがないと先へ進めない
	if( 0 < [pDataSettingTenpura count] )
	{
		CCScene*	pGameScene	= [GameScene scene:pDataSettingTenpura];
		CCTransitionFade*	pTransFade	=
		[CCTransitionFade transitionWithDuration:2 scene:pGameScene withColor:ccBLACK];

		[[CCDirector sharedDirector] replaceScene:pTransFade];
	}
	
	pDataSettingTenpura	= nil;
}

/*
	@brief	購入へ
*/
-(void)	pressShopBtn
{
	CCLOG(@"Shop");
	
	CCScene*	sinagakiScene	= [CCBReader sceneWithNodeGraphFromFile:@"siire.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:2 scene:sinagakiScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] pushScene:pTransFade];
}

/*
	@brief	天ぷら設定
*/
-(void)	pressSettingItemBtn:(id)sender
{
	CCLOG(@"SelectItem");
	
    CCNode* node = [CCBReader nodeGraphFromFile:@"use_item_select.ccbi" owner:nil];
	
	//	選択したセッティング項目を選択リストにアタッチ
	//	選択したオブジェクトがセッティング項目用かチェックもする
	//	(デリゲーダーが使える？)
	if( ( [node isKindOfClass:[UseSelectItemScene class]] ) && ([sender isKindOfClass:[SettingItemBtn class]]) )
	{
		UseSelectItemScene*	pUseSelectItemScene	= (UseSelectItemScene*)node;
		SettingItemBtn*	pSettingUseItemBtn	= (SettingItemBtn*)sender;
		
		//	タッチしたときのアクション
		{
			CCBlink*	pActBlink	= [CCBlink actionWithDuration:0.5f blinks:2];
			[pSettingUseItemBtn runAction:pActBlink];
		}
		
		[pUseSelectItemScene setup:pSettingUseItemBtn:mp_useItemNoList];
	}

    CCScene* scene = [CCScene node];
    [scene addChild:node];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:2 scene:scene withColor:ccBLACK];

	[[CCDirector sharedDirector] pushScene:pTransFade];
}

/*
	@brief	ミッション画面へ移行
*/
-(void)	pressMissionBtn
{
	CCLOG(@"Mission");
	
	CCScene*	sinagakiScene	= [CCBReader sceneWithNodeGraphFromFile:@"mission.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:2 scene:sinagakiScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] pushScene:pTransFade];
}

/*
	@brief	CCBI読み込み終了
*/
- (void) didLoadFromCCB
{
	DataSaveGame*	pDataSaveGame	= [DataSaveGame shared];
	const SAVE_DATA_ST*	pSaveData	= [pDataSaveGame getData];

	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		//	セッティング項目をあらかじめ取得する
		if( [pNode isKindOfClass:[CCMenu class]] )
		{
			CCNode*	pChildNode	= nil;
			CCARRAY_FOREACH(pNode.children, pChildNode)
			{
				if( [pChildNode isKindOfClass:[SettingItemBtn class]] )
				{
					[mp_useItemNoList addObject:pChildNode];
				}
			}
		}
		else if( [pNode isKindOfClass:[CCLabelTTF class]] )
		{
			CCLabelTTF*	pLabel	= (CCLabelTTF*)pNode;
			if( [pLabel.string isEqualToString:@"moneyNum"] )
			{
				mp_nowMoneyText	= pLabel;
				[mp_nowMoneyText setString:[NSString stringWithFormat:@"%06ld", pSaveData->money]];
			}
			else if( [pLabel.string isEqualToString:@"scoreNum"] )
			{
				mp_nowHiScoreText	= pLabel;
				[mp_nowHiScoreText setString:[NSString stringWithFormat:@"%06lld", pSaveData->score]];
			}
		}
		else if( [pNode isKindOfClass:[SettingGameStartBtn class]] )
		{
			mp_gameStartBtn	= (CCControlButton*)pNode;
			[mp_gameStartBtn setVisible:NO];
		}
	}
}

@end

/*
	@brief	アイテム設定項目ボタン
*/
@implementation SettingItemBtn

@synthesize itemNo	= m_itemNo;

/*
	@brief
*/
-(id)init
{
	if( self = [super init] )
	{
		mp_itemName	= [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:16];
		[mp_itemName setPosition:ccp(225 >> 1, 40 >> 1)];
		[mp_itemName setColor:ccBLACK];
		[self addChild:mp_itemName z:20];
		
		m_itemNo	= 0;
	}
	
	return self;
}

/*
	@brief
*/
-(void)dealloc
{
	mp_itemName	= nil;
	[super dealloc];
}

/*
	@brief
*/
-(void)settingItem:(const NETA_DATA_ST*)in_pData
{
	if( in_pData == nil )
	{
		return;
	}
	
	[mp_itemName setString:[NSString stringWithUTF8String:[[DataBaseText shared] getText:in_pData->textID]]];
	m_itemNo	= in_pData->no;
}

@end

/*
	@brief	ゲームスタート開始ボタン
*/
@implementation SettingGameStartBtn
@end
