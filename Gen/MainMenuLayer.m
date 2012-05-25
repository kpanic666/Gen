//
//  MainMenuLayer.m
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameManager.h"
#import "CCMenuItemSpriteIndependent.h"

#define kInfoSpriteTag 9
#define kPanelSpriteTag 10
#define kOptionsSpriteTag 11
#define kMusicToggleTag 12
#define kSfxToggleTag 13

@interface MainMenuLayer()
{
    CCSpriteBatchNode *sceneSpriteBatchNode;
    CCMenu *optionsMenu;
    CCMenu *mainMenu;
}
- (void)displayMainMenuButtons;
- (void)displayOptionsMenuButtons;
@end

@implementation MainMenuLayer

+ (id)scene {
    CCScene *scene = [CCScene node];
    MainMenuLayer *mainMenuLayer = [self node];
    [scene addChild:mainMenuLayer];
    return scene;
}

- (void)playPressed
{
    [[GameManager sharedGameManager] runSceneWithID:kLevelSelectScene];
}

- (void)optionsPressed
{
    [self displayOptionsMenuButtons];
}

- (void)leaderboardPressed
{
    
}

- (void)achievementPressed
{
    
}

- (void)showCredits
{
    CCLOG(@"OptionsMenu->Info Button Pressed!");
//	[[GameManager sharedGameManager] runSceneWithID:kCreditsScene];
}

- (void)musicTogglePressed
{
	if ([[GameManager sharedGameManager] isMusicON]) {
		CCLOG(@"OptionsLayer-> Turning Game Music OFF");
		[[GameManager sharedGameManager] setMusicState:NO];
	} else {
		CCLOG(@"OptionsLayer-> Turning Game Music ON");
		[[GameManager sharedGameManager] setMusicState:YES];
	}
}

- (void)SFXTogglePressed
{
    CCLOG(@"OptionsMenu->SFX Button Pressed!");
	if ([[GameManager sharedGameManager] isSoundEffectsON]) {
		CCLOG(@"OptionsLayer-> Turning Sound Effects OFF");
		[[GameManager sharedGameManager] setIsSoundEffectsON:NO];
	} else {
		CCLOG(@"OptionsLayer-> Turning Sound Effects ON");
		[[GameManager sharedGameManager] setIsSoundEffectsON:YES];
	}
}

- (void)removeOptionsMenu
{
    CCSprite *infoSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kInfoSpriteTag];
    CCSprite *panelSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kPanelSpriteTag];
    [infoSprite removeFromParentAndCleanup:YES];
    [panelSprite removeFromParentAndCleanup:YES];
    [optionsMenu removeFromParentAndCleanup:YES];
    optionsMenu = nil;
}

