//
//  LevelSelectLayer.m
//  Gen
//
//  Created by Andrey Korikov on 04.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "GameManager.h"
#import "GameState.h"
#import "SlidingMenuGrid.h"
#import "CCMenuItemSpriteIndependent.h"
#import "Helper.h"
#import "IAPHelper.h"
#import "ShopLayer.h"
#import "ProcessingLayer.h"

@interface LevelSelectLayer()
{
    NSMutableArray *allItems;
    CGSize screenSize;
    CCMenu *buttonsMenu;
    SlidingMenuGrid *menuGrid;
    CCSprite *spSprite;
    NSNumberFormatter * _priceFormatter;
    CCLabelTTF *spCounter;
    BOOL levelpackBuyed;
    CCSprite *lpPlateSprite;
    CCSprite *processIcon;
    CCSprite *processText;
    CCSpriteBatchNode *levelpackBatchNode;
}
- (void)displayLevelSelectMenuButtons;
- (void)playScene:(CCMenuItemFont*)itemPassedIn;
- (void)backButtonPressed;
- (void)spButtonPressed;
- (void)lpButtonPressed;
- (void)inAppPurchaseBuyed:(NSNotification *)notify;
@end

@implementation LevelSelectLayer

+ (id)scene 
{
    CCScene *scene = [CCScene node];
    LevelSelectLayer *levelSelectLayer = [self node];
    [scene addChild:levelSelectLayer];
    return scene;
}

- (void)playScene:(id)itemPassedIn
{
    PLAYSOUNDEFFECT(@"LEVEL_BUTTON_PRESSED");
    
    // Добавим брызг
    CCParticleSystemQuad *psPopUpBubble = [CCParticleSystemQuad particleWithFile:@"ps_popUpBubble.plist"];
    CCNode *levelButton = (CCNode*)itemPassedIn;
    psPopUpBubble.position = ccpAdd(levelButton.position, levelButton.parent.position);
    [self addChild:psPopUpBubble z:5];
    
    // Run scene till 0.4 sec
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.5],
                     [CCCallBlock actionWithBlock:^(void) { [[GameManager sharedGameManager] runSceneWithID:(SceneTypes)(kGameLevel1-1+[itemPassedIn tag])]; }],
                     nil]];
}

