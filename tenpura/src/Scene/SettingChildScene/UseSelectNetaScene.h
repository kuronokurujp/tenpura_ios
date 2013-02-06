//
//  UseSelectNetaScene.h
//  tenpura
//
//  Created by y.uchida on 12/09/08.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "./../../System/TableView/SWTableViewHelper.h"

//	前方宣言
@class SettingItemBtn;

@interface UseSelectNetaScene : SWTableViewHelper
{
	//	セッティング項目
	SettingItemBtn*	mp_settingItemBtn;
	//	セッティング項目全リスト（現在セッティングした情報を取得するために必要）
	CCArray*		mp_useItemNoList;
}

//	セットアップ
//	※必ず初期化後に呼ぶ（呼ばないとハングする）
-(void)setup:(SettingItemBtn*)in_pItemBtn :(CCArray*)in_pUseItemNoList;

@end
