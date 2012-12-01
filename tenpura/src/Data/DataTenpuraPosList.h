//
//  DataTenpuraPosList.h
//  tenpura
//
//  Created by y.uchida on 12/10/15.
//
//

#import <Foundation/Foundation.h>

typedef struct
{
	float	x,y;
	BOOL	bUse;
} TENPURA_POS_ST;

@interface DataTenpuraPosList : NSObject
{
@private
	TENPURA_POS_ST*	mp_dataList;
	UInt32	m_dataNum;
}

//	外部参照可能に
+(DataTenpuraPosList*)	shared;
+(void)	end;

//	プロパティ
@property(nonatomic, readonly)	UInt32	dataNum;

//	データ取得
-(TENPURA_POS_ST)	getData:(UInt32)in_idx;
//	未使用のデータIdx取得
-(UInt32)	getIdxNoUse;

//	使用設定と取得
-(void)	setUseFlg:(BOOL)in_flg:(UInt32)in_idx;
-(BOOL)	isUse:(UInt32)in_idx;
-(void)	clearFlg;
	
@end
