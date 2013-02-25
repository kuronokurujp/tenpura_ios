//
//  DataOjamaNetaList.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import "DataOjamaNetaList.h"

//	非公開関数
@interface DataOjamaNetaList (PrivateMethod)

-(OJAMA_NETA_DATA)	parse:(NSArray*)in_dataArray;

@end

@implementation DataOjamaNetaList

//	プロパティ
@synthesize dataNum	= m_dataNum;

static DataOjamaNetaList*	s_pInst	= nil;

/*
	@brief
*/
+(DataOjamaNetaList*)shared
{
	if( s_pInst == nil )
	{
		s_pInst	= [[DataOjamaNetaList alloc] init];
	}
	
	return s_pInst;
}

/*
	@brief
*/
+(void)end
{
	if( s_pInst != nil )
	{
		[s_pInst release];
		s_pInst	= nil;
	}
}

+(id)alloc
{
	NSAssert(s_pInst == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:@"ojamaDataList" ofType:@"csv"];
		NSAssert(pPath, @"ojamaDataList.csvファイルがない");

		NSString*	pText	= [NSString stringWithContentsOfFile:pPath encoding:NSUTF8StringEncoding error:nil];
		NSString*	pDelmita	= @"\n";
		
		NSMutableArray*	pLines	= [[pText componentsSeparatedByString:pDelmita] mutableCopy];
		//	先頭のカテゴリ行と行末を削除
		[pLines removeObjectAtIndex:0];
		[pLines removeLastObject];
		
		NSString*	pObj	= nil;
		NSArray*	pDatas	= nil;

		m_dataNum	= [pLines count];
		NSAssert(0 < m_dataNum, @"データが一つもない。");
		mp_dataList	= (OJAMA_NETA_DATA*)malloc(m_dataNum * sizeof(OJAMA_NETA_DATA));
			
		for( SInt32 i = 0; i < m_dataNum; ++i )
		{
			pObj	= [pLines objectAtIndex:i];
		
			pDatas	= [pObj componentsSeparatedByString:@","];
			//	解析
			mp_dataList[ i ]	= [self parse:pDatas];
		}
		
		[pLines release];
	}
	
	return self;
}

/*
	@brief	破棄
*/
-(void)	dealloc
{
	free(mp_dataList);
	mp_dataList	= nil;

	[super dealloc];
}

/*
	@brief	データ解析
*/
-(OJAMA_NETA_DATA)	parse:(NSArray*)in_dataArray
{
	OJAMA_NETA_DATA	data	= { 0 };
	memset( &data, 0, sizeof(data) );

	SInt32	dataIdx	= 0;

	//	no
	data.no	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;
	
	//	x
	data.x	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;

	//	y
	data.y	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;

	//	乱数値
	data.randX	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;

	data.randY	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;
	
	SInt32	timeCnt	= sizeof(data.aChangeTime) / sizeof(data.aChangeTime[0]);
	for( SInt32 i = 0; i < timeCnt; ++i )
	{
		data.aChangeTime[i]	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
		++dataIdx;
	}

	data.money	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	data.score	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	data.time	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	//	データファイル名
	const char*	pStr	= [[in_dataArray objectAtIndex:dataIdx] UTF8String];
	memcpy( data.fileName, pStr, [[in_dataArray objectAtIndex:dataIdx] length]);
	++dataIdx;

	return data;
}

/*
	@brief	データ取得
*/
-(const OJAMA_NETA_DATA*)	getData:(UInt32)in_idx
{
	NSAssert( in_idx < m_dataNum, @"データベースリスト指定が間違っています" );
	
	return &mp_dataList[ in_idx ];
}

/*
	@brief	データ取得(id検索)
*/
-(const OJAMA_NETA_DATA*)	getDataSearchId:(UInt32)in_no
{
	for( SInt32 i = 0; i < m_dataNum; ++i )
	{
		if( mp_dataList[ i ].no == in_no )
		{
			return &mp_dataList[ i ];
		}
	}
	
	return nil;
}

@end
