//
//  TenpuraProtocol.h
//  tenpura
//
//  Created by y.uchida on 13/02/25.
//
//

#import <Foundation/Foundation.h>

/*
	@brief	天ぷらデリゲータ
*/
@protocol TenpuraProtocol<NSObject>

//	天ぷら爆発
-(void)	onExpTenpura:(CCNode*)in_pTenpura;
//	天ぷらをつける
-(void)	onAddChildTenpura:(CCNode*)in_pTenpura;

@end
