//
//  DataStoreList.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//	データ
typedef struct
{
	SInt32		no;
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
