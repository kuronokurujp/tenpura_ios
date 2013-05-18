//
//  SiireTableCell.h
//  tenpura
//
//  Created by y.uchida on 13/02/26.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "./../Object/TenpuraIcon.h"
#import "./../Data/DataNetaPackList.h"

@interface SiireTableCell : CCSprite {

@private
	CCLabelTTF*	mp_nameLabel;
	CCLabelTTF*	mp_moneyLabel;
	CCLabelTTF*	mpa_netaNameList[eNETA_PACK_MAX];
	TenpuraIcon*	mpa_tenpuraIcon[eNETA_PACK_MAX];
	CCSprite*	mp_soldOutSprite;
}

@property	(nonatomic, retain)CCLabelTTF*	pNameLabel;
@property	(nonatomic, retain)CCLabelTTF*	pMoneyLabel;

-(CCLabelTTF*)	getNetaNameLabel:(SInt32)in_idx;
-(TenpuraIcon*)	getNetaIconObj:(SInt32)in_idx;
-(void)	setEnableSoldOut:(BOOL)in_bFlg;


@end
