//
//  Nabe.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Nabe.h"

#import "./../Data/DataTenpuraPosList.h"
#import "./../Data/DataOjamaNetaList.h"
#import "./../Object/OjamaTenpura.h"
#import "./../Data/DataGlobal.h"
#import "./../System/Anim/AnimManager.h"

@interface Nabe (PrivateMethod)

//	追加した天ぷら削除
-(void)	_cleanTenpura:(Tenpura*)in_pTenpura :(BOOL)in_bCleanUp;

@end

@implementation Nabe

//	定数定義
enum
{
	eTEPURA_MAX	= 32,	//	天ぷら最大確保個数
};

//	鍋内に表示するZオーダー一覧
enum
{
	eZORDER_START_NORAMAL_TENPURA	= 4,
	eZORDER_OJAMA_TENPURA	= eZORDER_START_NORAMAL_TENPURA + 20,
	eZORDER_EXP,
	eZORDER_BIG_EXP,
};

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		AnimManager*	pAnimManager	= [AnimManager shared];

		m_flyTimeRate	= 1.f;
		mp_sp	= [CCSprite node];
		[mp_sp initWithFile:@"nabe0.png"];
		[mp_sp setAnchorPoint:ccp(0,0)];
		
		[self addChild:mp_sp];

		for( UInt32 i = 0; i < eTEPURA_MAX; ++i )
		{
			Tenpura*	pTenpura	= [Tenpura node];
			pTenpura.delegate	= self;
			[pTenpura setVisible:NO];
			[self addChild:pTenpura z:eZORDER_START_NORAMAL_TENPURA];
			
			//	爆弾エフェクトバッファで保持
			{
				CCNode*	pEff	= [pAnimManager createNode:[NSString stringWithUTF8String:ga_animDataList[eANIM_BOMG].pImageFileName] :NO];
				[pEff setVisible:NO];
				[self addChild:pEff];
			}
		}

		m_tenpuraZOrder	= eZORDER_START_NORAMAL_TENPURA;
		[self scheduleUpdate];
	}
	
	return self;
}

/*
	@brief	破棄
*/
-(void)	dealloc
{
	mp_sp	= nil;
	[super dealloc];
}

/*
	@brief	毎フレーム更新
*/
-(void)	update:(ccTime)delta
{
	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];

	Tenpura*	pTenpura	= nil;
	CCNode*		pNode		= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			pTenpura	= (Tenpura*)pNode;
			if( ([pTenpura isFly]) && (pTenpura.state == eTENPURA_STATE_RESTART) )
			{
				[pTenpura start];

				//	再配置する
				UInt32	posIdx	= [pDataTenpuraPosList getIdxNoUse];
				[pDataTenpuraPosList setUseFlg:YES :posIdx];

				[pTenpura setPosOfIndex:posIdx];
			}
		}
	}
}

/*
	@brief	天ぷら追加
*/
-(Tenpura*)	addTenpura:(const NETA_DATA_ST*)in_pData :(Float32)in_raiseSpeedRate
{
	NSAssert(in_pData, @"");

	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];

	Tenpura*	pTenpura	= nil;
	CCNode*		pNode		= nil;
	SInt32		idx			= 0;
	
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			pTenpura	= (Tenpura*)pNode;
			if( [pTenpura isFly] == NO )
			{
				UInt32	posIdx	= [pDataTenpuraPosList getIdxNoUse];
				[pDataTenpuraPosList setUseFlg:YES :posIdx];

				[pTenpura setupToPosIndex:in_pData:posIdx:in_raiseSpeedRate];
				[pTenpura start];
				[pTenpura setRaiseTimeRate:m_flyTimeRate];
				[pTenpura setZOrder:m_tenpuraZOrder];
				m_tenpuraZOrder += 1;
				
				return pTenpura;
			}
			
			++idx;
		}
	}

	return	nil;
}

/*
	@brief	配置した天ぷらをすべて外す
*/
-(void)	allCleanTenpura
{
	m_tenpuraZOrder	= eZORDER_START_NORAMAL_TENPURA;

	CCArray*	pRemoveTenpura	= [CCArray array];

	Tenpura*	pTenpura	= nil;
	CCNode*		pNode		= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] )
		{
			pTenpura	= (Tenpura*)pNode;
			[self _cleanTenpura:pTenpura:YES];
		}
		else if( [pNode isKindOfClass:[OjamaTenpura class]] )
		{
			[pRemoveTenpura addObject:pNode];
		}
	}

	CCARRAY_FOREACH(pRemoveTenpura, pNode)
	{
		[self removeChild:pNode cleanup:YES];
	}
}

