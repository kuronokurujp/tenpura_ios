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
#import "./../../Action/ActionCustomer.h"
#import "./../../Data/DataNetaList.h"


//	非公開関数
@interface GameInScene (PrivateMethod)

-(void)	_begin:(ccTime)in_time;
-(void)	_end:(ccTime)in_time;

-(void)	_timer:(ccTime)in_time;

-(BOOL)	_eatCustomer:(Customer*)in_pCustomer:(TENPURA_STATE_ET)in_tenpuraState:(NETA_DATA_ST*)in_pData;
-(Customer*)	_isHitCustomer:(CGRect)in_rect;

@end

@implementation GameInScene

static const SInt32	s_AddCustomerEatMax	= 1;

/*
	@brief
*/
-(id)	init:(Float32)in_time;
{
	if( self = [super init] )
	{
		mp_touchTenpura	= nil;
		m_time	= in_time;

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
	[self unschedule:@selector(_end:)];
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
			if( [pNode isKindOfClass:[Tenpura class]] == YES )
			{
				Tenpura*	pTenpura	= (Tenpura*)pNode;
				if( (pTenpura.bTouch == NO) && (pTenpura.visible == YES) )
				{
					if( CGRectContainsPoint([pTenpura getBoxRect], touchPoint) == YES )
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
		Customer*	pTenpuraHitCustomer	= [self _isHitCustomer:[mp_touchTenpura getBoxRect]];
		if( pTenpuraHitCustomer != nil )
		{
			//	ヒットした場合ヒットしていると表示する。
			[pTenpuraHitCustomer setFlgTenpuraHit:YES];
		}
		
		//	天ぷらとヒットしていない客はヒット演出を止める
		Customer*	pCustomer	= nil;
		GameScene*	pGameScene	= (GameScene*)[self parent];
		CCARRAY_FOREACH(pGameScene->mp_customerArray,pCustomer)
		{
			if( pCustomer != pTenpuraHitCustomer )
			{
				[pCustomer setFlgTenpuraHit:NO];
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

		pCustomer	= [self _isHitCustomer:[mp_touchTenpura getBoxRect]];
		if( pCustomer != nil )
		{
			NETA_DATA_ST	data	= mp_touchTenpura.data;

			//	ヒット
			bHitCustomer	= YES;
			//	天ぷらを消して客のアクションを決める
			bEatTenpura	= [self _eatCustomer:pCustomer:mp_touchTenpura.state:&data];
			if( bEatTenpura == YES )
			{
				//	食べるものがなければ新しい客を出す
				if( [pCustomer getEatCnt] <= 0 )
				{
					[pGameScene putCustomer:YES];
				}
			}
			
			[pCustomer setFlgTenpuraHit:NO];
		}

		CGPoint	nowTenpuraPos	= mp_touchTenpura.position;
		[mp_touchTenpura unLockTouch];
		if( ( bHitCustomer == YES ) && ( bEatTenpura == YES ) )
		{
			//	食べるのに成功
			[pGameScene->mp_nabe subTenpura:mp_touchTenpura];
		}
		else if( CGRectContainsPoint(pGameScene->mp_nabe.boundingBox, nowTenpuraPos))
		{
			//	鍋内なら現在で位置に配置
			[mp_touchTenpura setPosition:nowTenpuraPos];
		}

		mp_touchTenpura	= nil;
	}

	//	ヒットしたときの演出を終了
	CCARRAY_FOREACH(pGameScene->mp_customerArray,pCustomer)
	{
		[pCustomer setFlgTenpuraHit:NO];
	}
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
}

/*
	@brief	客が食べる
	@return	食べるのに成功かどうか
	@note	取得スコア/金額の反映させる
*/
-(BOOL)	_eatCustomer:(Customer*)in_pCustomer:(TENPURA_STATE_ET)in_tenpuraState:(NETA_DATA_ST*)in_pData
{
	if( in_pData == nil )
	{
		return NO;
	}

	if( in_pCustomer == nil )
	{
		return NO;
	}
	
	GameScene*	pGameScene	= (GameScene*)[self parent];

	SInt32	addScoreNum	= 0;
	SInt32	addMoneyNum	= 0;

	//	一人しか客がいない場合には退場させない
	BOOL	bExitAct	= ([pGameScene getPutCustomerNum] > 1);
	BOOL	bEat		= NO;
	
	//	客が欲しい天ぷらかチェック
	if( [in_pCustomer isEatTenpura:in_pData->no] == NO )
	{
		[in_pCustomer.act eatBat:in_pData->no:0:0:bExitAct];
	}
	else
	{
		//	食べたい天ぷらがあるかチェック
		switch( (SInt32)in_tenpuraState )
		{
			//	揚げてない
			case eTENPURA_STATE_NOT:
			{
				[in_pCustomer.act eatBat:in_pData->no:0:0:bExitAct];
				break;
			}
			//　ちょうど良い
			case eTENPURA_STATE_GOOD:
			{
				addMoneyNum	= in_pData->buyMoney;
				addScoreNum	= in_pData->score;
				[in_pCustomer.act eatGood:in_pData->no:addScoreNum:addMoneyNum];

				bEat	= YES;
				break;
			}
			//	最高
			case eTENPURA_STATE_VERYGOOD:
			{
				addMoneyNum	= in_pData->buyMoney * 2;
				addScoreNum	= in_pData->score * 2;
				[in_pCustomer.act eatVeryGood:in_pData->no:addScoreNum:addMoneyNum];
			
				bEat	= YES;
				break;
			}
			//	焦げ
			case eTENPURA_STATE_BAD:
			{
				[in_pCustomer.act eatBat:in_pData->no:0:0:NO];
				break;
			}
			//	丸焦げ
			case eTENPURA_STATE_ALLBAD:
			{
				[in_pCustomer.act eatAllBat:in_pData->no:0:0:NO];
				break;
			}
			default:
			{
				assert(0);
				break;
			}
		}
	}
	
	//	スコア反映
	pGameScene->m_scoreNum		+= addScoreNum;
	in_pCustomer.score			+= addScoreNum;

	//	取得金額反映
	pGameScene->m_addMoneyNum	+= addMoneyNum;
	in_pCustomer.money			+= addMoneyNum;
	
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

@end
