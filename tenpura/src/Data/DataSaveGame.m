//
//  DataSaveGame.m
//  tenpura
//
//  Created by y.uchida on 12/10/31.
//
//

#import "DataSaveGame.h"

#import "./DataItemList.h"
#import "./../System/Save/SaveData.h"

//	非公開関数
@interface DataSaveGame (PriveteMethod)

-(SAVE_DATA_NETA_ST*)	_getNetaPack:(UInt32)in_no;
-(SAVE_DATA_ITEM_ST*)	_getItem:(UInt32)in_no :(const BOOL)in_chkNum;

@end

@implementation DataSaveGame

static DataSaveGame*	s_pDataSaveGameInst	= nil;
static NSString*		s_pSaveIdName	= @"TenpuraGameData";
static const UInt16   s_maxLv_dataSaveGame    = 999;

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
				[self reset: [DataItemList shared]];
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
-(BOOL)reset:(DataItemList*)in_pDataItamList
{
    NSAssert(in_pDataItamList, @"");

	[mp_SaveData reset];
	
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		[self getInitSaveData:pData: in_pDataItamList];
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
-(const SAVE_DATA_NETA_ST*)getNetaPack:(UInt32)in_no
{
	return [self _getNetaPack:in_no];
}

/*
	@brief	指定したリストidxからネタ取得
	@parma	in_idx	: アイテムリストidx
	@return	指定したアイテムリストidxのデータアドレス
*/
-(const SAVE_DATA_NETA_ST*)getNetaPackOfIndex:(UInt32)in_idx
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( (pData != nil) && (in_idx < pData->netaNum) )
	{
		if( 0 < pData->aNetaPacks[in_idx].num )
		{
			return &pData->aNetaPacks[in_idx];
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
	return [self _getItem:in_no :YES];
}

/*
	@brief	指定したリストidxからアイテム取得
	@parma	in_idx	: アイテムリストidx
	@return	指定したアイテムリストidxのデータアドレス
*/
-(const SAVE_DATA_ITEM_ST*)getItemOfIndex:(UInt32)in_idx
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( (pData != nil) && (in_idx < pData->itemNum) )
	{
		if( 0 < pData->aItems[in_idx].num )
		{
			return &pData->aItems[in_idx];
		}
	}
	
	return nil;
}

//  アイテムロック取得
-(const BOOL)   isLockItem:(const UInt32)in_no
{
    const SAVE_DATA_ITEM_ST*    pItemData   = [self _getItem:in_no :NO];
    if( pItemData != nil )
    {
        return  (pItemData->unlockFlg == 1);
    }
    
    return NO;
}

//  アイテムロック解除
-(void) unlockItem:(const UInt32)in_no
{
    SAVE_DATA_ITEM_ST*    pItemData   = [self _getItem:in_no :NO];
    if( pItemData != nil )
    {
        pItemData->unlockFlg = 1;
    }    
}

/*
	@brief	ネタ追加
	@param	in_no	: 追加するネタno(1つ追加)
	@return	追加成功 = YES / 追加失敗 = NO
*/
-(BOOL)addNetaPack:(UInt32)in_no
{
	SAVE_DATA_NETA_ST*	pItem	= [self _getNetaPack:in_no];

	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		if( ( pData->netaNum < eSAVE_DATA_ITEMS_MAX ) && ( pItem == nil ) )
		{
			//	追加可能
			SAVE_DATA_NETA_ST*	pAddItem	= &pData->aNetaPacks[ pData->netaNum ];
			pAddItem->no	= in_no;
			pAddItem->unlockFlg	= 1;
			++pAddItem->num;

			++pData->netaNum;
			
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
    @brief
 */
-(const BOOL) setHiscoreNetaPack:(UInt32)in_no :(SInt32)in_hiscore
{
    SAVE_DATA_NETA_ST*  pSaveNetaData   = [self _getNetaPack:in_no];
    if( pSaveNetaData->hiscore < in_hiscore )
    {
        pSaveNetaData->hiscore  = in_hiscore;
        [mp_SaveData save];
        return YES;
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
	SAVE_DATA_ITEM_ST*	pItem	= [self _getItem:in_no :YES];

	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		if( ( pData->itemNum < eSAVE_DATA_ITEMS_MAX ) && ( pItem == nil ) )
		{
			//	追加可能
			SAVE_DATA_ITEM_ST*	pAddItem	= &pData->aItems[ pData->itemNum ];
			pAddItem->no	= in_no;
			pAddItem->unlockFlg	= 1;
			++pAddItem->num;
			++pData->itemNum;
			
			[mp_SaveData save];

			return YES;
		}
		else if( pItem != nil )
		{
            if( pItem->num < eSAVE_DATA_ITEM_USE_MAX )
            {
                pItem->num += 1;
                
                [mp_SaveData save];
                
                return YES;
            }
		}
		else
		{
			NSAssert(0, @"これ以上セーブデータに所持アイテム追加ができません");
		}
	}
	
	return NO;
}

/*
    @brief
 */
-(BOOL) subItem:(UInt32)in_no
{
	SAVE_DATA_ITEM_ST*	pItem	= [self _getItem:in_no :YES];
    if( pItem != NULL )
    {
        --pItem->num;
        return YES;
    }

    return NO;
}

/*
	@brief	スコア設定
	@param	in_score	: スコア数
*/
-(void)	setSaveScore:(SInt32)in_score
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert( pData, @"セーブデータ取得失敗" );

	if( pData != nil )
	{
		pData->score	= MIN( in_score, eSCORE_MAX_NUM );
		[mp_SaveData save];
	}
}

/*
    @brief
 */
-(const BOOL) setPutCustomerMaxNum:(UInt8)in_num
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert( pData, @"セーブデータ取得失敗" );
    
	if( pData != nil && pData->putCustomerMaxnum < in_num)
	{
		pData->putCustomerMaxnum	= in_num;
		[mp_SaveData save];
        
        return YES;
	}
    
    return NO;
}

/*
    @brief
 */
-(const BOOL) setEatTenpuraMaxNum:(UInt8)in_num
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert( pData, @"セーブデータ取得失敗" );
    
	if( pData != nil && pData->eatTenpuraMaxNum < in_num)
	{
		pData->eatTenpuraMaxNum	= in_num;
		[mp_SaveData save];
        
        return YES;
	}
    
    return NO;
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
		pData->money	= MIN(pData->money, eMONEY_MAX_NUM);
		[mp_SaveData save];
	}
}

