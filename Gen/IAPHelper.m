//
//  IAPHelper.m
//  Genby
//
//  Created by Andrey Korikov on 29.11.12.
//  Copyright (c) 2012 Andrey Korikov. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "Constants.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface IAPHelper() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, copy) void (^onTransactionCancelled)();
@property (nonatomic, copy) void (^onTransactionCompleted)(NSString *productId);

@property (nonatomic, copy) void (^onRestoreFailed)(NSError* error);
@property (nonatomic, copy) void (^onRestoreCompleted)();

@end

@implementation IAPHelper
{
    SKProductsRequest *_productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet *_productsIdentifiers;
    NSMutableSet *_purchasedProductIdentifiers;
}

+ (IAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static IAPHelper *sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:
                                     kInAppLevelpack,
                                     kInAppMagicShieldsSmall,
                                     kInAppMagicShieldsMedium,
                                     kInAppMagicShieldsLarge,
                                     kInAppMagicShieldsSuperLarge,
                                     nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init]))
    {
        // Store product identifiers
        _productsIdentifiers = productIdentifiers;
        _productsCache = [[NSMutableArray alloc] init];
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [[NSMutableSet alloc] init];
        for (NSString *productIdentifier in _productsIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"IAP: Already purchased: %@", productIdentifier);
            } else {
                NSLog(@"IAP: Not purchased: %@", productIdentifier);
            }
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        [self reloadProducts];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productsIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

+ (id)objectForKey:(NSString*) key
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    return obj;
}

+ (NSNumber*)numberForKey:(NSString*) key
{
    return [NSNumber numberWithInt:[[IAPHelper objectForKey:key] intValue]];
}

- (void)reloadProducts
{
    [_productsCache removeAllObjects];
    self.isProductsAvailable = NO;
    [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success)
        {
            [_productsCache addObjectsFromArray:products];
            
            // Сортируем массив с описанием продуктов по цене
            [_productsCache sortUsingComparator:^(id a, id b)
            {
                NSDecimalNumber *first = [(SKProduct*)a price];
                NSDecimalNumber *second = [(SKProduct*)b price];
                return [first compare:second];
            }];
        }
    }];
}

-(void) restorePreviousTransactionsOnComplete:(void (^)(void)) completionBlock
                                       onError:(void (^)(NSError*)) errorBlock
{
    self.onRestoreCompleted = completionBlock;
    self.onRestoreFailed = errorBlock;
    
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void) restoreCompleted
{
    if(self.onRestoreCompleted)
        self.onRestoreCompleted();
    self.onRestoreCompleted = nil;
}

-(void) restoreFailedWithError:(NSError*) error
{
    if(self.onRestoreFailed)
        self.onRestoreFailed(error);
    self.onRestoreFailed = nil;
}

- (void)removeAllKeychainData
{
    for (NSString *productIdentifier in _productsIdentifiers)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:productIdentifier];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kInAppMagicShieldsRefName];
    [_purchasedProductIdentifiers removeAllObjects];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyFeature:(SKProduct *)product onComplete:(void (^)(NSString *))completionBlock onCancelled:(void (^)(void))cancelBlock
{
    NSLog(@"IAP: Buying %@...", product.productIdentifier);
    
    self.onTransactionCompleted = completionBlock;
    self.onTransactionCancelled = cancelBlock;
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (BOOL)canConsumeProduct:(NSString*) productIdentifier
{
	int count = [[IAPHelper numberForKey:productIdentifier] intValue];
	
	return (count > 0);
}

- (BOOL)canConsumeProduct:(NSString*) productIdentifier quantity:(int) quantity
{
	int count = [[IAPHelper numberForKey:productIdentifier] intValue];
    
	return (count >= quantity);
}

- (BOOL)consumeProduct:(NSString*) productIdentifier quantity:(int) quantity
{
	int count = [[IAPHelper numberForKey:productIdentifier] intValue];
	if(count < quantity)
	{
		return NO;
	}
	else
	{
		count -= quantity;
        [[NSUserDefaults standardUserDefaults] setInteger:count forKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
		return YES;
	}
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [self restoreFailedWithError:error];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [self restoreCompleted];
}

- (void)failedTransaction: (SKPaymentTransaction *)transaction
{
#ifndef NDEBUG
    NSLog(@"IAP: Failed transaction: %@", [transaction description]);
    NSLog(@"error: %@", transaction.error);
#endif
	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if(self.onTransactionCancelled)
        self.onTransactionCancelled();
}

- (void)completeTransaction: (SKPaymentTransaction *)transaction
{
#ifndef NDEBUG
        NSLog(@"IAP: Complete transaction.");
#endif
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
#ifndef NDEBUG
        NSLog(@"IAP: Restore transaction: %@", [transaction description]);
#endif
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark In-App purchases callbacks
-(void) provideContentForProductIdentifier:(NSString*) productIdentifier
{
    if ([productIdentifier isEqualToString:kInAppLevelpack])
    {
        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        int currentValue = [[NSUserDefaults standardUserDefaults] integerForKey:kInAppMagicShieldsRefName];
        
        if ([productIdentifier isEqualToString:kInAppMagicShieldsSmall])
        {
            currentValue += kInAppMagicShieldsSmallNum;
        }
        else if ([productIdentifier isEqualToString:kInAppMagicShieldsMedium])
        {
            currentValue += kInAppMagicShieldsMediumNum;
        }
        else if ([productIdentifier isEqualToString:kInAppMagicShieldsLarge])
        {
            currentValue += kInAppMagicShieldsLargeNum;
        }
        else if ([productIdentifier isEqualToString:kInAppMagicShieldsSuperLarge])
        {
            currentValue += kInAppMagicShieldsSuperLargeNum;
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:currentValue forKey:kInAppMagicShieldsRefName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if(self.onTransactionCompleted)
        self.onTransactionCompleted(productIdentifier);
    
    // Создаем оповещение, что покупка совершена. Передаем какую покупку приобрел пользователь
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:productIdentifier forKey:@"productIdentifier"];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:self userInfo:userInfo];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    NSLog(@"IAP: Loaded list of products...");
    _productsRequest = nil;
    
    NSArray *skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"IAP: Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    self.isProductsAvailable = YES;
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    
    NSLog(@"IAP: Failed to load list of products.");
    _productsRequest = nil;
    
    self.isProductsAvailable = NO;
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

- (void)dealloc
{
    [_productsCache release];
    _productsCache = nil;
    [_purchasedProductIdentifiers release];
    _purchasedProductIdentifiers = nil;
    
    [super dealloc];
}

@end
