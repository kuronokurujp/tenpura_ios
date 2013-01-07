//
//  EffectManager.h
//  tenpura
//
//  Created by y.uchida on 13/01/06.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "Action/EffectActionSprite.h"

@interface EffectManager : NSObject
{
@private
	NSMutableDictionary*	mp_dicData;
}

+(EffectManager*)	shared;
+(void)	end;

//	エフェクト登録
-(CCNode*)	addEffect:(NSString*)in_pEffName:(EffectData*)in_pEffData;

//	エフェクトバッチ作成
-(CCNode*)	createBath:(const NSString*)in_pEffName;

//	エフェクト再生
-(CCNode*)	play:(const NSString*)in_pEffName;

@end
