//
//  SettingScene.m
//  tenpura
//
//  Created by y.uchida on 12/11/01.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingScene.h"
#import "GameScene.h"

#import "./../../libs/CCControlExtension/CCControlExtension.h"
#import "./../CCBReader/CCBReader.h"

#import "./../AppDelegate.h"
#import "./../Data/DataSettingNetaPack.h"
#import "./../Data/DataBaseText.h"
#import "./../Data/DataGlobal.h"
#import "./../Data/DataSaveGame.h"
#import "./../Data/DataMissionList.h"
#import	"./../Data/DataNetaPackList.h"
#import "./../Data/DataItemList.h"
#import "./../Data/DataStoreList.h"

#import "./../System/Sound/SoundManager.h"
#import "./../System/Anim/AnimManager.h"

#import "./SettingChildScene/UseSelectNetaScene.h"
#import "./SettingChildScene/UseSelectItemScene.h"

@interface SettingScene (PriveteMethod)

-(void) _runGamePlay;
-(void) _runPlayLifeProcess;

-(void)	_checkMissionSuccess;

-(NSString*)    _getEventNGMessage;
-(NSString*)    _getEventSuccessMessage;
-(NSString*)    _getEventInvocMessage:(const BOOL)in_bNewScore :(const BOOL)in_bNewLimit;

@end

@implementation SettingScene

@synthesize useItemNoList	= mp_useItemNoList;

/*
	@brief
*/
-(id)init
{
	if( self = [super init] )
	{
		//	エフェクト管理をいったんすべて解放
		[AnimManager end];

		mp_useItemNoList	= [[CCArray alloc] init];
		mp_gameStartBtn	= nil;
		mp_missionSucceesAlertView	= nil;
		mp_missionBounesAlertView	= nil;
        mp_eventInvocAlertView      = nil;
        mp_eventSuccessAlertView    = nil;
        mp_eventRewardAlertView     = nil;
        mp_eventNGAlertView         = nil;
        mp_eventChkAlertView        = nil;
        mp_eventChkBtn  = nil;

		mp_ticker	= nil;
		m_missionSuccessIdx	= 0;
        m_eventSuccessRet   = eEVENT_SUCCESS_RESULT_NONE;

        //  初回のみイベント発生
        {
            DataSaveGame*   pDataSaveGameInst   = [DataSaveGame shared];
            const SAVE_DATA_ST* pSaveData   = [pDataSaveGameInst getData];
            if(pSaveData->invocEventNo == -1)
            {
                mb_chkStartEvent    = YES;
            }
            else if( pSaveData->successEventNo != -1 )
            {
                m_eventSuccessRet   = eEVENT_SUCCESS_RESULT_OK;
            }
        }
		
		[[SoundManager shared] playBgm:@"normalBGM"];
	}
	
	return self;
}

/*
	@brief
*/
-(void)dealloc
{
	if( mp_missionSucceesAlertView != nil )
	{
		[mp_missionSucceesAlertView release];
		mp_missionSucceesAlertView	= nil;
	}
	
	if( mp_missionBounesAlertView != nil )
	{
		[mp_missionBounesAlertView release];
		mp_missionBounesAlertView	= nil;
	}

	if( mp_eventInvocAlertView != nil )
	{
		[mp_eventInvocAlertView release];
		mp_eventInvocAlertView	= nil;
	}

	if( mp_eventSuccessAlertView != nil )
	{
		[mp_eventSuccessAlertView release];
		mp_eventSuccessAlertView	= nil;
	}

	if( mp_eventRewardAlertView != nil )
	{
		[mp_eventRewardAlertView release];
		mp_eventRewardAlertView	= nil;
	}
    
    if( mp_eventNGAlertView != nil )
    {
        [mp_eventNGAlertView release];
        mp_eventNGAlertView = nil;
    }
    
    if( mp_eventChkAlertView )
    {
        [mp_eventChkAlertView release];
        mp_eventChkAlertView    = nil;
    }
    
	mp_ticker	= nil;
	
	if( mp_useItemNoList != nil )
	{
		[mp_useItemNoList release];
	}
	mp_useItemNoList	= nil;
	
	[super dealloc];
}

/*
	@brief
*/
-(void)	onEnter
{
    [self _runPlayLifeProcess];

	[mp_ticker setVisible:YES];

    [mp_eventChkBtn setVisible:NO];
    if( m_eventSuccessRet == eEVENT_SUCCESS_RESULT_NONE )
    {
        const SAVE_DATA_ST* pSaveData   = [[DataSaveGame shared] getData];
        if( pSaveData->invocEventNo != -1 )
        {
            [mp_eventChkBtn setVisible:YES];
        }
    }

	//	受け渡しためのデータリスト作成
	SettingItemBtn*	pSettingItemBtn	= nil;
	CCARRAY_FOREACH(mp_useItemNoList, pSettingItemBtn)
	{
		if( ( 0 < pSettingItemBtn.itemNo ) && ( pSettingItemBtn.type == eITEM_TYPE_NETA ) )
		{
			[mp_gameStartBtn setVisible:YES];
			[mp_ticker setVisible:NO];
			break;
		}
	}

	[super onEnter];
}

