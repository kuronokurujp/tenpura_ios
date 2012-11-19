//
//  SaveData.h
//  tenpura
//
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
-(BOOL)setup:(NSString*)in_pIdName:(SInt32)in_size;

-(BOOL)load;
-(BOOL)save;
-(BOOL)reset;

-(char*)getData;

@end
