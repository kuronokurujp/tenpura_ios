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
	UInt8	bNew;		//	3(1)
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
    
    UInt16  nabeLv;     //  662(2)
    UInt16  nabeExp;    //  664(2)
    UInt16  nabeAddExp; //  666(2)

    UInt32  chkEventPlayCnt;    //  668(4)

	SInt8	use;				//	672(1)
	SInt8	check;				//	673(1)
    SInt8   invocEventNo;       //  674(1)
	SInt8	adsDel;				//	675(1)
	
	SInt8	aMissionFlg[eSAVE_DATA_MISSION_MAX];		//	676(16)
    
    UInt8   putCustomerMaxnum;      // 692(1)
    UInt8   eventPutCustomerMaxnum;   // 693(1)

    UInt8   eatTenpuraMaxNum;       // 694(1)
    UInt8   eventEatTenpuraMaxNum;  //  695(1)
    
    SInt8   successEventNo;         //  696(1)
    SInt8   eventNetaPackNo;        //  697(1)
    
    SInt8   playLife;               //  698(1)
    BOOL    bTutorial;              //  699(1)
    
    SInt32  settingNetaPackId;      //  700(4)
    char    aCureBeginTimeStr[32];  //  704(32)
    char    aEventBeginTimeStr[32]; //  736(32)

    //	予約領域
	SInt8	dummy[256];				//	768(256)
} SAVE_DATA_ST;	//	1024byte

@interface DataSaveGame : NSObject
{
@private
	//	変数宣言
	SaveData*	mp_SaveData;
    SInt32  m_cureTime;
    SInt32  m_nowCureTime;
    SInt32  m_nowEventTime;
    UInt32  m_gameTime;
    NSDate* mp_networkDate;
}

@property   (nonatomic, readwrite)SInt32    cureTime;
@property   (nonatomic, retain)NSDate*   networkDate;
@property   (nonatomic, readonly)SInt32 nowCureTime;
@property   (nonatomic, readonly)SInt32 nowEventTime;
@property   (nonatomic, readwrite)UInt32    gameTime;

//	関数
+(DataSaveGame*)shared;
+(void)end;

-(void)save;

//  時間に関連するステータスを更新
-(void)updateTimeStatus:(NSDate*)in_date;

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
-(void) addPlayLife:(const SInt8)in_num;

//  ライフタイマー加算
-(void) addPlayLifeTimerCnt:(const SInt32)in_cnt;
//  イベントタイマー加算
-(void) addEventTimerCnt:(const SInt32)in_cnt;

//	広告削除
-(void)	saveCutAdsFlg;

//  なべ経験値を保存
//  (なべレベルには反映しない、ここで設定した値を[addNabeExp]に設定する
//  ゲームで取得した経験値を設定画面で使い、なべレベルが変更して初めてレベル値の表記を変更させるため
//  設定した値を使ったら０クリアする
-(void) saveNabeExp:(UInt16)in_expNum;

//  なべ経験値加算（レベルがあがるとtrue）
//  レベルが変わったら、アラートを出している
-(BOOL) addNabeExp:(UInt16)in_expNum;

//  イベント設定
-(void) setEventNo:(SInt8)in_no :(SInt32)in_timeCnt;
//  in_no=-1なら失敗値なので無視する
-(void) setSuccessEventNo:(SInt8)in_no;
-(void) endEvent;
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
