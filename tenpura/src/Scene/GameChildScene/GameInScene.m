//
//  GameInScene.m
//  tenpura
//
//  Created by y.uchida on 12/10/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameInScene.h"

#import "./../GameScene.h"
#import "./../../Object/Customer.h"
#import "./../../Object/Tenpura.h"
#import "./../../Object/OjamaTenpura.h"
#import "./../../Object/Nabe.h"
#import "./../../Object/ComboMessage.h"
#import	"./../../Object/GameInFeverEvent.h"
#import "./../../ActionCustomer/ActionCustomer.h"
#import "./../../Data/DataNetaList.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../System/Sound/SoundManager.h"
#import "./../../System/Anim/AnimManager.h"
#import "./../../System/Anim/Action/AnimActionNumCounterLabelTTF.h"
#import "./../../CCBReader/CCBReader.h"

//	非公開関数
@interface GameInScene (PrivateMethod)

-(void)	_begin:(ccTime)in_time;
-(void)	_updateNormal:(ccTime)in_time;
-(void)	_updateFever:(ccTime)in_time;
-(void)	_end:(ccTime)in_time;

@end

@implementation GameInScene

static const SInt32	s_AddCustomerEatMax	= 1;
static const UInt32	s_PutCustomerCombNum	= 3;

//	レイヤータグ
enum
{
	eCHILD_TAG_SCENE_NORMAL	= 5,
	eCHILD_TAG_SCENE_FEVER,
};

/*
	@brief
*/
-(id)	init:(Float32)in_time :(GameSceneData*)in_pGameSceneData
{
	if( self = [super init] )
	{
		NSAssert(in_pGameSceneData, @"ゲームシーンデータがない");
		
		[self setVisible:YES];
		[self schedule:@selector(_begin:)];
		
		[[SoundManager shared] playBgm:@"playBGM"];
		
		mp_normalScene	= [[[GameInNormalScene alloc] init:in_time] autorelease];
		mp_feverScene	= [GameInFeverScene node];
		[self addChild:mp_normalScene z:1 tag:eCHILD_TAG_SCENE_NORMAL];
		[self addChild:mp_feverScene z:2 tag:eCHILD_TAG_SCENE_FEVER];
		
		[self setTouchEnabled:false];
	}
	
	return self;
}

/*
	@brief
*/
-(BOOL)	isFever
{
	if( mp_normalScene != NULL )
	{
		return	mp_normalScene.bFever;
	}
	
	return NO;
}

/*
	@brief	開始
*/
-(void)	_begin:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)[self parent];

	//	食べたいものを並べる
	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH( pGameScene->mp_customerArray, pCustomer)
	{
		if( ( pCustomer.visible == YES ) && ( pCustomer.bPut == YES ) )
		{
			[pCustomer createEatList];
		}
	}
	
	//	開始
	[mp_normalScene start:pGameScene];
	
	[self unschedule:_cmd];
	[self scheduleUpdate];
	[self schedule:@selector(_updateNormal:)];
}

/*
	@brief	更新
*/
-(void)	update:(ccTime)delta
{
	GameScene*	pGameScene	= (GameScene*)[self parent];

	[pGameScene->mp_timerPut setString:[NSString stringWithFormat:@"%03ld", (SInt32)mp_normalScene.time]];
	if( mp_normalScene.time <= 0.f )
	{
		[self unscheduleUpdate];
		[self schedule:@selector(_end:)];
	}
	
	int64_t	nowScoreNum	= [pGameScene getScore];
	if( pGameScene->mp_scorePut.countNum != nowScoreNum )
	{
		[pGameScene->mp_scorePut setCountNum:nowScoreNum];
	}
}

/*
	@brief	通常更新
*/
-(void)	_updateNormal:(ccTime)in_time
{
	//	フィーバー状態になったら、フィーバ更新へ以降
	if( mp_normalScene.bFever == YES )
	{
		[self unschedule:_cmd];
		[mp_feverScene start:(GameScene*)[self parent]:mp_normalScene];
		[self schedule:@selector(_updateFever:)];
	}
}