/*
	@brief	変移演出終了
*/
-(void)	onEnterTransitionDidFinish
{
	//	バナー表示通知
	{
		NSString*	pBannerShowName	= [NSString stringWithUTF8String:gp_bannerShowObserverName];
		NSNotification *n = [NSNotification notificationWithName:pBannerShowName object:nil];
		NSAssert(n, @"");
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}

    {
        [self schedule:@selector(_runPlayLifeProcess)];
    }

    {
        DataSaveGame*   pDataSaveGameInst   = [DataSaveGame shared];
        const SAVE_DATA_ST* pSaveData   = [pDataSaveGameInst getData];
        
        if( mb_chkStartEvent == YES )
        {
            //  発生チェック
            const SInt8   no  = [DataEventDataList invocEvnet];
            if( no != -1 )
            {
                m_eventSuccessRet   = eEVENT_SUCCESS_RESULT_RUN;
                [pDataSaveGameInst setEventNo:no];
            }
            mb_chkStartEvent    = NO;
        }
        else if( (pSaveData->invocEventNo != -1) && (m_eventSuccessRet == eEVENT_SUCCESS_RESULT_NONE) )
        {
            if( [DataEventDataList isError:pSaveData->invocEventNo] )
            {
                m_eventSuccessRet   = eEVENT_SUCCESS_RESULT_NG;
            }            
        }
    }
	
    if( m_eventSuccessRet == eEVENT_SUCCESS_RESULT_NG )
    {
        [mp_eventChkBtn setVisible:NO];

        if( mp_eventNGAlertView != nil )
        {
            [mp_eventNGAlertView release];
            mp_eventNGAlertView = nil;
        }
        mp_eventNGAlertView	= [[UIAlertView alloc]	initWithTitle:[DataBaseText getString:201]
                                                                message:[self _getEventNGMessage]
                                                                delegate:self
                                                                cancelButtonTitle:[DataBaseText getString:46]
                                                                otherButtonTitles:nil];
        [mp_eventNGAlertView show];
    }
    else if( m_eventSuccessRet == eEVENT_SUCCESS_RESULT_OK )
    {
        if( mp_eventSuccessAlertView != nil )
        {
            [mp_eventSuccessAlertView release];
            mp_eventSuccessAlertView = nil;
        }
        mp_eventSuccessAlertView	= [[UIAlertView alloc]	initWithTitle:[DataBaseText getString:208]
                                                                        message:[self _getEventSuccessMessage]
                                                                        delegate:self
                                                                        cancelButtonTitle:[DataBaseText getString:46]
                                                                        otherButtonTitles:nil];
        [mp_eventSuccessAlertView show];
    }
    else if( m_eventSuccessRet == eEVENT_SUCCESS_RESULT_RUN )
    {
        if( mp_eventInvocAlertView != nil )
        {
            [mp_eventInvocAlertView release];
            mp_eventInvocAlertView = nil;
        }
        mp_eventInvocAlertView	= [[UIAlertView alloc]	initWithTitle:[DataBaseText getString:200]
                                                                    message:[self _getEventInvocMessage:YES :YES]
                                                                    delegate:self
                                                                    cancelButtonTitle:[DataBaseText getString:46]
                                                                    otherButtonTitles:nil];
        [mp_eventInvocAlertView show];
    }
    else
    {        
        //	成功しているミッションがあるかチェック
        [self _checkMissionSuccess];
    }

    m_eventSuccessRet   = eEVENT_SUCCESS_RESULT_NONE;

	[super onEnterTransitionDidFinish];
}

/*
	@brief	シーン終了(変移開始)
*/
-(void)	onExitTransitionDidStart
{
    AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
    pApp.storeSuccessDelegate   = nil;

	//	バナー非表示通知
	{
		NSString*	pBannerHideName	= [NSString stringWithUTF8String:gp_bannerHideObserverName];
		NSNotification *n = [NSNotification notificationWithName:pBannerHideName object:nil];
		NSAssert(n, @"");
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}

	[super onExitTransitionDidStart];
}

