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
	BOOL			mb_fever;
    BOOL            mb_tenpuraNonBurn;
	Float32			m_flyTimeRate;
	Float32			m_setFlyTimeRate;
	SInt32			m_tenpuraZOrder;
}

@property	(nonatomic, readwrite)Float32	setFlyTimeRate;
@property   (nonatomic, readwrite)BOOL  bTenpuraNonBurn;

//	関数定義

//	鍋画像設定(アイテム設定で鍋を変更することがある)
-(void)	setNabeImageFileName:(NSString*)in_pNabeFileName;

//	天ぷら追加
-(Tenpura*)	addTenpura:(const NETA_DATA_ST*)in_pData;
//	追加天ぷらすべて削除
-(void)	allCleanTenpura;
//	配置した天ぷらが爆発
-(void)	onExpTenpura:(CCNode *)in_pTenpura;
//	天ぷらをつける
-(void)	onAddChildTenpura:(CCNode*)in_pTenpura;
//	フィーバー設定
-(void)	setEnableFever:(const BOOL)in_bFlg;

//	配置した天ぷらもポーズする
-(void)	pauseSchedulerAndActions;
//	配置した天ぷらも再開
-(void)	resumeSchedulerAndActions;

//	オーバーライド定義
-(CGRect)	boundingBox;

@end
