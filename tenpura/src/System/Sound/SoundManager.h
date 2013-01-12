//
//  SoundManager.h
//  tenpura
//
//  Created by y.uchida on 13/01/03.
//
//

#import <Foundation/Foundation.h>

typedef struct
{
	Float32	delayTime;
	char	aDataName[64];
	char	aSoundName[64];
	char	aFormatName[16];
} SOUDN_DATA_ST;

@interface SoundManager : NSObject
{
@private
	
	SOUDN_DATA_ST*	mp_dataList;
	UInt32	m_dataNum;
}

//	外部参照可能に
+(SoundManager*)	shared;
+(void)	end;

//	セットアップ
-(BOOL)	setup:(NSString*)in_pFileName;

//	サウンド再生
-(const SInt32)	play:(const UInt32)in_idx;
//	サウンド再生(名前指定)
-(const SInt32)	playByName:(NSString*)in_pName;

//	前読み込み
-(void)	preLoad:(NSString*)in_pFormatName;

@end
