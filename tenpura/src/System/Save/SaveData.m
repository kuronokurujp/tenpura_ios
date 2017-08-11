//
//  SaveData.m
//  tenpura
//
//  Created by y.uchida on 12/10/20.
//
//

#import "SaveData.h"

@implementation SaveData

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_Data	= nil;
		m_Size	= 0;
		mp_IdName	= @"";
	}
	
	return self;
}

/*
	@brief
*/
-(void)dealloc
{
	if( mp_Data != nil )
	{
		free(mp_Data);
		mp_Data	= nil;
	}
	
	[super dealloc];
}

/*
	@brief	セットアップ
	@return	セットアップ成功 = YES / 失敗 = NO
*/
-(BOOL)setup:(NSString *)in_pIdName :(SInt32)in_size
{
	assert([in_pIdName isEqualToString:@""] == NO);
	assert(in_size > 0);
	
	BOOL	bFlg	= YES;
	
	mp_IdName	= in_pIdName;
	m_Size		= in_size;
	mp_Data		= malloc(in_size);
	assert(mp_Data != nil);
	memset(mp_Data, 0, in_size);
	
	return bFlg;
}

/*
	@brief	ロード
	@return	ロード成功 / 失敗
*/
-(BOOL)	load
{
	NSAssert( mp_Data != nil, @"セーブデータがないです" );

	BOOL	bFlg	= YES;
	NSData*	pData	= [[NSUserDefaults standardUserDefaults] dataForKey:mp_IdName];
	
	//	初回か判断
	if( pData == nil ) {
		//	初回
		[self save];
	}
	else {
		//	すでにデータがある
		[pData getBytes:mp_Data length:m_Size];
	}
	
	return bFlg;
}

/*
	@brief	セーブ
	@return	セーブ成功 = YES / 失敗 = NO
*/
-(BOOL)	save
{
	assert(mp_Data != nil);
/*
	NSDictionary*	pDict	= [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithFloat:m_Size], mp_IdName, nil];
	assert(pDict != nil);
	[[NSUserDefaults standardUserDefaults] registerDefaults:pDict];
*/	
	//	ゲームデータを書き込む
	NSData*	pSaveData	= [[[NSData alloc] initWithBytes:mp_Data length:m_Size] autorelease];
	assert(pSaveData != nil);
	
	[[NSUserDefaults standardUserDefaults] setObject:pSaveData forKey:mp_IdName];
	if( [[NSUserDefaults standardUserDefaults] synchronize] )
    {
        return YES;
    }
    
    NSAssert(NO, @"");
		
	return NO;
}

/*
	@brief	リセット
	@return	リセット成功 = YES / 失敗 = NO
*/
-(BOOL)	reset
{
	memset( mp_Data, 0, m_Size );
	
	return [self save];
}

/*
	@brief	データアドレス取得
	@return	データアドレス
*/
-(char*)getData
{
	assert(mp_Data != nil);
	assert(m_Size > 0);
	
	return mp_Data;
}

@end
