//
//  DataEventDataList.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    eEVENT_SUCCESS_BIT_HISCORE             = 0x01,
    eEVENT_SUCCESS_BIT_HIPUT_CUSTOMER      = 0x02,
    eEVENT_SUCCESS_BIT_HIRENDER_TENPURA    = 0x04,
    eEVENT_SUCCESS_BIT_HISCORE_NETAPACK    = 0x08,
} EVENT_SUCCESS_BIT_ENUM;

enum EVENT_SUCCESS_TYPE_ENUM
{
    eEVENT_TYPE_HISCORE             = 0,
    eEVENT_TYPE_HIPUT_CUSTOMER,
    eEVENT_TYPE_HIRENDER_TENPURA,
    eEVENT_TYPE_HISCORE_NETAPACK,
};

enum    EVENT_LIMIT_TYPE_ENUM
{
    eEVENT_LIMIT_TYPE_GAME_COUNT    = 0,
    eEVENT_LIMIT_TYPE_TIME,
};

//	データ
typedef struct
{
	SInt32		no;
	UInt32		textID;
    UInt8       typeNo;
	UInt8		invocId;
    UInt8       invocPercentNum;
    UInt8       invocId2;
    UInt8       invocPercentNum2;
    
    union
    {
        SInt32      num;
        SInt32      time;
        UInt8       playCnt;
    } limitData;
    
    UInt8       limitType;
    UInt8       rewardDataType;
    UInt8       padding[2];

    union
    {
        UInt32  no;
        UInt32  itemNo;
        UInt32  money;
    } reward;
    
} EVENT_DATA_ST;

@interface DataEventDataList : NSObject
{
@private
	EVENT_DATA_ST*	mp_dataList;
	UInt32	m_dataNum;
}

//	外部参照可能に
+(DataEventDataList*)shared;
+(void)end;
+(const SInt8)  invocEvnet;
+(const BOOL) isError:(const SInt8)in_no;
+(const SInt8) chkSuccess:(const UInt8)in_no :(const EVENT_SUCCESS_BIT_ENUM)in_successBit;
+(const SInt32) getLimitTimeSecond:(const SInt32)in_limitTime;

//	プロパティ
@property	(nonatomic, readonly) UInt32 dataNum;

//	データ取得
-(const EVENT_DATA_ST*)	getData:(UInt32)in_idx;
//	データ取得(id検索)
-(const EVENT_DATA_ST*)	getDataSearchId:(UInt32)in_no;

@end