/*
	@brief	フィーバー更新
*/
-(void)	_updateFever:(ccTime)in_time
{
	if( mp_normalScene.bFever == NO )
	{
		[self unschedule:_cmd];
		[self schedule:@selector(_updateNormal:)];
	}
}

/*
	@brief	終了
*/
-(void)	_end:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)[self parent];
	//	客の後始末
	{
		Customer*	pCustomer	= nil;
		CCARRAY_FOREACH( pGameScene->mp_customerArray, pCustomer )
		{
			[pCustomer stopAllActions];
		}
	}

	//	フィーバーの後処理
	[mp_feverScene end];

	[self unschedule:_cmd];
	[self setVisible:NO];
}

/*
	@brief
*/
-(void)	onEnter
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

/*
	@brief
*/
-(void)	onExit
{
	[[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
	[super onExit];
}

/*
	@brief	タッチ開始
*/
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[CCLayer class]] )
		{
			if( [mp_normalScene isTouchEnabled]== YES )
			{
				if( [mp_normalScene ccTouchBegan:touch withEvent:event] == YES )
				{
				}
			}
		}
	}

	return YES;
}

/*
	@brief	タッチしながら指を動かす
*/
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[CCLayer class]] )
		{
			if( [mp_normalScene isTouchEnabled] == YES )
			{
				[mp_normalScene ccTouchMoved:touch withEvent:event];
			}
		}
	}
}

/*
	@brief	タッチ離す
*/
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[CCLayer class]] )
		{
			if( [mp_normalScene isTouchEnabled] == YES )
			{
				[mp_normalScene ccTouchEnded:touch withEvent:event];
			}
		}
	}
}

/*
	@brief	タッチ中止
*/
-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		if( [pNode isKindOfClass:[CCLayer class]] )
		{
			if( [mp_normalScene isTouchEnabled] == YES )
			{
				[mp_normalScene ccTouchCancelled:touch withEvent:event];
			}
		}
	}
}

@end

@interface GameInNormalScene (PriveteMethod)

//	おじゃま処理
-(void)	onStartOjama:(NSNotification*)in_pCenter;

//	コンボタイムカウント
-(void)	_timerComb:(ccTime)in_time;

//	タイムカウント
-(void)	_timer:(ccTime)in_time;

//	客がネタを食べるかどうか
-(BOOL)	_throwTenpuraToCutomer:(Customer*)in_pCustomer :(TENPURA_STATE_ET)in_tenpuraState :(NETA_DATA_ST*)in_pData;
//	ネタが客とヒットしているか
-(Customer*)	_isHitCustomer:(CGRect)in_rect;
-(void)	_endTouch;

//	コンボ終了
-(void)	_exitCombMessage;
//	コンボ中の更新
-(void)	_updateCombo;

//	おじゃま開始を監視
-(void)	_chkSwitchOnOjama;

//	登場している客の個数を取得
-(UInt32)	_getPutCustomerNum;

@end

@implementation GameInNormalScene

enum
{
	eNORMAL_SCENE_CHILD_TAG_COMBO_MESSAGE	= 10,
};

@synthesize time	= m_time;
@synthesize bFever	= mb_fever;

/*
	@brief
*/
-(id)	init:(Float32)in_time
{
	if( self = [super init] )
	{
		mp_gameScene	= nil;
		mp_touchTenpura	= nil;
		m_time	= in_time;
		m_combCnt	= 0;
		m_veryEatCnt	= 0;
		m_feverCnt	= 0;
		mb_fever	= NO;

		//	コンボ新規追加
		CCNode*	pComboMessage	= [CCBReader nodeGraphFromFile:@"comboMessage.ccbi"];
		[pComboMessage setVisible:NO];

		[self addChild:pComboMessage z:10 tag:eNORMAL_SCENE_CHILD_TAG_COMBO_MESSAGE];
		
		[self setTouchEnabled:YES];
		
		//	おじゃま呼び出し
		{
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc addObserver:self selector:@selector(onStartOjama:) name:[NSString stringWithUTF8String:gp_startOjamaObserverName] object:nil];
		}
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	[super dealloc];
	
	//	オブサーバーを消す
	{
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self];
	}
}

