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
#import "./../../ActionCustomer/ActionCustomer.h"
#import "./../../Data/DataNetaList.h"
#import "./../../Data/DataGlobal.h"
#import "./../../System/Sound/SoundManager.h"
#import "./../../System/Effect/EffectManager.h"

//	非公開関数
@interface GameInScene (PrivateMethod)

-(void)	_begin:(ccTime)in_time;
-(void)	_end:(ccTime)in_time;

-(void)	_timer:(ccTime)in_time;

-(BOOL)	_eatCustomer:(Customer*)in_pCustomer:(TENPURA_STATE_ET)in_tenpuraState:(NETA_DATA_ST*)in_pData;
-(Customer*)	_isHitCustomer:(CGRect)in_rect;
-(void)	_endTouch;

//	スコア設定
-(void)	_setScore:(Customer*)in_pCustomer:(SInt32)in_num;
//	金額設定
-(void)	_setMoney:(Customer*)in_pCustomer:(SInt32)in_num;

@end

@implementation GameInScene

static const SInt32	s_AddCustomerEatMax	= 1;
static const UInt32	s_PutCustomerCombNum	= 3;

/*
	@brief
*/
-(id)	init:(Float32)in_time;
{
	if( self = [super init] )
	{
		mp_touchTenpura	= nil;
		m_time	= in_time;
		m_combCnt	= 0;

		[self setVisible:YES];
		[self schedule:@selector(_begin:)];
	}
	
	return self;
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
	
	[self unschedule:_cmd];
	[self schedule:@selector(_timer:) interval:1.f];
	[self scheduleUpdate];
}

/*
	@brief	更新
*/
-(void)	update:(ccTime)delta
{
	GameScene*	pGameScene	= (GameScene*)[self parent];

	[pGameScene->mp_timerPut setString:[NSString stringWithFormat:@"%03ld", (SInt32)m_time]];
	if( m_time <= 0.f )
	{
		[self unscheduleUpdate];
		[self schedule:@selector(_end:)];
	}

	[pGameScene->mp_scorePut setString:[NSString stringWithFormat:@"%06lld", pGameScene->m_scoreNum]];
}

