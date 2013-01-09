//
//  ShopLayer.m
//  Gen
//
//  Created by Andrey Korikov on 17.12.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ShopLayer.h"
#import "CCMenuItemSpriteIndependent.h"
#import "IAPHelper.h"
#import "GameManager.h"
#import "Helper.h"
#import "ProcessingLayer.h"

@interface ShopLayer()
{
    CCSpriteBatchNode *shopBatchNode;
    CCMenu *shopMenu;
    CGSize screenSize;
    NSNumberFormatter * _priceFormatter;
    CCSprite *processIcon;
    CCLabelTTF *processText;
}

@end

@implementation ShopLayer

- (id)init
{
    if ((self = [super initWithColor:ccc4(0, 0, 0, 150)]))
    {
        self.isTouchEnabled = YES;
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        shopBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"superpower_popup.pvr.ccz" capacity:177];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"superpower_popup.plist"];
        [self addChild:shopBatchNode];
        
        // Add animation cache
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"sp_popup_anim.plist"];
        
        // Создаем подложку для всплывающего окна магазина
        [self createUndercoverWithHeight:screenSize.height*0.9];
        
        // Проверяем готовы ли данные по продаваемым продуктам, если нет то запускаем анимацию ожидания, если готовы - показываем
        [self schedule:@selector(waitingForProducts) interval:0.2];
        
    }
    return self;
}

- (void)closePressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    [self removeFromParentAndCleanup:YES];
}

- (void)buyPressed:(id)itemPassedIn
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");

    // Показываем новый слой с надписью "Обработка"
    ProcessingLayer *procLayer = [[[ProcessingLayer alloc] initWithColor:ccc4(0, 0, 0, 200)] autorelease];
    [self addChild:procLayer z:2];

    CCNode *buyItem = (CCNode*)itemPassedIn;
    SKProduct *product = [IAPHelper sharedInstance].productsCache[buyItem.tag];
    
    [[IAPHelper sharedInstance] buyFeature:product onComplete:^(NSString* purchasedFeature)
    {
        [procLayer removeFromParentAndCleanup:YES];
        PLAYSOUNDEFFECT(@"INAPP_PURCHASED");
        [self removeFromParentAndCleanup:YES];
    }
                                                  onCancelled:^
    {
        // User cancels the transaction, you can log this using any analytics software like Flurry.
        [procLayer removeFromParentAndCleanup:YES];                    
    }];
    
}
         
- (void)waitingForProducts
{
    if ([IAPHelper sharedInstance].isProductsAvailable)
    {
        // Если информация по продуктам IAP уже загрузилась и доступна
        if (processIcon != nil && [processIcon isRunning]) {
            [processIcon removeFromParentAndCleanup:YES];
            [processText removeFromParentAndCleanup:YES];
        }
        [self unschedule:_cmd];
        [self displayMenuButtons];
    }
    else if (processIcon == nil && processText == nil)
    {
        processIcon = [CCSprite spriteWithSpriteFrameName:@"process_icon.png"];
        processIcon.anchorPoint = ccp(0.42, 0.5);
        processIcon.position = ccp(CGRectGetMidX(_popUpWindowRect), CGRectGetMidY(_popUpWindowRect));
        [shopBatchNode addChild:processIcon z:2];
        
        processText = [CCLabelTTF labelWithString:@"Loading..." fontName:@"Tahoma" fontSize:[Helper convertFontSize:14]];
        processText.color = ccc3(50, 50, 50);
        processText.position = ccp(CGRectGetMidX(_popUpWindowRect), CGRectGetMidY(_popUpWindowRect) - processIcon.contentSize.height * 0.75);
        [self addChild:processText];
        
        [processIcon runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2 angle:360]]];
    }
}

