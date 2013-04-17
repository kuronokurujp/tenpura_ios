//
//  GameScene.m
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"

#import "./GameChildScene/GameStartScene.h"
#import "./GameChildScene/GameInScene.h"
#import "./GameChildScene/GameEndScene.h"

#import "./../ActionCustomer/ActionCustomer.h"
#import "./../Data/DataNetaList.h"
#import "./../Data/DataNetaPackList.h"
#import "./../Data/DataGlobal.h"
#import "./../Data/DataSaveGame.h"
#import "./../Data/DataSettingNetaPack.h"
#import "./../Data/DataTenpuraPosList.h"
#import "./../Data/DataItemList.h"
#import "./../System/Sound/SoundManager.h"
#import "./../System/Anim/Action/AnimActionNumCounterLabelTTF.h"

#import "./../CCBReader/CCBReader.h"

@implementation GameData

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_netaList	= nil;
	}
	
	return self;
}

-(void)	dealloc
{
	if( mp_netaList != nil )
	{
		[mp_netaList release];
	}
	mp_netaList	= nil;
	
	[super dealloc];
}

@end

/*
	@brief
*/
@implementation GameSceneData

@synthesize combDelTime	= combDelTime;

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
	}
	
	return self;
}

@end

//	非公開関数
@interface GameScene (PrivateMethod)

//	ゲームスタート
-(void)	_updateGameStart:(ccTime)delta;

//	ゲーム中
-(void) _updateInGame:(ccTime)delta;

//	リザルト
-(void)	_updateResult:(ccTime)delta;

@end

@implementation GameScene

static const Float32	s_baseTimeVal	= 30.f;

//	各ゲームシーン
enum
{
	eGAME_START_SCENE_TAG	= 0,
	eGAME_IN_SCENE_TAG,
	eGAME_RESULT_SCENE_TAG,
};

/*
	@brief	シーン作成
*/
+(CCScene*)	scene:(GameData*)in_pData
{
	NSAssert( in_pData, @"ゲームデータがない" );
	CCScene*	pScene	= [CCScene node];
	
	CCLayer*	pLayer	= [[[GameScene alloc] init:in_pData] autorelease];
	[pScene addChild:pLayer];
	
	return pScene;
}

