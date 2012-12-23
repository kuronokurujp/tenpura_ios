//
//  SettingScene.h
//  tenpura
//
//  Created by y.uchida on 12/11/01.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import	"./../Data/DataNetaList.h"
#import "./../Object/Ticker.h"
#import "./../../libs/CCControlExtension/CCControl/CCControlButton.h"

@interface SettingScene : CCLayer
<
	UIAlertViewDelegate
>
{
@private
	//	セッティング用項目リスト
	CCArray*			mp_useItemNoList;
	CCControlButton*	mp_gameStartBtn;
	UIAlertView*		mp_missionSucceesAlertView;
	LeftMoveTicker*		mp_ticker;
}

@property	(nonatomic, retain)CCArray*	useItemNoList;

@end

/*
	@brief	アイテム設定項目ボタン
*/
@interface SettingItemBtn : CCMenuItemImage
{
@private
	CCLabelTTF*	mp_itemName;
	UInt32	m_itemNo;
}

@property	(nonatomic, readonly)UInt32 itemNo;

-(void)settingItem:(const NETA_DATA_ST*)in_pData;

@end

/*
	@brief	ゲームスタート開始ボタン
*/
@interface SettingGameStartBtn : CCControlButton

@end