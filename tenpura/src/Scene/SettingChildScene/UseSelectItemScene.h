//
//  UseSelectItemScene.h
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

enum
{
	USE_SELECT_ITEM_SCENE_TYPE_NABE	= 1,
	USE_SELECT_ITEM_SCENE_TYPE_DRINK,
	USE_SELECT_ITEM_SCENE_TYPE_SALT,
	USE_SELECT_ITEM_SCENE_TYPE_SAUCE,
	USE_SELECT_ITEM_SCENE_TYPE_MAX,
};

@interface UseSelectItemScene : SWTableViewHelper
{
@public
	//	セッティング項目
	SettingItemBtn*	mp_settingItemBtn;
	//	セッティング項目全リスト（現在セッティングした情報を取得するために必要）
	CCArray*		mp_useItemNoList;
	
	//	選択できるアイテムリスト
	CCArray*		mp_selectItemNoList;
}

//	セットアップ
//	※必ず初期化後に呼ぶ（呼ばないとハングする）
-(void)setup:(SettingItemBtn*)in_pItemBtn :(CCArray*)in_pUseItemNoList :(CCArray*)in_pSelectTypeList;

@end
