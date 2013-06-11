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

//	設定可能な値最大値
enum
{
	eSCORE_MAX_NUM	= 999999,
	eMONEY_MAX_NUM	= 999999,
};

enum
{
    eNABE_LVUP_NUM  = 10
};

//	セーブデータ内容
enum
{
	eSAVE_DATA_NETA_PACKS_MAX	= 64,
	eSAVE_DATA_ITEMS_MAX	= 32,
	eSAVE_DATA_MISSION_MAX	= 64,
	eSAVE_DATA_NETA_USE_MAX	= 99,
};

typedef struct
{
	unsigned char	no;			//	0(1)
	unsigned char	num;		//	1(1)
	unsigned char	unlockFlg;	//	2(1)
	unsigned char	dummy;		//	3(1)
} SAVE_DATA_ITEM_ST;	// 4byte

//
typedef struct
{
	//	ネタ所持数
	SAVE_DATA_ITEM_ST	aNetaPacks[eSAVE_DATA_NETA_PACKS_MAX];	//	0(256)
	long	netaNum;				//	256(4)
	
	//	アイテム所持数
	SAVE_DATA_ITEM_ST	aItems[eSAVE_DATA_ITEMS_MAX];	//	260(128)
	long	itemNum;					//	388(4)

	//	所持金
	long	money;					//	392(4)
	//	日付
	long	year, month, day;		//	396(12)
		
	int64_t	score;				//	408(8)
	char	use;				//	409(1)
	char	check;				//	410(1)
    char    padding[2];          //  411(2)
	
	char	aMissionFlg[eSAVE_DATA_MISSION_MAX];		//	413(64)
	char	adsDel;				//	477(1)
    char    padding2[3];          //  478(3)
	
	//	予約領域
    unsigned short  nabeLv;     //  481(2)
    unsigned short  nabeExp;    //  483(2)
	char	dummy[27];				//	485(27)
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
-(const SAVE_DATA_ITEM_ST*)getNetaPack:(UInt32)in_no;
//	ネタ取得(リストidx)
-(const SAVE_DATA_ITEM_ST*)getNetaPackOfIndex:(UInt32)in_idx;

//	アイテム取得
-(const SAVE_DATA_ITEM_ST*)getItem:(UInt32)in_no;
//	アイテム取得(リストidx)
-(const SAVE_DATA_ITEM_ST*)getItemOfIndex:(UInt32)in_idx;

//	ネタ追加
-(BOOL)addNetaPack:(UInt32)in_no;
//	アイテム追加
-(BOOL)addItem:(UInt32)in_no;
//	金額加算
-(void)	addSaveMoeny:(long)in_addMoney;
//	スコア設定
-(void)	setSaveScore:(int64_t)in_score;

//	現在時刻を記録
-(BOOL)	saveDate;

//	ミッションフラグをたてる
-(void)	saveMissionFlg:(BOOL)in_flg :(UInt32)in_idx;

//	広告削除
-(void)	saveCutAdsFlg;

//  なべ経験値加算（レベルがあがるとtrueが変える）
-(BOOL) addNabeExp:(unsigned short)in_expNum;

//	データ丸ごと取得
-(const SAVE_DATA_ST*)getData;

//	セーブ初期データ取得
-(void)getInitSaveData:(SAVE_DATA_ST*)out_pData;

@end