/*
	@brief	ゲームスタート
*/
-(void)	pressGameBtn
{
	CCLOG(@"GameStart");

    DataSaveGame*   pSaveGameInst   = [DataSaveGame shared];
    const SAVE_DATA_ST* pSaveData   = [pSaveGameInst getData];
    if( pSaveData->playLife <= 0 )
    {
        //  ライフ購入のアドオン処理へ
        StoreAppPurchaseManager*	pStoreApp	= [StoreAppPurchaseManager share];
        
        DataStoreList*	pDataStoreInst	= [DataStoreList shared];
        const STORE_DATA_ST*	pData	= [pDataStoreInst getDataSearchId:eSTORE_ID_CURELIEF];
        if( pData != nil )
        {
            if( pStoreApp.bLoad == false )
            {
                if( [pStoreApp isPayment] == YES )
                {
                    AppController*	pApp	= (AppController*)[UIApplication sharedApplication].delegate;
                    pApp.storeSuccessDelegate   = self;

                    [pStoreApp requestProduct:[NSString stringWithUTF8String:pData->aStoreIdName]];
                }
                else
                {
                    //	機能制限でつかえない
                    UIAlertView*	pAlert	= [[[UIAlertView alloc]
                                                initWithTitle:@"" message:[DataBaseText getString:155]
                                                delegate:nil
                                                cancelButtonTitle:[DataBaseText getString:46]
                                                otherButtonTitles:nil, nil] autorelease];
                    [pAlert show];
                }                
            }
        }
    }
    else
    {
        [self _startGamePlay];
    }
		
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	ネタ購入へ
*/
-(void)	pressNetaShopBtn
{
	CCLOG(@"Shop");
	
	CCScene*	sinagakiScene	= [CCBReader sceneWithNodeGraphFromFile:@"siire.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:sinagakiScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] pushScene:pTransFade];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	アイテム購入
*/
-(void)	pressItemShopBtn
{
	CCLOG(@"ItemShop");

	CCScene*	sinagakiScene	= [CCBReader sceneWithNodeGraphFromFile:@"itemShop.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:sinagakiScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] pushScene:pTransFade];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	天ぷら設定
*/
-(void)	pressSettingNetaBtn:(id)sender
{
	CCLOG(@"SelectItem");
	
	CCNode* node = [CCBReader nodeGraphFromFile:@"use_neta_select.ccbi" owner:nil];
	
	//	選択したセッティング項目を選択リストにアタッチ
	//	選択したオブジェクトがセッティング項目用かチェックもする
	//	(デリゲーダーが使える？)
	if( ( [node isKindOfClass:[UseSelectNetaScene class]] ) && ([sender isKindOfClass:[SettingItemBtn class]]) )
	{
		UseSelectNetaScene*	pUseSelectNetaScene	= (UseSelectNetaScene*)node;
		SettingItemBtn*	pSettingUseItemBtn	= (SettingItemBtn*)sender;
		
		//	タッチしたときのアクション
		{
			CCBlink*	pActBlink	= [CCBlink actionWithDuration:0.5f blinks:2];
			[pSettingUseItemBtn runAction:pActBlink];
		}

		[pUseSelectNetaScene setup:pSettingUseItemBtn:mp_useItemNoList];
	}

	CCScene* scene = [CCScene node];
	[scene addChild:node];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:scene withColor:ccBLACK];

	[[CCDirector sharedDirector] pushScene:pTransFade];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	アイテム設定
*/
-(void)	pressSettingItemBtn:(id)sender
{
	CCLOG(@"settingItemBtn");
	
	CCNode* node = [CCBReader nodeGraphFromFile:@"use_item_select.ccbi" owner:nil];
	
	//	選択したセッティング項目を選択リストにアタッチ
	//	選択したオブジェクトがセッティング項目用かチェックもする
	//	(デリゲーダーが使える？)
	if( ( [node isKindOfClass:[UseSelectItemScene class]] ) && ([sender isKindOfClass:[SettingItemBtn class]]) )
	{
		UseSelectItemScene*	pUseSelectItemScene	= (UseSelectItemScene*)node;
		SettingItemBtn*	pSettingUseItemBtn	= (SettingItemBtn*)sender;
		
		//	タッチしたときのアクション
		{
			CCBlink*	pActBlink	= [CCBlink actionWithDuration:0.5f blinks:2];
			[pSettingUseItemBtn runAction:pActBlink];
		}

        CCArray*	pItemSelectTypeList	= [CCArray array];
        {
            NSArray*    pTmp    = [pSettingUseItemBtn getItemSelectType];
            for( SInt32 i = 0; i < pTmp.count; ++i )
            {
                NSNumber*   pNum    = (NSNumber*)[pTmp objectAtIndex:i];
                [pItemSelectTypeList addObject:[NSNumber numberWithUnsignedInt:[pNum intValue]]];
            }
        }

        [pUseSelectItemScene setup:pSettingUseItemBtn:mp_useItemNoList:pItemSelectTypeList];
	}

	CCScene* scene = [CCScene node];
	[scene addChild:node];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:scene withColor:ccBLACK];

	[[CCDirector sharedDirector] pushScene:pTransFade];

	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	アドオン購入画面へ移行
*/
-(void)	pressAdonBtn
{
	CCScene*	storeScene	= [CCBReader sceneWithNodeGraphFromFile:@"store.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:storeScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] pushScene:pTransFade];

	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	ミッション画面へ移行
*/
-(void)	pressMissionBtn
{
	CCLOG(@"Mission");
	
	CCScene*	sinagakiScene	= [CCBReader sceneWithNodeGraphFromFile:@"mission.ccbi"];

	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:sinagakiScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] pushScene:pTransFade];
	
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
	@brief	タイトル画面へ移行
*/
-(void)	pressTitleBtn
{
	CCScene*	pTitleScene	= [CCBReader sceneWithNodeGraphFromFile:@"title.ccbi"];
	CCTransitionFade*	pTransFade	=
	[CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:pTitleScene withColor:ccBLACK];
	
	[[CCDirector sharedDirector] replaceScene:pTransFade];
	
	[[SoundManager shared] playSe:@"pressBtnClick"];
}

/*
    @brief  イベント確認
 */
-(void) pressEventBtn
{
    //	イベント内容を出す
    mp_eventChkAlertView	= [[UIAlertView alloc]	initWithTitle:[DataBaseText getString:202]
                                                                    message:[self _getEventInvocMessage:NO :NO]
                                                                    delegate:self
                                                                    cancelButtonTitle:[DataBaseText getString:46]
                                                                    otherButtonTitles:nil];
    [mp_eventChkAlertView show];
    
	[[SoundManager shared] playSe:@"btnClick"];
}

/*
    @brief  アドオン購入成功
 */
-(void) onStoreSuccess:(NSString*)in_pProducts
{
	//	購入内容によって設定する
	DataStoreList*	pStoreInst	= [DataStoreList shared];
	if( pStoreInst != nil )
	{
		for( int i = 0; i < pStoreInst.dataNum; ++i )
		{
			const STORE_DATA_ST*	pData	= [pStoreInst getData:i];
			if( pData != nil )
			{
				NSString*	pStr	= [NSString stringWithUTF8String:pData->aStoreIdName];
				if([pStr isEqualToString:in_pProducts])
				{
					switch( pData->no )
					{
                        case eSTORE_ID_CURELIEF:
                        {
                            //  回復した
                            [self _startGamePlay];
                            return;
                        }
					}
				}
			}
		}        
	}
}

/*
	@brief	CCBI読み込み終了
*/
- (void) didLoadFromCCB
{
    const SAVE_DATA_ST* pSaveData   = [[DataSaveGame shared] getData];

    CCArray*    pDelNodeArray   = [CCArray array];

	CCNode*	pNode	= nil;
	CCARRAY_FOREACH(_children, pNode)
	{
		//	セッティング項目をあらかじめ取得する
		if( [pNode isKindOfClass:[CCMenu class]] )
		{
			CCNode*	pChildNode	= nil;
			CCARRAY_FOREACH(pNode.children, pChildNode)
			{
				if( [pChildNode isKindOfClass:[SettingItemBtn class]] )
				{
					[mp_useItemNoList addObject:pChildNode];
				}
			}
		}
        else if( [pNode isKindOfClass:[CCLabelTTF class]] )
        {
            CCLabelTTF* pLabel  = (CCLabelTTF*)pNode;
            if( [pLabel.string isEqualToString:@"PlayLifePos"])
            {
                m_playLifePos   = pLabel.position;
                mp_playerLifeNumStr    = pLabel;
                [mp_playerLifeNumStr setString:[NSString stringWithFormat:@"%d", pSaveData->playLife]];
                //                [pDelNodeArray addObject:pLabel];
            }
        }
        else if( [pNode isKindOfClass:[CCLabelBMFont class]] )
        {
            CCLabelBMFont*  pLabel  = (CCLabelBMFont*)pNode;
            if( [pLabel.string isEqualToString:@"00:00"] )
            {
                mp_cureTimeStr  = pLabel;
                [mp_cureTimeStr setVisible:NO];
            }
        }
		else if( [pNode isKindOfClass:[SettingGameStartBtn class]] )
		{
			mp_gameStartBtn	= (CCControlButton*)pNode;
			[mp_gameStartBtn setVisible:NO];
		}
		else if( [pNode isKindOfClass:[LeftMoveTicker class]] )
		{
			mp_ticker	= (LeftMoveTicker*)pNode;
		}
        else if( [pNode isKindOfClass:[CCSprite class]])
        {
            CCNode*	pChildNode	= nil;
            CCARRAY_FOREACH(pNode.children, pChildNode)
            {
                if( [pChildNode isKindOfClass:[CCLabelBMFont class]])
                {
                    CCLabelBMFont*  pLabelBmFont    = (CCLabelBMFont*)pChildNode;
                    if( [pLabelBmFont.string isEqualToString:@"LvNum"] )
                    {
                        pLabelBmFont.string = [NSString stringWithFormat:@"%d", pSaveData->nabeLv];
                    }
                }
            }
        }
        else if( [pNode isKindOfClass:[SettingEventChkBtn class]] )
        {
            mp_eventChkBtn  = pNode;
        }
	}
    
    CCARRAY_FOREACH(pDelNodeArray, pNode)
    {
        [self removeChild:pNode cleanup:YES];
    }
}

/*
	@brief	ミッション成功メッセージ終了
*/
-(void)	alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DataSaveGame*   pDataSaveGameInst   = [DataSaveGame shared];

	if( alertView == mp_missionSucceesAlertView )
	{
		if( mp_missionSucceesAlertView != nil )
		{
			[mp_missionSucceesAlertView release];
			mp_missionSucceesAlertView	= nil;
		}

		if( mp_missionBounesAlertView != nil )
		{
			[mp_missionBounesAlertView release];
			mp_missionBounesAlertView	= nil;
		}
		
		DataMissionList*	pMissionInst	= [DataMissionList shared];

		//	報酬内容を出す
		mp_missionBounesAlertView	= [[UIAlertView alloc]	initWithTitle:[DataBaseText getString:800]
										message:[pMissionInst getSuccessMsg:m_missionSuccessIdx]
										delegate:self
										cancelButtonTitle:[DataBaseText getString:46]
										otherButtonTitles:nil];
		[mp_missionBounesAlertView show];
		
		m_missionSuccessIdx	= 0;
	}
	else if( alertView == mp_missionBounesAlertView )
	{
		if( mp_missionBounesAlertView != nil )
		{
			[mp_missionBounesAlertView release];
			mp_missionBounesAlertView	= nil;
		}

		//	他に成功しているミッションがないかチェック
		[self _checkMissionSuccess];
	}
    else if( alertView == mp_eventInvocAlertView )
    {
        if( mp_eventInvocAlertView )
        {
            [mp_eventInvocAlertView release];
        }
        mp_eventInvocAlertView  = nil;
        
        [mp_eventChkBtn setVisible:YES];

        //	成功しているミッションがあるかチェック
        [self _checkMissionSuccess];
    }
    else if( alertView == mp_eventSuccessAlertView )
    {
        if( mp_eventSuccessAlertView )
        {
            [mp_eventSuccessAlertView release];
        }
        mp_eventSuccessAlertView    = nil;
        
        if( mp_eventRewardAlertView )
        {
            [mp_eventRewardAlertView release];
        }
        
        //  アイテム取得／お金取得
        NSString*   pMessage    = nil;
        {
            const SAVE_DATA_ST* pSaveData   = [pDataSaveGameInst getData];
            NSAssert(pSaveData->invocEventNo != -1, @"");
            const EVENT_DATA_ST*  pEventData  = [[DataEventDataList shared] getDataSearchId:pSaveData->invocEventNo];
            if( pEventData->rewardDataType == 0 )
            {
                //  アイテム取得
                const ITEM_DATA_ST* pItemData   = [[DataItemList shared] getDataSearchId:pEventData->reward.itemNo];
                NSAssert(pItemData, @"");
                                
                //  アイテム内容によって追加できないのがある
                if( pItemData->no == eITEM_IMPACT_OPEN_NETAPACK )
                {
                    //  ネタパックを一つ開く
                    DataNetaPackList*   pDataNetaPackListInst   = [DataNetaPackList shared];
                    SInt32  openNetaPackIdx = pSaveData->netaNum;
                    if( openNetaPackIdx < pDataNetaPackListInst.dataNum )
                    {
                        const NETA_PACK_DATA_ST*    pNetaPackData   = [pDataNetaPackListInst getData:openNetaPackIdx];
                        [pDataSaveGameInst addNetaPack:pNetaPackData->no];
                        
                        [pDataSaveGameInst addItem:pItemData->no];
                        pMessage    = [NSString stringWithFormat:[DataBaseText getString:214], [DataBaseText getString:pNetaPackData->textID]];
                    }
                    else
                    {
                        //  もうこれ以上取得できない場合は金額に変える
                        pMessage    = [NSString stringWithFormat:[DataBaseText getString:213], 10000];
                        [pDataSaveGameInst addSaveMoeny:10000];
                    }
                }
                else
                {
                    //  アイテム取得
                    const SAVE_DATA_ITEM_ST*  pSaveDataItem   = [pDataSaveGameInst getItem:pItemData->no];
                    if( (pSaveDataItem == nil) || (pSaveDataItem->num < eSAVE_DATA_ITEM_USE_MAX ) )
                    {
                        [pDataSaveGameInst addItem:pItemData->no];
                        pMessage    = [NSString stringWithFormat:[DataBaseText getString:212], [DataBaseText getString:pItemData->textID]];
                    }
                    else
                    {
                        //  これ以上取得できない場合は金に換える
                        SInt32  money   = pItemData->sellMoney * 0.5f;
                        pMessage    = [NSString stringWithFormat:[DataBaseText getString:213], money];
                        [pDataSaveGameInst addSaveMoeny:money];
                    }
                }
            }
            else if( pEventData->rewardDataType == 1 )
            {
                //  金取得
                pMessage    = [NSString stringWithFormat:[DataBaseText getString:213], pEventData->reward.money];
                [pDataSaveGameInst addSaveMoeny:pEventData->reward.money];
            }
        }
        NSAssert(pMessage, @"");
    
        mp_eventRewardAlertView = nil;

		//	報酬内容を出す
		mp_eventRewardAlertView	= [[UIAlertView alloc]	initWithTitle:[DataBaseText getString:203]
                                                                        message:pMessage
                                                                        delegate:self
                                                                        cancelButtonTitle:[DataBaseText getString:46]
                                                                        otherButtonTitles:nil];
		[mp_eventRewardAlertView show];
    }
    else if ( alertView == mp_eventRewardAlertView )
    {
        if( mp_eventRewardAlertView )
        {
            [mp_eventRewardAlertView release];
        }
        mp_eventRewardAlertView = nil;
                
        [pDataSaveGameInst setEventNo:-1];
        //	成功しているミッションがあるかチェック
        [self _checkMissionSuccess];
    }
    else if( alertView == mp_eventNGAlertView )
    {
        if( mp_eventNGAlertView )
        {
            [mp_eventNGAlertView release];
        }
        mp_eventNGAlertView = nil;
        
        [pDataSaveGameInst setEventNo:-1];
        //	成功しているミッションがあるかチェック
        [self _checkMissionSuccess];        
    }
    else if( alertView == mp_eventChkAlertView )
    {
        if( mp_eventChkAlertView )
        {
            [mp_eventChkAlertView release];
        }
        mp_eventChkAlertView    = nil;
    }
}

/*
    @brief  ゲーム開始
 */
-(void) _startGamePlay
{
	CCArray*	pDataSettingTenpura	= [[[CCArray alloc] init] autorelease];
	//	受け渡しためのデータリスト作成
	{
		SettingItemBtn*	pSettingItemBtn	= nil;
		CCARRAY_FOREACH(mp_useItemNoList, pSettingItemBtn)
		{
			if( ( 0 < pSettingItemBtn.itemNo ) && ( pSettingItemBtn.type == eITEM_TYPE_NETA ) )
			{
				DataSettingNetaPack*	pSettingData	= [[[DataSettingNetaPack alloc] init] autorelease];
				pSettingData.no	= pSettingItemBtn.itemNo;
				[pDataSettingTenpura addObject:pSettingData];
			}
		}
	}

    DataSaveGame*   pSaveGameInst   = [DataSaveGame shared];
    const SAVE_DATA_ST* pSaveData   = [pSaveGameInst getData];

    if( 0 < pSaveData->playLife )
    {
        CCArray*	pDataSettingItem	= [[[CCArray alloc] init] autorelease];
        //	受け渡しためのデータリスト作成
        {
            
            SettingItemBtn*	pSettingItemBtn	= nil;
            CCARRAY_FOREACH(mp_useItemNoList, pSettingItemBtn)
            {
                if( ( 0 < pSettingItemBtn.itemNo ) && ( pSettingItemBtn.type == eITEM_TYPE_OPTION ) )
                {
                    [pDataSettingItem addObject:[NSNumber numberWithInt:pSettingItemBtn.itemNo]];
                    //  アイテムを減らす
                    [pSaveGameInst subItem:pSettingItemBtn.itemNo];
                }
            }
        }
        
        //	アニメ登録
        {
            AnimManager*	pEffMng	= [AnimManager shared];
            
            UInt32	num	= sizeof(ga_animDataList) / sizeof(ga_animDataList[0]);
            for( UInt32 i = 0; i < num; ++i )
            {
                AnimData*	pEffData	=
                [[[AnimData alloc] initWithData
                  :ga_animDataList[i].pListFileName
                  :ga_animDataList[i].pImageFileName
                  :ga_animDataList[i].fps] autorelease];
                
                [pEffMng add:[NSString stringWithUTF8String:ga_animDataList[i].pImageFileName]:pEffData];
            }
        }
        
        GameData*	pGameData	= [[GameData alloc] autorelease];
        pGameData->mp_netaList	= [pDataSettingTenpura retain];
        pGameData->mp_itemNoList	= [pDataSettingItem retain];
        
        CCScene*	pGameScene	= [GameScene scene:pGameData];
        
        CCTransitionFade*	pTransFade	=
        [CCTransitionFade transitionWithDuration:g_sceneChangeTime scene:pGameScene withColor:ccBLACK];
        
        [[CCDirector sharedDirector] replaceScene:pTransFade];
        
        [pSaveGameInst addPlayLife:-1 :NO];
    }
    
	pDataSettingTenpura	= nil;
}

/*
    @brief  ライフ値の変更時に対応
 */
-(void) _runPlayLifeProcess
{
    DataSaveGame*   pDataSaveGameInst   = [DataSaveGame shared];
    const SAVE_DATA_ST* pSaveData   = [pDataSaveGameInst getData];
    
    [mp_cureTimeStr setVisible:NO];

    [mp_playerLifeNumStr setString:[NSString stringWithFormat:@"%d", pSaveData->playLife]];
    if( pSaveData->playLife < eSAVE_DATA_PLAY_LIEF_MAX )
    {
        //  回復時間を表示
        [mp_cureTimeStr setVisible:YES];

        //  回復時間になっているか
        {
            NSDate* pDt = [NSDate date];
            NSDateFormatter*    pDateFrm    = [[[NSDateFormatter alloc] init] autorelease];
            [pDateFrm setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            NSDate* pCureDt    = [pDateFrm dateFromString:[NSString stringWithUTF8String:pSaveData->aCureTimeStr]];
            
            NSDate* pChkDt  = [[[NSDate alloc] initWithTimeInterval:self.cureTimeByCcbiProperty sinceDate:pCureDt] autorelease];
            int  span    = (int)[pChkDt timeIntervalSinceDate:pDt];
            
            if( span <= 0 )
            {
                int absSpan = ABS(span);
                SInt8   cureNum = 1;
                if( self.cureTimeByCcbiProperty <= absSpan )
                {
                    cureNum = (SInt8)MIN(eSAVE_DATA_PLAY_LIEF_MAX, ((absSpan / self.cureTimeByCcbiProperty) + 1));
                }
                //  回復
                [pDataSaveGameInst addPlayLife:cureNum :YES];
            }
        }

        //  回復時間を表示
        if( pSaveData->playLife < eSAVE_DATA_PLAY_LIEF_MAX )
        {
            NSDate* pDt = [NSDate date];
            NSDateFormatter*    pDateFrm    = [[[NSDateFormatter alloc] init] autorelease];
            [pDateFrm setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            NSDate* pCureDt    = [pDateFrm dateFromString:[NSString stringWithUTF8String:pSaveData->aCureTimeStr]];
            
            NSDate* pChkDt  = [[[NSDate alloc] initWithTimeInterval:self.cureTimeByCcbiProperty sinceDate:pCureDt] autorelease];
            int  span    = (int)[pChkDt timeIntervalSinceDate:pDt];
            
            SInt32  second  = (span <= 0) ? 0 : span % 60;
            SInt32  minute  = (span <= 0) ? 0 : span / 60;
            
            [mp_cureTimeStr setString:[NSString stringWithFormat:@"%02ld:%02ld", minute, second]];
        }
        else
        {
            [mp_cureTimeStr setVisible:NO];
        }
    }
}

/*
	@brief	ミッション成功チェック
*/
-(void)	_checkMissionSuccess
{
	DataMissionList*	pMissionInst	= [DataMissionList shared];
	UInt32	missionNum	= pMissionInst.dataNum;
	for( UInt32 i = 0; i < missionNum; ++i )
	{
		if( [pMissionInst checSuccess:i] == YES )
		{
			m_missionSuccessIdx	= i;
			[pMissionInst setSuccess:YES:i];
			//	ミッション成功メッセージを出す（アラート）
			if( mp_missionSucceesAlertView != nil )
			{
				[mp_missionSucceesAlertView release];
				mp_missionSucceesAlertView	= nil;
			}

			mp_missionSucceesAlertView	= [[UIAlertView alloc]	initWithTitle:[DataBaseText getString:68]
											message:[pMissionInst getMissonName:i]
											delegate:self
											cancelButtonTitle:[DataBaseText getString:46]
											otherButtonTitles:nil];
			[mp_missionSucceesAlertView show];
			break;
		}
	}
}

/*
    @brief  イベント関連のメッセージ取得
 */
-(NSString*)    _getEventNGMessage
{
    return [self _getEventInvocMessage:NO :YES];
}

-(NSString*)    _getEventSuccessMessage
{
    return [self _getEventInvocMessage:NO :YES];
}

-(NSString*)    _getEventInvocMessage:(const BOOL)in_bNewScore :(const BOOL)in_bNewLimit
{
    DataSaveGame*   pSaveGameInst   = [DataSaveGame shared];
    const SAVE_DATA_ST*   pSaveGameData   = [pSaveGameInst getData];
    NSAssert(pSaveGameData->invocEventNo != -1, @"");

    const EVENT_DATA_ST*  pEventData  = [[DataEventDataList shared] getDataSearchId:pSaveGameData->invocEventNo];
    NSAssert(pEventData, @"");

    NSString*   pStr    = nil;
    //  イベント内容
    {
        if( pEventData->typeNo == eEVENT_TYPE_HISCORE )
        {
            SInt32  score   = pSaveGameData->eventScore;
            if( in_bNewScore )
            {
                score   = pSaveGameData->score;
            }
            
            pStr    = [NSString stringWithFormat:[DataBaseText getString:204], score];
        }
        else if( pEventData->typeNo == eEVENT_TYPE_HIPUT_CUSTOMER )
        {
            UInt8       putCustomerMaxnum   = pSaveGameData->eventPutCustomerMaxnum;
            if( in_bNewScore )
            {
                putCustomerMaxnum   = pSaveGameData->putCustomerMaxnum;
            }
            
            pStr    = [NSString stringWithFormat:[DataBaseText getString:205], putCustomerMaxnum];
        }
        else if( pEventData->typeNo == eEVENT_TYPE_HIRENDER_TENPURA )
        {
            UInt8   eatTenpuraMaxnum    = pSaveGameData->eventEatTenpuraMaxNum;
            if( in_bNewScore )
            {
                eatTenpuraMaxnum    = pSaveGameData->eatTenpuraMaxNum;
            }
            
            pStr    = [NSString stringWithFormat:[DataBaseText getString:206], eatTenpuraMaxnum];
        }
        else if( pEventData->typeNo == eEVENT_TYPE_HISCORE_NETAPACK )
        {
            const SAVE_DATA_NETA_ST*  pSaveDataNeta   = [pSaveGameInst getNetaPack:pSaveGameData->eventNetaPackNo];
            NSAssert(pSaveGameData, @"");
            
            const NETA_PACK_DATA_ST*   pDataNedaPack   = [[DataNetaPackList shared] getDataSearchId:pSaveGameData->eventNetaPackNo];
            NSAssert(pDataNedaPack, @"");
            
            SInt32  score   = pSaveDataNeta->eventHitScore;
            if( in_bNewScore )
            {
                score   = pSaveDataNeta->hiscore;
            }
            
            pStr    = [NSString stringWithFormat:[DataBaseText getString:207], [DataBaseText getString:pDataNedaPack->textID], score];
        }
    }
    
    NSAssert(pStr, @"");
    
    //  期限内容
    {
        if( pEventData->limitType == eEVENT_LIMIT_TYPE_GAME_COUNT )
        {
            SInt32  cnt = pEventData->limitData.playCnt;
            if( in_bNewLimit == NO )
            {
                cnt = pEventData->limitData.playCnt - pSaveGameData->chkEventPlayCnt;
            }
            
            pStr    = [pStr stringByAppendingString:[NSString stringWithFormat:[DataBaseText getString:209], cnt]];
        }
        else if( pEventData->limitType == eEVENT_LIMIT_TYPE_TIME )
        {
            SInt32  textId  = 210;
            SInt32  time    = pEventData->limitData.time;
            if( in_bNewLimit == NO )
            {
                time = [DataEventDataList getLimitTimeSecond:pEventData->limitData.time];
            }

            if( time <= 60 )
            {
                textId  = 211;
            }
            else
            {
                time /= 60;
            }

            pStr    = [pStr stringByAppendingString:[NSString stringWithFormat:[DataBaseText getString:textId], time]];
        }
    }
    
    return pStr;
}

@end

/*
	@brief	アイテム設定項目ボタン
*/
@implementation SettingItemBtn

@synthesize type	= m_type;
@synthesize itemNo	= m_itemNo;

/*
	@brief
*/
-(id)init
{
	if( self = [super init] )
	{
        mp_itemName = [CCLabelBMFont labelWithString:@"" fntFile:@"font.fnt"];
        [mp_itemName setScale:0.5];
		[mp_itemName setPosition:ccp(225 >> 1, 40 >> 1)];
		[self addChild:mp_itemName z:20];
		
		m_itemNo	= 0;
	}
	
	return self;
}

/*
	@brief
*/
-(void)dealloc
{
	mp_itemName	= nil;
	[super dealloc];
}

/*
	@brief	アイテム項目設定
*/
-(void)settingItem:(SInt32)in_type :(SInt32)in_textId :(SInt32)in_no;
{
	[mp_itemName setString:[NSString stringWithUTF8String:[[DataBaseText shared] getText:in_textId]]];
	m_itemNo	= in_no;
	m_type	= in_type;
}

/*
    @brief  選択できるアイテムタイプを配列で返す
 */
-(NSArray*) getItemSelectType
{
    //  ,区切りで値があるので、配列に変換する
    return [self.itemSelectTypeList componentsSeparatedByString:@","];
}

@end

/*
	@brief	ゲームスタート開始ボタン
*/
@implementation SettingGameStartBtn
@end

/*
 @brief  イベント確認ボタン
 */
@implementation SettingEventChkBtn
@end
