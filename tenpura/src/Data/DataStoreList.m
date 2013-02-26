//
//  DataStoreList.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import "DataStoreList.h"

//	非公開関数
@interface DataStoreList (PrivateMethod)

-(STORE_DATA)	parse:(NSArray*)in_dataArray;

@end

@implementation DataStoreList

//	プロパティ
@synthesize dataNum	= m_dataNum;

static DataStoreList*	s_pInst	= nil;

/*
	@brief
*/
+(DataStoreList*)shared
{
	if( s_pInst == nil )
	{
		s_pInst	= [[DataStoreList alloc] init];
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
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:@"storeDataList" ofType:@"csv"];
		NSAssert(pPath, @"storeDataList.csvファイルがない");

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
		mp_dataList	= (STORE_DATA*)malloc(m_dataNum * sizeof(STORE_DATA));
			
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
-(STORE_DATA)	parse:(NSArray*)in_dataArray
{
	STORE_DATA	data	= { 0 };
	memset( &data, 0, sizeof(data) );

	SInt32	dataIdx	= 0;

	//	no
	data.no	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;
	
	//	textId
	data.textId	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	//	money
	data.money	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	//	ストアID名
	const char*	pStr	= [[in_dataArray objectAtIndex:dataIdx] UTF8String];
	memcpy( data.aStoreIdName, pStr, [[in_dataArray objectAtIndex:dataIdx] length]);
	++dataIdx;

	return data;
}

/*
	@brief	データ取得
*/
-(const STORE_DATA*)	getData:(UInt32)in_idx
{
	NSAssert( in_idx < m_dataNum, @"データベースリスト指定が間違っています" );
	
	return &mp_dataList[ in_idx ];
}

/*
	@brief	データ取得(id検索)
*/
-(const STORE_DATA*)	getDataSearchId:(UInt32)in_no
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
