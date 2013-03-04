//
//  StoreAppPurchaseManager.h
//  tenpura	課金ビュー制御
//
//  Created by y.uchida on 12/11/25.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

typedef enum
{
	eSTORE_REQUEST_TYPE_PAY	= 1,
	eSTORE_REQUEST_TYPE_RESTORE,
	eSTORE_REQUEST_TYPE_RESTART,
} STORE_REQUEST_TYPE_ENUM;

/*
	@brief	課金時のデリゲーダー定義
*/
@protocol  StoreAppPurchaseManagerProtocol<NSObject>

//	トランザクションの開始／終了
-(void)	onStartTransaction:(const STORE_REQUEST_TYPE_ENUM)in_type;
-(void)	onEndTransaction;

//	購入決済終了
-(void)	onPaymentPurchased:(NSString*)in_pProducts;
//	リストア完了
-(void)	onPaymentRestore:(NSString*)in_pProducts;
//	決済途中キャンセル
-(void)	onPaymentFailed:(SInt32)in_errorType;

@end

/*
	@brief	課金ビュー制御
*/
@interface StoreAppPurchaseManager : NSObject
<
	SKProductsRequestDelegate,
	SKPaymentTransactionObserver
>
{
@private
	id<StoreAppPurchaseManagerProtocol>	m_delegate;

	BOOL	mb_loading;
	SKProductsRequest*	mp_skProductsRequest;
	NSMutableDictionary*	mp_productDic;
}

@property	(nonatomic, retain)	id<StoreAppPurchaseManagerProtocol>	delegate;
@property	(nonatomic, retain)	NSMutableDictionary*	pProductDic;

//	関数定義
+(StoreAppPurchaseManager*)	share;
+(void)	end;

//	プロダクトリクエスト
-(BOOL)	requestProduct:(NSString*)in_pIdName;
//	課金開始
-(BOOL)	requestPayment:(SKProduct*)in_pProduct;
//	リストア
-(BOOL)	requestRestore;

//	トランザクション中かチェック
-(void)	checkTransaction;

//	課金処理可能か
-(BOOL)	isPayment;
//	トランザクション中か
-(BOOL)	isTransaction;

@end