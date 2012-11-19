//
//  DataSaveGame.m
//  tenpura
//
//  Created by y.uchida on 12/10/31.
//
//

#import "DataSaveGame.h"

#import "./../System/Save/SaveData.h"

@interface DataSaveGame (PriveteMethod)

-(void)	_setSaveScore:(int64_t)in_score;
-(void)	_addSaveMoeny:(UInt32)in_addMoney;

@end

@implementation DataSaveGame

static DataSaveGame*	s_pDataSaveGameInst	= nil;
static NSString*		s_pSaveIdName	= @"TenpuraGameData";

/*
	@brief
*/
+(DataSaveGame*)shared
{
	if( s_pDataSaveGameInst == nil )
	{
		s_pDataSaveGameInst	= [[DataSaveGame alloc] init];
	}
	
	return s_pDataSaveGameInst;
}

/*
	@brief
*/
+(void)end
{
	if( s_pDataSaveGameInst != nil )
	{
		[s_pDataSaveGameInst release];
		s_pDataSaveGameInst	= nil;
	}
}

+(id)alloc
{
	NSAssert(s_pDataSaveGameInst == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_SaveData	= [SaveData alloc];
		[mp_SaveData setup:s_pSaveIdName :sizeof(SAVE_DATA_ST)];
		[mp_SaveData load];
		
		SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
		if( pData != nil )
		{
			if( pData->use == 0 )
			{
				//	データがない
				//	リセットしてセーブする
				[self reset];
			}
		}
	}

	return self;
}

/*
	@brief
*/
-(void)dealloc
{
	if( mp_SaveData != nil )
	{
		[mp_SaveData release];
	}
	
	mp_SaveData	= nil;
	
	[super dealloc];
}

/*
	@brief	リセット
*/
-(BOOL)reset
{
	[mp_SaveData reset];
	
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		[self getInitSaveData:pData ];
		[self saveDate];
		pData->use	= 1;
	}
	
	[mp_SaveData save];
	
	return TRUE;
}

/*
	@brief	すでにアイテムを持っているかどうか
*/
-(BOOL)isItem:(UInt32)in_no
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		for( SInt32 i = 0; i < pData->itemNum; ++i )
		{
			if( pData->aItems[ i ] == in_no )
			{
				return TRUE;
			}
		}
	}
	
	return FALSE;
}

/*
	@brief	アイテム追加
*/
-(BOOL)addItem:(UInt32)in_no
{
	if( [self isItem:in_no] == TRUE )
	{
		return FALSE;
	}

	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		if( pData->itemNum < ( eITEMS_MAX - 1 ) )
		{
			//	追加可能
			pData->aItems[ pData->itemNum ]	= in_no;
			++pData->itemNum;
			
			[mp_SaveData save];

			return TRUE;
		}
		else
		{
			NSAssert(0, @"これ以上セーブデータに所持アイテム追加ができません");
		}
	}
	
	return FALSE;
}

/*
	@brief	現在時刻を記録
*/
-(BOOL)	saveDate
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		NSDate*	pDt					= [NSDate date];
		NSCalendar*	pCal			= [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
		NSDateComponents*	pComp	= [pCal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:pDt];
	
		pData->year		= pComp.year;
		pData->month	= pComp.month;
		pData->day		= pComp.day;

		[mp_SaveData save];

		return TRUE;
	}
	
	NSAssert( 0, @"セーブデータ取得失敗" );
	return FALSE;
}

/*
	@brief
*/
-(const SAVE_DATA_ST*)getData
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		return pData;
	}
	
	NSAssert( 0, @"セーブデータ取得失敗" );
	return nil;
}

/*
	@brief	セーブ初期データ取得
*/
-(void)	getInitSaveData:(SAVE_DATA_ST*)out_pData
{
	if( out_pData == NULL )
	{
		return;
	}
	
	memset( out_pData, 0, sizeof( SAVE_DATA_ST ) );
	out_pData->money	= 1000;
	out_pData->aItems[ 0 ]	= 1;
	out_pData->itemNum	= 1;
}

/*
	@brief	スコア設定
*/
-(void)	_setSaveScore:(int64_t)in_score
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert( pData, @"セーブデータ取得失敗" );

	if( pData != nil )
	{
		pData->score	= in_score;
		[mp_SaveData save];
	}
}

/*
	@brief	金額加算
*/
-(void)	_addSaveMoeny:(UInt32)in_addMoney
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert( pData, @"セーブデータ取得失敗" );

	if( pData != nil )
	{
		pData->money	= pData->money + in_addMoney;
		[mp_SaveData save];
	}
}

@end
