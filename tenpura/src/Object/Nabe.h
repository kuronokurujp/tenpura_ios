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
}

//	関数定義
-(Tenpura*)	addTenpura:(NETA_DATA_ST)in_data;
-(void)	subTenpura:(Tenpura*)in_pTenpura;

-(void)	setVisibleTenpura:(BOOL)in_bFlg;

//	オーバーライド定義
-(CGRect)	boundingBox;

@end
