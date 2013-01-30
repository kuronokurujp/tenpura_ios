//
//  ComboMessage.m
//  tenpura
//
//  Created by y.uchida on 13/01/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "ComboMessage.h"

@interface ComboMessage (PrivateMethod)

//	退場終了時に
-(void)	_endActExit;

@end

@implementation ComboMessage

enum
{
	eACT_TAG_PUT	= 0,
	eACT_TAG_EXIT,
};

/*
	@brief
*/
-(id)	init
{
	if( self = [super init] )
	{
		mp_number	= [CCLabelBMFont labelWithString:@"1" fntFile:@"combo_num.fnt"];
		[self addChild:mp_number];
	}
	
	return self;
}

/*
	@brief
*/
-(void)	dealloc
{
	[super dealloc];
}

/*
	@brief	コンボメッセージ開始
*/
-(void)	start:(UInt32)in_num
{
	//	すでに登場しているかチェック
	//	登場していないなら登場アクション開始
	if( (self.visible == NO ) && ([self getActionByTag:eACT_TAG_PUT] == nil) )
	{
		[self stopAllActions];

		[self setPosition:ccp(startPosX, startPosY)];

		[mp_message setOpacity:255];
		[mp_number setOpacity:255];

		CCMoveTo*		pMove		= [CCMoveTo actionWithDuration:startActTime position:ccp(endPosX, endPosY)];
		CCEaseIn*		pEaseMove	= [CCEaseIn actionWithAction:pMove rate:1];

		[pEaseMove setTag:eACT_TAG_PUT];
		[self runAction:pEaseMove];

		[self setVisible:YES];
	}

	//	登場しているなら単純に数字のみ変更
	[mp_number setString:[NSString stringWithFormat:@"%ld", in_num]];
}

/*
	@brief	コンボメッセージ終了
*/
-(void)	end
{
	//	登場しているかチェック
	if( self.visible )
	{
		[self stopAllActions];

		//	登場しているなら退場させる
		CCFadeOut*	pFadeOut	= [CCFadeOut actionWithDuration:endActTime];

		CCCallFunc*	pEndCall	= [CCCallFunc actionWithTarget:self selector:@selector(_endActExit)];
		CCSequence*	pRun	= [CCSequence actionOne:pFadeOut two:pEndCall];
		[pRun setTag:eACT_TAG_EXIT];

		[mp_message runAction:pRun];
		//	インスタンス作成したアクションは使い回すのは危険！！
		[mp_number runAction:[CCFadeOut actionWithDuration:endActTime]];
	}

	//	登場していなら何もしない
}

/*
	@brief	退場終了時に
*/
-(void)	_endActExit
{
	[self setVisible:NO];
}

/*
	@brief	CCBI読み込み終了
*/
- (void) didLoadFromCCB
{
	[self setPosition:ccp(startPosX, startPosY)];
	[mp_number setPosition:ccp(numPosX, numPosY)];
	
	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(children_, pNode)
	{
		if( [pNode isKindOfClass:[CCSprite class]] )
		{
			mp_message	= (CCSprite*)pNode;
		}
	}
	
	[mp_message setOpacity:0];
	[mp_number setOpacity:0];
}

@end
