//
//  DataSaveGame.m
//  tenpura
//
//  Created by y.uchida on 12/10/31.
//
//

#import "DataSaveGame.h"

#import "./../System/Save/SaveData.h"

//	非公開関数
@interface DataSaveGame (PriveteMethod)

-(SAVE_DATA_ITEM_ST*)	_getNeta:(UInt32)in_no;
-(SAVE_DATA_ITEM_ST*)	_getItem:(UInt32)in_no;

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
	@brief	終了
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
	@brief	初期化
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
	@brief	指定したnoネタを取得
	@param	in_no	: アイテムno
	@return	アイテムnoのデータアドレス
*/
-(const SAVE_DATA_ITEM_ST*)getNeta:(UInt32)in_no
{
	return [self _getNeta:in_no];
}

/*
	@brief	指定したリストidxからネタ取得
	@parma	in_idx	: アイテムリストidx
	@return	指定したアイテムリストidxのデータアドレス
*/
-(const SAVE_DATA_ITEM_ST*)getNetaOfIndex:(UInt32)in_idx
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		if( 0 < pData->aNetas[in_idx].num )
		{
			return &pData->aNetas[in_idx];
		}
	}
	
	return nil;
}

/*
	@brief	指定したnoアイテムを取得
	@param	in_no	: アイテムno
	@return	アイテムnoのデータアドレス
*/
-(const SAVE_DATA_ITEM_ST*)getItem:(UInt32)in_no
{
	return [self _getItem:in_no];
}

/*
	@brief	指定したリストidxからアイテム取得
	@parma	in_idx	: アイテムリストidx
	@return	指定したアイテムリストidxのデータアドレス
*/
-(const SAVE_DATA_ITEM_ST*)getItemOfIndex:(UInt32)in_idx
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
	@brief	ネタ追加
	@param	in_no	: 追加するネタno(1つ追加)
	@return	追加成功 = YES / 追加失敗 = NO
*/
-(BOOL)addNeta:(UInt32)in_no
{
	SAVE_DATA_ITEM_ST*	pItem	= [self _getNeta:in_no];

	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		if( ( pData->netaNum < ( eITEMS_MAX - 1 ) ) && ( pItem == nil ) )
		{
			//	追加可能
			pData->aNetas[ pData->netaNum ].no	= in_no;
			++pData->aNetas[ pData->netaNum ].num;
			++pData->netaNum;
			
			[mp_SaveData save];

			return YES;
		}
		else if( ( pItem != nil ) && ( pItem->num < eNETA_USE_MAX ) )
		{
			pItem->num += 1;
			
			[mp_SaveData save];

			return YES;
		}
		else
		{
			NSAssert(0, @"これ以上セーブデータに所持ネタ追加ができません");
		}
	}
	
	return NO;
}

/*
	@brief	ネタ減らす
	@param	in_no	: 減らすするネタno(1つ減らす)
	@return	成功 = YES / 失敗 = NO
*/
-(BOOL)subNeta:(UInt32)in_no
{
	SAVE_DATA_ITEM_ST*	pItem	= [self _getNeta:in_no];

	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		if( ( pData->netaNum < ( eITEMS_MAX - 1 ) ) && ( pItem == nil ) )
		{
			return NO;
		}
		else if( ( pItem != nil ) && ( pItem->num < eNETA_USE_MAX ) )
		{
			pItem->num -= 1;
			if( pItem->num <= 0 )
			{
				--pData->netaNum;
			}

			[mp_SaveData save];

			return YES;
		}
	}
	
	return NO;
}

/*
	@brief	アイテム追加
	@param	in_no	: 追加するアイテムno(1つ追加)
	@return	追加成功 = YES / 追加失敗 = NO
*/
-(BOOL)addItem:(UInt32)in_no
{
	SAVE_DATA_ITEM_ST*	pItem	= [self _getItem:in_no];

	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		if( ( pData->itemNum < ( eITEMS_MAX - 1 ) ) && ( pItem == nil ) )
		{
			//	追加可能
			pData->aItems[ pData->itemNum ].no	= in_no;
			++pData->aItems[ pData->itemNum ].num;
			++pData->itemNum;
			
			[mp_SaveData save];

			return YES;
		}
		else if( pItem != nil )
		{
			pItem->num += 1;
			
			[mp_SaveData save];

			return YES;
		}
		else
		{
			NSAssert(0, @"これ以上セーブデータに所持アイテム追加ができません");
		}
	}
	
	return NO;
}

/*
	@brief	スコア追加
	@param	in_score	: 加算するスコア数
*/
-(void)	addSaveScore:(int64_t)in_score
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert( pData, @"セーブデータ取得失敗" );

	if( pData != nil )
	{
		pData->score	+= in_score;
		[mp_SaveData save];
	}
}

/*
	@brief	金額加算
	@param	in_addMoney : 追加する金額
*/
-(void)	addSaveMoeny:(long)in_addMoney
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert( pData, @"セーブデータ取得失敗" );

	if( pData != nil )
	{
		pData->money	= pData->money + in_addMoney;
		[mp_SaveData save];
	}
}

/*
	@brief	現在時刻を記録
	@return	時刻セーブ成功 = YES
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

		return YES;
	}
	
	NSAssert( 0, @"セーブデータ取得失敗" );
	return NO;
}

/*
	@brief	ミッションフラグをたてる
	@param	設定するフラグ / 設定するミッションリストidx
*/
-(void)	saveMissionFlg:(BOOL)in_flg :(UInt32)in_idx;
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( (pData != nil) && (in_idx < eMISSION_MAX) )
	{
		pData->aMissionFlg[in_idx]	= in_flg;
		
		[mp_SaveData save];
	}
}

/*
	@brief	ランク設定
	@param	設定するランク値
*/
-(void)	saveRank:(char)in_rank
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		pData->rank	= in_rank;
		[mp_SaveData save];
	}
}

/*
	@brief	データ丸ごとアドレス取得
	@return	データアドレス
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
	@param	out_pData	: リセットデータを受け取る構造体アドレス
*/
-(void)	getInitSaveData:(SAVE_DATA_ST*)out_pData
{
	if( out_pData == NULL )
	{
		return;
	}
	
	memset( out_pData, 0, sizeof( SAVE_DATA_ST ) );
	out_pData->money	= 1000;
	out_pData->aNetas[ 0 ].no	= 1;
	out_pData->aNetas[ 0 ].num	= 1;
	out_pData->netaNum	= 1;
}

/*
	@brief	指定したnoから特定のネタデータを取得
	@param	in_no : ネタno
	@return	noネタデータ / nil = ネタデータがない or アイテム数が０
*/
-(SAVE_DATA_ITEM_ST*)	_getNeta:(UInt32)in_no
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		for( SInt32 i = 0; i < pData->netaNum; ++i )
		{
			if( ( pData->aNetas[ i ].no == in_no ) && ( 0 < pData->aNetas[ i ].num ) )
			{
				return &pData->aNetas[ i ];
			}
		}
	}
	
	return nil;
}

/*
	@brief	指定したnoから特定のアイテムデータを取得
	@param	in_no : アイテムno
	@return	noアイテムデータ / nil = アイテムデータがない or アイテム数が０
*/
-(SAVE_DATA_ITEM_ST*)	_getItem:(UInt32)in_no
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		for( SInt32 i = 0; i < pData->itemNum; ++i )
		{
			if( ( pData->aItems[ i ].no == in_no ) && ( 0 < pData->aItems[ i ].num ) )
			{
				return &pData->aItems[ i ];
			}
		}
	}
	
	return nil;
}

@end
