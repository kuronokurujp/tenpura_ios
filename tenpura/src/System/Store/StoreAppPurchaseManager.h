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
 @brief	課金成功のデリゲーダー定義
 */
@protocol  StoreAppPurchaseManagerSuccessProtocol<NSObject>

-(void) onStoreSuccess:(NSString*)in_pProducts;

@end

/*
	@brief	課金時のデリゲーダー定義
*/
@protocol  StoreAppPurchaseManagerProtocol<NSObject>

//	リクエスト開始
-(void)	onRequest;
//	リクエストエラー
-(void)	onErrorRequest:(NSError*)in_pError;

//	トランザクションの開始／終了
-(void)	onStartTransaction:(const STORE_REQUEST_TYPE_ENUM)in_type;
-(void)	onEndTransaction;

//	購入決済終了
-(void)	onPaymentPurchased:(NSString*)in_pProducts;
//	リストア完了
-(void)	onPaymentRestore:(NSString*)in_pProducts;
//	決済途中キャンセル
-(void)	onPaymentFailed:(NSError*)in_pError;

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
}

@property	(nonatomic, retain)	id<StoreAppPurchaseManagerProtocol>	delegate;
@property	(nonatomic, readonly)	BOOL	bLoad;

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
