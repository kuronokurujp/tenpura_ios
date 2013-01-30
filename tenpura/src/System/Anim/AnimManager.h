//
//  AnimManager.h
//  tenpura
//
//  Created by y.uchida on 13/01/06.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "Action/AnimActionSprite.h"

@interface AnimManager : NSObject
{
@private
	NSMutableDictionary*	mp_dicData;
}

+(AnimManager*)	shared;
+(void)	end;

//	エフェクト登録
-(CCNode*)	add:(NSString*)in_pName:(AnimData*)in_pData;

//	エフェクトバッチ作成
-(CCNode*)	createBath:(const NSString*)in_pName;

//	エフェクト再生
-(CCNode*)	play:(const NSString*)in_pName;

@end
