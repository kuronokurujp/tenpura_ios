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
@public
	enum ITEM_TYPE_ENUM
	{
		eITEM_TYPE_NETA	= 0,
		eITEM_TYPE_OPTION,
	};
@private
	CCLabelTTF*	mp_itemName;
	
	UInt32	m_itemNo;
	SInt32	m_type;
}

@property	(nonatomic, readonly)UInt32 itemNo;
@property	(nonatomic, readonly)SInt32	type;

-(void)settingItem:(SInt32)in_type :(SInt32)in_textId :(SInt32)in_no;

@end

/*
	@brief	ゲームスタート開始ボタン
*/
@interface SettingGameStartBtn : CCControlButton

@end