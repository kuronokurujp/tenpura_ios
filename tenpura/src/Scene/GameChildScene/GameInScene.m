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
#import "./../../Object/Nabe.h"
#import "./../../Object/ComboMessage.h"
#import	"./../../Object/GameInFeverEvent.h"
#import "./../../Object/DustBoxToTenpura.h"
#import "./../../Object/FeverStatusMenu.h"

#import "./../../Data/DataNetaList.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataBaseText.h"

#import "./../../System/Sound/SoundManager.h"
#import "./../../System/Anim/AnimManager.h"
#import "./../../System/Anim/Action/AnimActionNumCounterLabelTTF.h"

#import "./../../ActionCustomer/ActionCustomer.h"
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

typedef enum
{
	eEAT_STATE_NONE,
	eEAT_STATE_OK	= 1,
	eEAT_STATE_NG,
} eEAT_STATE;

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
		
        m_oldFeverCnt   = 0;
        
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
	if( [pGameScene->mp_scorePut getCountNum] != nowScoreNum )
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
        m_oldFeverCnt   = mp_normalScene.feverCnt;
        
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
    else if( mp_normalScene.feverCnt != m_oldFeverCnt )
    {
        m_oldFeverCnt   = mp_normalScene.feverCnt;
        //  再度フィーバーイベント開始
        [mp_feverScene start:(GameScene*)[self parent]:mp_normalScene];
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

//	コンボタイムカウント
-(void)	_timerComb:(ccTime)in_time;

//	タイムカウント
-(void)	_timer:(ccTime)in_time;

//	客がネタを食べるかどうか
-(eEAT_STATE)	_throwTenpuraToCutomer:(Customer*)in_pCustomer :(TENPURA_STATE_ET)in_tenpuraState :(NETA_DATA_ST*)in_pData;
//	ネタが客とヒットしているか
-(Customer*)	_isHitCustomer:(CGRect)in_rect;
-(void)	_endTouch;

//	コンボ終了
-(void)	_exitCombMessage;
//	コンボ中の更新
-(void)	_updateCombo;

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
@synthesize feverCnt    = m_feverCnt;

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
	@brief	タッチ開始
*/
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint	touchPointView	= [touch locationInView:[touch view]];
	CGPoint	touchPoint	= [[CCDirector sharedDirector] convertToGL:touchPointView];

	GameScene*	pGameScene	= mp_gameScene;
	
	CCNode*	pNode	= nil;

    if( mp_touchTenpura == nil )
	{
		//	後の出した天ぷらを先にチェックする
		SInt32	cnt	= [pGameScene->mp_nabe.children count];
		for( SInt32 i = cnt - 1; 0 <= i; --i )
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
                        
                        //  タッチした時のエフェクト
                        {
                            CCParticleSystemQuad*   pParticle   = [CCParticleSystemQuad particleWithFile:@"touch.plist"];
                            NSAssert(pParticle, @"");
                            pParticle.autoRemoveOnFinish    = YES;
                            [pParticle setPosition:mp_touchTenpura.position];
                            
                            [self addChild:pParticle z:20];
                        }
                        
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

    GameScene*	pGameScene	= mp_gameScene;

	if( mp_touchTenpura != nil )
	{
        BOOL    bDust   = NO;
        //  ゴミ箱にはいっているかチェック
        DustBoxToTenpura*   pDustBoxToTenpura   = pGameScene->mp_dustBoxToTenpura;
        if( (pDustBoxToTenpura != nil ) && (pDustBoxToTenpura.visible == YES) )
        {
            if( CGRectIntersectsRect([pDustBoxToTenpura getColBox], [mp_touchTenpura boundingBox]) )
            {
                //  天ぷらを捨てる
                bDust   = YES;
                
                [mp_touchTenpura unLockTouch];
                [mp_touchTenpura setState:eTENPURA_STATE_RESTART];
                mp_touchTenpura = nil;
            }
        }
        
        if( bDust == NO )
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
		eEAT_STATE	eEatTenpuraState	= eEAT_STATE_NONE;

		pCustomer	= [self _isHitCustomer:[mp_touchTenpura boundingBox]];
		if( pCustomer != nil )
		{
			//	ヒット
			bHitCustomer	= YES;
			//	天ぷらを消して客のアクションを決める
			eEatTenpuraState	= [self _throwTenpuraToCutomer:pCustomer:mp_touchTenpura];
			if( eEatTenpuraState != eEAT_STATE_NONE )
			{
				if( eEatTenpuraState == eEAT_STATE_OK )
				{
					switch ((SInt32)mp_touchTenpura.state)
					{
						case eTENPURA_STATE_VERYGOOD:
						{
                            ++pGameScene->m_eatTenpuraMaxNum;
							++m_veryEatCnt;
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
	
									[self unschedule:@selector(_timerComb:)];
								
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
					
                    BOOL    bNewPutCustomer = NO;
					if( ([self _getPutCustomerNum] <= 1) && ( [pCustomer getEatCnt] <= 0 ) )
					{
                        bNewPutCustomer = YES;
						//	客が一人しかいない状態で退場する時客が新しく出す
					}
					else if( s_PutCustomerCombNum <= m_veryEatCnt )
					{
                        bNewPutCustomer = YES;
					}
                    
                    if( bNewPutCustomer == YES )
                    {
						[pGameScene putCustomer:YES];
                        ++pGameScene->m_putCustomerMaxNum;
                    }
				}
				else
				{
					m_combCnt		= 0;
					m_veryEatCnt	= 0;
				}
			}
			else
			{
				//	食べるのに失敗
				m_combCnt		= 0;
				m_veryEatCnt	= 0;
			}
			
			[pCustomer.act endFlash];
		}

		CGPoint	nowTenpuraPos	= mp_touchTenpura.position;
		if( ( bHitCustomer == YES ) && ( eEatTenpuraState != eEAT_STATE_NONE ) )
		{
			//	食べるのに成功
		}
		else if( CGRectContainsRect([pGameScene->mp_nabe boundingBox], [mp_touchTenpura boundingBox]) )
		{
			//	鍋内なら現在位置に配置
			[mp_touchTenpura unLockTouchByPos:nowTenpuraPos];
		}
		else
		{
			//	タッチ前の位置に設定しているので注意！
			[mp_touchTenpura unLockTouchByAct];
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
			[mp_touchTenpura unLockTouchByPos:mp_touchTenpura.position];
		}
		else
		{
			[mp_touchTenpura unLockTouchByAct];
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
-(eEAT_STATE)	_throwTenpuraToCutomer:(Customer*)in_pCustomer :(Tenpura*)in_pTenpura
{
	if( (in_pTenpura == nil) || in_pCustomer == nil )
	{
		return eEAT_STATE_NONE;
	}
	
	GameScene*	pGameScene	= mp_gameScene;
	if( pGameScene == nil )
	{
		return eEAT_STATE_NONE;
	}

	if( [in_pCustomer getEatCnt] <= 0 )
	{
		return eEAT_STATE_NONE;
	}

	SInt32	addScoreNum	= 0;
	SInt32	addMoneyNum	= 0;
	
	//	客が欲しい天ぷらでなければ客がおこって終了
	if( [in_pCustomer isEatTenpura:in_pTenpura.data.no] == NO )
	{
		[in_pCustomer.act anger:in_pTenpura];
		return	eEAT_STATE_NG;
	}

    //  取得するスコアと金額を設定
	TENPURA_STATE_ET	tenpuraState	= in_pTenpura.state;
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
		addMoneyNum	*= pGameScene->m_feverBonusRate;
		addScoreNum	*= pGameScene->m_feverBonusRate;
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
	
	return eEAT_STATE_OK;
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

		if( CGRectIntersectsRect( in_rect, [pCustomer getBoxRectByTenpuraColision] ) == YES )
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
		//[self unschedule:@selector(_exitCombMessage)];

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
-(void)	_updateEvent:(ccTime)in_dt;

@end

@implementation GameInFeverScene

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
        mp_gameScene    = nil;
        mp_gameInNormalScene    = nil;
        mp_filterColorAction    = nil;
        m_feverTime = 0;
        
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

	[mp_gameScene->mp_fliterColorBG setVisible:YES];
	[mp_gameScene->mp_fliterColorBG setOpacity:255];

	[mp_gameScene->mp_feverEvent start];
    
    //  フィーバー中であれば画面効果を削除
    if( mp_filterColorAction )
    {
        [mp_gameScene->mp_fliterColorBG stopAction:mp_filterColorAction];
    }
    mp_filterColorAction    = nil;

    //  演出と同時にフィーバーボーナス開始
    {
		m_feverTime	+= mp_gameScene->m_feverTime;
        if( mp_gameScene->m_feverBonusRate <= 0.f )
        {
            mp_gameScene->m_feverBonusRate  = mp_gameScene->mp_gameSceneData.feverBonusBaseRate;
        }
        else
        {
            //  まだフィーバー中であればボーナス率を加算
            mp_gameScene->m_feverBonusRate += mp_gameScene->mp_gameSceneData.feverBonusBaseRate - 1.f;
        }
        
		//	ボーナス設定
		{
			[mp_gameScene->mp_nabe setEnableFever:YES];
		}
		
		//	BGフィルターに演出
		{
			[mp_gameScene->mp_fliterColorBG setVisible:YES];
			{
				CCFadeOut*	pFadeOut	= [CCFadeOut actionWithDuration:m_feverTime];
                
				CCCallFunc*	pEndCall	= [CCCallFunc actionWithTarget:self selector:@selector(end)];
				CCSequence*	pRun	= [CCSequence actionOne:pFadeOut two:pEndCall];
                mp_filterColorAction    = [pRun retain];
                
				[mp_gameScene->mp_fliterColorBG runAction:mp_filterColorAction];
			}
		}
	}
    
    //  ステータスを表示
    [mp_gameScene->mp_feverStatusMenu setVisible:YES];

	[self schedule:@selector(_updateEvent:)];	
    
	//	BGM変更
	[[SoundManager shared] playBgm:@"feverBGM"];
}

/*
	@brief	フィーバーイベント
*/
-(void)	_updateEvent:(ccTime)in_dt
{
    m_feverTime -= in_dt;
    if( m_feverTime <= 0.f )
    {
        m_feverTime = 0.f;
    }
    
    CCLabelBMFont*  pBonusRateBMFont    = mp_gameScene->mp_feverStatusMenu.bonusRateBMFont;
    pBonusRateBMFont.string = [NSString stringWithFormat:[DataBaseText getString:301], mp_gameScene->m_feverBonusRate];

    CCLabelBMFont*  pTimeBMFont = mp_gameScene->mp_feverStatusMenu.timerBMFont;
    pTimeBMFont.string  = [NSString stringWithFormat:[DataBaseText getString:302], (SInt32)m_feverTime];
}

/*
	@breif	フィーバー終了
*/
-(void)	end
{
    [self unschedule:@selector(_updateEvent:)];

	[self stopAllActions];
	if( mp_gameScene != nil )
	{
		[mp_gameScene->mp_fliterColorBG stopAllActions];

		//	ボーナスを消す
        mp_gameInNormalScene.bFever	= NO;
		[mp_gameScene->mp_nabe setEnableFever:mp_gameInNormalScene.bFever];

		//	フィーバーの後処理
		[mp_gameScene->mp_feverEvent setVisible:NO];
		[mp_gameScene->mp_fliterColorBG setVisible:NO];
	
		[[SoundManager shared] playBgm:@"playBGM"];
        
        [mp_gameScene->mp_feverStatusMenu setVisible:NO];
        
        mp_gameScene->m_feverBonusRate  = 0.f;
	}
    mp_gameScene    = nil;
    mp_gameInNormalScene    = nil;
    
    m_feverTime = 0;
    mp_filterColorAction    = nil;
}

@end