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
@class DataItemList;

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
	eSAVE_DATA_ITEMS_MAX	= 32,
	eSAVE_DATA_MISSION_MAX	= 16,
	eSAVE_DATA_ITEM_USE_MAX	= 99,
    eSAVE_DATA_PLAY_LIEF_MAX    = 4,
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
	UInt8	dumy;       //	1(1)
	UInt8	unlockFlg;	//	2(1)
	UInt8	num;		//	3(1)
    UInt32  hiscore;    //  4(4)
    UInt32  eventHitScore;    //  8(4)
    UInt8   padding[4]; //  12(4)
} SAVE_DATA_NETA_ST;	// 16byte

//
typedef struct
{
	//	ネタ所持数
	SAVE_DATA_NETA_ST	aNetaPacks[eSAVE_DATA_NETA_PACKS_MAX];	//	0(128)
	SInt32	netaNum;				//	128(4)
	
	//	アイテム所持数
	SAVE_DATA_ITEM_ST	aItems[eSAVE_DATA_ITEMS_MAX];	//	130(512)
	SInt32	itemNum;					//	642(4)

	//	所持金
	SInt32	money;					//	646(4)
		
	SInt32	score;				//	650(4)
    SInt32  eventScore;
    
    char   aEventTimeStr[32];  //  654(32)
    char   aCureTimeStr[32];  //  686(32)

    UInt16  nabeLv;     //  718(2)
    UInt16  nabeExp;    //  720(2)

    UInt32  chkEventPlayCnt;    //  722(4)

	SInt8	use;				//	726(1)
	SInt8	check;				//	727(1)
    SInt8   invocEventNo;       //  728(1)
	SInt8	adsDel;				//	729(1)
	
	SInt8	aMissionFlg[eSAVE_DATA_MISSION_MAX];		//	730(16)
    
    UInt8   putCustomerMaxnum;      // 746(1)
    UInt8   eventPutCustomerMaxnum;   // 747(1)

    UInt8   eatTenpuraMaxNum;       // 748(1)
    UInt8   eventEatTenpuraMaxNum;
    
    SInt8   successEventNo;         //  749(1)
    SInt8   eventNetaPackNo;        //  750(1)
    
    SInt8   playLife;               //  751(1)
    BOOL    bTutorial;              //  752(1)
    
    SInt32  settingNetaPackId;    //  753(4)

    //	予約領域
	SInt8	dummy[258];				//	756(258)
} SAVE_DATA_ST;	//	1024byte

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
-(BOOL)reset:(DataItemList*)in_pDataItamList;
//	ネタ取得
-(const SAVE_DATA_NETA_ST*)getNetaPack:(UInt32)in_no;
//	ネタ取得(リストidx)
-(const SAVE_DATA_NETA_ST*)getNetaPackOfIndex:(UInt32)in_idx;

//	アイテム取得
-(const SAVE_DATA_ITEM_ST*)getItem:(UInt32)in_no;
//	アイテム取得(リストidx)
-(const SAVE_DATA_ITEM_ST*)getItemOfIndex:(UInt32)in_idx;
//  アイテムロック取得
-(const BOOL)   isLockItem:(const UInt32)in_no;
//  アイテムロック解除
-(void) unlockItem:(const UInt32)in_no;


//	ネタ追加
-(BOOL) addNetaPack:(UInt32)in_no;
//  ネタパックごとのハイスコア(関数内部で保存している値より小さい場合は処理をスキップしている)
-(const BOOL) setHiscoreNetaPack:(UInt32)in_no :(SInt32)in_hiscore;

//	アイテム追加
-(BOOL) addItem:(UInt32)in_no;
-(BOOL) subItem:(UInt32)in_no;
//	金額加算
-(void)	addSaveMoeny:(long)in_addMoney;
//	スコア設定
-(void)	setSaveScore:(SInt32)in_score;
//  客の最大出現数(関数内部で保存している値より小さい場合は処理をスキップしている)
-(const BOOL) setPutCustomerMaxNum:(UInt8)in_num;
//  天ぷらを食べさせた最大数(関数内部で保存している値より小さい場合は処理をスキップしている)
-(const BOOL) setEatTenpuraMaxNum:(UInt8)in_num;

//	ミッションフラグをたてる
-(void)	saveMissionFlg:(BOOL)in_flg :(UInt32)in_idx;

//  ライフ増減
-(void) addPlayLife:(const SInt8)in_num :(const BOOL)in_bSaveLiefTime;

//	広告削除
-(void)	saveCutAdsFlg;

//  なべ経験値加算（レベルがあがるとtrueが変える）
-(BOOL) addNabeExp:(UInt16)in_expNum;

//  イベント設定
-(void) setEventNo:(SInt8)in_no;
-(void) setSuccessEventNo:(SInt8)in_no;
-(void) addEventChkPlayCnt;

//  チュートリアル設定
-(void) setTutorial:(const BOOL)in_flg;

//  ネタパックid設定
-(void) setSettingNetaPackId:(const SInt32)in_id;

//	データ丸ごと取得
-(const SAVE_DATA_ST*)getData;

//	セーブ初期データ取得
-(void)getInitSaveData:(SAVE_DATA_ST*)out_pData :(DataItemList*)in_pDataItemInst;

@end
