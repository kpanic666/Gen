//
//  CreditsLayer.m
//  Gen
//
//  Created by Andrey Korikov on 13.01.13.
//  Copyright (c) 2013 Atom Games. All rights reserved.
//

#import "CreditsLayer.h"
#import "GameManager.h"
#import "CCMenuItemSpriteIndependent.h"
#import "Helper.h"
#import "iRate.h"
#import "GameState.h"

@implementation CreditsLayer

+ (id)scene
{
    CCScene *scene = [CCScene node];
    CreditsLayer *creditsLayer = [self node];
    [scene addChild:creditsLayer];
    return scene;
}

- (void)backButtonPressed
{
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

- (void)goToWebSite:(CCMenuItemLabel*)labelPressed
{
	CCLOG(@"Going to WebSite");
	[[GameManager sharedGameManager] openSiteWithLinkType:(LinkTypes)[labelPressed tag]];
}

- (void)resetStateButtonPressed
{
    // Delete Information about current game progress
    //    [[GCHelper sharedInstance] resetAchievements];
    [[GameState sharedInstance] resetState];
    //    [[IAPHelper sharedInstance] removeAllKeychainData];
}

- (id)init
{
    if ((self = [super init])) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // add background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background1.jpg"];
        [background setPosition:ccp(screenSize.width / 2, screenSize.height / 2)];
        [self addChild:background z:0];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // Back button
        CCSprite *backSprite = [CCSprite spriteWithSpriteFrameName:@"button_back.png"];
        float padding = [backSprite contentSize].width*0.5 * 0.2;
        float xButtonPos = [backSprite contentSize].width*0.5 + padding;
        float yButtonPos = [backSprite contentSize].height*0.5 + padding;
        [backSprite setPosition:ccp(xButtonPos, yButtonPos)];
        [self addChild:backSprite z:1];
        CCMenuItemSpriteIndependent *backButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:backSprite selectedSprite:nil target:self selector:@selector(backButtonPressed)];
        
        // Reset State Button
        CCSprite *resetGameSprite = [CCSprite spriteWithSpriteFrameName:@"middle_button.png"];
        padding = 0;
        xButtonPos = screenSize.width - resetGameSprite.contentSize.width * 0.5 - padding;
        yButtonPos = resetGameSprite.contentSize.height * 0.5 + padding;
        [resetGameSprite setPosition:ccp(xButtonPos, yButtonPos)];
        [self addChild:resetGameSprite z:1];
        CCMenuItemSpriteIndependent *resetGameButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:resetGameSprite selectedSprite:nil target:self selector:@selector(resetStateButtonPressed)];
        CCLabelTTF *resetLabelText = [CCLabelTTF labelWithString:@"Reset game" fontName:@"Tahoma-Bold" fontSize:[Helper convertFontSize:14]];
        resetLabelText.position = resetGameSprite.position;
        [self addChild:resetLabelText z:2];
        
        // Make menu for Back, Reset State buttons
        CCMenu *buttonsMenu = [CCMenu menuWithItems:backButton, resetGameButton, nil];
        [self addChild:buttonsMenu z:1];
        
        // Logo
        CCSprite *genbyLogo = [CCSprite spriteWithSpriteFrameName:@"genby_logo.png"];
        genbyLogo.scale = 0.5;
        genbyLogo.anchorPoint = ccp(0.5, 1);
        genbyLogo.position = ccp(screenSize.width * 0.5, screenSize.height - genbyLogo.contentSize.height*0.25);
        [self addChild:genbyLogo z:1];
        
        // Version Info
        CCLabelTTF *verText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"ver. %@", [[iRate sharedInstance] applicationVersion]] fontName:@"Tahoma" fontSize:[Helper convertFontSize:12]];
        verText.position = ccp(screenSize.width * 0.5, screenSize.height * 0.75);
        verText.color = ccBLACK;
        [self addChild:verText z:1];
        
        // Programmer
        CCLabelBMFont *developerLabelText = [CCLabelBMFont labelWithString:@"Programming, Game Design, Idea" fntFile:@"levelselectNumbers.fnt"];
        CCLabelTTF *developerText = [CCLabelTTF labelWithString:@"Andrey Korikov" fontName:@"Tahoma-Bold" fontSize:[Helper convertFontSize:16]];
        developerText.color = ccBLACK;
        developerText.position = ccp(developerLabelText.contentSize.width / 2, -developerText.contentSize.height / 2);
		CCMenuItemLabel *developerLabel = [CCMenuItemLabel itemWithLabel:developerLabelText target:self selector:@selector(goToWebSite:)];
        [developerLabel addChild:developerText];
		[developerLabel setTag:kLinkTypeDeveloperEmail];
        
        // Artist
		CCLabelBMFont *artistLabelText = [CCLabelBMFont labelWithString:@"Art and Graphics" fntFile:@"levelselectNumbers.fnt"];
        CCLabelTTF *artistText = [CCLabelTTF labelWithString:@"Darya Romanova" fontName:@"Tahoma-Bold" fontSize:[Helper convertFontSize:16]];
        artistText.color = ccBLACK;
        artistText.position = ccp(artistLabelText.contentSize.width / 2, -artistText.contentSize.height / 2);
		CCMenuItemLabel *artistLabel = [CCMenuItemLabel itemWithLabel:artistLabelText target:self selector:@selector(goToWebSite:)];
        [artistLabel addChild:artistText];
		[artistLabel setTag:kLinkTypeArtistEmail];
		
        // Music
		CCLabelBMFont *musicianLabelText = [CCLabelBMFont labelWithString:@"Music" fntFile:@"levelselectNumbers.fnt"];
        CCLabelTTF *musicianText = [CCLabelTTF labelWithString:@"Kevin MacLeod" fontName:@"Tahoma-Bold" fontSize:[Helper convertFontSize:16]];
        musicianText.color = ccBLACK;
        musicianText.position = ccp(musicianLabelText.contentSize.width / 2, -musicianText.contentSize.height / 2);
		CCMenuItemLabel *musicianLabel = [CCMenuItemLabel itemWithLabel:musicianLabelText target:self selector:@selector(goToWebSite:)];
        [musicianLabel addChild:musicianText];
		[musicianLabel setTag:kLinkTypeMusicSite];
		
        CCMenu *creditsMenu = [CCMenu menuWithItems:
							   developerLabel,
							   artistLabel,
							   musicianLabel,
							   nil];
		
		[creditsMenu alignItemsVerticallyWithPadding:screenSize.height * 0.15f];
		[creditsMenu setPosition:ccp(screenSize.width /2, screenSize.height * 0.4f)];
		[self addChild:creditsMenu];

    }
    return self;
}

@end
