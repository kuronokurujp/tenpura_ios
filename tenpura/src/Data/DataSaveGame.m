//
//  DataSaveGame.m
//  tenpura
//
//  Created by y.uchida on 12/10/31.
//
//

#import "DataSaveGame.h"
#import "DataBaseText.h"

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
static const int	s_nowVersionNum	= 2;

@synthesize cureTime        = m_cureTime;
@synthesize networkDate     = mp_networkDate;
@synthesize nowEventTime    = m_nowEventTime;
@synthesize gameTime        = m_gameTime;

/*
	@brief
*/
+(DataSaveGame*)shared
{
	if( s_pDataSaveGameInst == nil ) {
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
        m_cureTime      = 0;
        m_nowEventTime  = 0;
        m_gameTime      = 0;
        mp_networkDate  = nil;
        memset(m_aCureTime, 0, sizeof(m_aCureTime));
        
		mp_SaveData	= [SaveData alloc];
		[mp_SaveData setup:s_pSaveIdName :sizeof(SAVE_DATA_ST)];
		[mp_SaveData load];
		
		SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
		if( pData != nil ) {
			pData->upgradeChk	= 0;
			
			if( pData->use == 0 ) {
				//	データがない
				//	リセットしてセーブする
				[self reset: [DataItemList shared]];
			}
			else if(pData->version != s_nowVersionNum) {
				//	すでにセーブデータが存在するが、バージョンが異なる場合
				//	特典をつける
				[self addSaveMoeny:eSPECIAL_FAVOR_ADD_MONEY_NUM];
				//	ライフを回復へ
				[self addPlayLife:eSAVE_DATA_PLAY_LIEF_MAX];
				
				//	バージョンを最新へ
				pData->version	= s_nowVersionNum;
				pData->upgradeChk	= 1;
			}
			
			[self save];
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
        [mp_SaveData save];
		[mp_SaveData release];
	}
	
	mp_SaveData	= nil;
	
	[super dealloc];
}

-(void)save
{
    [mp_SaveData save];
}

//  時間に関連するステータスを更新
-(void)updateTimeStatus:(NSDate*)in_date
{
	mp_networkDate	= in_date;
	[mp_networkDate retain];
	
    SAVE_DATA_ST* pSaveData   = (SAVE_DATA_ST*)[mp_SaveData getData];
    
    //  指定した時間を超えているかチェック
    NSDateFormatter*    pFmt    = [[[NSDateFormatter alloc] init] autorelease];
    [pFmt setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    //  ライフが減っているなら
    if( pSaveData->playLife < eSAVE_DATA_PLAY_LIEF_MAX )
    {
		//	回復開始時間から現在の時間との差の時間を取得
        NSDate* pCureBaseDt = [pFmt dateFromString:[NSString stringWithUTF8String:pSaveData->aCureBeginTimeStr]];
        NSTimeInterval  span    = [mp_networkDate timeIntervalSinceDate:pCureBaseDt];
        if( m_cureTime <= span )
        {
            //  １ライフ回復時間を超えていたら、１ライフ回復時間未満になるまで回復する
			while ( m_cureTime < span ) {
				/*
				 下記のメソッドは使えない
				 回復してまだ全回復でない場合に次の回復時間を再設定するが、設定する時間の基準がネットから取得した時間になってしまう。
				 ここでは以前設定した回復期間時間を基準に設定しないと次の回復時間がネット時間を基準した期間になって回復時間がライフを減った時からのびる
				 */
	//           [self addPlayLife:cureNum];
				pSaveData->playLife += 1;
				pSaveData->playLife = MIN(pSaveData->playLife, eSAVE_DATA_PLAY_LIEF_MAX);

				if( eSAVE_DATA_PLAY_LIEF_MAX <= pSaveData->playLife ) {
					span	= 0;
					break;
				}
								
				span -= m_cureTime;
			}

			//	回復したが、まだ全快ではない。
			if( 0 < span ) {
				//  ライフ最大から減った後の時間を取得する、ここから回復時間を取得
				NSDate* pCureDt = [[[NSDate alloc] initWithTimeInterval:span sinceDate:mp_networkDate] autorelease];

				NSString*   pFmtStr = [pFmt stringFromDate:pCureDt];
				memcpy(pSaveData->aCureBeginTimeStr, [pFmtStr UTF8String], sizeof(pSaveData->aCureBeginTimeStr));
				
				//  次の回復時間を取得
				{
					//	今の時刻と回復時刻から秒を取得
					NSTimeInterval  span    = [pCureDt timeIntervalSinceDate:mp_networkDate];
					m_aCureTime[pSaveData->playLife]    = abs(span);

				}
			}
        }
        else {
            //  まだ回復時間が残っている。
            m_aCureTime[pSaveData->playLife]    = abs(span);
        }
		
		//	まだ先に回復があれば回復時間を設定
		for( int i = pSaveData->playLife + 1; i < eSAVE_DATA_PLAY_LIEF_MAX; ++i ) {
			m_aCureTime[i]	= m_cureTime;
		}
	}
    
    //  イベントが発生期間の時間を取得
    if( pSaveData->invocEventNo != -1 )
    {
        NSDate* pEventBaseDt    = [pFmt dateFromString:[NSString stringWithUTF8String:pSaveData->aEventBeginTimeStr]];
        NSTimeInterval  span    = [pEventBaseDt timeIntervalSinceDate:mp_networkDate];
        if( span <= 0  ) {
            //  イベント終了
            m_nowEventTime  = 0;
        }
        else {
            m_nowEventTime  = span;
        }
    }
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
        pItemData->bNew = 1;
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
            pAddItem->bNew  = 0;
            
			++pAddItem->num;
			++pData->itemNum;
		
			return YES;
		}
		else if( pItem != nil )
		{
            if( pItem->num < eSAVE_DATA_ITEM_USE_MAX )
            {
                pItem->num += 1;
                
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
	}
}

/*
    @brief  ライフ増減
 */
-(void) addPlayLife:(const SInt8)in_num
{
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
    SInt8   oldPlayerLife   = pData->playLife;
    SInt8   newPlayerLife   = pData->playLife + in_num;

	if ( newPlayerLife < 0 ) {
		return;
	}

    BOOL    bSaveTime   = NO;
    if( in_num < 0 ) {
        //  現在のライフ最大値であればセーブする。
        if(eSAVE_DATA_PLAY_LIEF_MAX == oldPlayerLife) {
            bSaveTime   = YES;
        }

		m_aCureTime[newPlayerLife]  = m_cureTime;
		for( int i = newPlayerLife - 1; 0 <= i; --i ) {
			m_aCureTime[i]	= 0;
		}
    }
    else if( pData->playLife < eSAVE_DATA_PLAY_LIEF_MAX )
    {
        //  回復する時
        if( eSAVE_DATA_PLAY_LIEF_MAX <= newPlayerLife ) {
            //  全回復した場合は回復時間を初期化
            memset(pData->aCureBeginTimeStr, 0, sizeof(pData->aCureBeginTimeStr));
			memset( m_aCureTime, 0, sizeof(m_aCureTime) );
        }
        else {
            //  まだ回復が残っている場合は、残り回復時間をセーブしておく
            bSaveTime   = YES;
			m_aCureTime[pData->playLife]	= 0;
        }
    }
    
    if( bSaveTime == YES )
    {
        //  ライフ最大から減った後の時間を取得する、ここから回復時間を取得
        NSDate* pGameDt = [[[NSDate alloc] initWithTimeInterval:m_gameTime sinceDate:mp_networkDate] autorelease];
        NSDate* pCureDt = [[[NSDate alloc] initWithTimeInterval:m_aCureTime[newPlayerLife] sinceDate:pGameDt] autorelease];

        NSDateFormatter*    pFmt    = [[[NSDateFormatter alloc] init] autorelease];
        [pFmt setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        NSString*   pFmtStr = [pFmt stringFromDate:pCureDt];
        memcpy(pData->aCureBeginTimeStr, [pFmtStr UTF8String], sizeof(pData->aCureBeginTimeStr));
    }
    
    pData->playLife += in_num;
    
    pData->playLife = MIN(pData->playLife, eSAVE_DATA_PLAY_LIEF_MAX);
    pData->playLife = MAX(pData->playLife, 0);

    [mp_SaveData save];
}

-(const SInt32) getNowCureTime
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
    if( pData->playLife < eSAVE_DATA_PLAY_LIEF_MAX ) {
        return m_aCureTime[pData->playLife];
    }
    
    return 0;
}

-(const SInt32) getAllCureLifeTime
{
    SInt32  num = 0;
    
    for( SInt32 i = 0; i < eSAVE_DATA_PLAY_LIEF_MAX; ++i ) {
        num += m_aCureTime[i];
    }
    
    return num;
}

//  ライフ最大値になる日付取得
-(NSDate*)  getAllCureLifeDate
{
    SInt32  num = [self getAllCureLifeTime];
    
    NSDate* pGameDt = [[[NSDate alloc] initWithTimeInterval:m_gameTime sinceDate:mp_networkDate] autorelease];
    NSDate* pCureDt = [[[NSDate alloc] initWithTimeInterval:num sinceDate:pGameDt] autorelease];
    
    return pCureDt;
}

//  ライフタイマー加算
-(void) addPlayLifeTimerCnt:(const SInt32)in_cnt
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
    if( pData->playLife < eSAVE_DATA_PLAY_LIEF_MAX )
    {
        m_aCureTime[pData->playLife] += in_cnt;
    }
}

//  イベントタイマー加算
-(void) addEventTimerCnt:(const SInt32)in_cnt
{
    m_nowEventTime  += in_cnt;
    if( m_nowEventTime < 0 )
    {
        m_nowEventTime = 0;
    }
}

/*
    @brief  なべ経験値を保存
*/
-(void) saveNabeExp:(UInt16)in_expNum
{
    SAVE_DATA_ST*   pData   = (SAVE_DATA_ST*)[mp_SaveData getData];
    if( pData != nil ) {
        pData->nabeAddExp   = in_expNum;
    }
}

/*
    @brief  なべ経験値加算
 */
-(BOOL) addNabeExp:(UInt16)in_expNum
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != nil )
    {
        if( pData->nabeLv < s_maxLv_dataSaveGame )
        {
            pData->nabeExp += in_expNum;
            if( eNABE_LVUP_NUM <= pData->nabeExp )
            {
                pData->nabeExp -= eNABE_LVUP_NUM;
                pData->nabeLv += 1;
                
				[self save];

                return true;
            }
        }
    }

    return false;
}

