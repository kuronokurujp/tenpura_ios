//
//  HelpScene.h
//  tenpura
//
//  Created by y.uchida on 12/12/24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/*
	@brief	ヘルプ画面表示
	@note	html内にimgタグを使って画像を参照している時には
			htmlファイルと同じフォルダに画像を配置する
*/
@class PrevPageBtnByHelp;
@class PrevSceneBtnByHelp;

@interface HelpScene : CCLayer
{
@private
	SInt32	m_nowPageNum;
	SInt32	m_maxPageNum;
	UIWebView*			mp_helpView;
	
	Float32	helpSceneXPos;
	Float32	helpSceneYPos;
	Float32	helpSceneSizeWidth;
	Float32	helpSceneSizeHeight;
    
    PrevSceneBtnByHelp* mp_prevSceneBtn;
    PrevPageBtnByHelp*  mp_prevPageBtn;
}

@end
