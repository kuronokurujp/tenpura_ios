//
//  GameResultScene.h
//  tenpura
//
//  Created by y.uchida on 12/10/06.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
	eRESULT_TYPE_NONE	= 0,
	eRESULT_TYPE_RESTART,
	eRESULT_TYPE_SINAGAKI,
} ResultTypeEnum;

@interface GameResultScene : CCLayer {
	
	ResultTypeEnum	m_resultType;
}

@property (nonatomic, readonly)ResultTypeEnum resultType;

@end
