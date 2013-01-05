//
//  SoundManager.m
//  tenpura
//
//  Created by y.uchida on 13/01/03.
//
//

#import "SoundManager.h"
#import "SimpleAudioEngine.h"

@interface SoundManager (PrivateMethod)

//	事前読み込み
-(void)	_preLoad:(const UInt32)in_idx:(NSString*)in_pFormatName;

//	再生するサウンド名を取得
-(NSString*)	_getPlaySoundName:(const UInt32)in_idx;

@end

@implementation SoundManager

static	SoundManager*	sp_inst	= nil;

/*
	@brief
*/
+(SoundManager*)	shared
{
	if( sp_inst == nil )
	{
		sp_inst	= [[SoundManager alloc] init];
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
		m_dataNum	= 0;
		mp_dataList	= nil;
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	if( mp_dataList != nil )
	{
		free(mp_dataList);
		mp_dataList	= nil;
	}
	
	[super dealloc];
}

/*
	@brief	セットアップ
	@param	in_pFileName:	データシートファイル名(ファイル拡張子はいらない＋csvファイル限定)
*/
-(BOOL)	setup:(NSString *)in_pFileName
{
	NSAssert(in_pFileName, @"ファイル名を指定していない");

	NSString*	pPath	= [[NSBundle mainBundle] pathForResource:in_pFileName ofType:@"csv"];

	NSString*	pText	= [NSString stringWithContentsOfFile:pPath encoding:NSUTF8StringEncoding error:nil];
	NSString*	pDelmita	= @"\n";
		
	NSMutableArray*	pLines	= [[pText componentsSeparatedByString:pDelmita] mutableCopy];
	//	先頭のカテゴリ行と行末を削除
	[pLines removeObjectAtIndex:0];
	[pLines removeLastObject];
		
	NSString*	pObj	= nil;
	NSArray*	pItems	= nil;

	m_dataNum	= [pLines count];
	NSAssert(0 < m_dataNum, @"ネタデータが一つもない。");
	mp_dataList	= (SOUDN_DATA_ST*)malloc(m_dataNum * sizeof(SOUDN_DATA_ST));
			
	for( SInt32 i = 0; i < m_dataNum; ++i )
	{
		pObj	= [pLines objectAtIndex:i];
		
		pItems	= [pObj componentsSeparatedByString:@","];
		//	解析
		{
			memset( &mp_dataList[ i ], 0, sizeof(mp_dataList[ i ]) );

			SInt32	dataIdx	= 0;

			//	サウンドファイル名
			const char*	pStr	= [[pItems objectAtIndex:dataIdx] UTF8String];
			memcpy( mp_dataList[ i ].aSoundName, pStr, [[pItems objectAtIndex:dataIdx] length]);
			++dataIdx;

			//	サウンドフォーマット
			pStr	= [[pItems objectAtIndex:dataIdx] UTF8String];
			memcpy( mp_dataList[ i ].aFormatName, pStr, [[pItems objectAtIndex:dataIdx] length]);
			++dataIdx;
		}
		
		//	事前読み込み(cafファイル限定)
//		[self _preLoad:i:@"caf"];
	}
		
	[pLines release];

	return NO;
}

/*
	@brief	サウンド再生
	@param	リストidx
	@return	サウンドハンドル(未使用)
*/
-(const SInt32)	play:(const UInt32)in_idx
{
	SInt32	handle	= -1;
	NSString*	pSoundName	= [self _getPlaySoundName:in_idx];
	if( pSoundName != nil )
	{
		SimpleAudioEngine*	pAudioEngine	= [SimpleAudioEngine sharedEngine];

		NSString*	pFormatName	= [NSString stringWithUTF8String:mp_dataList[in_idx].aFormatName];
		if( [pFormatName isEqualToString:@"mp3"] )
		{
			[pAudioEngine playBackgroundMusic:pSoundName];
		}
		else if( [pFormatName isEqualToString:@"caf"] )
		{
			[pAudioEngine playEffect:pSoundName];
		}
	}

	return handle;
}

/*
	@brief	前読み込み
	@param	in_pFormatName: 前読み込みするファイル拡張し
*/
-(void)	preLoad:(NSString*)in_pFormatName
{
	for( UInt32 i = 0; i < m_dataNum; ++i )
	{
		[self _preLoad:i :@"caf"];
	}
}

/*
	@brief	事前読み込み
*/
-(void)	_preLoad:(const UInt32)in_idx:(NSString*)in_pFormatName;
{
	NSString*	pSoundName	= [self _getPlaySoundName:in_idx];
	if( pSoundName != nil )
	{
		SimpleAudioEngine*	pAudioEngine	= [SimpleAudioEngine sharedEngine];

		NSString*	pFormatName	= [NSString stringWithUTF8String:mp_dataList[in_idx].aFormatName];
		if( [pFormatName isEqualToString:@"mp3"] )
		{
			[pAudioEngine preloadBackgroundMusic:pSoundName];
		}
		else if( [pFormatName isEqualToString:@"caf"] )
		{
			[pAudioEngine preloadEffect:pSoundName];
		}
	}
}

/*
	@brief	再生するサウンド名を取得
*/
-(NSString*)	_getPlaySoundName:(const UInt32)in_idx
{
	NSString*	pSoundName	= nil;
	if( in_idx < m_dataNum )
	{
		pSoundName	= [NSString stringWithFormat:@"%s.%s", mp_dataList[in_idx].aSoundName, mp_dataList[in_idx].aFormatName];
		
		NSString*	pFormatName	= [NSString stringWithUTF8String:mp_dataList[in_idx].aFormatName];
		if( [pFormatName isEqualToString:@"mp3"] )
		{
			NSLog(@"%s(%d):soundPlay=mp3 filename[%@]", __FILE__, __LINE__, pSoundName);
		}
		else if( [pFormatName isEqualToString:@"caf"] )
		{
			NSLog(@"%s(%d):soundPlay=caf filename[%@]", __FILE__, __LINE__, pSoundName);
		}
		else
		{
			NSLog(@"%s(%d):指定したサウンドフォーマット(%@)が間違っている", __FILE__, __LINE__, pFormatName);
			pSoundName	= nil;
		}
	}
	else
	{
		NSLog(@"%s(%d):サウンドデータのidx値が間違っている", __FILE__, __LINE__ );
	}

	return pSoundName;
}


@end
