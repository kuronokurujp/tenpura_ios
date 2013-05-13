//
//  AnimActionNumCounterLabelTTF.h
//  tenpura
//
//  Created by y.uchida on 13/02/27.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AnimActionNumCounter : NSObject
{
@private
	SInt32	m_num;
	SInt32	m_oldNum;
	SInt32	m_count;
	SInt32	m_addNum;
	ccTime	m_time;
	NSString*	mp_format;
}

@property	(nonatomic, readonly)SInt32	countNum;

//	更新
-(bool)	update:(ccTime)delta;

//	表示フォーマット
-(void)	setStringFormat:(NSString*)in_pFormat;
//	カウント目標値設定
-(void)	setCountNum:(SInt32)in_num;
//	カウントせずに即反映
-(void)	setNum:(SInt32)in_num;

//	文字列取得
-(NSString*)	getText;

@end

@interface AnimActionNumCounterLabelTTF : CCLabelTTF
{
@private
	AnimActionNumCounter*	mp_animCnt;
}

//	表示フォーマット
-(void)	setStringFormat:(NSString*)in_pFormat;
//	カウント目標値設定
-(void)	setCountNum:(SInt32)in_num;
//	カウントせずに即反映
-(void)	setNum:(SInt32)in_num;

-(SInt32)	getCountNum;

@end

@interface AnimActionNumCounterLabelBMT : CCLabelBMFont
{
@private
	AnimActionNumCounter*	mp_animCnt;
}

//	表示フォーマット
-(void)	setStringFormat:(NSString*)in_pFormat;
//	カウント目標値設定
-(void)	setCountNum:(SInt32)in_num;
//	カウントせずに即反映
-(void)	setNum:(SInt32)in_num;

-(SInt32)	getCountNum;

@end
