//
//  GameInScene.h
//  tenpura
//
//  Created by y.uchida on 12/10/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Tenpura;

@interface GameInScene : CCLayer
{
@private
	Float32		m_time;
	Tenpura*	mp_touchTenpura;
}

-(id)	init:(Float32)in_time;

@end
