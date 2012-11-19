//
//  GameResultScene.m
//  tenpura
//
//  Created by y.uchida on 12/10/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameResultScene.h"

#import "./../GameScene.h"
#import "./../../Object/Customer.h"
#import "./../../Action/ActionCustomer.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../CCBReader/CCBReader.h"

//	非公開関数
@interface GameResultScene (PrivateMethod)

-(void)_begin:(ccTime)in_time;
-(void)_waitPutCustomer:(ccTime)in_time;
-(void)_end:(ccTime)in_time;

-(void)createMenu;
-(void)_menuRestartTouched;
-(void)_menuEndTouched;

@end

@implementation GameResultScene

@synthesize resultType	= m_resultType;

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		[self schedule:@selector(_begin:)];
		m_resultType	= eRESULT_TYPE_NONE;
	}
	
	return	self;
}

/*
	@brief	開始
*/
-(void)_begin:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)[self parent];
	Customer*	pCustomer	= nil;
	
	CCARRAY_FOREACH( pGameScene->mp_customerArray, pCustomer )
	{
		//	強制登場
		[pCustomer.act put:NO];

		//	天ぷらアイコンを消す
		[pCustomer removeAllEatIcon];
	}
	
	[self unschedule:@selector(_begin:)];
	[self schedule:@selector(_waitPutCustomer:)];
}

/*
	@brief
*/
-(void)_waitPutCustomer:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)[self parent];

	SInt32	cnt	= 0;
	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH( pGameScene->mp_customerArray, pCustomer )
	{
		if( ( pCustomer.visible == YES ) && ( pCustomer.bPut == YES ) )
		{
			++cnt;
		}
	}

	if( cnt >= eCUSTOMER_MAX )
	{
		CCARRAY_FOREACH( pGameScene->mp_customerArray, pCustomer )
		{			
			//	スコア表示開始
			[pCustomer.act putResultScore];
		}
		
		[pGameScene->mp_nabe setVisibleTenpura:NO];
		
		[self unschedule:_cmd];
		
		[self createMenu];
		[self scheduleUpdate];
	}
}

/*
	@brief
*/
-(void)update:(ccTime)delta
{
	if( m_resultType != eRESULT_TYPE_NONE )
	{
		[self unschedule:_cmd];
		[self schedule:@selector(_end:)];
	}
}

/*
	@brief	終了
*/
-(void)_end:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)[self parent];

	DataSaveGame*	pDataSaveGame	= [DataSaveGame shared];
	const SAVE_DATA_ST*	pSaveData	= [pDataSaveGame getData];
	
	//	ハイスコアであれば記録
	if( pSaveData->score < pGameScene->m_scoreNum )
	{
		pDataSaveGame.score		= pGameScene->m_scoreNum;
	}

	pDataSaveGame.addMoney	= pGameScene->m_addMoneyNum;

	[self setVisible:NO];
}

/*
	@brief	メニュー作成
*/
-(void)createMenu
{
	CGSize	winSize	= [[CCDirector sharedDirector] winSize];
	CCNode*	pNode	= [CCBReader nodeGraphFromFile:@"gameResult.ccbi" owner:self parentSize:winSize];
	[self addChild:pNode];
}

/*
	@brief
*/
-(void)_menuRestartTouched
{
	m_resultType	= eRESULT_TYPE_RESTART;
}

/*
	@brief
*/
-(void)_menuEndTouched
{
	m_resultType	= eRESULT_TYPE_SINAGAKI;
}

@end