- (void)createUndercoverWithHeight:(float)uHeight
{
    CCSprite *bottomSprite = [CCSprite spriteWithSpriteFrameName:@"bottom_border.png"];
    CCSprite *topSprite = [CCSprite spriteWithSpriteFrameName:@"top_border.png"];
    CCSprite *middleSprite = [CCSprite spriteWithSpriteFrameName:@"middle.png"];

    // Подсчитываем кол-во промежуточных звеньев для данного размера окна
    uHeight = floorf(uHeight);
    int numOfMiddleTiles = (uHeight - topSprite.contentSize.height - bottomSprite.contentSize.height) / middleSprite.contentSize.height + 2; // +2 - это верхняя и нижняя части окна

    // Определяем начальную верхнюю позицию окна
    CGPoint plankPos = ccp(screenSize.width * 0.5, floorf(screenSize.height*0.5 + uHeight * 0.5));
    float yOffset = 0;
    
    // Создаем фон всплывающего окна
    for (int x = 0; x < numOfMiddleTiles; x++)
    {
        plankPos = ccpSub(plankPos, ccp(0, yOffset));

        if (x == 0)
        {
            // ADD верхюю планку
            [topSprite setAnchorPoint:ccp(0.5, 1)];
            [topSprite setPosition:plankPos];
            [shopBatchNode addChild:topSprite z:1];
            yOffset = topSprite.contentSize.height;
        }
        else if (x == numOfMiddleTiles-1)
        {
            // ADD нижнюю планку
            [bottomSprite setAnchorPoint:ccp(0.5, 1)];
            [bottomSprite setPosition:plankPos];
            [shopBatchNode addChild:bottomSprite z:1];
        }
        else
        {
            // Средние планки
            CCSprite *midSprite = [CCSprite spriteWithSpriteFrameName:@"middle.png"];
            [midSprite setAnchorPoint:ccp(0.5, 1)];
            [midSprite setPosition:plankPos];
            [shopBatchNode addChild:midSprite z:0];
            yOffset = middleSprite.contentSize.height;
        }
    }
    
    // Задаем значение св-ву для хранения положения и размера окна.  Координаты нижнего левого угла окна. В ширине компенсируем размер тени справа.
    [self setPopUpWindowRect:CGRectMake(bottomSprite.position.x - bottomSprite.contentSize.width*0.5,
                                        bottomSprite.position.y - bottomSprite.contentSize.height,
                                        bottomSprite.contentSize.width * 0.9627,
                                        uHeight)];
    
    // Add close button at top left corner of the pop up window
    CCSprite *closeSprite = [CCSprite spriteWithSpriteFrameName:@"button_close.png"];
    [closeSprite setPosition:ccp(CGRectGetMaxX(self.popUpWindowRect) - closeSprite.contentSize.width * 0.25,
                                 CGRectGetMaxY(self.popUpWindowRect) - closeSprite.contentSize.height * 0.25)];
    [shopBatchNode addChild:closeSprite z:2];
    CCMenuItemSpriteIndependent *closeButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:closeSprite selectedSprite:nil target:self selector:@selector(closePressed)];
    
    // Настраиваем меню
    shopMenu = [CCMenu menuWithItems:closeButton, nil];
    [shopMenu setPosition:ccp(0, 0)];
    [self addChild:shopMenu];
}

