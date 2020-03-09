//
//  IAPHelper.h
//  InAppRage
//
//  Created by Andrey Korikov on 29.11.12.
//  Copyright (c) 2012 Andrey Korikov. All rights reserved.
//

#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface IAPHelper : NSObject

@property (nonatomic, assign) NSMutableArray *productsCache;
@property (nonatomic, assign) BOOL isProductsAvailable;

+ (IAPHelper *)sharedInstance;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

// use this method to start a purchase
- (void)buyFeature:(SKProduct*) product
        onComplete:(void (^)(NSString* purchasedFeature)) completionBlock
        onCancelled:(void (^)(void)) cancelBlock;

// use this method to restore a purchase
- (void)restorePreviousTransactionsOnComplete:(void (^)(void)) completionBlock
                                       onError:(void (^)(NSError* error)) errorBlock;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)reloadProducts;
// For consumable support
- (BOOL)canConsumeProduct:(NSString*) productName quantity:(int) quantity;
- (BOOL)consumeProduct:(NSString*) productName quantity:(int) quantity;
// for testing proposes you can use this method to remove all the saved keychain data (saved purchases, etc.)
- (void)removeAllKeychainData;
+ (NSNumber*) numberForKey:(NSString*)key;

@end