/*
	@brief	開始
*/
-(void)	start:(GameScene*)in_pGameScene
{
	mp_gameScene	= in_pGameScene;

	//	おじゃま発動チェック
	[self schedule:@selector(_chkSwitchOnOjama)];

	[self scheduleUpdate];
	[self schedule:@selector(_timer:) interval:1.f];
}

/*
	@brief	更新
*/
-(void)	update:(ccTime)delta
{
	GameScene*	pGameScene	= mp_gameScene;
	Customer*	pCustomer	= nil;
	SInt32	notVisibleCntCustomer	= 0;
	CCARRAY_FOREACH(pGameScene->mp_customerArray, pCustomer)
	{
		if( pCustomer.visible == NO )
		{
			++notVisibleCntCustomer;
		}
	}
	
	if( pGameScene->mp_customerArray.count <= notVisibleCntCustomer )
	{
		//	一人も客がいない状態
		[pGameScene putCustomer:YES];
	}
}

/*
	@brief	ポーズ
*/
-(void)	pauseSchedulerAndActions
{
	[super pauseSchedulerAndActions];
	[self setTouchEnabled:NO];
	
	[mp_gameScene pauseObject:YES];
}

/*
	@brief	再開
*/
-(void)	resumeSchedulerAndActions
{
	[super resumeSchedulerAndActions];
	[self setTouchEnabled:YES];
	
	[mp_gameScene pauseObject:NO];
}

/*
	@brief	おじゃま処理
*/
-(void)	onStartOjama:(NSNotification*)in_pCenter
{
	if( in_pCenter == nil )
	{
		return;
	}

	NSValue*	pData	= [[in_pCenter userInfo] objectForKey:[NSString stringWithUTF8String:gp_startOjamaDataName]];
	if( pData != nil )
	{
		GameScene*	pGameScene	= mp_gameScene;

		OJAMA_NETA_DATA	data;
		[pData getValue:&data];
		//	おじゃま処理をする
		Customer*	pCustomer	= nil;
		BOOL	bRunPutActCustomer	= NO;
		SInt32	cntPutCustomer	= 0;
		CCARRAY_FOREACH(pGameScene->mp_customerArray, pCustomer)
		{
			if( pCustomer.bPut )
			{
				[pCustomer removeAllEatIcon];
				[pCustomer.act exit];
				
				++cntPutCustomer;
			}
			else if( [pCustomer.act isRunPutAct] )
			{
				bRunPutActCustomer	= YES;
			}
		}
		
		if( (bRunPutActCustomer == NO) && (cntPutCustomer < pGameScene->mp_customerArray.count) )
		{
			//	客が一人もいない状態になるのをふせぐために客を一人出す
			[pGameScene putCustomer:YES];
		}
		
		//	配置した天ぷらをすべてクリア
		[pGameScene->mp_nabe allCleanTenpura];
	}
}

