//
//  DataNetaList.h
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
	Float32		eatTime;
	//	各揚げた状態のステータス
	struct
	{
		Float32	changeTime;
		SInt32	score;
		SInt32	money;
	}aStatusList[3];

	char		fileName[128];
} NETA_DATA_ST;

@interface DataNetaList : NSObject
{
@private
	NETA_DATA_ST*	mp_dataList;
	UInt32	m_dataNum;
}

//	外部参照可能に
+(DataNetaList*)shared;
+(void)end;

//	プロパティ
@property	(nonatomic, readonly) UInt32 dataNum;

//	データ取得
-(const NETA_DATA_ST*)	getData:(UInt32)in_idx;
//	データ取得(id検索)
-(const NETA_DATA_ST*)	getDataSearchId:(UInt32)in_no;

@end
