//
//  DataSettingNetaPack.h
//  tenpura
//
//  Created by y.uchida on 12/11/03.
//
//

#import <Foundation/Foundation.h>

/*
	@brief	セッティングした天ぷらパックデータ
*/
@interface DataSettingNetaPack : NSObject
{
@private
	//	天ぷらパックno
	UInt32		m_no;
}

@property	(nonatomic, readwrite)UInt32	no;

//	関数定義
//	別データからのデータコピー用
-(void)CopyData:(DataSettingNetaPack*)in_pData;

@end
