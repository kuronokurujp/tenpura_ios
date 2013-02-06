//
//  AnimManager.m
//  tenpura
//
//  Created by y.uchida on 13/01/06.
//
//

#import "AnimManager.h"
#import "Action/AnimActionSprite.h"

@implementation AnimManager

static	AnimManager*	sp_inst	= nil;

/*
	@brief
*/
+(AnimManager*)	shared
{
	if( sp_inst == nil )
	{
		sp_inst	= [[AnimManager alloc] init];
	}
	
	return sp_inst;
}

/*
	@brief
*/
+(void)	end
{
	if( sp_inst != nil )
	{
		[sp_inst release];
		sp_inst	= nil;
	}
}

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_dicData	= [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

/*
	@brief
*/
+(id)alloc
{
	NSAssert(sp_inst == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

/*
	@brief
*/
-(void)	dealloc
{
	[mp_dicData release];

	[super dealloc];
}

/*
	@brief	エフェクト登録
*/
-(CCNode*)	add:(NSString*)in_pName :(AnimData*)in_pData
{
	id	pChkData	= [mp_dicData objectForKey:in_pName];
	if( pChkData == nil )
	{
		[mp_dicData setValue:[in_pData retain] forKey:in_pName];
	}

	return nil;
}

/*
	@brief	エフェクトバッチ作成
*/
-(CCNode*)	createBath:(const NSString*)in_pName
{
	NSAssert(in_pName, @"%s(%d):エフェクト名がない", __FILE__, __LINE__);
	id	pData	= [mp_dicData objectForKey:in_pName];
	if( pData != nil )
	{
		if( [pData isKindOfClass:[AnimData class]] )
		{
		//	CCSpriteBatchNode*	pBatchNode	= nil;
		}
	}
	
	return nil;
}

/*
	@brief	エフェクト作成
*/
-(CCNode*)	createNode:(const NSString*)in_pName :(BOOL)in_bLoop
{
	id	pEffData	= [mp_dicData objectForKey:in_pName];
	if( pEffData != nil )
	{
		if( [pEffData isKindOfClass:[AnimData class]] )
		{
			if( in_bLoop == YES )
			{
				return [[[AnimActionSprite alloc] initWithDataAndLoop:(AnimData*)pEffData] autorelease];
			}
			else
			{
				return [[[AnimActionSprite alloc] initWithData:(AnimData*)pEffData] autorelease];
			}
		}
	}
	
	NSAssert(nil, @"%s(%d):エフェクト名「%@」がない", __FILE__, __LINE__, in_pName);
	
	return nil;
}

/*
	@brief	エフェクト再生
*/
-(CCNode*)	play:(const NSString*)in_pName
{
	id	pEffData	= [mp_dicData objectForKey:in_pName];
	if( pEffData != nil )
	{
		if( [pEffData isKindOfClass:[AnimData class]] )
		{
			AnimActionSprite*	pNode	= [[[AnimActionSprite alloc] initWithData:(AnimData*)pEffData] autorelease];
			[pNode start];
			return pNode;
		}
	}
	
	NSAssert(nil, @"%s(%d):エフェクト名「%@」がない", __FILE__, __LINE__, in_pName);

	return nil;
}

@end