/*
	@brief	タッチ開始
*/
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint	touchPointView	= [touch locationInView:[touch view]];
	CGPoint	touchPoint	= [[CCDirector sharedDirector] convertToGL:touchPointView];

	GameScene*	pGameScene	= mp_gameScene;
	
	CCNode*	pNode	= nil;
	OjamaTenpura*	pRemoveOjamaTenpura	= nil;
	//	おじゃま天ぷらのヒットを優先
	CCARRAY_FOREACH(pGameScene->mp_nabe.children, pNode)
	{
		if( [pNode isKindOfClass:[OjamaTenpura class]] )
		{
			OjamaTenpura*	pOjamaTenpura	= (OjamaTenpura*)pNode;
			if( ([pOjamaTenpura isTouchOK]) && (CGRectContainsPoint([pOjamaTenpura boundingBox], touchPoint)) )
			{
				pRemoveOjamaTenpura	= pOjamaTenpura;
				break;
			}
		}
	}

	if( pRemoveOjamaTenpura )
	{
		//	消滅方法は仮
		[pRemoveOjamaTenpura runTouchDelAction];
	}
	else if( mp_touchTenpura == nil )
	{
		//	後の出した天ぷらを先にチェックする
		SInt32	cnt	= [pGameScene->mp_nabe.children count];
		for( SInt32 i = cnt - 1; i >= 0; --i )
		{
			pNode	= [pGameScene->mp_nabe.children objectAtIndex:i];
			if( ([pNode isKindOfClass:[Tenpura class]] == YES) && (pNode.visible == YES) )
			{
				Tenpura*	pTenpura	= (Tenpura*)pNode;
				if( [pTenpura isTouchOK] )
				{
					if( CGRectContainsPoint([pTenpura boundingBox], touchPoint) == YES )
					{
						[pTenpura lockTouch];
						mp_touchTenpura	= pTenpura;
						break;
					}
				}
			}
		}
	}
	
	return YES;
}

/*
	@brief	タッチしながら指を動かす
*/
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint	touchPointView	= [touch locationInView:[touch view]];
	CGPoint	touchPoint	= [[CCDirector sharedDirector] convertToGL:touchPointView];

	if( mp_touchTenpura != nil )
	{
		[mp_touchTenpura setPosition:touchPoint];
		Customer*	pTenpuraHitCustomer	= [self _isHitCustomer:[mp_touchTenpura boundingBox]];
		if( pTenpuraHitCustomer != nil )
		{
			//	ヒットした場合ヒットしていると表示する。
			[pTenpuraHitCustomer.act loopFlash];
		}

		//	天ぷらとヒットしていない客はヒット演出を止める
		Customer*	pCustomer	= nil;
		GameScene*	pGameScene	= mp_gameScene;
		CCARRAY_FOREACH(pGameScene->mp_customerArray,pCustomer)
		{
			if( pCustomer != pTenpuraHitCustomer )
			{
				[pCustomer.act endFlash];
			}
		}
	}
}