- (void)displayMenuButtons
{
    CCSprite *itemBackForSize = [CCSprite spriteWithSpriteFrameName:@"item_background.png"]; // только для размеров
    float vOffset = itemBackForSize.contentSize.height * 1.3;
    float hOffset = itemBackForSize.contentSize.width * 0.7;
    const int numOfItemsInRow = 2;
    int counter = 1;
    
    // Добавляем продукты ID заказываемых продуктов
    NSSet *consumableProductIdentifiers = [NSSet setWithObjects:
                                    kInAppMagicShieldsSmall,
                                    kInAppMagicShieldsMedium,
                                    kInAppMagicShieldsLarge,
                                    kInAppMagicShieldsSuperLarge,
                                           nil];
    
    for (SKProduct *product in [[[IAPHelper sharedInstance] productsCache] reverseObjectEnumerator])
    {
        if ([consumableProductIdentifiers containsObject:product.productIdentifier])
        {
            CCSprite *itemBackgroundSprite = [CCSprite spriteWithSpriteFrameName:@"item_background.png"];
            CCSprite *priceBackgroundSprite = [CCSprite spriteWithSpriteFrameName:@"price_background.png"];
            CCSprite *spIconSprite = [CCSprite spriteWithSpriteFrameName:@"sp_icon.png"];
            
            [itemBackgroundSprite setPosition:ccp(CGRectGetMidX(_popUpWindowRect) + hOffset,
                                                  CGRectGetMinY(_popUpWindowRect) + vOffset)];
            [priceBackgroundSprite setPosition:ccp(itemBackgroundSprite.position.x,
                                                   itemBackgroundSprite.position.y - itemBackgroundSprite.contentSize.height * 0.45)];
            [priceBackgroundSprite setScaleX:1.5];
            [spIconSprite setPosition:ccp(itemBackgroundSprite.position.x - spIconSprite.contentSize.width * 0.5,
                                          itemBackgroundSprite.position.y)];
            
            // Показываем цену предмета
            [_priceFormatter setLocale:product.priceLocale];
            CCLabelTTF *priceLabel = [CCLabelTTF labelWithString:[_priceFormatter stringFromNumber:product.price] fontName:@"Verdana-Bold" fontSize:[Helper convertFontSize:7]];
            [priceLabel setColor:ccc3(50, 50, 50)];
            [priceLabel setPosition:priceBackgroundSprite.position];
            
            // Извлекаем данные о кол-ве покупаемых зарядов из названия продукта
            NSUInteger startInd = product.localizedTitle.length - 3;
            NSString *quantity = [[product.localizedTitle substringFromIndex:startInd]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            // Показываем кол-во предметов
            CCLabelTTF *quantityLabel = [CCLabelTTF labelWithString:quantity fontName:@"Verdana-Bold" fontSize:[Helper convertFontSize:14]];
            [quantityLabel setColor:ccBLACK];
            [quantityLabel setPosition:ccp(itemBackgroundSprite.position.x + quantityLabel.contentSize.width * 0.5, itemBackgroundSprite.position.y)];
            
            // Put Label "Best Value"
            if ([product.productIdentifier isEqualToString:kInAppMagicShieldsSuperLarge]) {
                CCSprite *bestValueLabel = [CCSprite spriteWithSpriteFrameName:@"best_value_label.png"];
                bestValueLabel.anchorPoint = ccp(0, 1);
                bestValueLabel.position = ccp(CGRectGetMinX(itemBackgroundSprite.boundingBox),
                                              CGRectGetMaxY(itemBackgroundSprite.boundingBox));
                [shopBatchNode addChild:bestValueLabel z:4];
            }
            
            // Меняем координатные значения для след этапа цикла
            if (counter % numOfItemsInRow == 0) {
                vOffset *= 2;
            }
            hOffset *= -1;
            counter++;
            
            [shopBatchNode addChild:itemBackgroundSprite z:2];
            [shopBatchNode addChild:priceBackgroundSprite z:3];
            [shopBatchNode addChild:spIconSprite z:3];
            [self addChild:priceLabel z:1];
            [self addChild:quantityLabel z:1];
            
            CCMenuItemSpriteIndependent *itemBackgroundButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:itemBackgroundSprite selectedSprite:nil target:self selector:@selector(buyPressed:)];
            itemBackgroundButton.tag = [[IAPHelper sharedInstance].productsCache indexOfObject:product];
            [shopMenu addChild:itemBackgroundButton];
        }
    }
    
    // Добавляем анимацию суперсилы вверху окна
    CCSprite *spAnim = [CCSprite spriteWithSpriteFrameName:@"sp_big_anim0001.png"];
    spAnim.position = ccp(CGRectGetMidX(_popUpWindowRect),
                          CGRectGetMaxY(_popUpWindowRect) - spAnim.contentSize.height * 0.4);
    [shopBatchNode addChild:spAnim z:2];
    
    // Запуск анимации
    CCAnimation *spRotateAnim = [[CCAnimationCache sharedAnimationCache] animationByName:@"sp_popup_anim"];
    [spAnim runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:spRotateAnim]]];
    
    // Добавляем заголовок окна и описание продаваемого функционала
    // Заголовок
    CCLabelBMFont *spCaption = [CCLabelBMFont labelWithString:@"Get Magic Shields" fntFile:@"levelselectNumbers.fnt"];
    spCaption.position = ccp(spAnim.position.x, spAnim.position.y - spAnim.contentSize.height * 0.6);
    [self addChild:spCaption z:3];
    // Описание
    CCLabelTTF *spDesc = [CCLabelTTF labelWithString:@"Stuck on a tricky level?\nUnleash the Magic Shields\nto protect food from danger!" fontName:@"Verdana-Bold" fontSize:[Helper convertFontSize:10]];
    spDesc.color = ccc3(50, 50, 50);
    spDesc.position = ccp(spCaption.position.x, spCaption.position.y - spCaption.contentSize.height * 2);
    [self addChild:spDesc z:1];
}

#pragma mark - Touch Delegates

- (void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

BOOL buttonTouched;
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	buttonTouched = [shopMenu ccTouchBegan:touch withEvent:event];
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if(buttonTouched) [shopMenu ccTouchEnded:touch withEvent:event];
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	if(buttonTouched) [shopMenu ccTouchCancelled:touch withEvent:event];
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if(buttonTouched) [shopMenu ccTouchMoved:touch withEvent:event];
}

- (void)dealloc
{
    [_priceFormatter release];
    
    [super dealloc];
}

@end
