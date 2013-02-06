//
//  StoreAppPurchaseViewController.h
//  tenpura	課金ビュー制御
//
//  Created by y.uchida on 12/11/25.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

typedef enum
{
	eErrorStoreProductsRequest	= 1,
} STORE_ERROR_STATE_ENUM;

/*
	@brief	課金時のデリゲーダー定義
*/
@protocol  StoreAppPurchaseViewControllerProtocol<NSObject>

//	購入決済終了
-(void)	onPaymentPurchased;
//	決済途中キャンセル
-(void)	onPaymentFailed;
//	ビュー終了
-(void)	onEndView;
//	エラー
-(void)	onError:(STORE_ERROR_STATE_ENUM)in_state;


@end

/*
	@brief	課金ビュー制御
*/
@interface StoreAppPurchaseViewController : UIViewController
<
	SKProductsRequestDelegate,
	SKPaymentTransactionObserver
>
{
@private
	id<StoreAppPurchaseViewControllerProtocol>	m_delegate;

	BOOL	mb_loading;
	SKProductsRequest*	mp_skProductsRequest;
	CGSize	m_grayViewSize;
	CGPoint	m_indicatorPos;
}

@property	(nonatomic, retain)	id<StoreAppPurchaseViewControllerProtocol>	delegate;

//	関数定義
-(id)	initToData:(CGPoint)in_indicatorPos :(CGSize)in_grayViewSize;

//	課金リクエスト
-(BOOL)	requestPurchase:(NSString*)in_pIdName;
//	課金処理可能か
-(BOOL)	isPayment;

@end