/*
	@brief
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
	@brief
*/
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint	touchPointView	= [touch locationInView:[touch view]];
	CGPoint	touchPoint	= [[CCDirector sharedDirector] convertToGL:touchPointView];

	GameScene*	pGameScene	= (GameScene*)[self parent];
	CCNode*	pNode	= nil;
	if( mp_touchTenpura == nil )
	{
		//	後の出した天ぷらを先にチェックする
		SInt32	cnt	= [pGameScene->mp_nabe.children count];
		for( SInt32 i = cnt - 1; i >= 0; --i )
		{
			pNode	= [pGameScene->mp_nabe.children objectAtIndex:i];
			if( ([pNode isKindOfClass:[Tenpura class]] == YES) && (pNode.visible == YES) )
			{
				Tenpura*	pTenpura	= (Tenpura*)pNode;
				if( (pTenpura.bTouch == NO) && (pTenpura.bRaise == YES) )
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
		GameScene*	pGameScene	= (GameScene*)[self parent];
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
	GameScene*	pGameScene	= (GameScene*)[self parent];
	if( mp_touchTenpura != nil )
	{
		//	客にヒットしているか
		BOOL	bHitCustomer	= NO;
		BOOL	bEatTenpura		= NO;

		pCustomer	= [self _isHitCustomer:[mp_touchTenpura boundingBox]];
		if( pCustomer != nil )
		{
			NETA_DATA_ST	data	= mp_touchTenpura.data;

			//	ヒット
			bHitCustomer	= YES;
			//	天ぷらを消して客のアクションを決める
			bEatTenpura	= [self _eatCustomer:pCustomer:mp_touchTenpura.state:&data];
			if( bEatTenpura == YES )
			{
				switch ((SInt32)mp_touchTenpura.state)
				{
					case eTENPURA_STATE_GOOD:
					case eTENPURA_STATE_VERYGOOD:
					{
						++m_combCnt;
						break;
					}
					default:
					{
						m_combCnt	= 0;
						break;
					}
				}

				if( ([pGameScene getPutCustomerNum] <= 1) && ( [pCustomer getEatCnt] <= 0 ) )
				{
					//	客が一人しかいない状態で退場する時客が新しく出す
					[pGameScene putCustomer:YES];
				}
				else if( s_PutCustomerCombNum <= m_combCnt )
				{
					[pGameScene putCustomer:YES];
					m_combCnt	= 0;
				}
			}
			else
			{
				//	食べるのに失敗
				m_combCnt	= 0;
			}
			
			[pCustomer.act endFlash];
		}

		BOOL	bRemoveTenpura		= NO;
		BOOL	bNewPostionTenpura	= NO;
		CGPoint	nowTenpuraPos	= mp_touchTenpura.position;
		if( ( bHitCustomer == YES ) && ( bEatTenpura == YES ) )
		{
			//	食べるのに成功
			bRemoveTenpura	= YES;
		}
		else if( CGRectContainsRect([pGameScene->mp_nabe boundingBox], [mp_touchTenpura boundingBox]) )
		{
			//	鍋内なら現在位置に配置
			bNewPostionTenpura	= YES;
		}

		//	タッチ前の位置に設定しているので注意！
		[mp_touchTenpura unLockTouch];

		if( bRemoveTenpura == YES )
		{
			[pGameScene->mp_nabe removeTenpura:mp_touchTenpura];
		}
		else if( bNewPostionTenpura == YES )
		{
			//	鍋枠内であれば現在を位置に変更
			[mp_touchTenpura setPosition:nowTenpuraPos];
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
		[mp_touchTenpura unLockTouch];
		mp_touchTenpura	= nil;
	}
	
	[self _endTouch];
}

/*
	@brief	客が食べる
	@return	食べたかどうか
	@note	取得スコア/金額の反映させる
*/
-(BOOL)	_eatCustomer:(Customer*)in_pCustomer:(TENPURA_STATE_ET)in_tenpuraState:(NETA_DATA_ST*)in_pData
{
	if( (in_pData == nil) || in_pCustomer == nil )
	{
		return NO;
	}
	
	GameScene*	pGameScene	= (GameScene*)[self parent];
	if( pGameScene == nil )
	{
		return NO;
	}

	SInt32	addScoreNum	= 0;
	SInt32	addMoneyNum	= 0;
	
	BOOL	bEat		= NO;
	
	//	客が欲しい天ぷらでなければ客がおこって終了
	if( [in_pCustomer isEatTenpura:in_pData->no] == NO )
	{
		[in_pCustomer.act anger];
		return	bEat;
	}

	bEat	= YES;
	addScoreNum	= in_pData->aStatusList[in_tenpuraState].score;
	addMoneyNum	= in_pData->aStatusList[in_tenpuraState].money;
	
	if( addMoneyNum > 0 )
	{
		addMoneyNum	*=	pGameScene->m_moneyRate;
	}
	
	if( addScoreNum > 0 )
	{
		addScoreNum	*=	pGameScene->m_scoreRate;
	}
	
	{
		//	食べたい天ぷらがあるかチェック
		switch( (SInt32)in_tenpuraState )
		{
			default:
			{
				assert(0);
				break;
			}

			//	揚げてない
			case eTENPURA_STATE_NOT:
			{
				[in_pCustomer.act eatVeryBat:in_pData->no:addScoreNum:addMoneyNum];
				break;
			}
			//　ちょうど良い
			case eTENPURA_STATE_GOOD:
			{
				[in_pCustomer.act eatGood:in_pData->no:addScoreNum:addMoneyNum];
				break;
			}
			//	最高
			case eTENPURA_STATE_VERYGOOD:
			{
				[in_pCustomer.act eatVeryGood:in_pData->no:addScoreNum:addMoneyNum];
			
				break;
			}
			//	焦げ
			case eTENPURA_STATE_BAD:
			{
				[in_pCustomer.act eatBat:in_pData->no:addScoreNum:addMoneyNum];
				
				break;
			}
			//	丸焦げ
			case eTENPURA_STATE_VERYBAD:
			{
				[in_pCustomer.act eatVeryBat:in_pData->no:addScoreNum:addMoneyNum];
				break;
			}
		}
	}
	
	//	スコア反映
	[self _setScore:in_pCustomer:addScoreNum];

	//	取得金額反映
	[self _setMoney:in_pCustomer:addMoneyNum];
	
	return bEat;
}

/*
	@brief	客とのヒット判定
*/
-(Customer*)	_isHitCustomer:(CGRect)in_rect
{
	GameScene*	pGameScene	= (GameScene*)[self parent];
	if( pGameScene == nil )
	{
		return NO;
	}

	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH(pGameScene->mp_customerArray,pCustomer)
	{
		if( ( pCustomer.visible == NO ) || ( pCustomer.bPut == NO ) )
		{
			continue;
		}

		if( CGRectIntersectsRect( in_rect, [pCustomer getBoxRect] ) == YES )
		{
			return pCustomer;
		}
	}
	
	return nil;
}

/*
	@brief	タッチ処理終了
*/
-(void)	_endTouch
{
	GameScene*	pGameScene	= (GameScene*)[self parent];

	//	ヒットしたときの演出を終了
	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH(pGameScene->mp_customerArray,pCustomer)
	{
		[pCustomer.act endFlash];
	}
}

/*
	@brief	スコア設定
	@note	設定した客とゲームに設定
*/
-(void)	_setScore:(Customer*)in_pCustomer:(SInt32)in_num
{
	GameScene*	pGameScene	= (GameScene*)[self parent];

	pGameScene.score			+= in_num;
	in_pCustomer.score			+= in_num;
}

/*
	@brief	金額設定
	@note	設定した客とゲームに設定
*/
-(void)	_setMoney:(Customer*)in_pCustomer:(SInt32)in_num
{
	GameScene*	pGameScene	= (GameScene*)[self parent];

	pGameScene.money	+= in_num;
	in_pCustomer.money	+= in_num;
}

@end
