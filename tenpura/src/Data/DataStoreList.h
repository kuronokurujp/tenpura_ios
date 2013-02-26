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
	SInt32		textId;
	SInt32		money;
	char		aStoreIdName[128];
	
} STORE_DATA;

@interface DataStoreList : NSObject
{
@private
	STORE_DATA*	mp_dataList;
	UInt32	m_dataNum;
}

//	外部参照可能に
+(DataStoreList*)shared;
+(void)end;

//	プロパティ
@property	(nonatomic, readonly) UInt32 dataNum;

//	データ取得
-(const STORE_DATA*)	getData:(UInt32)in_idx;
//	データ取得(id検索)
-(const STORE_DATA*)	getDataSearchId:(UInt32)in_no;

@end
