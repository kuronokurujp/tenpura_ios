//
//  FileTexLoadManager.m
//  tenpura
//
//  Created by y.uchida on 13/01/07.
//
//

#import "FileTexLoadManager.h"
#import	"cocos2d.h"

@interface FileTexLoadManager (PriveteMethod)

-(void)	_LoadedImage:(CCTexture2D*)in_pTex;

@end

@implementation FileTexLoadManager

static FileTexLoadManager*	sp_inst	= nil;

/*
	@brief
*/
+(FileTexLoadManager*)	shared
{
	if( sp_inst == nil )
	{
		sp_inst	= [[FileTexLoadManager alloc] init];
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
	}
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
	@brief	ファイル非同期読み込み
*/
-(void)	LoadAsync:(NSString*)in_pFileName
{
	[[CCTextureCache sharedTextureCache] addImageAsync:in_pFileName target:self selector:@selector(_LoadedImage:)];
}

/*
	@brief	ファイル読み込み終了
*/
-(void)	_LoadedImage:(CCTexture2D*)in_pTex
{
	NSLog(@"テクスチャーファイル読み終了");
}

@end
