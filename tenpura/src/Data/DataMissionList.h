//
//  DataMissionList.h
//  tenpura
//
//  Created by y.uchida on 12/11/29.
//
//

#import <Foundation/Foundation.h>

@interface DataMissionList : NSObject
{
@private
	struct MISSION_DATA_ST*	mp_dataList;
	UInt32	m_dataNum;
}

@property	(nonatomic, readonly)UInt32	dataNum;

//	関数
+(DataMissionList*)	shared;
+(void)	end;

//	ミッション名取得
-(NSString*)	getMissonName:(UInt32)in_idx;
//	ミッション成功時のメッセージ取得
-(NSString*)	getSuccessMsg:(UInt32)in_idx;
//	ミッション成功しているかどうかの設定
-(void)	setSuccess:(BOOL)in_flg :(UInt32)in_idx;
//	ミッションが成功しているかのフラグ取得
-(BOOL)	isSuccess:(UInt32)in_idx;
//	ミッション成功しているかとうかのチェック(内部でチェック処理をするので重い)
-(BOOL)	checkSuccess:(UInt32)in_idx;

@end
