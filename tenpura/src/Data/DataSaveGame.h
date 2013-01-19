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
	eNETAS_MAX	= 64,
	eITEMS_MAX	= 32,
	eMISSION_MAX	= 64,
	eNETA_USE_MAX	= 99,
};

typedef struct
{
	unsigned char	no;		//	0(1)
	unsigned char	num;	//	1(1)
} SAVE_DATA_ITEM_ST;	// 2byte

//
typedef struct
{
	//	ネタ所持数
	SAVE_DATA_ITEM_ST	aNetas[eNETAS_MAX];	//	0(128)
	long	netaNum;				//	128(4)
	
	//	アイテム所持数
	SAVE_DATA_ITEM_ST	aItems[eITEMS_MAX];	//	132(64)
	long	itemNum;					//	196(4)

	//	所持金
	long	money;					//	200(4)
	//	日付
	long	year, month, day;		//	204(12)
		
	int64_t	score;				//	216(8)
	char	use;				//	224(1)
	char	check;				//	225(1)
	
	char	aMissionFlg[eMISSION_MAX];		//	226(64)
	char	rank;							//	290(1)
	
	//	予約領域
	char	dummy[221];				//	291(221)
} SAVE_DATA_ST;	//	512byte

@interface DataSaveGame : NSObject
{
@private
	//	変数宣言
	SaveData*	mp_SaveData;
}

//	関数
+(DataSaveGame*)shared;
+(void)end;

//	データリセット
-(BOOL)reset;
//	ネタ取得
-(const SAVE_DATA_ITEM_ST*)getNeta:(UInt32)in_no;
//	ネタ取得(リストidx)
-(const SAVE_DATA_ITEM_ST*)getNetaOfIndex:(UInt32)in_idx;

//	アイテム取得
-(const SAVE_DATA_ITEM_ST*)getItem:(UInt32)in_no;
//	アイテム取得(リストidx)
-(const SAVE_DATA_ITEM_ST*)getItemOfIndex:(UInt32)in_idx;

//	ネタ追加
-(BOOL)addNeta:(UInt32)in_no;
//	アイテム追加
-(BOOL)addItem:(UInt32)in_no;
//	金額加算
-(void)	addSaveMoeny:(long)in_addMoney;
//	スコア追加
-(void)	addSaveScore:(int64_t)in_score;

//	現在時刻を記録
-(BOOL)	saveDate;

//	ミッションフラグをたてる
-(void)	saveMissionFlg:(BOOL)in_flg:(UInt32)in_idx;

//	ランク設定
-(void)	saveRank:(char)in_rank;

//	データ丸ごと取得
-(const SAVE_DATA_ST*)getData;

//	セーブ初期データ取得
-(void)getInitSaveData:(SAVE_DATA_ST*)out_pData;

@end
