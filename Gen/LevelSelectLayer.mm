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
    PLAYSOUNDEFFECT(@"BUTTON_PRESSED");
    [[GameManager sharedGameManager] runSceneWithID:(SceneTypes)(kGameLevel1 - 1 + [itemPassedIn tag])];
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
    
    float menuFontSize = [Helper convertFontSize:16];
    
    // Create CCMenuItemSprite objects with tags, callback methods
	for (int i = 1; i <= kLevelCount; ++i)
    {
        CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:@"button_level.png"];
        CCSprite *selectedSprite = [CCSprite spriteWithSpriteFrameName:@"button_level.png"];
		
		CCMenuItemSprite* item = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:self selector:@selector(playScene:)];
		item.tag = i;
        
        // Disable level button if it locked (progress)
        if (i > [GameState sharedInstance].highestOpenedLevel) {
            [item setColor:ccc3(150, 150, 150)];
            [item setOpacity:190];
            [item setIsEnabled:NO];
            
            CCSprite *lock = [CCSprite spriteWithSpriteFrameName:@"icon_locked.png"];
            lock.position = ccp(item.contentSize.width*0.5, item.contentSize.height*0.5);
            [item addChild:lock];
        }
        else
        {
            // Лепим звезды на пройденных уровнях
            int starsReceivedNum = [[[GameState sharedInstance].levelHighestStarsNumArray objectAtIndex:i-1] integerValue];
            ccBlendFunc blendInactiveStar = (ccBlendFunc){GL_ONE_MINUS_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
            float xPosition, yPosition;
            
            for (int counter = 1; counter <= 3; counter++)
            {
                CCSprite *star = [CCSprite spriteWithSpriteFrameName:@"childcell_idle.png"];
                star.scale = 0.8;
                star.position = ccp(item.contentSize.width/4 * counter, star.contentSize.height/2.5);
                [item addChild:star];
                
                if (counter > starsReceivedNum) [star setBlendFunc:blendInactiveStar];
            }
            
            // Пишем номер уровня на уже пройденных уровнях
            CCLabelTTF *levelNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", i] fontName:@"Helvetica" fontSize:menuFontSize];
            levelNumber.position = ccp(item.contentSize.width*0.5, item.contentSize.height*0.5);
            [item addChild:levelNumber];
        }
		
		//Add each item to array
		[allItems addObject:item];
	}
	
	//Init SlidingMenuGrid object with array and some other information
    CCSprite *normalSprite = [CCSprite spriteWithFile:@"button_level.png"]; // Only for size of texture
    SlidingMenuGrid *menuGrid = [SlidingMenuGrid menuWithArray:allItems cols:5 rows:4 
                                                      position:ccp(screenSize.width*0.28, screenSize.height*0.75) 
                                                      padding:ccp(normalSprite.contentSize.width * 1.1, normalSprite.contentSize.height) 
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
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:ccp(screenSize.width*0.5, screenSize.height*0.5)];
        [self addChild:background z:-1];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
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
