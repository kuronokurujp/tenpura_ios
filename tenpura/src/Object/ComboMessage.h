//
//  ComboMessage.h
//  tenpura
//
//  Created by y.uchida on 13/01/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ComboMessage : CCLayer
{
@private
	CCSprite*		mp_message;
	CCLabelBMFont*	mp_number;
	
	Float32	startPosX, startPosY;
	Float32	endPosX,	endPosY;
	Float32	numPosX,	numPosY;
	Float32	startActTime, endActTime;
}

//	コンボメッセージ開始
-(void)	start:(UInt32)in_num;
//	コンボメッセージ終了
-(void)	end;

@end
