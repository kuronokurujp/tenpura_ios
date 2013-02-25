//
//  GameEndScene.m
//  tenpura
//
//  Created by y.uchida on 12/10/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameEndScene.h"

#import "./../GameScene.h"
#import "./../../Object/Customer.h"
#import "./../../ActionCustomer/ActionCustomer.h"
#import "./../../CCBReader/CCBReader.h"
#import "./../../Data/DataGlobal.h"
#import "./../../Data/DataSaveGame.h"
#import	"./../../Data/DataBaseText.h"
#import "./../../Data/DataGlobal.h"
#import "./../../System/Sound/SoundManager.h"

//	非公開関数
@interface GameEndScene (PrivateMethod)

-(void)	_begin:(ccTime)in_time;
-(void)	_endByLogoInAlphaEvent;
-(void)	_endByLogoOutAlphaEvnet;
-(void)	_beginByPrepaEvent:(ccTime)in_time;
-(void)	_updatePrepaEvent:(ccTime)in_time;
-(void)	_endPrepaEvent:(ccTime)in_time;
-(void)	_end:(ccTime)in_time;

-(void)	_createMenu;
-(void)	_menuRestartTouched;
-(void)	_menuTwitterTouched;
-(void)	_menuEndTouched;

@end

@implementation GameEndScene

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
		
		mp_endLogoSp	= [CCSprite spriteWithFile:@"play_end.png"];
		[mp_endLogoSp setVisible:NO];
		[self addChild:mp_endLogoSp];		
	}
	
	return	self;
}

/*
	@brief	開始
*/
-(void)	_begin:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)[self parent];
	
	//	天ぷらを消滅
	[pGameScene->mp_nabe allCleanTenpura];
	
	//	客を一時停止
	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH(pGameScene->mp_customerArray,pCustomer)
	{
		[pCustomer pauseSchedulerAndActions];
	}
	
	//	ロゴ表示イベント
	{
		CGPoint	pos	= ccp(SCREEN_SIZE_WIDTH * 0.5f, SCREEN_SIZE_HEIGHT * 0.5f);
		[mp_endLogoSp setVisible:YES];
		[mp_endLogoSp setPosition:pos];

		CCFadeIn*	pFadeIn		= [CCFadeIn actionWithDuration:1.f];
		CCCallFunc*	pEndFunc	= [CCCallFunc actionWithTarget:self selector:@selector(_endByLogoInAlphaEvent)];
		CCSequence*	pSeq		= [CCSequence actions:pFadeIn, pEndFunc, nil];
		[mp_endLogoSp runAction:pSeq];
	}

	[[SoundManager shared] playSe:@"gameEnd"];

	[self unschedule:_cmd];
}

/*
	@brief
*/
-(void)	_endByLogoInAlphaEvent
{
	[self scheduleOnce:@selector(_beginByPrepaEvent:) delay:3.f];
}

/*
	@brief
*/
-(void)	_endByLogoOutAlphaEvnet
{
	[mp_endLogoSp setVisible:NO];
}

/*
	@brief
*/
-(void)	_beginByPrepaEvent:(ccTime)in_time
{	
	GameScene*	pGameScene	= (GameScene*)[self parent];
	Customer*	pCustomer	= nil;
	
	{
		CCARRAY_FOREACH( pGameScene->mp_customerArray, pCustomer )
		{
			//	停止した客を再起動
			[pCustomer resumeSchedulerAndActions];
			
			[pCustomer settingResult];
		}
	}
	
	//	ロゴ消滅
	{
		[mp_endLogoSp setVisible:YES];
		CCFadeOut*	pFadeOut	= [CCFadeOut actionWithDuration:1.f];
		CCCallFunc*	pEndFunc	= [CCCallFunc actionWithTarget:self selector:@selector(_endByLogoOutAlphaEvnet)];
		CCSequence*	pSeq		= [CCSequence actions:pFadeOut, pEndFunc, nil];
		[mp_endLogoSp runAction:pSeq];
	}
	
	[self unschedule:_cmd];
	[self schedule:@selector(_updatePrepaEvent:)];
}

