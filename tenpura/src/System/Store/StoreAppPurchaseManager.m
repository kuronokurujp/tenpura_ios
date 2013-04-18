//
//  StoreAppPurchaseManager.m
//  tenpura
//
//  Created by y.uchida on 12/11/25.
//
//

#import "StoreAppPurchaseManager.h"

@interface StoreAppPurchaseManager (PrivateMethod)

-(void)	_showErrorAlert:(NSString*)in_pStr;
-(void)	_requestProductData:(NSString*)in_pIdName;

@end

@implementation StoreAppPurchaseManager

@synthesize delegate	= m_delegate;
@synthesize pProductDic	= mp_productDic;
@synthesize bLoad	= mb_loading;

static	StoreAppPurchaseManager*	sp_storeAppManagerInst	= nil;
static	const char*	sp_transactionFlgName	= "storeTransactionFlg";

/*
	@brief
*/
+(StoreAppPurchaseManager*)	share
{
	if( sp_storeAppManagerInst == nil )
	{
		sp_storeAppManagerInst	= [[StoreAppPurchaseManager alloc] init];
	}
	
	return sp_storeAppManagerInst;
}

/*
	@brief
*/
+(void)	end
{
	if( sp_storeAppManagerInst != nil )
	{
		[sp_storeAppManagerInst release];
		sp_storeAppManagerInst	= nil;
	}
}

/*
	@brief
*/
+(id)	alloc
{
	NSAssert(sp_storeAppManagerInst == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

/*
	@brief	初期化
*/
-(id)	init
{
	if( self = [super init] )
	{
		mb_loading	= NO;
		mp_skProductsRequest	= nil;
		m_delegate	= nil;
		mp_productDic	= [[NSMutableDictionary alloc] init];
	}

	return self;
}

/*
	@breif
*/
-(void)	dealloc
{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
	if( mp_skProductsRequest != nil )
	{
		[mp_skProductsRequest release];
	}
	
	if( mp_productDic )
	{
		[mp_productDic release];
	}

	[super dealloc];
}

/*
	@brief	課金リクエスト
*/
-(BOOL)requestProduct:(NSString*)in_pIdName
{
	//	課金設定リクエスト可能
	[self _requestProductData:in_pIdName];

	mb_loading	= true;
	return YES;
}

/*
	@brief	課金開始
*/
-(BOOL)	requestPayment:(SKProduct*)in_pProduct
{
	if( in_pProduct == nil )
	{
		return NO;
	}

	SKPayment*	pPayment	= [SKPayment paymentWithProduct:in_pProduct];
	[[SKPaymentQueue defaultQueue] addPayment:pPayment];

	if( (m_delegate != nil ) && ([m_delegate respondsToSelector:@selector(onStartTransaction:)]) )
	{
	//	[m_delegate onStartTransaction:eSTORE_REQUEST_TYPE_PAY];
	}

	return YES;
}

/*
	@brief	リストア開始
*/
-(BOOL)	requestRestore
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	
	if( (m_delegate != nil ) && ([m_delegate respondsToSelector:@selector(onStartTransaction:)]) )
	{
	//	[m_delegate onStartTransaction:eSTORE_REQUEST_TYPE_RESTORE];
	}

	return YES;
}

/*
	@brief	トランザクション中かチェック
*/
-(void)	checkTransaction
{
	if( [self isTransaction] )
	{
		//	リスタート
		if( m_delegate && ([m_delegate respondsToSelector:@selector(onStartTransaction:)]) )
		{
	//		[m_delegate onStartTransaction:eSTORE_REQUEST_TYPE_RESTART];

			if( [m_delegate respondsToSelector:@selector(onEndTransaction)] )
			{
				//	タイムアウトを用意する
				[NSTimer scheduledTimerWithTimeInterval:2.f
				target:m_delegate
				selector:@selector(onEndTransaction)
				userInfo:nil
				repeats:NO];
			}
		}
	}
}

/*
	@brief	課金処理可能か
*/
-(BOOL)	isPayment
{
	if( ([SKPaymentQueue canMakePayments]) && ([UIDevice currentDevice]) )
	{
		return YES;
	}

	return NO;
}

/*
	@brief	トランザクション中か
*/
-(BOOL)	isTransaction
{
	return [[NSUserDefaults standardUserDefaults] objectIsForcedForKey:[NSString stringWithUTF8String:sp_transactionFlgName]];
}

/*
	@brief	プロダクト情報受信
*/
-(void)	productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	if( response == nil )
	{
		return;
	}
	
	for( NSString* pIdentifier in response.invalidProductIdentifiers )
	{
		NSLog(@"invalid product identifier: %@", pIdentifier);
	}

	for( SKProduct*	pProduct in response.products )
	{
		NSLog(@"volid product identifier: %@", pProduct.productIdentifier);
		/*
		//	プロダクトを保管
		if( [mp_productDic objectForKey:pProduct.productIdentifier] == nil )
		{
			[mp_productDic setObject:pProduct forKey:pProduct.productIdentifier];
		}
		*/
		[self requestPayment:pProduct];
	}
}

