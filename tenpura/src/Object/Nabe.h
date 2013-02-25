//
//  Nabe.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "../Data/DataNetaList.h"
#import "Tenpura.h"

@interface Nabe : CCNode
<
	TenpuraProtocol
>
{
@private
	//	変数定義
	CCSprite*		mp_sp;
	Float32			m_flyTimeRate;
	SInt32			m_tenpuraZOrder;
}

//	関数定義

//	天ぷら追加
-(Tenpura*)	addTenpura:(const NETA_DATA_ST*)in_pData :(Float32)in_raiseSpeedRate;
//	追加天ぷらすべて削除
-(void)	allCleanTenpura;
//	配置した天ぷらが爆発
-(void)	onExpTenpura:(CCNode *)in_pTenpura;
//	天ぷらをつける
-(void)	onAddChildTenpura:(CCNode*)in_pTenpura;
//	揚げる天ぷらの揚げる時間レートを変更(すくない値を渡すほど早くなる)
-(void)	setRaiseTimeRate:(Float32)in_rate;
//	おじゃまを出す
-(void)	putOjamaTenpura;

//	配置した天ぷらもポーズする
-(void)	pauseSchedulerAndActions;
//	配置した天ぷらも再開
-(void)	resumeSchedulerAndActions;

//	オーバーライド定義
-(CGRect)	boundingBox;

@end
