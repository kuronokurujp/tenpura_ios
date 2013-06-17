//
//  ItemShopScene.h
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "./ShopBaseScene.h"
#import "./../../Data/DataSaveGame.h"
#import "./../../Data/DataItemList.h"

@interface ItemShopScene : ShopBaseScene
{
@private
    SInt32  m_itemNum;
    ITEM_DATA_ST   ma_itemList[eSAVE_DATA_ITEMS_MAX];
}

//	セル最大数
-(SInt32)	getCellMax;
//	購入金額
-(SInt32)	getSellMoney:(SInt32)in_idx;
//	購入
-(BOOL)	buy:(SInt32)in_idx;
//	購入チェック
-(BOOL)	isBuy:(SInt32)in_idx;

@end
