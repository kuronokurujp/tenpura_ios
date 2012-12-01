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
	eMISSION_MAX	= 64,
};

typedef struct
{
	unsigned char	no;		//	0(1)
	unsigned char	num;	//	1(1)
} SAVE_DATA_ITEM_ST;	// 2byte

//
typedef struct
{
	//	アイテム所持数
	SAVE_DATA_ITEM_ST	aItems[eITEMS_MAX];	//	0(128)
	long	itemNum;				//	128(4)
	
	//	所持金
	long	money;					//	132(4)
	//	日付
	long	year, month, day;		//	136(12)
		
	int64_t	score;				//	148(8)
	char	use;				//	156(1)
	char	check;				//	157(1)
	
	char	aMissionFlg[eMISSION_MAX];		//	158(64)
	char	rank;							//	221(1)
	
	//	予約領域
	char	dummy[34];				//	222(34)
} SAVE_DATA_ST;	//	256byte

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
//	アイテム取得
-(const SAVE_DATA_ITEM_ST*)getItem:(UInt32)in_no;
//	アイテム取得(リストidx)
-(const SAVE_DATA_ITEM_ST*)getItemOfIndex:(UInt32)in_idx;

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
