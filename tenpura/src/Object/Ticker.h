//
//  Ticker.h
//  tenpura
//
//  Created by y.uchida on 12/12/23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LeftMoveTicker : CCSprite
{
@private
	CGPoint	m_limitPos;
	CGPoint	m_startPos;
}

@end