/*
	@brief	初期化
*/
-(id)	init:(GameData*)in_pData
{
	if( self = [super init] )
	{
		mp_gameData	= [in_pData retain];

		m_timeVal	= 0.f;
		m_scoreRate	= 1;
		m_moneyRate	= 1;
		m_combAddTime	= 0.f;

		{
			DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];
			[pDataTenpuraPosList clearFlg];
		}

		Float32	customerEatRate	= 1.f;
		Float32	raiseTimeRate	= 1.f;
		
		//	オプションアイテムによる追加設定
		{
			DataItemList*	pItemListInst	= [DataItemList shared];
			CCNode*	pNode	= nil;
			CCARRAY_FOREACH(in_pData->mp_itemNoList, pNode)
			{
				if( [pNode isKindOfClass:[NSNumber class]] )
				{
					NSNumber*	pNumber	= (NSNumber*)pNode;
					//	アイテムNOからオプション設定
					const ITEM_DATA_ST*	pItem	= [pItemListInst getDataSearchId:[pNumber intValue]];
					if( pItem != nil )
					{
						SInt32	num	= sizeof(pItem->aItemDataNo) / sizeof(pItem->aItemDataNo[0]);
						for( SInt32 i = 0; i < num; ++i )
						{
							switch( pItem->aItemDataNo[i] )
							{
								//	金額が２倍
								case eITEM_IMPACT_MONEY_TWO_RATE:
								{
									m_moneyRate *= 2;
									break;
								}
								//	スコアが２倍
								case eITEM_IMPACT_SCORE_TWO_RATE:
								{
									m_scoreRate *= 2;
									break;
								}
								//	揚げる速度が２倍
								case eITEM_IMPACT_RAISE_TIME_HALF:
								{
									raiseTimeRate *= 0.5f;
									break;
								}
								//	コンボタイムに１秒追加
								case eITEM_IMPACT_COMB_ADD_ONE_TIME:
								{
									m_combAddTime	+= 1.f;
									break;
								}
								//	コンボタイムに３秒追加
								case eITEM_IMPACT_COMB_ADD_THREE_TIME:
								{
									m_combAddTime	+= 3.f;
									break;
								}
								//	食べる時間が半分
								case eITEM_IMPACT_EAT_TIME_HALF:
								{
									customerEatRate *= 0.5f;
									break;
								}
								//	食べる時間が3/4
								case eITEM_IMPACT_EAT_TIME_THREE_FOUR:
								{
									customerEatRate	*= (3.f / 4.f);
									break;
								}
							}
						}
					}
				}
			}
		}

		//	なべに配置できるてんぷらリスト作成
		{
			mp_settingItemList	= [[CCArray alloc] init];

			DataNetaPackList*	pDataNetaPackListInst	= [DataNetaPackList shared];
			CCNode*	pNode	= nil;
			CCARRAY_FOREACH(in_pData->mp_netaList, pNode)
			{
				if( [pNode isKindOfClass:[DataSettingNetaPack class]] )
				{
					DataSettingNetaPack*	pDataSettingNetaPack	= (DataSettingNetaPack*)pNode;
					const NETA_PACK_DATA_ST*	pNetaPackData	= [pDataNetaPackListInst getDataSearchId:pDataSettingNetaPack.no];
					for( SInt32 i = 0; i < eNETA_PACK_MAX; ++i )
					{
						if( 0 < pNetaPackData->aNetaId[i] )
						{
							NSNumber*	num	= [NSNumber numberWithInt:pNetaPackData->aNetaId[i]];
							[mp_settingItemList addObject:num];
						}
					}
				}
			}
			
			m_timeVal	= [mp_settingItemList count] * s_baseTimeVal;
		}
		
		CGSize size = [[CCDirector sharedDirector] winSize];

		{
			//	制御するオブジェクトを取得
			CCArray*	pCCLabelTTFArray	= [CCArray array];
			CCNode*	pCCBReader	= [CCBReader nodeGraphFromFile:@"gameIn.ccbi" owner:self parentSize:size];
			CCNode*	pChildNode	= nil;
			CCARRAY_FOREACH(pCCBReader.children, pChildNode)
			{
				//	鍋オブジェクト
				if( [pChildNode isKindOfClass:[Nabe class]] )
				{
					mp_nabe	= (Nabe*)pChildNode;
				}
				//	テキストオブジェクト
				else if( [pChildNode isKindOfClass:[CCLabelTTF class]] )
				{
					CCLabelTTF*	pLabel	= (CCLabelTTF*)pChildNode;

					if( [pLabel.string isEqualToString:@"timeNum"] )
					{
						mp_timerPut	= pLabel;
						[mp_timerPut setString:[NSString stringWithFormat:@"%03ld", (SInt32)m_timeVal]];
					}
					else if( ([pLabel.string isEqualToString:@"scoreNum"]) && ([pLabel isKindOfClass:[AnimActionNumCounterLabelTTF class]]) )
					{
						mp_scorePut	= (AnimActionNumCounterLabelTTF*)pLabel;
						[mp_scorePut setStringFormat:@"%06ld"];
						[mp_scorePut setNum:0];
					}

					[pCCLabelTTFArray addObject:pLabel];
				}
				else if( [pChildNode isKindOfClass:[GameInFeverMessage class]] )
				{
					mp_feverMessage	= (GameInFeverMessage*)pChildNode;
				}
				else if( [pChildNode isKindOfClass:[GameInFliterColorBG class]] )
				{
					mp_fliterColorBG	= (GameInFliterColorBG*)pChildNode;
				}
				else if( [pChildNode isKindOfClass:[GameInFeverEvent class]] )
				{
					mp_feverEvent	= (GameInFeverEvent*)pChildNode;
				}
			}

			[self addChild:pCCBReader];
			mp_gameSceneData	= (GameSceneData*)pCCBReader;
			
			//	オブジェクトの描画プライオリティ修正
			{
				[mp_nabe setZOrder:2.f];
				mp_nabe.setFlyTimeRate	= raiseTimeRate;
				
				CCLabelTTF*	pLabel	= nil;
				CCARRAY_FOREACH(pCCLabelTTFArray, pLabel)
				{
					[pLabel setZOrder:3.f];
				}
				
				[mp_feverMessage setZOrder:19.f];
				[mp_feverEvent setZOrder:20.f];
			}
		}

		//	客
		{
			//	お客の数分配列確保
			SInt32	num	= eCUSTOMER_MAX;

			mp_customerArray	= [[CCArray alloc] initWithCapacity:num];
			for( SInt32 i = 0; i < num; ++i )
			{
				Customer*	pCustomer	= [[[Customer alloc] initToType: i:mp_nabe:mp_settingItemList:customerEatRate] autorelease];
				[pCustomer setPosition:ccp(size.width, ga_initCustomerPos[i][1])];
				[pCustomer setAnchorPoint:ccp(0,0)];
				[pCustomer setVisible:NO];

				[self addChild:pCustomer];
				[mp_customerArray addObject:pCustomer];
			}
		}
	}
	
	return self;
}

