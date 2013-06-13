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
	eSAVE_DATA_NETA_PACKS_MAX	= 32,
    eSAVE_DATA_NETA_MAX     = 64,
	eSAVE_DATA_ITEMS_MAX	= 32,
	eSAVE_DATA_MISSION_MAX	= 32,
	eSAVE_DATA_ITEM_USE_MAX	= 99,
};

typedef struct
{
	UInt8	no;			//	0(1)
	UInt8	num;		//	1(1)
	UInt8	unlockFlg;	//	2(1)
	UInt8	dummy;		//	3(1)
} SAVE_DATA_ITEM_ST;	// 4byte

typedef struct
{
	UInt8	no;			//	0(1)
	UInt8	hiscore;	//	1(1)
	UInt8	unlockFlg;	//	2(1)
	UInt8	num;		//	3(1)
} SAVE_DATA_NETA_ST;	// 4byte

//
typedef struct
{
	//	ネタ所持数
	SAVE_DATA_NETA_ST	aNetaPacks[eSAVE_DATA_NETA_PACKS_MAX];	//	0(128)
	long	netaNum;				//	128(4)
	
	//	アイテム所持数
	SAVE_DATA_ITEM_ST	aItems[eSAVE_DATA_ITEMS_MAX];	//	130(128)
	long	itemNum;					//	258(4)

	//	所持金
	long	money;					//	262(4)
	//	日付
	long	year, month, day;		//	266(12)
		
	int64_t	score;				//	278(8)
	char	use;				//	286(1)
	char	check;				//	287(1)
    char    padding[1];          //  288(1)
	char	adsDel;				//	289(1)
	
	char	aMissionFlg[eSAVE_DATA_MISSION_MAX];		//	290(32)
    UInt8   putCustomerMaxnum;   // 322(1)
    UInt8   eatTenpuraMaxNum;   // 323(1)
    char    padding2[1];          //  324(1)
	
    unsigned short  nabeLv;     //  325(2)
    unsigned short  nabeExp;    //  327(2)
    
    unsigned char   aNetaMaxNum[eSAVE_DATA_NETA_MAX];   // 329(64)
    //	予約領域
	char	dummy[119];				//	393(119)
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
-(const SAVE_DATA_NETA_ST*)getNetaPack:(UInt32)in_no;
//	ネタ取得(リストidx)
-(const SAVE_DATA_NETA_ST*)getNetaPackOfIndex:(UInt32)in_idx;

//	アイテム取得
-(const SAVE_DATA_ITEM_ST*)getItem:(UInt32)in_no;
//	アイテム取得(リストidx)
-(const SAVE_DATA_ITEM_ST*)getItemOfIndex:(UInt32)in_idx;

//	ネタ追加
-(BOOL) addNetaPack:(UInt32)in_no;
//  ネタごとのハイスコア(関数内部で保存している値より小さい場合は処理をスキップしている)
-(void) setNetaMaxNum:(UInt32)in_no :(UInt8)in_num;

//	アイテム追加
-(BOOL) addItem:(UInt32)in_no;
-(BOOL) subItem:(UInt32)in_no;
//	金額加算
-(void)	addSaveMoeny:(long)in_addMoney;
//	スコア設定
-(void)	setSaveScore:(int64_t)in_score;
//  客の最大出現数(関数内部で保存している値より小さい場合は処理をスキップしている)
-(void) setPutCustomerMaxNum:(UInt8)in_num;
//  天ぷらを食べさせた最大数(関数内部で保存している値より小さい場合は処理をスキップしている)
-(void) setEatTenpuraMaxNum:(UInt8)in_num;

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
