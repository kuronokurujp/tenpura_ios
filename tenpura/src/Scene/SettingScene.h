//
//  SettingScene.h
//  tenpura
//
//  Created by y.uchida on 12/11/01.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "./../Data/DataEventDataList.h"

#import "./../System/Store/StoreAppPurchaseManager.h"

#import "./../../libs/CCControlExtension/CCControl/CCControlButton.h"

typedef enum
{
    eEVENT_SUCCESS_RESULT_NONE   = 0,
    eEVENT_SUCCESS_RESULT_RUN,
    eEVENT_SUCCESS_RESULT_OK,
    eEVENT_SUCCESS_RESULT_NG,
} EVENT_SUCCESS_RESULT_ENUM;

@interface SettingScene : CCLayer
<
	UIAlertViewDelegate,
    StoreAppPurchaseManagerSuccessProtocol
>
{
@private
	//	セッティング用項目リスト
	CCArray*			mp_useItemNoList;
	CCControlButton*	mp_gameStartBtn;
	UIAlertView*		mp_missionSucceesAlertView;
	UIAlertView*		mp_missionBounesAlertView;
    UIAlertView*        mp_eventInvocAlertView;
    UIAlertView*        mp_eventSuccessAlertView;
    UIAlertView*        mp_eventRewardAlertView;
    UIAlertView*        mp_eventNGAlertView;
    UIAlertView*        mp_eventChkAlertView;
    
    EVENT_SUCCESS_RESULT_ENUM   m_eventSuccessRet;
    CCNode* mp_eventChkBtn;
    
    CCArray*    mp_heartObjArray;
    CCLabelBMFont*  mp_cureTimeStr;
    CGPoint m_playLifePos;
    
	UInt32	m_missionSuccessIdx;
    BOOL    mb_chkStartEvent;
}

@property	(nonatomic, retain)CCArray*	useItemNoList;
@property   (nonatomic, readonly)SInt32 cureTimeByCcbiProperty;

-(void) onStoreSuccess:(NSString*)in_pProducts;

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
	CCLabelBMFont*	mp_itemName;
	
	UInt32	m_itemNo;
	SInt32	m_type;
}

@property	(nonatomic, readonly)UInt32 itemNo;
@property	(nonatomic, readonly)SInt32	type;
//  ,区切りで値があるので、配列に変換する
@property   (nonatomic, readonly)NSString*   itemSelectTypeList;

-(void)settingItem:(SInt32)in_type :(SInt32)in_textId :(SInt32)in_no;
-(NSArray*) getItemSelectType;

@end

//  天ぷら設定ボタン
@interface SettingNetaPackBtn : SettingItemBtn

@end

/*
	@brief	ゲームスタート開始ボタン
*/
@interface SettingGameStartBtn : CCControlButton

@end

/*
    @brief  イベント確認ボタン
*/
@interface SettingEventChkBtn : CCControlButton

@end
