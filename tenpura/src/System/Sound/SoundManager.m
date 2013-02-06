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
-(void)	_preLoad:(const UInt32)in_idx :(NSString*)in_pFormatName;

//	再生するサウンド名を取得
-(NSString*)	_getPlaySoundName:(const UInt32)in_idx;
//	再生
-(const SInt32)	_play:(const UInt32)in_idx;

//	再生単純再生
-(const SInt32)	_playSimple:(const UInt32)in_idx;
//	遅延再生
-(void)	_onPlayDelay:(NSTimer*)in_pTm;

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

+(id)alloc
{
	NSAssert(sp_inst == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
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
			SOUDN_DATA_ST*	pSoundDat	= &mp_dataList[i];

			SInt32	dataIdx	= 0;

			//	データ名
			const char*	pStr	= [[pItems objectAtIndex:dataIdx] UTF8String];
			memcpy( pSoundDat->aDataName, pStr, [[pItems objectAtIndex:dataIdx] length]);
			++dataIdx;

			//	サウンドファイル名
			pStr	= [[pItems objectAtIndex:dataIdx] UTF8String];
			memcpy( pSoundDat->aSoundName, pStr, [[pItems objectAtIndex:dataIdx] length]);
			++dataIdx;

			//	サウンドフォーマット
			pStr	= [[pItems objectAtIndex:dataIdx] UTF8String];
			memcpy( pSoundDat->aFormatName, pStr, [[pItems objectAtIndex:dataIdx] length]);
			++dataIdx;
			
			//	遅延
			pSoundDat->delayTime	= [(NSNumber*)[pItems objectAtIndex:dataIdx] floatValue];
			++dataIdx;
			
		}
	}
		
	[pLines release];

	return NO;
}

/*
	@brief	サウンド再生(名前指定)
*/
-(const SInt32)	playSe:(NSString*)in_pName
{
	NSAssert(in_pName, @"サウンドのデータ名を指定していない");
	UInt32	dataMax	= m_dataNum;
	for( UInt32 i = 0; i < dataMax; ++i )
	{
		NSString*	pDataName	= [NSString stringWithUTF8String:mp_dataList[i].aDataName];
		if( [pDataName isEqualToString:in_pName] )
		{
			return [self _play:i];
		}
	}
	
	return -1;
}

/*
	@brief	サウンド再生(名前指定)
*/
-(const SInt32)	playBgm:(NSString*)in_pName
{
#if 1
	NSAssert(in_pName, @"サウンドのデータ名を指定していない");
	UInt32	dataMax	= m_dataNum;
	for( UInt32 i = 0; i < dataMax; ++i )
	{
		NSString*	pDataName	= [NSString stringWithUTF8String:mp_dataList[i].aDataName];
		if( [pDataName isEqualToString:in_pName] )
		{
			if( ( mp_playNameBGM != nil ) && ( [mp_playNameBGM isEqualToString:in_pName] ) )
			{
			}
			else
			{
				mp_playNameBGM	=	[in_pName copy];
				return [self _play:i];
			}
		}
	}
#endif
	
	return -1;
}

/*
	@brief	BGM停止
*/
-(void)	stopBgm:(Float32)in_fadeTime
{
	if( mp_playNameBGM != nil )
	{
		mp_playNameBGM	= nil;
		//	BGM停止
		if( in_fadeTime <= 0.f )
		{
			SimpleAudioEngine*	pAudioEngine	= [SimpleAudioEngine sharedEngine];
			[pAudioEngine stopBackgroundMusic];
		}
		else
		{
			//	指定した時間をかけて消す
			SimpleAudioEngine*	pAudioEngine	= [SimpleAudioEngine sharedEngine];
			[pAudioEngine stopBackgroundMusic];
		}
	}
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
-(void)	_preLoad:(const UInt32)in_idx :(NSString*)in_pFormatName;
{
	NSString*	pSoundName	= [self _getPlaySoundName:in_idx];
	if( pSoundName != nil )
	{
		SimpleAudioEngine*	pAudioEngine	= [SimpleAudioEngine sharedEngine];

		NSString*	pFormatName	= [NSString stringWithUTF8String:mp_dataList[in_idx].aFormatName];
		if( [in_pFormatName isEqualToString:pFormatName] )
		{
			if( [in_pFormatName isEqualToString:@"mp3"] )
			{
				[pAudioEngine preloadBackgroundMusic:pSoundName];
			}
			else if( [in_pFormatName isEqualToString:@"caf"] )
			{
				[pAudioEngine preloadEffect:pSoundName];
			}
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

/*
	@brief	サウンド再生
	@param	リストidx
	@return	サウンドハンドル(未使用)
*/
-(const SInt32)	_play:(const UInt32)in_idx
{
	//	遅延値があるか
	if( in_idx < m_dataNum )
	{
		SOUDN_DATA_ST*	pSoundDat	= &mp_dataList[in_idx];
		if( pSoundDat->delayTime <= 0.f )
		{
			return [self _playSimple:in_idx];
		}
		else
		{
			//	遅延再生
			[NSTimer scheduledTimerWithTimeInterval:pSoundDat->delayTime
			target:self
			selector:@selector(_onPlayDelay:)
			userInfo:[NSNumber numberWithInt:in_idx]
			repeats:NO];
		}
	}
	
	return -1;
}

/*
	@brief	再生単純再生
*/
-(const SInt32)	_playSimple:(const UInt32)in_idx
{
	SInt32	handle	= -1;
	NSString*	pSoundName	= [self _getPlaySoundName:in_idx];
	if( pSoundName != nil )
	{
		SimpleAudioEngine*	pAudioEngine	= [SimpleAudioEngine sharedEngine];

		NSString*	pFormatName	= [NSString stringWithUTF8String:mp_dataList[in_idx].aFormatName];
		if( [pFormatName isEqualToString:@"mp3"] )
		{
			//	すでに別のmp3を鳴らしているのであればそれは停止
			if( [mp_playNameBGM isEqualToString:pSoundName] == NO )
			{
				[pAudioEngine stopBackgroundMusic];
			}
			
			[pAudioEngine setBackgroundMusicVolume:1.f];
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
	@brief	遅延再生
*/
-(void)	_onPlayDelay:(NSTimer*)in_pTm
{
	NSNumber*		pNumberData	= [in_pTm userInfo];
	
	[self _playSimple:[pNumberData intValue]];
}

@end
