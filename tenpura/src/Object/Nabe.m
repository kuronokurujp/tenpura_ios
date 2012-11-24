//
//  Nabe.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Nabe.h"
#import "Tenpura.h"

#import "./../Data/DataTenpuraPosList.h"

@implementation Nabe

//	定数定義
enum
{
	eTEPURA_MAX	= 32,	//	天ぷら最大確保個数
};

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_sp	= [CCSprite node];
		[mp_sp initWithFile:@"nabe0.png"];
		[mp_sp setAnchorPoint:ccp(0,0)];
		
		[self addChild:mp_sp];
		
		for( UInt32 i = 0; i < eTEPURA_MAX; ++i )
		{
			Tenpura*	pTenpura	= [Tenpura node];
			[pTenpura setVisible:NO];
			[self addChild:pTenpura z:10.f];
		}
		
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
			if( pTenpura.state == eTENPUrA_STATE_RESTART )
			{
				[pTenpura reset];
				[pTenpura setVisible:YES];

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
-(Tenpura*)	addTenpura:(NETA_DATA_ST)in_data
{
	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];

	Tenpura*	pTenpura	= nil;
	CCNode*		pNode		= nil;
	SInt32		idx			= 0;
	
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			pTenpura	= (Tenpura*)pNode;
			if( pTenpura.bRaise == NO )
			{
				UInt32	posIdx	= [pDataTenpuraPosList getIdxNoUse];
				[pDataTenpuraPosList setUseFlg:YES :posIdx];

				[pTenpura setupToPosIndex:in_data:posIdx];
				[pTenpura startRaise];
				
				return pTenpura;
			}
			
			++idx;
		}
	}

	return	nil;
}

/*
	@brief	天ぷら削除
*/
-(void)	subTenpura:(Tenpura*)in_pTenpura
{
	if( ( in_pTenpura == nil ) || ( in_pTenpura.bRaise == NO ) )
	{
		return;
	}

	//	使用した座標データを未使用状態に
	DataTenpuraPosList*	pDataTenpuraPosList	= [DataTenpuraPosList shared];
	[pDataTenpuraPosList setUseFlg:NO :in_pTenpura.posDataIdx];

	[in_pTenpura end];
}

/*
	@breif
*/
-(void)	setVisibleTenpura:(BOOL)in_bFlg
{
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[Tenpura class]] == YES )
		{
			[pNode setVisible:NO];
		}
	}
}

/*
	@brief
*/
-(CGRect)	boundingBox
{
	return mp_sp.boundingBox;
}

@end
