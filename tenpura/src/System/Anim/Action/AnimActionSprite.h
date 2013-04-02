//
//  AnimActionSprite.h
//  tenpura
//
//  Created by y.uchida on 13/01/06.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/*
	@brief	アニメデータ
	@note	アニメのフレーム名には必ず再生させる順序の数を設定する
*/
@interface AnimData : NSObject
{
@private
	NSString*	mp_fileName;
	NSString*	mp_fileImageName;
	NSArray*	mp_frameNameList;
	UInt32	m_fps;
}

@property	(nonatomic, retain)NSString*	fileName;
@property	(nonatomic, retain)NSString*	fileImageName;
@property	(nonatomic, retain)NSArray*	frameNameList;
@property	(nonatomic, readonly)UInt32	fps;

-(id)	initWithData:(const char*)in_pFileName :(const char*)in_pFileImageName :(const UInt32)in_fps;
@end

@interface AnimActionSprite : CCNode
{
@private
	CCSprite*	mp_sp;
	AnimData*	mp_data;
	CCAnimation*	mp_anim;
	NSArray*	mp_frameList;
	BOOL	mb_loop;
	BOOL	mb_pause;
	BOOL	mb_autoRelease;
}

@property	(nonatomic, retain)CCSprite*	sp;
@property	(nonatomic)BOOL	bLoop;
@property	(nonatomic, assign)BOOL	bAutoRelease;

-(id)	initWithData:(AnimData*)in_data;
-(id)	initWithDataAndLoop:(AnimData*)in_data;

-(void)	start;
-(void)	end;
-(void)	frame:(const UInt32)idx;

@end
