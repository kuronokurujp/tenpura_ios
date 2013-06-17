//
//  DataEventDataList.m
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import "DataEventDataList.h"
#import "DataSaveGame.h"

//	非公開関数
@interface DataEventDataList (PrivateMethod)

-(EVENT_DATA_ST)	parse:(NSArray*)in_dataArray;

@end

@implementation DataEventDataList

//	プロパティ
@synthesize dataNum	= m_dataNum;

static DataEventDataList*	s_pInst	= nil;

/*
	@brief
*/
+(DataEventDataList*)shared
{
	if( s_pInst == nil )
	{
		s_pInst	= [[DataEventDataList alloc] init];
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

/*
    @brief
 */
+(const SInt8)  invocEvnet
{
    DataEventDataList*  pEventDataList  = s_pInst;
    NSAssert(s_pInst, @"");
    
    SInt8   percent = (SInt8)(CCRANDOM_0_1() * 99.f);
    
    const UInt32    dataNum = pEventDataList.dataNum;
    for( UInt32 i = 0; i < dataNum; ++i )
    {
        const EVENT_DATA_ST*  pData   = [pEventDataList getData:i];
        if( percent < pData->invocPercentNum )
        {
            return pData->no;
        }
        else if( percent < pData->invocPercentNum2 )
        {
            return pData->no;
        }
    }
    
    return -1;
}

+(const BOOL)   isError:(const SInt8)in_no
{
    DataEventDataList*  pEventDataListInst  = s_pInst;
    NSAssert(s_pInst, @"");

    DataSaveGame*   pSaveGameInst   = [DataSaveGame shared];
    NSAssert(pSaveGameInst, @"");
    
    const SAVE_DATA_ST*   pSaveData   = [pSaveGameInst getData];
    NSAssert(pSaveData->invocEventNo != -1, @"");

    const EVENT_DATA_ST*  pData   = [pEventDataListInst getDataSearchId:in_no];
    NSAssert(pData, @"");
    
    {
        //  特定のネタバックのハイスコアのときのみチェックする
        if( pData->typeNo == eEVENT_TYPE_HISCORE_NETAPACK )
        {
            BOOL    bError  = YES;

            //  ネタが存在しないであれば失敗させる
            for( SInt32 i = 0; i < pSaveData->netaNum; ++i )
            {
                if( pSaveData->aNetaPacks[i].no == pSaveData->eventNetaPackNo )
                {
                    bError  = NO;
                    break;
                }
            }
            
            if( bError )
            {
                return YES;
            }
        }
    }
    
    //  条件によってチェックを変える
    if( pData->limitType == eEVENT_LIMIT_TYPE_GAME_COUNT )
    {
        if( pData->limitData.playCnt <= (Float32)pSaveData->chkEventPlayCnt )
        {
            //  失敗
            return YES;
        }
    }
    else if( pData->limitType == eEVENT_LIMIT_TYPE_TIME )
    {
        //  イベント発生前の時間になっている場合は不正として強制失敗
        {
            NSDate* pDt = [NSDate date];
            NSDateFormatter*    pDateFrm    = [[[NSDateFormatter alloc] init] autorelease];
            [pDateFrm setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            NSDate* pEventDt    = [pDateFrm dateFromString:[NSString stringWithUTF8String:pSaveData->aEventTimeStr]];

            NSTimeInterval  span    = [pEventDt timeIntervalSinceDate:pDt];
            if( 0 < (int)span )
            {
                //  イベント発生時間より前の時間
                return YES;
            }
        }
        
        //  イベント発生期限をすぎているか
        {
            SInt32  limitTime   = [DataEventDataList getLimitTimeSecond:pData->limitData.time];
            if( limitTime <= 0 )
            {
                return YES;
            }
        }
    }
        
    return NO;
}

/*
    @brief
 */
+(const SInt8) chkSuccess:(const UInt8)in_no :(const EVENT_SUCCESS_BIT_ENUM)in_successBit
{
    DataEventDataList*  pEventDataList  = s_pInst;
    NSAssert(s_pInst, @"");
    
    const EVENT_DATA_ST*  pData   = [pEventDataList getDataSearchId:in_no];
    NSAssert(pData, @"");
    
    SInt8   succes   = -1;
    if( ((pData->typeNo == eEVENT_TYPE_HISCORE) && (in_successBit & eEVENT_SUCCESS_BIT_HISCORE)) )
    {
        succes = eEVENT_SUCCESS_BIT_HISCORE;
    }
    else if( ((pData->typeNo == eEVENT_TYPE_HIPUT_CUSTOMER) && (in_successBit & eEVENT_SUCCESS_BIT_HIPUT_CUSTOMER)) )
    {
        succes = eEVENT_SUCCESS_BIT_HIPUT_CUSTOMER;
    }
    else if( ((pData->typeNo == eEVENT_TYPE_HIRENDER_TENPURA) && (in_successBit & eEVENT_SUCCESS_BIT_HIRENDER_TENPURA)) )
    {
        succes = eEVENT_SUCCESS_BIT_HIRENDER_TENPURA;
    }
    else if( ((pData->typeNo == eEVENT_TYPE_HISCORE_NETAPACK) && (in_successBit & eEVENT_SUCCESS_BIT_HISCORE_NETAPACK)) )
    {
        succes = eEVENT_SUCCESS_BIT_HISCORE_NETAPACK;
    }
    
    return succes;
}

+(const SInt32) getLimitTimeSecond:(const SInt32)in_limitTime
{
    DataSaveGame*   pSaveGameInst   = [DataSaveGame shared];
    NSAssert(pSaveGameInst, @"");
    
    const SAVE_DATA_ST*   pSaveData   = [pSaveGameInst getData];
    NSAssert(pSaveData->invocEventNo != -1, @"");

    NSDate* pDt = [NSDate date];
    NSDateFormatter*    pDateFrm    = [[[NSDateFormatter alloc] init] autorelease];
    [pDateFrm setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate* pEventDt    = [pDateFrm dateFromString:[NSString stringWithUTF8String:pSaveData->aEventTimeStr]];

    NSDate* pChkDt  = [[[NSDate alloc] initWithTimeInterval:in_limitTime sinceDate:pEventDt] autorelease];
    NSTimeInterval  span    = [pChkDt timeIntervalSinceDate:pDt];

    SInt32  limitTime   = (int)span;
    if( limitTime <= 0 )
    {
        limitTime   = 0;
    }
    
    return limitTime;
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
		NSString*	pPath	= [[NSBundle mainBundle] pathForResource:@"eventDataList" ofType:@"csv"];

		NSString*	pText	= [NSString stringWithContentsOfFile:pPath encoding:NSUTF8StringEncoding error:nil];
		NSString*	pDelmita	= @"\n";
		
		NSMutableArray*	pLines	= [[pText componentsSeparatedByString:pDelmita] mutableCopy];
		//	先頭のカテゴリ行と行末を削除
		[pLines removeObjectAtIndex:0];
		[pLines removeLastObject];
		
		NSString*	pObj	= nil;
		NSArray*	pItems	= nil;

        UInt32  dataNum = [pLines count];
		NSAssert(0 < dataNum, @"イベントデータが一つもない。");
		mp_dataList	= (EVENT_DATA_ST*)malloc(dataNum * sizeof(EVENT_DATA_ST));
			
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
	free(mp_dataList);
	mp_dataList	= nil;

	[super dealloc];
}

/*
	@brief	データ解析
*/
-(EVENT_DATA_ST)	parse:(NSArray*)in_dataArray
{
	EVENT_DATA_ST	data	= { 0 };
	memset( &data, 0, sizeof(data) );

	SInt32	dataIdx	= 0;

	//	no
	data.no	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;
	
	//	名称
	data.textID	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
	++dataIdx;

    data.typeNo	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
    ++dataIdx;

    {
        data.invocId	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
        ++dataIdx;
        
        data.invocPercentNum	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
        ++dataIdx;
        
        data.invocId2	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
        ++dataIdx;
        
        data.invocPercentNum2	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
        ++dataIdx;        
    }

    {
        data.limitData.num	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
        ++dataIdx;
        
        data.limitType	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
        ++dataIdx;
    }
    
    {
        data.reward.no	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
        ++dataIdx;
        
        data.rewardDataType	= [(NSNumber*)[in_dataArray objectAtIndex:dataIdx] integerValue];
        ++dataIdx;
    }
    
	return data;
}

/*
	@brief	データ取得
*/
-(const EVENT_DATA_ST*)	getData:(UInt32)in_idx
{
	NSAssert( in_idx < m_dataNum, @"ネタデータベースリスト指定が間違っています" );
	
	return &mp_dataList[ in_idx ];
}

/*
	@brief	データ取得(id検索)
*/
-(const EVENT_DATA_ST*)	getDataSearchId:(UInt32)in_no
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
