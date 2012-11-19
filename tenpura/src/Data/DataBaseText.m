//
//  DataBaseText.m
//  tenpura
//
//  Created by y.uchida on 12/11/04.
//
//

#import "DataBaseText.h"

@interface DataBaseText (PrivateMethod)

-(void)	parse:(DATA_TEXT_ST*)out_pData:(NSArray*)in_dataArray;
-(const DATA_TEXT_ST*)getData:(const UInt32)in_no;

@end

@implementation DataBaseText

static DataBaseText*	s_pDataBaseTextInst	= nil;
static NSString*	s_pDataBaseTextFileName	= @"textData";

/*
	@brief
*/
+(DataBaseText*)	shared
{
	if( s_pDataBaseTextInst == nil )
	{
		s_pDataBaseTextInst	= [[DataBaseText alloc] init];
	}
	
	return s_pDataBaseTextInst;
}

/*
	@brief
*/
+(void)	end
{
	if( s_pDataBaseTextInst != nil )
	{
		[s_pDataBaseTextInst release];
		s_pDataBaseTextInst	= nil;
	}
}

/*
	@brief
*/
+(NSString*)getString:(const UInt32)in_no
{
	if( s_pDataBaseTextInst != nil )
	{
		const char*	pText	= [s_pDataBaseTextInst getText:in_no];
		if( pText != nil )
		{
			return [NSString stringWithUTF8String:pText];
		}
	}
	
	NSAssert(nil, @"error not id[%ld] text", in_no);

	return nil;
}

+(id)	alloc
{
	NSAssert(s_pDataBaseTextInst == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:s_pDataBaseTextFileName ofType:@"csv"];
		NSAssert(pPath != nil, @"テキストデータベースのファイル読み込み失敗");

		NSString*	pText	= [NSString stringWithContentsOfFile:pPath encoding:NSUTF8StringEncoding error:nil];
		NSString*	pDelmita	= @"\n";
		
		NSMutableArray*	pLines	= [[pText componentsSeparatedByString:pDelmita] mutableCopy];
		//	先頭のカテゴリ行と行末を削除
		[pLines removeObjectAtIndex:0];
		[pLines removeLastObject];
		
		NSString*	pObj	= nil;
		NSArray*	pItems	= nil;

		m_dataNum	= [pLines count];
		NSAssert(0 < m_dataNum, @"テキストデータがひとつもない");
		mp_dataList	= (DATA_TEXT_ST*)malloc(m_dataNum * sizeof(DATA_TEXT_ST));

		for( SInt32 i = 0; i < m_dataNum; ++i )
		{
			pObj	= [pLines objectAtIndex:i];
			
			pItems	= [pObj componentsSeparatedByString:@","];
			//	解析
			[self parse:&mp_dataList[ i ]:pItems];
		}
		
		[pLines release];
	}
	
	return self;
}

/*
	@brief	テキスト取得
*/
-(const char*)getText:(const UInt32)in_no
{
	const DATA_TEXT_ST*	pData	= [self getData:in_no];
	if( pData != nil )
	{
		if([NSLocalizedString(@"la",@"") isEqualToString:@"ja"])
		{
			// 日本語
			return pData->nameJPN;
		}
		else
		{
			// 英語
			return pData->nameEN;
		}
	}
	
	return nil;
}

/*
	@brief	テキスト取得
*/
-(const UInt32)	getFontSize:(const UInt32)in_no
{
	const DATA_TEXT_ST*	pData	= [self getData:in_no];
	if ( pData != nil )
	{
		//return pData->fontSize;
	}
	
	return 0;
}

/*
	@brief	指定した書式からテキストIDに変換
*/
-(const SInt32)getConvertID:(const char*)in_pText
{
	SInt32	no	= -1;
	if( in_pText == nil )
	{
		return no;
	}
	
	//	textID:XX
	NSScanner*	pScanner	= [NSScanner scannerWithString:[NSString stringWithUTF8String:in_pText]];
	if( [pScanner scanString:@"textID:" intoString:nil] )
	{
		int	id	= 0;
		[pScanner scanInt:&id];
		no	= (SInt32)id;
	}
	
	return no;
}

/*
	@brief
*/
-(const DATA_TEXT_ST*)	getData:(const UInt32)in_no
{
	UInt32	num	= m_dataNum;
	for( UInt32 i = 0; i < num; ++i )
	{
		if( mp_dataList[i].no == in_no )
		{
			return &mp_dataList[i];
		}
	}

	return nil;
}

/*
	@brief	データ解析
*/
-(void)	parse:(DATA_TEXT_ST*)out_pData:(NSArray*)in_dataArray
{
	NSAssert(out_pData != nil, @"設定対象データがない");

	memset( out_pData, 0, sizeof(DATA_TEXT_ST) );

	SInt32	dataIdx	= 0;

	//	no
	out_pData->no	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;
	
	//	名称
	const char*	pStr	= [[in_dataArray objectAtIndex:dataIdx] UTF8String];
	strcpy( out_pData->nameJPN, pStr );
	++dataIdx;

	//	名称
	pStr	= [[in_dataArray objectAtIndex:dataIdx] UTF8String];
	strcpy( out_pData->nameEN, pStr );
	++dataIdx;
}

@end