/*
	@brief	ミッションフラグをたてる
	@param	設定するフラグ / 設定するミッションリストidx
*/
-(void)	saveMissionFlg:(BOOL)in_flg :(UInt32)in_idx;
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( (pData != nil) && (in_idx < eSAVE_DATA_MISSION_MAX) )
	{
		pData->aMissionFlg[in_idx]	= in_flg;
		
		[mp_SaveData save];
	}
}

/*
    @brief  ライフ増減
 */
-(void) addPlayLife:(const SInt8)in_num :(const BOOL)in_bSaveLiefTime
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
    SInt8   oldPlayerLife   = pData->playLife;
    pData->playLife += in_num;
    
    pData->playLife = MIN(pData->playLife, eSAVE_DATA_PLAY_LIEF_MAX);
    pData->playLife = MAX(pData->playLife, 0);
    
    BOOL    bSaveTime   = in_bSaveLiefTime;
    if( pData->playLife < eSAVE_DATA_PLAY_LIEF_MAX )
    {
        if( (in_num < 0) && (eSAVE_DATA_PLAY_LIEF_MAX <= oldPlayerLife) )
        {
            bSaveTime   = YES;
        }
        
        if( bSaveTime )
        {
            //  時間を記録
            NSDate* pDt = [NSDate date];
            NSDateFormatter*    pFmt    = [[[NSDateFormatter alloc] init] autorelease];
            pFmt.dateFormat = @"yyyy/MM/dd HH:mm:ss";
            NSString* pString  = [pFmt stringFromDate:pDt];
            
            //	イベント発生時の時刻
            const char*	pDateText	= [pString UTF8String];
            memcpy( pData->aCureTimeStr, pDateText, sizeof(pData->aCureTimeStr));
        }
    }
    
    [mp_SaveData save];
}

/*
    @brief  なべ経験値加算
 */
-(BOOL) addNabeExp:(UInt16)in_expNum
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
    {
        pData->nabeExp += in_expNum;
        if( eNABE_LVUP_NUM <= pData->nabeExp )
        {
            UInt16 addLv    = pData->nabeExp / eNABE_LVUP_NUM;
            pData->nabeLv += addLv;
            if( s_maxLv_dataSaveGame <= pData->nabeLv )
            {
                pData->nabeLv   = s_maxLv_dataSaveGame;
            }
            
            return true;
        }
    }

    return false;
}

/*
    @brief  イベント設定
 */
