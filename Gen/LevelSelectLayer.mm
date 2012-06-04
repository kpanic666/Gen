//
//  LevelSelectLayer.m
//  Gen
//
//  Created by Andrey Korikov on 04.05.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "GameManager.h"
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
    
    if ([itemPassedIn tag] == 1) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel1];
    } else if ([itemPassedIn tag] == 2) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel2];
    } else if ([itemPassedIn tag] == 3) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel3];
    } else if ([itemPassedIn tag] == 4) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel4];
    } else if ([itemPassedIn tag] == 5) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel5];
    } else if ([itemPassedIn tag] == 6) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel6];
    } else if ([itemPassedIn tag] == 7) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel7];
    } else if ([itemPassedIn tag] == 8) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel8];
    } else if ([itemPassedIn tag] == 9) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel9];
    } else if ([itemPassedIn tag] == 10) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel10];
    } else if ([itemPassedIn tag] == 11) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel11];
    } else if ([itemPassedIn tag] == 12) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel12];
    } else if ([itemPassedIn tag] == 13) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel13];
    } else if ([itemPassedIn tag] == 14) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel14];
    } else if ([itemPassedIn tag] == 15) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel15];
    } else if ([itemPassedIn tag] == 16) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel16];
    } else if ([itemPassedIn tag] == 17) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel17];
    } else if ([itemPassedIn tag] == 18) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel18];
    } else if ([itemPassedIn tag] == 19) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel19];
    } else if ([itemPassedIn tag] == 20) {
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel20];
    } else {
        CCLOG(@"Unexpected item.  Tag was: %d", [itemPassedIn tag]);
    }
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
        CCSprite *normalSprite = [CCSprite spriteWithFile:@"button_level.png"];
        CCSprite *selectedSprite = [CCSprite spriteWithFile:@"button_level.png"];
        CCLabelTTF *levelNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", i] fontName:@"Helvetica" fontSize:menuFontSize];
        levelNumber.position = ccp(normalSprite.contentSize.width*0.5, normalSprite.contentSize.height*0.5);
        [normalSprite addChild:levelNumber];
		
		CCMenuItemSprite* item = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:self selector:@selector(playScene:)];
		item.tag = i;
		
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