/*
	@brief	タッチ離す
*/
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	Customer*	pCustomer	= nil;
	GameScene*	pGameScene	= mp_gameScene;
	if( mp_touchTenpura != nil )
	{
		//	客にヒットしているか
		BOOL	bHitCustomer	= NO;
		BOOL	bEatTenpura		= NO;

		pCustomer	= [self _isHitCustomer:[mp_touchTenpura boundingBox]];
		if( pCustomer != nil )
		{
			//	ヒット
			bHitCustomer	= YES;
			//	天ぷらを消して客のアクションを決める
			bEatTenpura	= [self _throwTenpuraToCutomer:pCustomer:mp_touchTenpura];
			if( bEatTenpura == YES )
			{
				switch ((SInt32)mp_touchTenpura.state)
				{
					case eTENPURA_STATE_VERYGOOD:
					{
						++m_veryEatCnt;
						if( mp_touchTenpura.state == eTENPURA_STATE_VERYGOOD )
						{
							++m_combCnt;

							//	コンボメッセージを出す
							{
								CCNode*	pComboMessage	= [self getChildByTag:eNORMAL_SCENE_CHILD_TAG_COMBO_MESSAGE];
								//	コンボ数値変更
								if( 2 <= m_combCnt )
								{
									ComboMessage*	pCombo	= (ComboMessage*)pComboMessage;
									[pCombo start:m_combCnt];
								}

								[self unschedule:@selector(_updateCombo)];
								[self schedule:@selector(_updateCombo)];
	
								[self unschedule:@selector(_exitCombMessage)];
								[self unschedule:@selector(_timerComb:)];
								
								[self scheduleOnce:@selector(_exitCombMessage) delay:pGameScene->mp_gameSceneData.combMessageTime];
								[self scheduleOnce:@selector(_timerComb:) delay:pGameScene->mp_gameSceneData.combDelTime + pGameScene->m_combAddTime];
							}

							//	フィーバーを出すか
							if( ( m_combCnt % 10 ) == 0 )
							{
								++m_feverCnt;
								mb_fever	= YES;
							}
						}
						break;
					}
					default:
					{
						m_combCnt	= 0;
						m_veryEatCnt	= 0;
						break;
					}
				}

				if( ([self _getPutCustomerNum] <= 1) && ( [pCustomer getEatCnt] <= 0 ) )
				{
					//	客が一人しかいない状態で退場する時客が新しく出す
					[pGameScene putCustomer:YES];
				}
				else if( s_PutCustomerCombNum <= m_veryEatCnt )
				{
					[pGameScene putCustomer:YES];
				}
			}
			else
			{
				//	食べるのに失敗
				m_combCnt	= 0;
				m_veryEatCnt	= 0;
			}
			
			[pCustomer.act endFlash];
		}

		CGPoint	nowTenpuraPos	= mp_touchTenpura.position;
		if( ( bHitCustomer == YES ) && ( bEatTenpura == YES ) )
		{
			//	食べるのに成功
		}
		else if( CGRectContainsRect([pGameScene->mp_nabe boundingBox], [mp_touchTenpura boundingBox]) )
		{
			//	鍋内なら現在位置に配置
			[mp_touchTenpura unLockTouch:nowTenpuraPos];
		}
		else
		{
			//	タッチ前の位置に設定しているので注意！
			[mp_touchTenpura unLockTouchAct];
		}

		mp_touchTenpura	= nil;
	}

	[self _endTouch];
}

/*
	@brief	タッチ中止
*/
-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( mp_touchTenpura != nil )
	{
		GameScene*	pGameScene	= mp_gameScene;
		if( CGRectContainsRect([pGameScene->mp_nabe boundingBox], [mp_touchTenpura boundingBox]) )
		{
			//	鍋内なら現在位置に配置
			[mp_touchTenpura unLockTouch:mp_touchTenpura.position];
		}
		else
		{
			[mp_touchTenpura unLockTouchAct];
		}

		mp_touchTenpura	= nil;
	}
	
	[self _endTouch];
}

/*
	@brief	コンボタイムカウント
*/
-(void)	_timerComb:(ccTime)in_time
{
	m_combCnt	= 0;
}

/*
	@brief	タイムカウント
*/
-(void)	_timer:(ccTime)in_time
{
	//	時間がなくなったらゲーム終了
	m_time	-= 1.f;
	if( m_time <= 0.f )
	{
		m_time	= 0.f;
		[self unschedule:_cmd];
	}
}

