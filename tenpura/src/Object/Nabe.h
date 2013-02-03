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
	SInt32			m_tenpuraZOrder;
}

//	関数定義

//	天ぷら追加
-(Tenpura*)	addTenpura:(NETA_DATA_ST)in_data:(Float32)in_raiseSpeedRate;
//	追加天ぷらすべて削除
-(void)	allCleanTenpura;
//	配置した天ぷらが爆発
-(void)	onExpTenpura:(CCNode *)in_pTenpura;
//	天ぷらをつける
-(void)	onAddChildTenpura:(CCNode*)in_pTenpura;
//	揚げる天ぷらの揚げるスピートレートを変更
-(void)	setRaiseSpeedRate:(Float32)in_rate;

//	配置した天ぷらもポーズする
-(void)	pauseSchedulerAndActions;
//	配置した天ぷらも再開
-(void)	resumeSchedulerAndActions;

//	オーバーライド定義
-(CGRect)	boundingBox;

@end