/*
	@brief	購入後の対応
*/
-(void)	paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for( SKPaymentTransaction*	pTrans in transactions )
	{
		switch( pTrans.transactionState )
		{
			case SKPaymentTransactionStatePurchasing:
			{
				NSLog(@"SKPaymentTransactionStatePurchasing");
				
				//	トランザクション開始を記憶
				@synchronized( self )
				{
					[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithUTF8String:sp_transactionFlgName]];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
				
				break;
			}
			case SKPaymentTransactionStatePurchased:
			{
				//	購入手続き完了
				NSLog(@"SKPaymentTransactionStatePurchased: %@", pTrans.transactionIdentifier);
				[queue finishTransaction:pTrans];

				if( (m_delegate != nil) && ([m_delegate respondsToSelector:@selector(onPaymentPurchased:)]) )
				{
					[m_delegate onPaymentPurchased:pTrans.payment.productIdentifier];
				}

				break;
			}
			case SKPaymentTransactionStateFailed:
			{
				NSLog(@"SKPaymentTransactionStateFailed: 1[%@] 2[%@]", pTrans.transactionIdentifier, pTrans.error);
				[queue finishTransaction:pTrans];

				if( (m_delegate != nil ) && ([m_delegate respondsToSelector:@selector(onPaymentFailed:)]) )
				{
					[m_delegate onPaymentFailed:pTrans.error.code];
				}
				
				break;
			}
			case SKPaymentTransactionStateRestored:
			{
				NSLog(@"SKPaymentTransactionStateRestored: %@", pTrans.transactionIdentifier);
				
				if( m_delegate && ([m_delegate respondsToSelector:@selector(onPaymentRestore:)]) )
				{
					[m_delegate onPaymentRestore:[pTrans.payment productIdentifier]];
				}
				
				//	リストア
				[queue finishTransaction:pTrans];
				
				break;
			}
		}
	}
}

/*
	@brief	トランザクションの終了
*/
-(void)	paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	//	トランザクション終了を記憶
	@synchronized( self )
	{
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithUTF8String:sp_transactionFlgName]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	mb_loading	= false;
	if( (m_delegate != nil ) && ([m_delegate respondsToSelector:@selector(onEndTransaction)]) )
	{
		[m_delegate onEndTransaction];
	}
}

/*
	@brief	リストアの失敗
*/
-(void)	paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
}

/*
	@brief	リストアの終了
*/
-(void)	paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
}

/*
	@brief
*/
-(void)	_showErrorAlert:(NSString*)in_pStr
{
	UIAlertView*	pAlert	= [[[UIAlertView alloc]
								initWithTitle:@"ERROR"
								message:in_pStr
								delegate:nil cancelButtonTitle:
								@"OK" otherButtonTitles:
								nil, nil] autorelease];
				
	[pAlert show];
}

/*
	@brief	AppStoreにプロダクト依頼
*/
-(void)	_requestProductData:(NSString*)in_pIdName
{
	if( (m_delegate != nil ) && ([m_delegate respondsToSelector:@selector(onRequest)]) )
	{
		[m_delegate onRequest];
	}

	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

	mp_skProductsRequest	= [[SKProductsRequest alloc] initWithProductIdentifiers:
								[NSSet setWithObject:in_pIdName]];
	[mp_skProductsRequest setDelegate:self];
	[mp_skProductsRequest start];
}

@end
