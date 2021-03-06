//
//  DataNetaList.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import "DataNetaList.h"

//	非公開関数
@interface DataNetaList (PrivateMethod)

-(NETA_DATA_ST)	parse:(NSArray*)in_dataArray;

@end

@implementation DataNetaList

//	プロパティ
@synthesize dataNum	= m_dataNum;

static DataNetaList*	s_pInst	= nil;

/*
	@brief
*/
+(DataNetaList*)shared
{
	if( s_pInst == nil )
	{
		s_pInst	= [[DataNetaList alloc] init];
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
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:@"netaList" ofType:@"csv"];

		NSString*	pText	= [NSString stringWithContentsOfFile:pPath encoding:NSUTF8StringEncoding error:nil];
		NSString*	pDelmita	= @"\n";
		
		NSMutableArray*	pLines	= [[pText componentsSeparatedByString:pDelmita] mutableCopy];
		//	先頭のカテゴリ行と行末を削除
		[pLines removeObjectAtIndex:0];
		[pLines removeLastObject];
		
		NSString*	pObj	= nil;
		NSArray*	pItems	= nil;

		UInt32  dataNum = [pLines count];
		NSAssert(0 < dataNum, @"ネタデータが一つもない。");
		mp_dataList	= (NETA_DATA_ST*)malloc(dataNum * sizeof(NETA_DATA_ST));
			
		for( SInt32 i = 0; i < dataNum; ++i )
		{
			pObj	= [pLines objectAtIndex:i];
		
			pItems	= [pObj componentsSeparatedByString:@","];
			//	解析
			mp_dataList[ i ]	= [self parse:pItems];
		}
        m_dataNum   = dataNum;
		
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
-(NETA_DATA_ST)	parse:(NSArray*)in_dataArray
{
	NETA_DATA_ST	data	= { 0 };
	memset( &data, 0, sizeof(data) );

	SInt32	dataIdx	= 0;

	//	no
	data.no	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;
	
	//	名称
	data.textID	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	//	食べる時間
	data.eatTime	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;
	
	//	揚げる時間
	SInt32	num	= sizeof(data.aStatusList) / sizeof(data.aStatusList[0]);
	for( SInt32 i = 0; i < num; ++i )
	{
		data.aStatusList[i].changeTime	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
		++dataIdx;
		
		//	スコア
		data.aStatusList[i].score		= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
		++dataIdx;
	
		//	取得金額
		data.aStatusList[i].money	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
		++dataIdx;
	}

	//	データファイル名
	const char*	pStr	= [[in_dataArray objectAtIndex:dataIdx] UTF8String];
	memcpy( data.fileName, pStr, [[in_dataArray objectAtIndex:dataIdx] length]);
	++dataIdx;
	
	return data;
}

/*
	@brief	データ取得
*/
-(const NETA_DATA_ST*)	getData:(UInt32)in_idx
{
	NSAssert( in_idx < m_dataNum, @"ネタデータベースリスト指定が間違っています" );
	
	return &mp_dataList[ in_idx ];
}

/*
	@brief	データ取得(id検索)
*/
-(const NETA_DATA_ST*)	getDataSearchId:(UInt32)in_no
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
