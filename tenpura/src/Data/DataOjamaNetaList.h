//
//  DataOjamaNetaList.h
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
	Float32		x;
	Float32		y;
	Float32		randX;
	Float32		randY;
	Float32		aChangeTime[5];
	SInt32		money;
	SInt32		score;
	SInt32		time;
	char		fileName[128];
	
} OJAMA_NETA_DATA;

@interface DataOjamaNetaList : NSObject
{
@private
	OJAMA_NETA_DATA*	mp_dataList;
	UInt32	m_dataNum;
}

//	外部参照可能に
+(DataOjamaNetaList*)shared;
+(void)end;

//	プロパティ
@property	(nonatomic, readonly) UInt32 dataNum;

//	データ取得
-(const OJAMA_NETA_DATA*)	getData:(UInt32)in_idx;
//	データ取得(id検索)
-(const OJAMA_NETA_DATA*)	getDataSearchId:(UInt32)in_no;

@end
