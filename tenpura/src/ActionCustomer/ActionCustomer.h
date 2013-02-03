//
//  ActionCustomer.h
//  tenpura
//
//  Created by y.uchida on 12/09/17.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "../Data/DataNetaList.h"

@class Customer;
@class Tenpura;
@class TenpuraIcon;

/*
	@brief	客用のアクションリスト一覧
*/
@interface ActionCustomer : CCNode
{
	Customer*	mp_customer;
	CCLabelTTF*	mp_scoreLabel;
	CCLabelTTF*	mp_moneyLabel;
	
	SInt32	m_getScore;
	SInt32	m_getMoeny;
	
	BOOL	mb_SettingEat;
	BOOL	mb_flash;
}

//	初期化
-(id)	initWithCusomer:(Customer*)in_pCustomer;

//	出現アクション
-(void)	put:(BOOL)in_bSettingEat;

//	退場アクション
-(void)	exit;

//	点滅アクション
-(void)	loopFlash;
-(void)	endFlash;

//	リザルトスコア表示アクション
-(void)	putResultScore;

//	食べた時のアクション
-(void)eatGood:(Tenpura*)in_pTenpura:(SInt32)in_score:(SInt32)in_money;
-(void)eatVeryGood:(Tenpura*)in_pTenpura:(SInt32)in_score:(SInt32)in_money;
-(void)eatBat:(Tenpura*)in_pTenpura:(SInt32)in_score:(SInt32)in_money;
-(void)eatVeryBat:(Tenpura*)in_pTenpura:(SInt32)in_score:(SInt32)in_money;

//	違う食べ物を与えたときの怒りアクション
-(void)anger;

-(BOOL)	isEatting;

@end
