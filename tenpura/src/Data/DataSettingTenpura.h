//
//  DataSettingTenpura.h
//  tenpura
//
//  Created by y.uchida on 12/11/03.
//
//

#import <Foundation/Foundation.h>

/*
	@brief	セッティングした天ぷらデータ
*/
@interface DataSettingTenpura : NSObject
{
@private
	//	天ぷらno
	UInt32	m_no;
}

@property	(nonatomic, readwrite)UInt32	no;

//	関数定義
//	別データからのデータコピー用
-(void)CopyData:(DataSettingTenpura*)in_pData;

@end