/*
	@brief
*/
-(void)	_updatePrepaEvent:(ccTime)in_time
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

	if( (cnt >= eCUSTOMER_MAX) && (mp_endLogoSp.visible == NO) )
	{
		[self unschedule:_cmd];
		[self schedule:@selector(_endPrepaEvent:)];
	}
}

/*
	@brief
*/
-(void)	_endPrepaEvent:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)[self parent];
	Customer*	pCustomer	= nil;
	CCARRAY_FOREACH( pGameScene->mp_customerArray, pCustomer )
	{
		//	スコア表示開始
		[pCustomer.act putResultScore];
	}

	[self _createMenu];

	[self unschedule:_cmd];
	[self scheduleUpdate];
}

/*
	@brief
*/
-(void)	update:(ccTime)delta
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
-(void)	_end:(ccTime)in_time
{
	GameScene*	pGameScene	= (GameScene*)[self parent];

	DataSaveGame*	pDataSaveGame	= [DataSaveGame shared];
	const SAVE_DATA_ST*	pSaveData	= [pDataSaveGame getData];
	
	//	ハイスコアであれば記録
	int64_t	score	= [pGameScene getScore];
	if( pSaveData->score < score )
	{
		[pDataSaveGame addSaveScore:score];
	}
	
	int64_t	money	= [pGameScene getMoney];
	[pDataSaveGame addSaveMoeny:money];

	[self setVisible:NO];
}

/*
	@brief	メニュー作成
*/
-(void)	_createMenu
{
	CGSize	winSize	= [[CCDirector sharedDirector] winSize];
	
	GameScene*	pGameScene	= (GameScene*)[self parent];
	DataSaveGame*	pDataSaveGame	= [DataSaveGame shared];
	const SAVE_DATA_ST*	pSaveData	= [pDataSaveGame getData];
	
	//	ハイスコアであれば記録
	int64_t	score	= [pGameScene getScore];
	NSString*	pResultCcbiFileName	= @"game_result.ccbi";
	if( pSaveData->score < score )
	{
		pResultCcbiFileName	= @"game_result_hiscore.ccbi";
	}

	CCNode*	pNode	= [CCBReader nodeGraphFromFile:pResultCcbiFileName owner:self parentSize:winSize];
	[self addChild:pNode];
}

/*
	@brief
*/
-(void)	_pressRestartBtn
{
	m_resultType	= eRESULT_TYPE_RESTART;
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief
*/
-(void)	_pressTwitterBtn
{
	GameScene*	pGameScene	= (GameScene*)[self parent];
	DataBaseText*	pDataText	= [DataBaseText shared];

    NSString*	tweetText	= [NSString stringWithFormat:[NSString stringWithUTF8String:[pDataText getText:70]], [pGameScene getScore]];
	NSString*	searchURL	= [NSString stringWithUTF8String:[pDataText getText:56]];

	NSString*	pTextKeyName		= [NSString stringWithUTF8String:gp_tweetTextKeyName];
	NSString*	pSearchURLKeyName	= [NSString stringWithUTF8String:gp_tweetSearchURLKeyName];
	NSDictionary*	pDlc	= [NSDictionary dictionaryWithObjectsAndKeys:
		tweetText,	pTextKeyName,
		searchURL,	pSearchURLKeyName,
		nil];

	NSString*	pOBName	= [NSString stringWithUTF8String:gp_tweetShowObserverName];
	NSNotification*	pNotification	=
	[NSNotification notificationWithName:pOBName object:self userInfo:pDlc];
	
	[[NSNotificationCenter defaultCenter] postNotification:pNotification];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief
*/
-(void)	_pressGametEndBtn
{
	m_resultType	= eRESULT_TYPE_SINAGAKI;
	
	[[SoundManager shared] playSe:@"btnClick"];
}

@end
