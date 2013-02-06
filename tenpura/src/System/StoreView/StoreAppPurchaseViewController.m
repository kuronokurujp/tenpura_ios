//
//  StoreAppPurchaseViewController.m
//  tenpura
//
//  Created by y.uchida on 12/11/25.
//
//

#import "StoreAppPurchaseViewController.h"
#import "cocos2d.h"

@interface StoreAppPurchaseViewController (PrivateMethod)

-(void)	_showLoading;
-(void)	_requestProductData:(NSString*)in_pIdName;

@end

@implementation StoreAppPurchaseViewController

@synthesize delegate	= m_delegate;

/*
	@brief	初期化
*/
-(id)	initToData:(CGPoint)in_indicatorPos :(CGSize)in_grayViewSize
{
	if( self = [super init] )
	{
		mb_loading	= NO;
		mp_skProductsRequest	= nil;
		m_delegate	= nil;
		m_indicatorPos	= in_indicatorPos;
		m_grayViewSize	= in_grayViewSize;
	}
	
	return	self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		mb_loading	= NO;
		mp_skProductsRequest	= nil;
		m_delegate	= nil;
		m_indicatorPos	= CGPointMake(230, 320);
		m_grayViewSize	= CGSizeMake(320, 480);
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

	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
	@brief	課金リクエスト
*/
-(BOOL)requestPurchase:(NSString*)in_pIdName
{
	if( mb_loading == YES )
	{
		return NO;
	}
	else if([self isPayment] == YES)
	{
		//	課金設定リクエスト可能
		mb_loading	= YES;
		[self _showLoading];
		[self _requestProductData:in_pIdName];

		return YES;
	}
	else
	{
		//	課金不可能
	}
	
	return NO;
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
	@brief	プロダクト情報受信
*/
-(void)	productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	if( response == nil )
	{
		//	エラー扱い
		if( (m_delegate != nil ) && ([m_delegate respondsToSelector:@selector(onError:)]) )
		{
			[m_delegate onError:eErrorStoreProductsRequest];
		}
		return;
	}
	
	for( NSString* pIdentifier in response.invalidProductIdentifiers )
	{
		NSLog(@"invalid product identifier: %@", pIdentifier);
	}

	for( SKProduct*	pProduct in response.products )
	{
		NSLog(@"volid product identifier: %@", pProduct.productIdentifier);
		//	productを元にした購入オブジェクトをキューに格納
		//	購入手続きに入る
		SKPayment*	pPayment	= [SKPayment paymentWithProduct:pProduct];
		[[SKPaymentQueue defaultQueue] addPayment:pPayment];
	}	
}

/*
	@brief	購入後の対応
*/
-(void)	paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	BOOL	bFinished	= YES;
	for( SKPaymentTransaction*	pTrans in transactions )
	{
		switch( pTrans.transactionState )
		{
			case SKPaymentTransactionStatePurchasing:
			{
				NSLog(@"SKPaymentTransactionStatePurchasing");
				break;
			}
			case SKPaymentTransactionStatePurchased:
			{
				//	購入手続き完了
				NSLog(@"SKPaymentTransactionStatePurchased: %@", pTrans.transactionIdentifier);
				[queue finishTransaction:pTrans];
				bFinished	= NO;
				if( (m_delegate != nil) && ([m_delegate respondsToSelector:@selector(onPaymentPurchased)]) )
				{
					[m_delegate onPaymentPurchased];
				}
				
				break;
			}
			case SKPaymentTransactionStateFailed:
			{
				//	途中キャンセル
				NSLog(@"SKPaymentTransactionStateFailed: %@ %@", pTrans.transactionIdentifier, pTrans.error);
				[queue finishTransaction:pTrans];

				bFinished	= NO;
				if( (m_delegate != nil ) && ([m_delegate respondsToSelector:@selector(onPaymentFailed)]) )
				{
					[m_delegate onPaymentFailed];
				}
				
				break;
			}
			case SKPaymentTransactionStateRestored:
			{
				NSLog(@"SKPaymentTransactionStateRestored %@", pTrans.transactionIdentifier);

				//	リストア
				bFinished	= NO;
				[queue finishTransaction:pTrans];
				break;
			}
		}
	}
	
	if( bFinished == NO )
	{
		[(UIView*)[self.view.window viewWithTag:21] removeFromSuperview];
		[UIApplication sharedApplication].networkActivityIndicatorVisible	= NO;
		
		mb_loading	= NO;
		if( (m_delegate != nil ) && ([m_delegate respondsToSelector:@selector(onEndView)]) )
		{
			[m_delegate onEndView];
		}
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
	@biref	決済中のローディング表示
*/
-(void)	_showLoading
{
	//	通信状態を表示
	[UIApplication sharedApplication].networkActivityIndicatorVisible	= YES;
	
	UIView*	pGrayView	= [[UIView alloc] initWithFrame:CGRectMake(0,0,m_grayViewSize.width,m_grayViewSize.height)];
	[pGrayView setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f]];
	pGrayView.tag	= 21;
	[self.view addSubview:pGrayView];
	
	UIActivityIndicatorView*	pIndicator	= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[pIndicator setCenter:m_indicatorPos];
	[pGrayView addSubview:pIndicator];
	[pIndicator startAnimating];
	
	[pIndicator release];
	[pGrayView release];
}

/*
	@brief	AppStoreにプロダクト依頼
*/
-(void)	_requestProductData:(NSString*)in_pIdName
{
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

	mp_skProductsRequest	= [[SKProductsRequest alloc] initWithProductIdentifiers:
								[NSSet setWithObject:in_pIdName]];
	[mp_skProductsRequest setDelegate:self];
	[mp_skProductsRequest start];
}

@end
