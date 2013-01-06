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

@interface LevelSelectLayer()
{
    NSMutableArray *allItems;
    CCMenu *buttonsMenu;
    SlidingMenuGrid *menuGrid;
    CCSprite *spSprite;
    CCLabelTTF *spCounter;
}
- (void)displayLevelSelectMenuButtons;
- (void)playScene:(CCMenuItemFont*)itemPassedIn;
- (void)backButtonPressed;
- (void)spButtonPressed;
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
    // Проверяем не создан ли уже слой с паузой
    if ([self getChildByTag:kShopLayer]) {
        return;
    }
    
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    
    // Добавляем слой с магазином
    ShopLayer *shopLayer = [ShopLayer node];
    [self addChild:shopLayer z:10 tag:kShopLayer];
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
        
    }
    else
    {
        [self updateScore:productIdentifier];
    }
}

- (void)displayLevelSelectMenuButtons
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    // Init item array
    allItems = [[NSMutableArray alloc] init];
    
    // Create CCMenuItemSprite objects with tags, callback methods
	for (int i = 1; i <= kLevelCount; ++i)
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
    CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:@"choose_level_button.png"];; // Only for size of texture
    menuGrid = [SlidingMenuGrid menuWithArray:allItems cols:4 rows:5
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

- (id)init
{
    if ((self = [super init])) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
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
        
        // Display Main Menu Buttons
        [self displayLevelSelectMenuButtons];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
    
    [allItems release];
    allItems = nil;
    [super dealloc];
}

@end