/*
	@brief	客が食べる
	@return	食べたかどうか
	@note	取得スコア/金額の反映させる
*/
-(BOOL)	_throwTenpuraToCutomer:(Customer*)in_pCustomer :(Tenpura*)in_pTenpura
{
	if( (in_pTenpura == nil) || in_pCustomer == nil )
	{
		return NO;
	}
	
	GameScene*	pGameScene	= mp_gameScene;
	if( pGameScene == nil )
	{
		return NO;
	}

	if( [in_pCustomer getEatCnt] <= 0 )
	{
		return NO;
	}

	SInt32	addScoreNum	= 0;
	SInt32	addMoneyNum	= 0;
	
	BOOL	bEat		= NO;
	
	//	客が欲しい天ぷらでなければ客がおこって終了
	if( [in_pCustomer isEatTenpura:in_pTenpura.data.no] == NO )
	{
		[in_pCustomer.act anger];
		return	bEat;
	}

	TENPURA_STATE_ET	tenpuraState	= in_pTenpura.state;
	bEat	= YES;
	addScoreNum	= in_pTenpura.data.aStatusList[tenpuraState].score;
	addMoneyNum	= in_pTenpura.data.aStatusList[tenpuraState].money;
	
	if( addMoneyNum > 0 )
	{
		addMoneyNum	*=	pGameScene->m_moneyRate;
	}
	
	if( addScoreNum > 0 )
	{
		addScoreNum	*=	pGameScene->m_scoreRate;
	}

	if( mb_fever == YES )
	{
		addMoneyNum	*= 2;
		addScoreNum	*= 2;
	}

	{
		//	食べたい天ぷらがあるかチェック
		switch( (SInt32)tenpuraState )
		{
			default:
			{
				assert(0);
				break;
			}
			case eTENPURA_STATE_VERYGOOD:
			{
				[in_pCustomer.act eatVeryGood:in_pTenpura:addScoreNum:addMoneyNum];
			
				break;
			}
			//	焦げ
			case eTENPURA_STATE_BAD:
			{
				[in_pCustomer.act eatBat:in_pTenpura:addScoreNum:addMoneyNum];
				
				break;
			}
			//	丸焦げ
			case eTENPURA_STATE_VERYBAD:
			{
				[in_pCustomer.act eatVeryBat:in_pTenpura:addScoreNum:addMoneyNum];
				break;
			}
		}
	}

	//	スコア反映
	in_pCustomer.addScore	= addScoreNum;
	
	//	取得金額反映
	in_pCustomer.addMoney	= addMoneyNum;
	
	return bEat;
}

/*
	@brief	おじゃま発動の監視
*/
-(void)	_chkSwitchOnOjama
{
	//	指定したスコア数を超えたら開始（一度のみ）
	GameScene*	pGameScene	= mp_gameScene;
	const SAVE_DATA_ST*	pSaveData	= [[DataSaveGame shared] getData];
	if( (pSaveData->score != 0) && (pSaveData->score <= [pGameScene getScore]) )
	{
		//	おじゃま開始
		//	なべにおじゃまを出すように指示
		[pGameScene->mp_nabe putOjamaTenpura];

		[self unschedule:_cmd];
	}
}

/*
	@brief	客とのヒット判定
*/
-(Customer*)	_isHitCustomer:(CGRect)in_rect
{
	GameScene*	pGameScene	= mp_gameScene;
	if( pGameScene == nil )
	{
		return NO;
	}

	Customer*	pCustomer	= nil;
	Customer*	pNewCutomer	= nil;
	CCARRAY_FOREACH(pGameScene->mp_customerArray,pCustomer)
	{
		if( ( pCustomer.visible == NO ) || ( pCustomer.bPut == NO ) )
		{
			continue;
		}

		if( CGRectIntersectsRect( in_rect, [pCustomer getBoxRect] ) == YES )
		{
			if( pNewCutomer != nil )
			{
				//	天ぷらとの距離が短い場合のを対象に
				Float32	dis	= ccpDistanceSQ( in_rect.origin, pCustomer.position );
				Float32	dis2	= ccpDistanceSQ( in_rect.origin, pNewCutomer.position );
				if( dis < dis2 )
				{
					pNewCutomer	= pCustomer;
				}
			}
			else
			{
				pNewCutomer	= pCustomer;
			}
		}
	}
	
	return pNewCutomer;
}

/*
	@brief	タッチ処理終了
*/
-(void)	_endTouch
{
	GameScene*	pGameScene	= mp_gameScene;

	//	ヒットしたときの演出を終了
	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH(pGameScene->mp_customerArray,pCustomer)
	{
		[pCustomer.act endFlash];
	}
}

/*
	@brief	コンボ時間チェック
*/
-(void)	_exitCombMessage
{
	CCNode*	pComboMessage	= [self getChildByTag:eNORMAL_SCENE_CHILD_TAG_COMBO_MESSAGE];
	if( ( pComboMessage != nil ) && ( [pComboMessage isKindOfClass:[ComboMessage class]] ) )
	{
		ComboMessage*	pCombo	= (ComboMessage*)pComboMessage;
		[pCombo end];
	}
	else
	{
		NSAssert(0, @"コンボメッセージオブジェクトがない");
	}
}