- (void)backButtonPressed
{
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

- (void)spButtonPressed
{
    // Открывает окно с покупкой суперсил
    
    // Проверяем не создан ли уже слой с паузой
    if ([self getChildByTag:kShopLayer]) {
        return;
    }
    
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    
    // Добавляем слой с магазином
    ShopLayer *shopLayer = [ShopLayer node];
    [self addChild:shopLayer z:10 tag:kShopLayer];
}

- (void)lpButtonPressed
{
    // Покупка доп. уровней
    if (![IAPHelper sharedInstance].isProductsAvailable) {
        CCLOG(@"IAP: Level Pack can't be purchased now! Waiting list of products...");
        return;
    }
    
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    
    // Показываем новый слой с надписью "Обработка"
    ProcessingLayer *procLayer = [[[ProcessingLayer alloc] initWithColor:ccc4(0, 0, 0, 200)] autorelease];
    [self addChild:procLayer z:2];
    
    // Извлекаем нужный продукт из кэша IAPHelpera
    SKProduct *product;
    NSUInteger index = [[IAPHelper sharedInstance].productsCache indexOfObjectPassingTest:^BOOL (SKProduct *obj, NSUInteger idx, BOOL *stop)
    {
        return [kInAppLevelpack isEqualToString:obj.productIdentifier];
    }];
    
    if (index != NSNotFound)
    {
        product = [[IAPHelper sharedInstance].productsCache objectAtIndex:index];
    }
    else
    {
        CCLOG(@"IAP: Level Pack can't be purchased now! Can't find product in cache");
        return;
    }
    
    // Покупаем продукт, если он был найден в кэше
    
    [[IAPHelper sharedInstance] buyFeature:product onComplete:^(NSString* purchasedFeature)
     {
         [procLayer removeFromParentAndCleanup:YES];
         PLAYSOUNDEFFECT(@"INAPP_PURCHASED");
     }
                               onCancelled:^
     {
         // User cancels the transaction, you can log this using any analytics software like Flurry.
         [procLayer removeFromParentAndCleanup:YES];
     }];

}

-(void) updateScore:(NSString*)productIdentifier
{
    NSString *currentValue = [[IAPHelper numberForKey:kInAppMagicShieldsRefName] stringValue];
    NSUInteger startInd = productIdentifier.length - 3;
    NSString *buyedValue = [[productIdentifier substringFromIndex:startInd]stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];
    
    if (spSprite.tag == kSuperpowerNoneIconTag)
    {
        [spSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button_sp_buyed.png"]];
        spSprite.tag = kSuperpowerBuyedIconTag;
    }
    
    [spCounter setString:currentValue];
    
    // Анимируем покупку суперсил
    // Создаем label с кол-вом купленных суперсил
    CCLabelBMFont *buyedLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"+%@", buyedValue] fntFile:@"levelselectNumbers.fnt"];
    buyedLabel.anchorPoint = ccp(1, 0.5);
    buyedLabel.opacity = 0;
    buyedLabel.position = ccp(spCounter.position.x, CGRectGetMinY(spCounter.boundingBox) - buyedLabel.contentSize.height/2);
    [self addChild:buyedLabel z:2];
    
    // Запускаем действия
    id move1 = [CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:0.5f position:ccp(0, -20)] rate:2];
    id move2 = [CCMoveBy actionWithDuration:0.4f position:ccp(0, -30)];
    id fadeInAct = [CCFadeIn actionWithDuration:0.4];
    id fadeOutAct = [CCFadeOut actionWithDuration:0.5];
    id removeAct = [CCCallBlock actionWithBlock:
                      ^{
                          [buyedLabel removeFromParentAndCleanup:YES];
                      }];
    id spawnAct1 = [CCSpawn actionOne:move1 two:fadeInAct];
    id spawnAct2 = [CCSpawn actionOne:move2 two:fadeOutAct];
    id seqAct = [CCSequence actions:spawnAct1, spawnAct2, removeAct, nil];
    [buyedLabel runAction:seqAct];
}

- (void)inAppPurchaseBuyed:(NSNotification *)notify
{
    NSString *productIdentifier = [notify.userInfo valueForKey:@"productIdentifier"];
    
    if ([productIdentifier isEqualToString:kInAppLevelpack])
    {
        [[GameManager sharedGameManager] runSceneWithID:kLevelSelectScene];
    }
    else
    {
        [self updateScore:productIdentifier];
    }
}

