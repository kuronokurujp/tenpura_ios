//
//  DataNetaPackList.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum
{
	eNETA_PACK_MAX	= 3,
};

typedef struct
{
	SInt32		no;
	UInt32		textID;
	SInt32		aNetaId[eNETA_PACK_MAX];
	SInt32		money;

} NETA_PACK_DATA_ST;

@interface DataNetaPackList : NSObject
{
@private
	NETA_PACK_DATA_ST*	mp_dataList;
	UInt32	m_dataNum;
}

//	外部参照可能に
+(DataNetaPackList*)shared;
+(void)end;

//	プロパティ
@property	(nonatomic, readonly) UInt32 dataNum;

//	データ取得
-(const NETA_PACK_DATA_ST*)	getData:(UInt32)in_idx;
//	データ取得(id検索)
-(const NETA_PACK_DATA_ST*)	getDataSearchId:(UInt32)in_no;

@end
