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
	NSString*	mp_playNameBGM;
}

//	外部参照可能に
+(SoundManager*)	shared;
+(void)	end;

//	セットアップ
-(BOOL)	setup:(NSString*)in_pFileName;

//	サウンド再生
-(const SInt32)	playBgm:(NSString*)in_pName;
-(const SInt32)	playSe:(NSString*)in_pName;

//	サウンド停止
-(void)	stopBgm:(Float32)in_fadeTime;

//	前読み込み
-(void)	preLoad:(NSString*)in_pFormatName;

@end
