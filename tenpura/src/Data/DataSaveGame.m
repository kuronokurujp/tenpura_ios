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
-(const SAVE_DATA_ITEM_ST*)isItem:(UInt32)in_no
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		for( SInt32 i = 0; i < pData->itemNum; ++i )
		{
			if( ( pData->aItems[ i ].id == in_no ) && ( 0 < pData->aItems[ i ].num ) )
			{
				return &pData->aItems[ i ];
			}
		}
	}
	
	return nil;
}

/*
	@brief	すでにアイテムを持っているかどうか
*/
-(const SAVE_DATA_ITEM_ST*)isItemOfIndex:(UInt32)in_idx
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		if( 0 < pData->aItems[in_idx].num )
		{
			return &pData->aItems[in_idx];
		}
	}
	
	return nil;
}

/*
	@brief	アイテム追加
*/
-(BOOL)addItem:(UInt32)in_no
{
	const SAVE_DATA_ITEM_ST*	pItem	= [self isItem:in_no];

	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		if( ( pData->itemNum < ( eITEMS_MAX - 1 ) ) && ( pItem == nil ) )
		{
			//	追加可能
			pData->aItems[ pData->itemNum ].id	= in_no;
			++pData->aItems[ pData->itemNum ].num;
			++pData->itemNum;
			
			[mp_SaveData save];

			return YES;
		}
		else if( pItem != nil )
		{
			++pData->aItems[ in_no ].num;
		}
		else
		{
			NSAssert(0, @"これ以上セーブデータに所持アイテム追加ができません");
		}
	}
	
	return NO;
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
	out_pData->aItems[ 0 ].id	= 1;
	out_pData->aItems[ 0 ].num	= 1;
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
