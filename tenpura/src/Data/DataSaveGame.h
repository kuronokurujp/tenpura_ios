//
//  DataSaveGame.h
//  tenpura
//
//  Created by y.uchida on 12/10/31.
//
//

#import <Foundation/Foundation.h>

#import "DataGlobal.h"

//	前方宣言
@class SaveData;

//	セーブデータ内容
enum
{
	eITEMS_MAX	= 64,
};

typedef struct
{
	unsigned char	id;		//	0(1)
	unsigned char	num;	//	1(1)
	char	padding;	//	2(4)
} SAVE_DATA_ITEM_ST;

//
typedef struct
{
	//	アイテム所持数
	SAVE_DATA_ITEM_ST	aItems[eITEMS_MAX];	//	0(256)
	long	itemNum;				//	256(4)
	
	//	所持金
	long	money;					//	260(4)
	//	日付
	long	year, month, day;		//	264(12)
		
	int64_t	score;				//	272(8)
	char	use;				//	280(1)
	char	check;				//	281(1)

	//	予約領域
	char	dummy[230];				//	282(230)
} SAVE_DATA_ST;	//	512

@interface DataSaveGame : NSObject
{
@private
	//	変数宣言
	SaveData*	mp_SaveData;
}

@property	(nonatomic, setter = _setSaveScore: )int64_t	score;
@property	(nonatomic, setter = _addSaveMoney: )UInt32		addMoney;

//	関数
+(DataSaveGame*)shared;
+(void)end;

//	データリセット
-(BOOL)reset;
//	すでにアイテムを持っているかどうか
-(const SAVE_DATA_ITEM_ST*)isItem:(UInt32)in_no;
-(const SAVE_DATA_ITEM_ST*)isItemOfIndex:(UInt32)in_idx;

//	アイテム追加
-(BOOL)addItem:(UInt32)in_no;

//	現在時刻を記録
-(BOOL)saveDate;

-(const SAVE_DATA_ST*)getData;

//	セーブ初期データ取得
-(void)getInitSaveData:(SAVE_DATA_ST*)out_pData;

@end
