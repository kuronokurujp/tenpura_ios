//
//  SaveData.h
//  tenpura
//
//	@note	NSUserDefaultを使用している大容量メモリでの使用はまずい1Mbyte以下がベストかも
//			要領が大きいとアプリに必要なメモリも使用してアプリ自体が動かなくなる
//  Created by y.uchida on 12/10/20.
//
//

#import <Foundation/Foundation.h>

@interface SaveData : NSObject
{
@private
		char*		mp_Data;
		SInt32		m_Size;
		NSString*	mp_IdName;
}

//	必ず最初に呼ぶ
-(BOOL)setup:(NSString*)in_pIdName :(SInt32)in_size;

//	ロード
-(BOOL)load;
//	セーブ
-(BOOL)save;
//	リセット
-(BOOL)reset;

//	データアドレス取得
-(char*)getData;

@end
