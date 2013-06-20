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
	eITEM_IMPACT_SCORE_POWERUP	= 1,        //	スコア倍増
	eITEM_IMPACT_TIME_ADD,                  //	タイム増加
	eITEM_IMPACT_FIVER_TIME_ADD,            //	フィーバータイム増加
	eITEM_IMPACT_END_SCORE_POWERUP,         //	最終得点の倍増
    eITEM_IMPACT_ALL_TENPURA_EAT    = 10,   //  すべての天ぷらを食べられる
    eITEM_IMPACT_NOT_BURN_TENPURA,          //  天ぷらがこげない
    eITEM_IMPACT_DUST_TENPURA,               //  天ぷらをすてることができる
    eITEM_IMPACT_ALL_MONEY_CUSTOMER,        //  客が必ず金持ちに
    eITEM_IMPACT_OPEN_NETAPACK,             //  ネタパック一つ開く
};

//	アイテム画像の種類一覧
enum
{
	eITEM_IMG_TYPE_NONE	= 0,
	eITEM_IMG_TYPE_NABE,
};

//	アイテムデータ
typedef struct
{
	SInt32		no;
	UInt32		textID;
	UInt32		contentTextID;
	SInt32		sellMoney;
	UInt32		itemType;
	Float32		value;
	SInt32		unlockItemNo;
	char		fileName[128];
	SInt32		imageType;
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