- (void)displayLevelSelectMenuButtons
{
    // Init item array
    allItems = [[NSMutableArray alloc] init];
    
    // Определяем куплены доп. уровни или нет. Если нет то показываем только первые (бесплатные)
    uint maxLvl = 15;
    int nCols = 3;
    if (levelpackBuyed)
    {
        maxLvl = kLevelCount;
        nCols = 4;
    }
    
    // Create CCMenuItemSprite objects with tags, callback methods
	for (int i = 1; i <= maxLvl; ++i)
    {
        CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:@"choose_level_button.png"];
        CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:@"choose_level_buttonPressed.png"];
        CCSprite *disabledSprite = [CCSprite spriteWithSpriteFrameName:@"choose_level_buttonDisabled.png"];
		
		CCMenuItemSprite* item = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:self selector:@selector(playScene:)];
		item.tag = i;
        
        // Disable level button if it locked (progress)
        if (i > [GameState sharedInstance].highestOpenedLevel) {
            item.isEnabled = NO;
        }
        else
        {
            // Лепим звезды на пройденных уровнях
            int starsReceivedNum = [[[GameState sharedInstance].levelHighestStarsNumArray objectAtIndex:i-1] integerValue];
            CCSprite *stars = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"stars_%i.png", starsReceivedNum]];
            stars.position = ccp(item.contentSize.width * 0.5, 0);
            [item addChild:stars];
            
            // Пишем номер уровня на уже пройденных уровнях
            CCLabelBMFont *levelNumber = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", i] fntFile:@"levelselectNumbers.fnt"];
            levelNumber.position = ccp(item.contentSize.width*0.5, item.contentSize.height*0.5);
            levelNumber.alignment = kCCTextAlignmentCenter;
            [item addChild:levelNumber];
        }
		
		//Add each item to array
		[allItems addObject:item];
	}
	
	//Init SlidingMenuGrid object with array and some other information
    CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:@"choose_level_button.png"]; // Only for size of texture
    menuGrid = [SlidingMenuGrid menuWithArray:allItems cols:nCols rows:5
                                                      position:ccp(screenSize.width*0.18, screenSize.height*0.89)
                                                      padding:ccp(normalSprite.contentSize.width*1.18, normalSprite.contentSize.height * 1.26)
                                                      verticalPages:false];
	 
	[self addChild:menuGrid z:1];
    
    // Add additional functional buttons
    
    // Back button
    CCSprite *backSprite = [CCSprite spriteWithSpriteFrameName:@"button_back.png"];
    float padding = [backSprite contentSize].width*0.5 * 0.2;
    float xButtonPos = [backSprite contentSize].width*0.5 + padding;
    float yButtonPos = [backSprite contentSize].height*0.5 + padding;
    [backSprite setPosition:ccp(xButtonPos, yButtonPos)];
    [self addChild:backSprite z:1];
    CCMenuItemSpriteIndependent *backButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:backSprite selectedSprite:nil target:self selector:@selector(backButtonPressed)];
    
    // Superpower button
    // Определяем есть ли купленные заряды. Если есть то показываем счетчик и цветную кнопку, если нет - то черно-белую
    int currentValue = [[IAPHelper numberForKey:kInAppMagicShieldsRefName] intValue];
    
    if (currentValue > 0) {
        spSprite = [CCSprite spriteWithSpriteFrameName:@"button_sp_buyed.png"];
        spSprite.tag = kSuperpowerBuyedIconTag;
    }
    else
    {
        spSprite = [CCSprite spriteWithSpriteFrameName:@"button_sp_none.png"];
        spSprite.tag = kSuperpowerNoneIconTag;
    }
    
    padding = [spSprite contentSize].width*0.5 * 0.2;
    xButtonPos = [spSprite contentSize].width*0.5 + padding;
    yButtonPos = screenSize.height - [backSprite contentSize].height*0.5 - padding;
    [spSprite setPosition:ccp(xButtonPos, yButtonPos)];
    [self addChild:spSprite z:1];
    CCMenuItemSpriteIndependent *spButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:spSprite selectedSprite:nil target:self selector:@selector(spButtonPressed)];
    
    // Добавляем счетчик оставшихся зарядов
    spCounter = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", currentValue] fntFile:@"levelselectNumbers.fnt"];
    spCounter.anchorPoint = ccp(1, 0.25);
    spCounter.position = ccp(CGRectGetMaxX(spSprite.boundingBox), CGRectGetMinY(spSprite.boundingBox));
    [self addChild:spCounter z:2];
    
    // Make menu for buttons
    buttonsMenu = [CCMenu menuWithItems:backButton, spButton, nil];
    [self addChild:buttonsMenu z:5];    
}

