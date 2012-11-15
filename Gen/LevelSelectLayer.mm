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

@interface LevelSelectLayer()
{
    NSMutableArray *allItems;
}
- (void)displayLevelSelectMenuButtons;
- (void)playScene:(CCMenuItemFont*)itemPassedIn;
- (void)backButtonPressed;
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
            levelNumber.position = ccp(item.contentSize.width*0.5, item.contentSize.height*0.45);
            levelNumber.alignment = kCCTextAlignmentCenter;
            [item addChild:levelNumber];
        }
		
		//Add each item to array
		[allItems addObject:item];
	}
	
	//Init SlidingMenuGrid object with array and some other information
    CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:@"choose_level_button.png"];; // Only for size of texture
    SlidingMenuGrid *menuGrid = [SlidingMenuGrid menuWithArray:allItems cols:4 rows:5
                                                      position:ccp(screenSize.width*0.15, screenSize.height*0.89)
                                                      padding:ccp(normalSprite.contentSize.width*1.18, normalSprite.contentSize.height * 1.26)
                                                      verticalPages:false];
	 
	[self addChild:menuGrid z:1];
    
    // Back button menu
    CCSprite *backSprite = [CCSprite spriteWithSpriteFrameName:@"button_back.png"];
    float padding = [backSprite contentSize].width*0.5 * 0.2;
    float xButtonPos = [backSprite contentSize].width*0.5 + padding;
    float yButtonPos = [backSprite contentSize].height*0.5 + padding;
    [backSprite setPosition:ccp(xButtonPos, yButtonPos)];
    [self addChild:backSprite z:1];
    CCMenuItemSpriteIndependent *backButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:backSprite selectedSprite:nil target:self selector:@selector(backButtonPressed)];
    CCMenu *backMenu = [CCMenu menuWithItems:backButton, nil];
    [self addChild:backMenu z:5];
}

- (id)init
{
    if ((self = [super init])) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
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
        
//        // Slide tip
//        CCSprite *slideTip = [CCSprite spriteWithSpriteFrameName:@"tut_finger_slide.png"];
//        [slideTip setPosition:ccp(screenSize.width*0.7, screenSize.height*0.3)];
//        [self addChild:slideTip];
        
        // Display Main Menu Buttons
        [self displayLevelSelectMenuButtons];
    }
    return self;
}

- (void)dealloc
{
    [allItems release];
    allItems = nil;
    [super dealloc];
}

@end