/*
    @brief  イベント設定
 */
-(void)   setEventNo:(SInt8)in_no :(SInt32)in_timeCnt
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
        m_nowEventTime    = in_timeCnt;

        //  イベント期間時間があれば記録する
        if( 0 < in_timeCnt )
        {
            NSDate* pGameDt = [[[NSDate alloc] initWithTimeInterval:m_gameTime sinceDate:mp_networkDate] autorelease];
            NSDate* pCureDt = [[[NSDate alloc] initWithTimeInterval:in_timeCnt sinceDate:pGameDt] autorelease];
            
            NSDateFormatter*    pFmt    = [[[NSDateFormatter alloc] init] autorelease];
            [pFmt setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            NSString*   pFmtStr = [pFmt stringFromDate:pCureDt];
            memcpy(pData->aEventBeginTimeStr, [pFmtStr UTF8String], sizeof(pData->aEventBeginTimeStr));
        }
    }

    [self save];
}

-(void)   setSuccessEventNo:(SInt8)in_no
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert(pData, @"");

    pData->successEventNo   = in_no;
}

-(void) endEvent
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert(pData, @"");

    pData->invocEventNo = -1;
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

//  ネタパックid設定
-(void) setSettingNetaPackId:(const SInt32)in_id
{
    SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	NSAssert(pData, @"");
    
    pData->settingNetaPackId    = in_id;
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
	out_pData->money	= 10000;
	out_pData->netaNum	= 1;
    out_pData->nabeLv   = 1;
    out_pData->invocEventNo = -1;
    out_pData->successEventNo   = -1;
    out_pData->playLife = eSAVE_DATA_PLAY_LIEF_MAX;
    out_pData->bTutorial    = YES;
    out_pData->settingNetaPackId  = 1;
	out_pData->version	= s_nowVersionNum;

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
	@brief	特典内容のメッセージをしたかの通知
*/
-(void) noticeSpecialFavorMessage {
	SAVE_DATA_ST*	pData	= (SAVE_DATA_ST*)[mp_SaveData getData];
	if( pData != NULL ) {
		pData->upgradeChk	= 0;
		[mp_SaveData save];
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
