//
//  DataStoreList.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//	購入種類
enum
{
	eSTORE_ID_CUTABS		= 0,
    eSTORE_ID_CURELIEF      = 6,
	eSTORE_ID_MONEY_3000	= 1,
	eSTORE_ID_MONEY_9000	= 2,
	eSTORE_ID_MONEY_80000	= 3,
	eSTORE_ID_MONEY_400000	= 4,
	eSTORE_ID_MONEY_900000	= 5,
};

//	データ
typedef struct
{
	SInt32		no;
	UInt32		textId;
	char		aStoreIdName[128];
	
} STORE_DATA_ST;

@interface DataStoreList : NSObject
{
@private
	STORE_DATA_ST*	mp_dataList;
	UInt32	m_dataNum;
}

//	外部参照可能に
+(DataStoreList*)shared;
+(void)end;

//	プロパティ
@property	(nonatomic, readonly) UInt32 dataNum;

//	データ取得
-(const STORE_DATA_ST*)	getData:(UInt32)in_idx;
//	データ取得(id検索)
-(const STORE_DATA_ST*)	getDataSearchId:(UInt32)in_no;

@end
