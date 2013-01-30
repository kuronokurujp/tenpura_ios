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
-(CCNode*)	addEffect:(NSString*)in_pEffName:(AnimData*)in_pEffData;

//	エフェクトバッチ作成
-(CCNode*)	createBath:(const NSString*)in_pEffName;

//	エフェクト再生
-(CCNode*)	play:(const NSString*)in_pEffName;

@end