/*
	@brief	コンボメッセージ更新
*/
-(void)	_updateCombo
{
	if( m_combCnt <= 0 )
	{
		[self unschedule:_cmd];
		[self unschedule:@selector(_exitCombMessage)];

		CCNode*	pComboMessage	= [self getChildByTag:eNORMAL_SCENE_CHILD_TAG_COMBO_MESSAGE];
		ComboMessage*	pCombo	= (ComboMessage*)pComboMessage;
		[pCombo end];
	}
}

/*
	@brief	登場している客の個数を取得
*/
-(UInt32)	_getPutCustomerNum
{
	GameScene*	pGameScene	= mp_gameScene;

	UInt32	cnt	= 0;
	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH(pGameScene->mp_customerArray, pCustomer)
	{
		if( pCustomer.bPut == YES )
		{
			++cnt;
		}
	}
	
	return cnt;
}

@end

/*
	@brief	ゲーム中のフィーバ-シーン
*/
@interface GameInFeverScene (PriveteMethod)

//	フィーバー開始イベント
-(void)	_updateEvent;

@end

@implementation GameInFeverScene

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		[self setTouchEnabled:NO];
	}
	
	return self;
}

/*
	@brief	開始
*/
-(void)	start:(GameScene*)in_pGameScene :(GameInNormalScene*)in_pGameInNormalScene
{
	mp_gameScene	= in_pGameScene;
	mp_gameInNormalScene	= in_pGameInNormalScene;

	//	停止
	{
		[in_pGameInNormalScene pauseSchedulerAndActions];
	}

	[mp_gameScene->mp_fliterColorBG setVisible:YES];
	[mp_gameScene->mp_fliterColorBG setOpacity:255];

	[mp_gameScene->mp_feverEvent start];
	[self schedule:@selector(_updateEvent)];
	
	//	BGM変更
	[[SoundManager shared] playBgm:@"feverBGM"];
}

/*
	@brief	フィーバーイベント
*/
-(void)	_updateEvent
{
	if( mp_gameScene->mp_feverEvent.visible == NO )
	{
		Float32	feverTime	= mp_gameScene->m_feverTime;
		
		[self unschedule:_cmd];

		//	再開
		{
			[mp_gameInNormalScene resumeSchedulerAndActions];
		}
		
		//	ボーナス設定
		{
			[mp_gameScene->mp_nabe setEnableFever:YES];
		}
		
		//	フィーバーメッセージを出す
		[mp_gameScene->mp_feverMessage setVisible:YES];
		//	BGフィルターに演出
		{
			[mp_gameScene->mp_fliterColorBG setVisible:YES];
			{
				CCFadeOut*	pFadeOut	= [CCFadeOut actionWithDuration:feverTime];

				CCCallFunc*	pEndCall	= [CCCallFunc actionWithTarget:self selector:@selector(end)];
				CCSequence*	pRun	= [CCSequence actionOne:pFadeOut two:pEndCall];

				[mp_gameScene->mp_fliterColorBG runAction:pRun];
			}
		}
	}
}

/*
	@breif	フィーバー終了
*/
-(void)	end
{
	[self stopAllActions];
	if( mp_gameScene != nil )
	{
		[mp_gameScene->mp_fliterColorBG stopAllActions];

		//	ボーナスを消す
		[mp_gameScene->mp_nabe setEnableFever:NO];
		mp_gameInNormalScene.bFever	= NO;

		//	フィーバーの後処理
		[mp_gameScene->mp_feverMessage setVisible:NO];
		[mp_gameScene->mp_feverEvent setVisible:NO];
		[mp_gameScene->mp_fliterColorBG setVisible:NO];
	
		[[SoundManager shared] playBgm:@"playBGM"];
	}
}

@end