- (void)displayLevelPackButtons
{
    // Создаем кнопки для покупки доп. уровней
    // Добавляем Баннер с предложением купить уровни и кнопку
    CCSprite *lpButtonSprite = [CCSprite spriteWithSpriteFrameName:@"button_get.png"];
    lpButtonSprite.position = ccp(lpPlateSprite.position.x,
                                  CGRectGetMinY(lpPlateSprite.boundingBox));
    [levelpackBatchNode addChild:lpButtonSprite z:2];
    
    CCMenuItemSpriteIndependent *lpPlateButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:lpPlateSprite selectedSprite:nil target:self selector:@selector(lpButtonPressed)];
    CCMenuItemSpriteIndependent *lpButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:lpButtonSprite selectedSprite:nil target:self selector:@selector(lpButtonPressed)];
    
    // Пишем номер уровня на уже пройденных уровнях
    CCLabelBMFont *lpText = [CCLabelBMFont labelWithString:@"Buy\n25 New Levels" fntFile:@"levelselectNumbers.fnt"];
    lpText.position = ccp(lpPlateSprite.position.x, lpPlateSprite.position.y + lpText.contentSize.height * 2);
    lpText.alignment = kCCTextAlignmentCenter;
    [self addChild:lpText z:2];
    
    [buttonsMenu addChild:lpPlateButton];
    [buttonsMenu addChild:lpButton];
}

- (void)waitingForProducts
{
    if (lpPlateSprite == nil)
    {
        levelpackBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"levelpack.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"levelpack.plist"];
        [self addChild:levelpackBatchNode z:1];
        
        lpPlateSprite = [CCSprite spriteWithSpriteFrameName:@"levelpack_plate.png"];
        lpPlateSprite.position = ccp(screenSize.width * 0.75, screenSize.height * 0.6);
        [levelpackBatchNode addChild:lpPlateSprite];
    }
    
    if ([IAPHelper sharedInstance].isProductsAvailable)
    {
        // Если информация по продуктам IAP уже загрузилась и доступна
        if (processIcon != nil && [processIcon isRunning]) {
            [processIcon removeFromParentAndCleanup:YES];
            [processText removeFromParentAndCleanup:YES];
            processIcon = nil;
            processText = nil;
        }
        [self unschedule:_cmd];
        [self displayLevelPackButtons];
    }
    else if (processIcon == nil && processText == nil)
    {
        processIcon = [CCSprite spriteWithFile:@"process_icon.png"];
        processIcon.anchorPoint = ccp(0.42, 0.5);
        processIcon.position = lpPlateSprite.position;
        [self addChild:processIcon z:2];
        
        processText = [CCLabelTTF labelWithString:@"Loading..." fontName:@"Tahoma" fontSize:[Helper convertFontSize:14]];
        processText.color = ccc3(50, 50, 50);
        processText.position = ccp(lpPlateSprite.position.x, lpPlateSprite.position.y - processIcon.contentSize.height * 0.75);
        [self addChild:processText z:2];
        
        [processIcon runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2 angle:360]]];
    }
}

- (id)init
{
    if ((self = [super init])) {
        screenSize = [[CCDirector sharedDirector] winSize];
        
        // Добавляем обзорщик событий для покупки внутриигровых объектов
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inAppPurchaseBuyed:) name:IAPHelperProductPurchasedNotification object:nil];
        
        // Background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"levelselect_back.png"];
        [background setPosition:ccp(screenSize.width*0.5, screenSize.height*0.5)];
        [self addChild:background z:-1];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Choose level Label
        CCSprite *chooseLevelLabel = [CCSprite spriteWithSpriteFrameName:@"choose_level_label.png"];
        [chooseLevelLabel setPosition:ccp(screenSize.width*0.78, screenSize.height*0.14)];
        [self addChild:chooseLevelLabel];
        
        // Проверяем куплены или нет платные уровни
        levelpackBuyed = [[IAPHelper sharedInstance] productPurchased:kInAppLevelpack];
        
        // Display Main Menu Buttons
        [self displayLevelSelectMenuButtons];
        
        // Проверяем готовы ли данные по продаваемым продуктам, если нет то отключаем кнопки на покупку уровней, если готовы - показываем
        if (levelpackBuyed == NO)
        {
            _priceFormatter = [[NSNumberFormatter alloc] init];
            [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            
            [self schedule:@selector(waitingForProducts) interval:0.2];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
    
    if (_priceFormatter != nil) {
        [_priceFormatter release];
    }
    
    [allItems release];
    allItems = nil;
    [super dealloc];
}

@end
