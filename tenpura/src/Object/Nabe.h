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

//	前方宣言
@class Tenpura;

@interface Nabe : CCNode {
    	
@private
	//	変数定義
	CCSprite*		mp_sp;
	SInt32			m_tenpuraZOrder;
}

//	関数定義

//	天ぷら追加
-(Tenpura*)	addTenpura:(NETA_DATA_ST)in_data;
//	追加した天ぷら削除
-(void)	removeTenpura:(Tenpura*)in_pTenpura;
//	追加天ぷらすべて削除
-(void)	allRemoveTenpura;

//	オーバーライド定義
-(CGRect)	boundingBox;

@end
