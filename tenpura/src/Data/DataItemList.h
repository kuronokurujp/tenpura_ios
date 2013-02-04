//
//  DataItemList.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//	アイテム効果内容一覧
enum
{
	eITEM_IMPACT_MONEY_TWO_RATE	= 1,	//	金額が２倍
	eITEM_IMPACT_SCORE_TWO_RATE,		//	スコアが２倍
	eITEM_IMPACT_RAISE_TIME_HALF,		//	揚げる速度が２倍
	eITEM_IMPACT_COMB_ADD_ONE_TIME,		//	コンボタイムに１秒追加
	eITEM_IMPACT_COMB_ADD_THREE_TIME,	//	コンボタイムに３秒追加
	eITEM_IMPACT_EAT_TIME_HALF,			//	食べる時間が半分
	eITEM_IMPACT_EAT_TIME_THREE_FOUR,	//	食べる時間が3/4
};

//	ネタデータ
typedef struct
{
	SInt32		no;
	UInt32		textID;
	UInt32		contentTextID;
	SInt32		sellMoney;
	UInt32		aItemDataNo[2];
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