- (void)displayOptionsMenuButtons
{
    CCSprite *optionsSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kOptionsSpriteTag];
    CCHide *hideAction = [CCHide action]; 
    
    if (optionsMenu != nil)
    {
        CCMenuItemToggle *musicToggle = (CCMenuItemToggle*) [optionsMenu getChildByTag:kMusicToggleTag];
        CCMenuItemToggle *sfxToggle = (CCMenuItemToggle*) [optionsMenu getChildByTag:kSfxToggleTag];
        CCSprite *infoSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kInfoSpriteTag];
        CCSprite *panelSprite = (CCSprite*)[sceneSpriteBatchNode getChildByTag:kPanelSpriteTag];
        
        CCCallFunc *removeMenuAction = [CCCallFunc actionWithTarget:self selector:@selector(removeOptionsMenu)];
        CCMoveTo *move1Action = [CCMoveTo actionWithDuration:0.2 position:optionsSprite.position];
        CCMoveTo *move2Action = [CCMoveTo actionWithDuration:0.3 position:optionsSprite.position];
        CCMoveTo *move3Action = [CCMoveTo actionWithDuration:0.4 position:optionsSprite.position];
        CCScaleTo *scaleAction = [CCScaleTo actionWithDuration:0.4 scaleX:1 scaleY:0.5];
        [panelSprite runAction:[CCSequence actions:scaleAction, removeMenuAction, nil]];
        [sfxToggle runAction:[CCSequence actions:move1Action, hideAction, nil]];
        [musicToggle runAction:[CCSequence actions:move2Action, hideAction, nil]];
        [infoSprite runAction:[CCSequence actions:move3Action, hideAction, nil]];
    }
    else 
    {
        // Make Sprites for Menu
        CCSprite *musicOnSprite = [CCSprite spriteWithSpriteFrameName:@"button_music_on.png"];
        CCSprite *musicOffSprite = [CCSprite spriteWithSpriteFrameName:@"button_music_off.png"];
        CCSprite *sfxOnSprite = [CCSprite spriteWithSpriteFrameName:@"button_sfx_on.png"];
        CCSprite *sfxOffSprite = [CCSprite spriteWithSpriteFrameName:@"button_sfx_off.png"];
        CCSprite *infoSprite = [CCSprite spriteWithSpriteFrameName:@"button_info.png"];
        CCSprite *panelSprite = [CCSprite spriteWithSpriteFrameName:@"optionsButtonUnder.png"];
        
        // Adding sprites to Batchnode
        [sceneSpriteBatchNode addChild:panelSprite z:1 tag:kPanelSpriteTag];
        [sceneSpriteBatchNode addChild:infoSprite z:3 tag:kInfoSpriteTag];
        
        // Options Menu Items
        CCMenuItemSprite *sfxOnButton = [CCMenuItemSprite itemWithNormalSprite:sfxOnSprite selectedSprite:nil target:self selector:nil];
        CCMenuItemSprite *sfxOffButton = [CCMenuItemSprite itemWithNormalSprite:sfxOffSprite selectedSprite:nil target:self selector:nil];
        CCMenuItemSprite *musicOnButton = [CCMenuItemSprite itemWithNormalSprite:musicOnSprite selectedSprite:nil target:self selector:nil];
        CCMenuItemSprite *musicOffButton = [CCMenuItemSprite itemWithNormalSprite:musicOffSprite selectedSprite:nil target:self selector:nil];
        CCMenuItemSpriteIndependent *infoButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:infoSprite selectedSprite:nil target:self selector:@selector(showCredits)];
        CCMenuItemToggle *musicToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicTogglePressed) items:musicOnButton, musicOffButton, nil];
        CCMenuItemToggle *sfxToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(SFXTogglePressed) items:sfxOnButton, sfxOffButton, nil];
        
        optionsMenu = [CCMenu menuWithItems:musicToggle, sfxToggle, infoButton, nil];
        [optionsMenu setPosition:ccp(0, 0)];
        [self addChild:optionsMenu z:3];
        
        // Hide and scale down sprites for Options Menu
        float padding = 0.8;
        [musicToggle setScale:padding];
        [sfxToggle setScale:padding];
        [infoSprite setScale:padding];
        [panelSprite setAnchorPoint:ccp(0.5, 0)];
        [musicToggle setTag:kMusicToggleTag];
        [sfxToggle setTag:kSfxToggleTag];
        
        // Positioning sprites
        float xButtonPos = 0;
        float yButtonPos = 0;
        xButtonPos = optionsSprite.position.x;
        yButtonPos = optionsSprite.position.y;
        [panelSprite setPosition:ccp(xButtonPos, yButtonPos)];
        padding = optionsSprite.contentSize.height;
        yButtonPos += padding;
        sfxToggle.position = ccp(xButtonPos, yButtonPos);
        yButtonPos += padding;
        musicToggle.position = ccp(xButtonPos, yButtonPos);
        yButtonPos += padding;
        [infoSprite setPosition:ccp(xButtonPos, yButtonPos)];
        
        if ([[GameManager sharedGameManager] isMusicON] == NO) {
            [musicToggle setSelectedIndex:1]; // Music is OFF
        }
        if ([[GameManager sharedGameManager] isSoundEffectsON] == NO) {
            [sfxToggle setSelectedIndex:1]; // SFX are OFF
        }
        
        // Animating open menu
        CCShow *showAction = [CCShow action];
        CCDelayTime *delay1Action = [CCDelayTime actionWithDuration:0.1];
        CCDelayTime *delay2Action = [CCDelayTime actionWithDuration:0.2];
        CCDelayTime *delay3Action = [CCDelayTime actionWithDuration:0.3];
        [panelSprite runAction:[CCScaleTo actionWithDuration:0.2 scaleX:1 scaleY:5]];
        [sfxToggle runAction:[CCSequence actions:hideAction, delay1Action ,showAction, nil]];
        [musicToggle runAction:[CCSequence actions:hideAction, delay2Action, showAction, nil]];
        [infoSprite runAction:[CCSequence actions:hideAction, delay3Action, showAction, nil]];  
    }
}

