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

//
typedef struct
{
	//	アイテム所持数
	unsigned char	aItems[ eITEMS_MAX ];	//	0(64)
	int	itemNum;				//	64(4)
	
	//	所持金
	int	money;					//	68(4)
	//	日付
	int	year, month, day;		//	72(12)
	
	int	check;					//	84(4)
	
	int64_t	score;				//	88(8)
	char	use;				//	96(1)
	//	予約領域
	char	dummy[31];				//	97(31)
} SAVE_DATA_ST;	//	128

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
-(BOOL)isItem:(UInt32)in_no;
//	アイテム追加
-(BOOL)addItem:(UInt32)in_no;
//	現在時刻を記録
-(BOOL)saveDate;

-(const SAVE_DATA_ST*)getData;

//	セーブ初期データ取得
-(void)getInitSaveData:(SAVE_DATA_ST*)out_pData;

@end
