//
//  DataItemList.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//	ネタデータ
typedef struct
{
	SInt32		no;
	UInt32		textID;
	UInt32		contentTextID;
	SInt32		sellMoney;
	char		fileName[128];
} ITEM_DATA_ST;

@interface DataItemList : NSObject
{
@private
	ITEM_DATA_ST*	mp_dataList;
	UInt32	m_dataNum;
}

//	外部参照可能に
+(DataItemList*)shared;
+(void)end;

//	プロパティ
@property	(nonatomic, readonly) UInt32 dataNum;

//	データ取得
-(const ITEM_DATA_ST*)	getData:(UInt32)in_idx;
//	データ取得(id検索)
-(const ITEM_DATA_ST*)	getDataSearchId:(UInt32)in_no;

@end
