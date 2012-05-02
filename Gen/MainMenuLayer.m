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
#define kPlayGameButtonTag 14
#define kMagnitSpriteTag 15

@interface MainMenuLayer()
{
    CCSpriteBatchNode *sceneSpriteBatchNode;
    CCMenu *optionsMenu;
    CCMenu *mainMenu;
    CCMenu *levelMenu;
}
- (void)displayMainMenuButtons;
- (void)displayOptionsMenuButtons;
- (void)displayLevelSelectMenuButtons;
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
    [self displayLevelSelectMenuButtons];
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

- (void)playScene:(CCMenuItemFont*)itemPassedIn
{
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
    } else {
        CCLOG(@"Unexpected item.  Tag was: %d", [itemPassedIn tag]);
    }
}

- (void)displayLevelSelectMenuButtons
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    // Hide Big play game button and disable element of main menu at center of the screen. Don't delete.
    CCSprite *magnitSprite = (CCSprite*)[self getChildByTag:kMagnitSpriteTag];
    CCMenuItemSpriteIndependent *playGameButton = (CCMenuItemSpriteIndependent*) [mainMenu getChildByTag:kPlayGameButtonTag];
    [playGameButton setIsEnabled:NO];
    [playGameButton.normalImage setVisible:NO];
    [magnitSprite pauseSchedulerAndActions];
    [magnitSprite setVisible:NO];
    
    // Make Level Select menu
    NSString *menuFontName = @"Helvetica";
    float menuFontSize = 28;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        menuFontSize = 14;
    }
    
    CCLabelTTF *playScene1Label = [CCLabelTTF labelWithString:@"Level 1" fontName:menuFontName fontSize:menuFontSize];
    CCMenuItemLabel *playScene1 = [CCMenuItemLabel itemWithLabel:playScene1Label target:self selector:@selector(playScene:)];
    [playScene1 setTag:1];
    
    CCLabelTTF *playScene2Label = [CCLabelTTF labelWithString:@"Level 2" fontName:menuFontName fontSize:menuFontSize];
    CCMenuItemLabel *playScene2 = [CCMenuItemLabel itemWithLabel:playScene2Label target:self selector:@selector(playScene:)];
    [playScene2 setTag:2];
    
    CCLabelTTF *playScene3Label = [CCLabelTTF labelWithString:@"Level 3" fontName:menuFontName fontSize:menuFontSize];
    CCMenuItemLabel *playScene3 = [CCMenuItemLabel itemWithLabel:playScene3Label target:self selector:@selector(playScene:)];
    [playScene3 setTag:3];
    
    CCLabelTTF *playScene4Label = [CCLabelTTF labelWithString:@"Level 4" fontName:menuFontName fontSize:menuFontSize];
    CCMenuItemLabel *playScene4 = [CCMenuItemLabel itemWithLabel:playScene4Label target:self selector:@selector(playScene:)];
    [playScene4 setTag:4];
    
    CCLabelTTF *playScene5Label = [CCLabelTTF labelWithString:@"Level 5" fontName:menuFontName fontSize:menuFontSize];
    CCMenuItemLabel *playScene5 = [CCMenuItemLabel itemWithLabel:playScene5Label target:self selector:@selector(playScene:)];
    [playScene5 setTag:5];
    
    CCLabelTTF *backButtonLabel = [CCLabelTTF labelWithString:@"Back" fontName:menuFontName fontSize:menuFontSize];
    CCMenuItemLabel *backButton = [CCMenuItemLabel itemWithLabel:backButtonLabel target:self selector:@selector(displayMainMenuButtons)];
    levelMenu = [CCMenu menuWithItems:playScene1,playScene2,playScene3,playScene4,playScene5,backButton,nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [levelMenu alignItemsVerticallyWithPadding:screenSize.height*0.049f];
    }
    else {
        [levelMenu alignItemsVerticallyWithPadding:screenSize.height*0.029f];
    }
    [levelMenu setPosition:ccp(screenSize.width*2, screenSize.height/2)];
    id moveAction = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width*0.5f, screenSize.height*0.5f)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    [levelMenu runAction:moveEffect];
    [self addChild:levelMenu z:3];
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
    if (mainMenu != nil)
    {
        if (levelMenu != nil) {
            [levelMenu removeFromParentAndCleanup:YES];
            levelMenu = nil;
        }
        // Show hiden main menu elements
        CCSprite *magnitSprite = (CCSprite*)[self getChildByTag:kMagnitSpriteTag];
        CCMenuItemSpriteIndependent *playGameButton = (CCMenuItemSpriteIndependent*) [mainMenu getChildByTag:kPlayGameButtonTag];
        [playGameButton setIsEnabled:YES];
        [playGameButton.normalImage setVisible:YES];
        [magnitSprite setVisible:YES];
        [magnitSprite resumeSchedulerAndActions];
    }
    else
    {
        // Center Magnit
        CCSprite *magnit = [CCSprite spriteWithFile:@"playButtonUnder.png"];
        [magnit setPosition:ccp(screenSize.width*0.5, screenSize.height*0.5)];
        [self addChild:magnit z:0 tag:kMagnitSpriteTag];
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
        yButtonPos = 0+[optionsSprite contentSize].height*0.5 + padding;
        [optionsSprite setPosition:ccp(xButtonPos, yButtonPos)];
        xButtonPos = screenSize.width*0.5-([leaderboardSprite contentSize].width + padding);
        yButtonPos = 0+[leaderboardSprite contentSize].height*0.5 + padding;
        [leaderboardSprite setPosition:ccp(xButtonPos, yButtonPos)];
        xButtonPos = screenSize.width*0.5+([achievmentsSprite contentSize].width + padding);
        yButtonPos = 0+[achievmentsSprite contentSize].height*0.5 + padding;
        [achievmentsSprite setPosition:ccp(xButtonPos, yButtonPos)];

        // Adding sprites to Batchnode
        [self addChild:playGameSprite z:3];
        [sceneSpriteBatchNode addChild:optionsSprite z:3 tag:kOptionsSpriteTag];
        [sceneSpriteBatchNode addChild:leaderboardSprite z:3];
        [sceneSpriteBatchNode addChild:achievmentsSprite z:3];
        
        // Main Menu Items
        CCMenuItemSpriteIndependent *playGameButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:playGameSprite selectedSprite:nil target:self selector:@selector(playPressed)];
        playGameButton.tag = kPlayGameButtonTag;
        CCMenuItemSpriteIndependent *optionsButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:optionsSprite selectedSprite:nil target:self selector:@selector(optionsPressed)];
        CCMenuItemSpriteIndependent *leaderboardButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:leaderboardSprite selectedSprite:nil target:self selector:@selector(leaderboardPressed)];
        CCMenuItemSpriteIndependent *achievementButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:achievmentsSprite selectedSprite:nil target:self selector:@selector(achievementPressed)];

        mainMenu = [CCMenu menuWithItems:playGameButton, optionsButton, leaderboardButton, achievementButton,nil];
        [self addChild:mainMenu z:5];
    }
}

- (id)init {
    if ((self = [super init])) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode z:1];
        
        // Background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background1.png"];
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