-(void)   setEventNo:(SInt8)in_no
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert(pData, @"");

    pData->invocEventNo = in_no;
    pData->successEventNo   = -1;
    pData->chkEventPlayCnt  = 0;
    
    SInt8 netaIdx   = (SInt8)(random() % (long)pData->netaNum);
    pData->eventNetaPackNo  = pData->aNetaPacks[netaIdx].no;

    pData->eventEatTenpuraMaxNum  = pData->eatTenpuraMaxNum;
    pData->eventPutCustomerMaxnum = pData->putCustomerMaxnum;
    pData->eventScore = pData->score;
    
    SAVE_DATA_NETA_ST*  pSaveDataNeta   = [self _getNetaPack:pData->eventNetaPackNo];
    NSAssert(pSaveDataNeta, @"");
    pSaveDataNeta->eventHitScore  = pSaveDataNeta->hiscore;

    {
        NSDate* pDt = [NSDate date];
        NSDateFormatter*    pFmt    = [[[NSDateFormatter alloc] init] autorelease];
        pFmt.dateFormat = @"yyyy/MM/dd HH:mm:ss";
        NSString* pString  = [pFmt stringFromDate:pDt];
        
        //	イベント発生時の時刻
        const char*	pDateText	= [pString UTF8String];
        memcpy( pData->aEventTimeStr, pDateText, sizeof(pData->aEventTimeStr));
    }
    
    [mp_SaveData save];
}

-(void)   setSuccessEventNo:(SInt8)in_no
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert(pData, @"");

    pData->successEventNo   = in_no;
}

-(void) addEventChkPlayCnt
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert(pData, @"");
    
    ++pData->chkEventPlayCnt;
}

-(void) setTutorial:(const BOOL)in_flg
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert(pData, @"");

    pData->bTutorial    = in_flg;
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
-(void)	getInitSaveData:(SAVE_DATA_ST*)out_pData :(DataItemList*)in_pDataItemInst
{
	if( out_pData == NULL )
	{
		return;
	}
	
	memset( out_pData, 0, sizeof( SAVE_DATA_ST ) );
	out_pData->money	= 1000;    
	out_pData->netaNum	= 1;
    out_pData->nabeLv   = 1;
    out_pData->invocEventNo = -1;
    out_pData->successEventNo   = -1;
    out_pData->playLife = eSAVE_DATA_PLAY_LIEF_MAX;
    out_pData->bTutorial    = YES;

    //  アイテムデータとのマッピング
    {
        DataItemList*   pDataItemListInst   = [DataItemList shared];
        NSAssert(pDataItemListInst, @"");
        for( int i = 0; i < pDataItemListInst.dataNum; ++i )
        {
            const ITEM_DATA_ST* pDataItem   = [pDataItemListInst getData:i];
            NSAssert(pDataItem, @"");
            out_pData->aItems[i].no = pDataItem->no;
        }

        out_pData->aNetaPacks[ 0 ].no = 1;
        out_pData->aNetaPacks[ 0 ].num	= 1;
    }
}

/*
	@brief	広告カットフラグをたてる
*/
-(void)	saveCutAdsFlg
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		pData->adsDel	= 1;
		[mp_SaveData save];
	}
}


/*
	@brief	指定したnoから特定のネタデータを取得
	@param	in_no : ネタno
	@return	noネタデータ / nil = ネタデータがない or アイテム数が０
*/
-(SAVE_DATA_NETA_ST*)	_getNetaPack:(UInt32)in_no
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
		for( SInt32 i = 0; i < pData->netaNum; ++i )
		{
			if( ( pData->aNetaPacks[ i ].no == in_no ) && ( 0 < pData->aNetaPacks[ i ].num ) )
			{
				return &pData->aNetaPacks[ i ];
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
-(SAVE_DATA_ITEM_ST*)	_getItem:(UInt32)in_no :(const BOOL)in_chkNum
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
	{
        if( in_chkNum == YES )
        {
            for( SInt32 i = 0; i < pData->itemNum; ++i )
            {
                if( pData->aItems[ i ].no == in_no )
                {
                    return &pData->aItems[i];
                }
            }
        }
        else
        {
            SInt32  num = sizeof(pData->aItems) / sizeof(pData->aItems[0]);
            for( SInt32 i = 0; i < num; ++i )
            {
                if( pData->aItems[ i ].no == in_no )
                {
                    return &pData->aItems[i];
                }
            }
        }
	}
	
	return nil;
}

@end