/*
	@brief	破棄
*/
-(void)	dealloc
{
	if( mp_gameData != nil )
	{
		[mp_gameData release];
	}
	mp_gameData	= nil;
	
	if( mp_settingItemList != nil )
	{
		[mp_settingItemList release];
	}
	mp_settingItemList	= nil;

	if( mp_customerArray != nil )
	{
		[mp_customerArray release];
	}	
	mp_customerArray	= nil;
	
	[super dealloc];
}

/*
	@brief
*/
-(void)	onEnter
{
	[[SoundManager shared] stopBgm:1.f];
	[super onEnter];
}

/*
	@brief	シーン変異演出終了
*/
-(void)	onEnterTransitionDidFinish
{
	//	ゲームスタート演出
	[self addChild:[GameStartScene node] z:10 tag:eGAME_START_SCENE_TAG];
	[self schedule:@selector(_updateGameStart:)];
}

/*
	@brief	ゲームスタート更新
*/
-(void)	_updateGameStart:(ccTime)delta
{
	//	スタート演出終了
	GameStartScene*	pGameStartScene	= (GameStartScene*)[self getChildByTag:eGAME_START_SCENE_TAG];
	if( pGameStartScene.visible == NO )
	{
		[self removeChildByTag:eGAME_START_SCENE_TAG cleanup:YES];

		[self unschedule:_cmd];
		
		[self addChild:[[[GameInScene alloc] init:m_timeVal:mp_gameSceneData] autorelease] z:10 tag:eGAME_IN_SCENE_TAG];
		[self schedule:@selector(_updateInGame:)];
	}
}

/*
	@brief	ゲーム更新
*/
-(void) _updateInGame:(ccTime)delta
{
	GameInScene*	pGameInScene	= (GameInScene*)[self getChildByTag:eGAME_IN_SCENE_TAG];
	if( pGameInScene.visible == NO )
	{
		[self removeChildByTag:eGAME_IN_SCENE_TAG cleanup:YES];

		[self unschedule:_cmd];
		
		[self addChild:[GameEndScene node] z:10 tag:eGAME_RESULT_SCENE_TAG];
		[self schedule:@selector(_updateResult:)];
	}
}

