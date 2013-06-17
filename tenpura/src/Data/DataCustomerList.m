//
//  DataCustomerList.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import "DataCustomerList.h"

//	非公開関数
@interface DataCustomerList (PrivateMethod)

-(CUSTOMER_DATA_ST)	parse:(NSArray*)in_dataArray;

@end

@implementation DataCustomerList

//	プロパティ
@synthesize dataNum	= m_dataNum;

static DataCustomerList*	s_pInst	= nil;

/*
	@brief
*/
+(DataCustomerList*)shared
{
	if( s_pInst == nil )
	{
		s_pInst	= [[DataCustomerList alloc] init];
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
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:@"customerListData" ofType:@"csv"];
		NSAssert(pPath, @"customerListData.csvファイルがない");

		NSString*	pText	= [NSString stringWithContentsOfFile:pPath encoding:NSUTF8StringEncoding error:nil];
		NSString*	pDelmita	= @"\n";
		
		NSMutableArray*	pLines	= [[pText componentsSeparatedByString:pDelmita] mutableCopy];
		//	先頭のカテゴリ行と行末を削除
		[pLines removeObjectAtIndex:0];
		[pLines removeLastObject];
		
		NSString*	pObj	= nil;
		NSArray*	pDatas	= nil;

		UInt32  dataNum = [pLines count];
		NSAssert(0 < dataNum, @"カスタムデータが一つもない。");
		mp_dataList	= (CUSTOMER_DATA_ST*)malloc(dataNum * sizeof(CUSTOMER_DATA_ST));
			
		for( SInt32 i = 0; i < dataNum; ++i )
		{
			pObj	= [pLines objectAtIndex:i];
		
			pDatas	= [pObj componentsSeparatedByString:@","];
			//	解析
			mp_dataList[ i ]	= [self parse:pDatas];
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
-(CUSTOMER_DATA_ST)	parse:(NSArray*)in_dataArray
{
	CUSTOMER_DATA_ST	data	= { 0 };
	memset( &data, 0, sizeof(data) );

	SInt32	dataIdx	= 0;

	//	no
	data.no	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;
	
	//	食べる速度
	data.eatTime	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;

	//	取得金額の比率
	data.moneyRate	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;

	//	取得スコアの比率
	data.scoreRate	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;
	
	return data;
}

/*
	@brief	データ取得
*/
-(const CUSTOMER_DATA_ST*)	getData:(UInt32)in_idx
{
	NSAssert( in_idx < m_dataNum, @"カスタムデータベースリスト指定が間違っています" );
	
	return &mp_dataList[ in_idx ];
}

/*
	@brief	データ取得(id検索)
*/
-(const CUSTOMER_DATA_ST*)	getDataSearchId:(UInt32)in_no
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