/*
	@brief	配置した天ぷらが爆発
*/
-(void)	onExpTenpura:(CCNode *)in_pTenpura
{
	//	爆発エフェクト
	if( [in_pTenpura isKindOfClass:[Tenpura class]] )
	{
		CCNode*	pNode	= nil;
		CCARRAY_FOREACH(children_, pNode)
		{
			if( ([pNode isKindOfClass:[AnimActionSprite class]] == YES) && (pNode.visible == NO) )
			{
				AnimActionSprite*	pEff	= (AnimActionSprite*)pNode;
				if( pEff != nil )
				{
					[pEff setVisible:YES];
					[pEff start];
					[pEff setPosition:in_pTenpura.position];
					[pEff setZOrder:eZORDER_EXP];
				
					return;
				}
			}
		}
	}
	else if( [in_pTenpura isKindOfClass:[OjamaTenpura class]] )
	{
		//	大爆発
		AnimManager*	pAnimManager	= [AnimManager shared];
		AnimActionSprite*	pEff	= [pAnimManager play:[NSString stringWithUTF8String:ga_animDataList[eANIM_BIGBOMG].pImageFileName]];
		pEff.bAutoRelease	= YES;
		[self addChild:pEff];

		[pEff setVisible:YES];
		{
			CGRect	imgRect	= [mp_sp textureRect];
			CGPoint	pos	= ccp(position_.x + imgRect.size.width * 0.5f, position_.y + imgRect.size.height * 0.5f);
			[pEff setPosition:pos];
		}
		[pEff setZOrder:eZORDER_BIG_EXP];
		
		//	おじゃま処理を送信
		OjamaTenpura*	pOjamaTenpura	= (OjamaTenpura*)in_pTenpura;
		OJAMA_NETA_DATA	data	= pOjamaTenpura.data;
		NSValue*	val	= [NSValue value:&data withObjCType:@encode(OJAMA_NETA_DATA)];

		NSString*	pDataName		= [NSString stringWithUTF8String:gp_startOjamaDataName];
		NSDictionary*	pDlc	= [NSDictionary dictionaryWithObjectsAndKeys:val,	pDataName, nil];

		NSString*	pOBName	= [NSString stringWithUTF8String:gp_startOjamaObserverName];
		NSNotification*	pNotification	=
		[NSNotification notificationWithName:pOBName object:self userInfo:pDlc];
	
		[[NSNotificationCenter defaultCenter] postNotification:pNotification];
	}
}

/*
	@brief	天ぷらをつける
*/
-(void)	onAddChildTenpura:(CCNode*)in_pTenpura;
{
	NSAssert(in_pTenpura, @"天ぷらがない");
	[self _cleanTenpura:(Tenpura*)in_pTenpura :YES];
	[in_pTenpura removeFromParentAndCleanup:NO];
	[self addChild:in_pTenpura];
}

/*
	@brief	揚げる天ぷらの揚げる時間レートを変更
	@note	すくない値を渡すほど早くなる
*/
-(void)	setRaiseTimeRate:(Float32)in_rate
{
	m_flyTimeRate	= in_rate;
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] )
		{
			Tenpura*	pTenpura	= (Tenpura*)pNode;
			[pTenpura setRaiseTimeRate:in_rate];
		}
	}
}

/*
	@brief	おじゃまを出す
*/
-(void)	putOjamaTenpura
{
	DataOjamaNetaList*	pOjamaNetaList	= [DataOjamaNetaList shared];
	
	SInt32	cnt	= CCRANDOM_0_1() * pOjamaNetaList.dataNum;
	if( cnt <= 0 )
	{
		cnt	= 1;
	}

	for( SInt32 i = 0; i < cnt; ++i )
	{
		OjamaTenpura*	pOjama	= [OjamaTenpura node];
		[self addChild:pOjama z:eZORDER_OJAMA_TENPURA];

		[pOjama setup:[pOjamaNetaList getData:i] :1.f];
		pOjama.delegate	= self;
		[pOjama start];
	}
}

/*
	@brief	配置した天ぷらもポーズする
*/
-(void)	pauseSchedulerAndActions
{
	CCNode*		pNode		= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			[pNode pauseSchedulerAndActions];
		}
	}

	[super pauseSchedulerAndActions];
}

/*
	@brief	配置した天ぷらも再開
*/
-(void)	resumeSchedulerAndActions
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			[pNode resumeSchedulerAndActions];
		}
	}
	
	[super resumeSchedulerAndActions];
}

/*
	@brief
*/
-(CGRect)	boundingBox
{
	return mp_sp.boundingBox;
}

/*
	@brief	天ぷら削除
*/
-(void)	_cleanTenpura:(Tenpura*)in_pTenpura :(BOOL)in_bCleanUp
{
	if( in_pTenpura == nil )
	{
		return;
	}

	//	使用した座標データを未使用状態に
	if( in_pTenpura.posDataIdx != -1 )
	{
		DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];
		[pDataTenpuraPosList setUseFlg:NO :in_pTenpura.posDataIdx];
	}

	if( in_bCleanUp == YES )
	{
		if(in_pTenpura.visible == YES)
		{
			m_tenpuraZOrder -= 1;
		}

		[in_pTenpura end];
	}
}

#if 0
#ifdef DEBUG
-(void)	draw
{
	[super draw];

	ccDrawColor4B(255, 0, 255, 255);
	CGPoint	p1,p2,p3,p4;
	
	CGRect	rect	= [self boundingBox];

	p1	= ccp(rect.origin.x + 2,rect.origin.y + 1);
	p2	= ccp(rect.origin.x + 2,rect.origin.y + rect.size.height - 2);
	p3	= ccp(rect.origin.x + rect.size.width - 2,rect.origin.y + rect.size.height - 2);
	p4	= ccp(rect.origin.x + rect.size.width - 2,rect.origin.y + 1);

	ccDrawLine(p1,p2);
	ccDrawLine(p2,p3);
	ccDrawLine(p3,p4);
	ccDrawLine(p4,p1);
	
	ccDrawColor4B(255, 255, 255, 255);
}

#endif
#endif

@end
