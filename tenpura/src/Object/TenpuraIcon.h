//
//  TenpuraIcon.h
//  tenpura
//
//  Created by y.uchida on 12/10/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TenpuraIcon : CCNode
{
@private
	CCSprite*	mp_sp;
	SInt32		m_no;
}

@property	(nonatomic, readonly)SInt32 no;

//	関数
-(id)	initWithFile:(NSString*)in_pFileName :(SInt32)in_no;


@end
