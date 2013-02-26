//
//  ShopBaseScene.h
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "./../../System/TableView/SWTableViewHelper.h"

@interface ShopBaseScene : SWTableViewHelper
<
	UIAlertViewDelegate
>
{
	UIAlertView*	mp_buyCheckAlertView;
	UIAlertView*	mp_buyAlertView;
	
	SWTableViewCell*	mp_buyItemCell;
	CCLabelTTF*	mp_moneyTextLable;
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
