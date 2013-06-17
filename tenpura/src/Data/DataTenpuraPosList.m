//
//  DataTenpuraPosList.m
//  tenpura
//
//  Created by y.uchida on 12/10/15.
//
//

#import "DataTenpuraPosList.h"

//	非公開関数
@interface DataTenpuraPosList (PrivateMethod)

//	データ解析
-(TENPURA_POS_ST)	parse:(NSArray*)in_dataArray;

@end

@implementation DataTenpuraPosList

//	プロパティ
@synthesize dataNum	= m_dataNum;

static DataTenpuraPosList*	s_pDatTenpuraPosListInst	= nil;

/*
	@brief
*/
+(DataTenpuraPosList*)shared
{
	if( s_pDatTenpuraPosListInst == nil )
	{
		s_pDatTenpuraPosListInst	= [[DataTenpuraPosList alloc] init];
	}
	
	return s_pDatTenpuraPosListInst;
}

/*
	@brief
*/
+(void)end
{
	if( s_pDatTenpuraPosListInst != nil )
	{
		[s_pDatTenpuraPosListInst release];
		s_pDatTenpuraPosListInst	= nil;
	}
}

+(id)alloc
{
	NSAssert(s_pDatTenpuraPosListInst == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

/*
	@breif	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:@"tenpuraPosList" ofType:@"csv"];

		NSString*	pText	= [NSString stringWithContentsOfFile:pPath encoding:NSUTF8StringEncoding error:nil];
		NSString*	pDelmita	= @"\n";
		
		NSMutableArray*	pLines	= [[pText componentsSeparatedByString:pDelmita] mutableCopy];
		//	先頭のカテゴリ行と行末を削除
		[pLines removeObjectAtIndex:0];
		[pLines removeLastObject];
		
		NSString*	pObj	= nil;
		NSArray*	pItems	= nil;

		UInt32  dataNum = [pLines count];
		NSAssert(0 < dataNum, @"天ぷら座標データが一つもない");
		mp_dataList	= (TENPURA_POS_ST*)malloc(dataNum * sizeof(TENPURA_POS_ST));

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
	if( mp_dataList != nil )
	{
		free(mp_dataList);
	}
		
	[super dealloc];
}

/*
	@brief
*/
-(TENPURA_POS_ST)getData:(UInt32)in_idx
{
	TENPURA_POS_ST	data;
	memset(&data, 0, sizeof(data));
	
	if( in_idx < m_dataNum )
	{
		data	= mp_dataList[ in_idx ];
	}
	
	return data;
}

/*
	@brief
*/
-(UInt32)getIdxNoUse
{
	UInt32	idx	= rand() % m_dataNum;
	
	for( UInt32	i = 0; i < m_dataNum; ++i )
	{
		if( mp_dataList[ idx ].bUse == NO )
		{
			break;
		}
		
		++idx;
		idx	= idx % m_dataNum;
	}
	
	return idx;
}

/*
	@brief
*/
-(void)setUseFlg:(BOOL)in_flg :(UInt32)in_idx
{
	if( in_idx < m_dataNum )
	{
		mp_dataList[ in_idx ].bUse	= in_flg;
	}
}

/*
	@brief
*/
-(BOOL)isUse:(UInt32)in_idx
{
	BOOL	flg	= NO;
	if( in_idx < m_dataNum )
	{
		flg	= mp_dataList[ in_idx ].bUse;
	}
	
	return flg;
}

/*
	@brief
*/
-(void)	clearFlg
{
	SInt32	i	= 0;
	for( i = 0; i < m_dataNum; ++i )
	{
		mp_dataList[i].bUse	= NO;
	}
}

/*
	@brief	データ解析
*/
-(TENPURA_POS_ST)	parse:(NSArray*)in_dataArray
{
	TENPURA_POS_ST	data	= { 0 };
	memset( &data, 0, sizeof(data) );

	SInt32	dataIdx	= 0;

	//	no
	data.x	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;

	data.y	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] floatValue];
	++dataIdx;
	
	data.bUse	= NO;
	
	return data;
}

@end
