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
*/
@interface AnimData : NSObject
{
@private
	NSString*	mp_fileName;
	NSString*	mp_fileImageName;
	CCArray*	mp_spriteFileNamList;
	UInt32	m_fileNum;
	UInt32	m_fps;
}

@property	(nonatomic, retain)NSString*	fileName;
@property	(nonatomic, retain)NSString*	fileImageName;
@property	(nonatomic, retain)CCArray*	spriteFileNameList;
@property	(nonatomic, readonly)UInt32	fileNum;
@property	(nonatomic, readonly)UInt32	fps;

-(id)	initWithData:(const char*)in_pFileName:(const char*)in_pFileImageName:(const char**)in_pFrameNameList:(const UInt32)in_FrameNum:(const UInt32)in_fps;
@end

@interface AnimActionSprite : CCNode
{
@private
	CCSprite*	mp_sp;
	AnimData*	mp_data;
	CCAnimate*	mp_anim;
	BOOL	mb_loop;
}

@property	(nonatomic)BOOL	bLoop;

-(id)	initWithData:(AnimData*)in_data;

@end
