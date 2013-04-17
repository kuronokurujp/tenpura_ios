//
//  DataNetaPackList.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import "DataNetaPackList.h"

//	非公開関数
@interface DataNetaPackList (PrivateMethod)

-(NETA_PACK_DATA_ST)	parse:(NSArray*)in_dataArray;

@end

@implementation DataNetaPackList

//	プロパティ
@synthesize dataNum	= m_dataNum;

static DataNetaPackList*	s_pInst	= nil;

/*
	@brief
*/
+(DataNetaPackList*)shared
{
	if( s_pInst == nil )
	{
		s_pInst	= [[DataNetaPackList alloc] init];
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
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:@"netaPackList" ofType:@"csv"];

		NSString*	pText	= [NSString stringWithContentsOfFile:pPath encoding:NSUTF8StringEncoding error:nil];
		NSString*	pDelmita	= @"\n";
		
		NSMutableArray*	pLines	= [[pText componentsSeparatedByString:pDelmita] mutableCopy];
		//	先頭のカテゴリ行と行末を削除
		[pLines removeObjectAtIndex:0];
		[pLines removeLastObject];
		
		NSString*	pObj	= nil;
		NSArray*	pItems	= nil;

		m_dataNum	= [pLines count];
		NSAssert(0 < m_dataNum, @"ネタパックデータが一つもない。");
		mp_dataList	= (NETA_PACK_DATA_ST*)malloc(m_dataNum * sizeof(NETA_PACK_DATA_ST));
			
		for( SInt32 i = 0; i < m_dataNum; ++i )
		{
			pObj	= [pLines objectAtIndex:i];
		
			pItems	= [pObj componentsSeparatedByString:@","];
			//	解析
			mp_dataList[ i ]	= [self parse:pItems];
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
-(NETA_PACK_DATA_ST)	parse:(NSArray*)in_dataArray
{
	NETA_PACK_DATA_ST	data	= { 0 };
	memset( &data, 0, sizeof(data) );

	SInt32	dataIdx	= 0;

	//	no
	data.no	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;
	
	//	名称
	data.textID	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	SInt32	netaDataNum	= sizeof(data.aNetaId) / sizeof(data.aNetaId[0]);
	for( SInt32 i = 0; i < netaDataNum; ++i )
	{
		data.aNetaId[i]	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
		++dataIdx;
	}

	//	ショップ販売金額
	data.money	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

	return data;
}

/*
	@brief	データ取得
*/
-(const NETA_PACK_DATA_ST*)	getData:(UInt32)in_idx
{
	if( in_idx < m_dataNum )
	{
		return &mp_dataList[ in_idx ];
	}
	
	return NULL;
}

/*
	@brief	データ取得(id検索)
*/
-(const NETA_PACK_DATA_ST*)	getDataSearchId:(UInt32)in_no
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
