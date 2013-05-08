//
//  CreditScene.h
//  tenpura
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/*
	@brief	クレジット画面表示
	@note	html内にimgタグを使って画像を参照している時には
			htmlファイルと同じフォルダに画像を配置する
*/
@interface CreditScene : CCLayer
{
@private
	UIWebView*			mp_view;
	
	Float32	creditSceneXPos;
	Float32	creditSceneYPos;
	Float32	creditSceneSizeWidth;
	Float32	creditSceneSizeHeight;
}

@end
