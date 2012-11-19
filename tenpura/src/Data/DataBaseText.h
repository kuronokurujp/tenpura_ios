//
//  DataBaseText.h
//  tenpura
//
//  Created by y.uchida on 12/11/04.
//
//

#import <Foundation/Foundation.h>

typedef struct
{
	UInt32	no;
//	UInt32	fontSize;
	char	nameJPN[256];
	char	nameEN[256];
	
} DATA_TEXT_ST;

@interface DataBaseText : NSObject
{
@private
	DATA_TEXT_ST*	mp_dataList;
	UInt32			m_dataNum;
}

//	関数定義
+(DataBaseText*)	shared;
+(void)	end;

+(NSString*)getString:(const UInt32)in_no;

-(const char*)getText:(const UInt32)in_no;
-(const UInt32)getFontSize:(const UInt32)in_no;
-(const SInt32)getConvertID:(const char*)in_pText;

@end
