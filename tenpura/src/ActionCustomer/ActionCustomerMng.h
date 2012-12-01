//
//  ActionCustomerMng.h
//  tenpura
//
//  Created by y.uchida on 12/12/01.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ActionCustomerList.h"

//	前方宣言
@class Customer;

@interface ActionCustomerMng : CCNode
{
@private
	Customer*	mp_onwer;
}

//	関数定義
-(id)	initWithData:(Customer*)in_pOwner;
-(BOOL)	setAction:(ACTION_CUSTOMER_ENUM)in_act;

@end
