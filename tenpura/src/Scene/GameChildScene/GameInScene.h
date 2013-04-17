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

@class GameScene;
@class GameSceneData;
@class GameInNormalScene;
@class GameInFeverScene;

/*
	@brief	インゲーム
*/
@interface GameInScene : CCLayer
{
@private	
	GameInNormalScene*	mp_normalScene;
	GameInFeverScene*	mp_feverScene;
}

-(id)	init:(Float32)in_time :(GameSceneData*)in_pGameSceneData;

-(BOOL)	isFever;

@end

/*
	@brief	ゲーム中の通常シーン
*/
@interface GameInNormalScene : CCLayer
{
@private
	GameScene*	mp_gameScene;
	Float32		m_time;
	Tenpura*	mp_touchTenpura;
	UInt32		m_combCnt;
	UInt32		m_veryEatCnt;
	UInt32		m_feverCnt;
	BOOL		mb_fever;
}

@property	(nonatomic, readonly)Float32	time;
@property	(nonatomic)BOOL	bFever;

//	初期化
-(id)	init:(Float32)in_time;

//	開始
-(void)	start:(GameScene*)in_pGameScene;

@end

/*
	@brief	ゲーム中のフィーバーシーン
*/
@interface GameInFeverScene : CCLayer
{
@private
	GameScene*	mp_gameScene;
	GameInNormalScene*	mp_gameInNormalScene;
}

//	開始
-(void)	start:(GameScene*)in_pGameScene :(GameInNormalScene*)in_pGameInNormalScene;
//	終了
-(void)	end;

@end