- (void)displayMainMenuButtons 
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    // Center Magnit
    CCSprite *magnit = [CCSprite spriteWithFile:@"playButtonUnder.png"];
    [magnit setPosition:ccp(screenSize.width*0.5, screenSize.height*0.5)];
    [self addChild:magnit z:0];
    id scaleUp = [CCScaleTo actionWithDuration:0.1f scale:1.2f];
    id scaleDown = [CCScaleTo actionWithDuration:2.0f scale:1.0f];
    [magnit runAction:[CCRepeatForever actionWithAction:[CCSequence actions:scaleUp, scaleDown, nil]]];
    [magnit runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:20.0f angle:360]]];
    
    // Make Sprites for Menu
    CCSprite *playGameSprite = [CCSprite spriteWithFile:@"button_big_play.png"];
    CCSprite *optionsSprite = [CCSprite spriteWithSpriteFrameName:@"button_options.png"];
    CCSprite *leaderboardSprite = [CCSprite spriteWithSpriteFrameName:@"button_leaderboard.png"];
    CCSprite *achievmentsSprite = [CCSprite spriteWithSpriteFrameName:@"button_achievments.png"];
    
    // Positioning sprites
    float padding = [optionsSprite contentSize].width*0.5 * 0.2; // отступ от края экрана c учетом спец эффекта меню
    float xButtonPos = 0;
    float yButtonPos = 0;
    [playGameSprite setPosition:ccp(screenSize.width*0.5, screenSize.height*0.5)];
    xButtonPos = screenSize.width-[optionsSprite contentSize].width*0.5 - padding;
    yButtonPos = [optionsSprite contentSize].height*0.5 + padding;
    [optionsSprite setPosition:ccp(xButtonPos, yButtonPos)];
    xButtonPos = screenSize.width*0.5-([leaderboardSprite contentSize].width + padding);
    yButtonPos = [leaderboardSprite contentSize].height*0.5 + padding;
    [leaderboardSprite setPosition:ccp(xButtonPos, yButtonPos)];
    xButtonPos = screenSize.width*0.5+([achievmentsSprite contentSize].width + padding);
    yButtonPos = [achievmentsSprite contentSize].height*0.5 + padding;
    [achievmentsSprite setPosition:ccp(xButtonPos, yButtonPos)];

    // Adding sprites to Batchnode
    [self addChild:playGameSprite z:3];
    [sceneSpriteBatchNode addChild:optionsSprite z:3 tag:kOptionsSpriteTag];
    [sceneSpriteBatchNode addChild:leaderboardSprite z:3];
    [sceneSpriteBatchNode addChild:achievmentsSprite z:3];
    
    // Main Menu Items
    CCMenuItemSpriteIndependent *playGameButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:playGameSprite selectedSprite:nil target:self selector:@selector(playPressed)];
    CCMenuItemSpriteIndependent *optionsButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:optionsSprite selectedSprite:nil target:self selector:@selector(optionsPressed)];
    CCMenuItemSpriteIndependent *leaderboardButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:leaderboardSprite selectedSprite:nil target:self selector:@selector(leaderboardPressed)];
    CCMenuItemSpriteIndependent *achievementButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:achievmentsSprite selectedSprite:nil target:self selector:@selector(achievementPressed)];

    mainMenu = [CCMenu menuWithItems:playGameButton, optionsButton, leaderboardButton, achievementButton,nil];
    [self addChild:mainMenu z:5];
}

- (id)init {
    if ((self = [super init])) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode z:1];
        
        // Background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.png"];
        [background setPosition:ccp(screenSize.width*0.5, screenSize.height*0.5)];
        [self addChild:background z:-1];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Logo
        CCSprite *logo = [CCSprite spriteWithFile:@"logo.png"];
        [logo setPosition:ccp(screenSize.width*0.5, screenSize.height*0.85)];
        [self addChild:logo];
        
        // Cells for Beautify
        
        // Display Main Menu Buttons
        [self displayMainMenuButtons];
        
//        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_1];
    }
    return self;
}

@end