/*
	@brief	リザルト更新
*/
-(void)	_updateResult:(ccTime)delta
{
	GameEndScene*	pGameEndScene	= (GameEndScene*)[self getChildByTag:eGAME_RESULT_SCENE_TAG];
	if( pGameEndScene.visible == NO )
	{
		[self unschedule:_cmd];
		
		switch ((SInt32)pGameEndScene.resultType)
		{
			case eRESULT_TYPE_RESTART:
			{
				//	再スタート
				CCTransitionFade*	pTransFade	=
				[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:[GameScene scene:mp_gameData] withColor:ccBLACK];
	
				[[CCDirector sharedDirector] replaceScene:pTransFade];

				break;
			}
			case eRESULT_TYPE_SINAGAKI:
			{
				//	品書きに戻る
				CCScene*	sinagakiScene	= [CCBReader sceneWithNodeGraphFromFile:@"setting.ccbi"];

				CCTransitionFade*	pTransFade	=
				[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:sinagakiScene withColor:ccBLACK];
	
				[[CCDirector sharedDirector] replaceScene:pTransFade];
				break;
			}
			default:
			{
				assert(0);
				break;
			}
		}
		
		[self removeChildByTag:eGAME_RESULT_SCENE_TAG cleanup:YES];
	}
}

/*
	@brief	客を一人出す
*/
-(Customer*)	putCustomer:(BOOL)in_bCreateEat
{
	Customer*	pCustomer	= nil;
	UInt32	cnt	= 0;
	CCARRAY_FOREACH( mp_customerArray, pCustomer )
	{
		if( ( pCustomer.visible == NO ) && ( pCustomer.bPut == NO ) )
		{
			//	表示処理をする
			if( in_bCreateEat == YES )
			{
				TYPE_ENUM	type	= eTYPE_MAN;
				GameInScene*	pGameInScene	= (GameInScene*)[self getChildByTag:eGAME_IN_SCENE_TAG];
				if( pGameInScene != NULL )
				{
					if( [pGameInScene isFever] == YES )
					{
						if( m_timeVal <= mp_gameSceneData.customerMoneyPutTime )
						{
							int		num = rand() % 10;
							if( num <= 7 )
							{
								type	= eTYPE_MONEY;
							}
							else
							{
								type	= rand() % 2;
							}
						}
						else
						{
							type	= rand() % eTYPE_MAX;
						}
					}
					else
					{
						if( m_timeVal <= mp_gameSceneData.customerMoneyPutTime )
						{
							type	= rand() % eTYPE_MAX;
						}
						else
						{
							int	randNum	= rand() % 2;
							if( randNum == 0 )
							{
								type	= eTYPE_MAN;
							}
							else
							{
								type	= eTYPE_WOMAN;
							}
						}
					}

					[pCustomer setType:type];
					[pCustomer.act putEat];
				}
			}
			else
			{
				[pCustomer.act putResult];
			}

			break;
		}
		
		++cnt;
	}
	
	return pCustomer;
}

/*
	@breif	客を一人退場
*/
-(void)	exitCustomer:(Customer*)in_pCustomer
{
	if( in_pCustomer == nil )
	{
		return;
	}
	
	[in_pCustomer.act exit];
}

/*
	@brief	オブジェクトのポーズ
*/
-(void)	pauseObject:(BOOL)in_bFlg
{
	if( in_bFlg == YES )
	{
		[mp_nabe pauseSchedulerAndActions];
	}
	else
	{
		[mp_nabe resumeSchedulerAndActions];
	}
	
	CCNode*	pCustomer	= nil;
	CCARRAY_FOREACH(mp_customerArray, pCustomer)
	{
		if( in_bFlg == YES )
		{
			[pCustomer pauseSchedulerAndActions];
		}
		else
		{
			[pCustomer resumeSchedulerAndActions];
		}
	}
}

/*
	@brief	スコア取得
*/
-(int64_t)	getScore
{
	int64_t	score	= 0;
	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH(mp_customerArray, pCustomer)
	{
		score += pCustomer.score;
	}
	
	return score;
}

/*
	@brief	金額取得
*/
-(int64_t)	getMoney
{
	int64_t	money	= 0;
	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH(mp_customerArray, pCustomer)
	{
		money += pCustomer.money;
	}
	
	return money;
}

@end