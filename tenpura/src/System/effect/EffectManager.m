//
//  EffectManager.m
//  tenpura
//
//  Created by y.uchida on 13/01/06.
//
//

#import "EffectManager.h"
#import "Action/EffectActionSprite.h"

@implementation EffectManager

static	EffectManager*	sp_inst	= nil;

/*
	@brief
*/
+(EffectManager*)	shared
{
	if( sp_inst == nil )
	{
		sp_inst	= [[EffectManager alloc] init];
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
-(CCNode*)	addEffect:(NSString*)in_pEffName:(EffectData*)in_pEffData
{
	id	pChkData	= [mp_dicData objectForKey:in_pEffName];
	if( pChkData == nil )
	{
		[mp_dicData setValue:[in_pEffData retain] forKey:in_pEffName];
	}

	return nil;
}

/*
	@brief	エフェクトバッチ作成
*/
-(CCNode*)	createBath:(const NSString*)in_pEffName
{
	NSAssert(in_pEffName, @"%s(%d):エフェクト名がない", __FILE__, __LINE__);
	id	pData	= [mp_dicData objectForKey:in_pEffName];
	if( pData != nil )
	{
		if( [pData isKindOfClass:[EffectData class]] )
		{
		//	CCSpriteBatchNode*	pBatchNode	= nil;
			EffectData*	pEffData	= (EffectData*)pData;
			for( UInt32 i = 0; i < pEffData.fileNum; ++i )
			{
				
			}
		}
	}
	
	return nil;
}

/*
	@brief	エフェクト再生
*/
-(CCNode*)	play:(const NSString*)in_pEffName
{
	id	pEffData	= [mp_dicData objectForKey:in_pEffName];
	if( pEffData != nil )
	{
		if( [pEffData isKindOfClass:[EffectData class]] )
		{
			return [[[EffectActionSprite alloc] initWithData:(EffectData*)pEffData] autorelease];
		}
	}
	
	NSAssert(nil, @"%s(%d):エフェクト名「%@」がない", __FILE__, __LINE__, in_pEffName);

	return nil;
}

@end
