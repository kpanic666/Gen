//
//  Box2DUILayer.m
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DUILayer.h"
#import "CCMenuItemSpriteIndependent.h"
#import "GameManager.h"
#import "PauseLayer.h"
#import "Helper.h"

@interface Box2DUILayer()
{
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *totalLabel;
    CCLabelBMFont *leftScoreLabel;
    CCLabelBMFont *centerLabel;
    CCSprite *centerLabelSFX;
    CCSprite *infopanel;
    float originalScale;
    CCMenu *pauseMenu;
    CCSprite *pauseGameSprite;
}
@end

@implementation Box2DUILayer

- (void)pausePressed
{
    // Проверяем не создан ли уже слой с паузой
    if ([self.parent getChildByTag:kPauseLayer]) {
        return;
    }
    
    // Затеняем фон
    ccColor4B c = ccc4(0, 0, 0, 100); // Black transparent background
    PauseLayer *pauseLayer = [[[PauseLayer alloc] initWithColor:c] autorelease];
    [self.parent addChild:pauseLayer z:10 tag:kPauseLayer];
    
    // Ставим на паузу всех детей основного batchnode. так просто поставить слой на паузу не достаточно
    CCLayer *gl = (CCLayer*) [self.parent getChildByTag:kBox2DLayer];
    [gl setIsTouchEnabled:NO];
    CCSpriteBatchNode *bn = (CCSpriteBatchNode*)[gl getChildByTag:kMainSpriteBatchNode];
    [gl pauseSchedulerAndActions];
    for (CCNode *tempNode in [bn children]) {
        [tempNode pauseSchedulerAndActions];
    }
}

- (void)hideUI
{
    infopanel.visible = FALSE;
    scoreLabel.visible = FALSE;
    totalLabel.visible = FALSE;
    leftScoreLabel.visible = FALSE;
    pauseMenu.enabled = FALSE;
    pauseGameSprite.visible = FALSE;
}

- (id) init {
    
    if ((self = [super init])) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // Place info panel
        infopanel = [CCSprite spriteWithSpriteFrameName:@"infopanel.png"];
        infopanel.anchorPoint = ccp(0, 1);
        infopanel.position = ccp(0, screenSize.height);
        [self addChild:infopanel z:1];
        
        // Place pause menu button
        pauseGameSprite = [CCSprite spriteWithSpriteFrameName:@"button_pause.png"];
        float padding = [pauseGameSprite contentSize].width*0.5 * 0.2; // отступ от края экрана c учетом спец эффекта меню
        [pauseGameSprite setAnchorPoint:ccp(1, 1)];
        [pauseGameSprite setPosition:ccp(screenSize.width, screenSize.height)];
        [pauseGameSprite setOpacity:200];
        [self addChild:pauseGameSprite z:1];
        CCMenuItemSpriteIndependent *pauseGameButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:pauseGameSprite selectedSprite:nil target:self selector:@selector(pausePressed)];
        pauseMenu = [CCMenu menuWithItems:pauseGameButton, nil];
        [self addChild:pauseMenu z:5];
        
        // Init Score Label
        scoreLabel = [CCLabelBMFont labelWithString:@"  " fntFile:@"levelNameText.fnt"];
        scoreLabel.alignment = kCCTextAlignmentRight;
        scoreLabel.anchorPoint = ccp(0, 1);
        scoreLabel.position = ccp(infopanel.contentSize.width * 0.15, screenSize.height - padding);
        originalScale = 0.6;
        scoreLabel.scale = originalScale;
        [self addChild:scoreLabel z:2];
        
        // Init Total Label
        totalLabel = [CCLabelBMFont labelWithString:@"  " fntFile:@"levelNameText.fnt"];
        totalLabel.alignment = kCCTextAlignmentLeft;
        totalLabel.anchorPoint = ccp(0, 1);
        totalLabel.position = ccp(infopanel.contentSize.width * 0.4, screenSize.height - padding);
        totalLabel.scale = originalScale;
        [self addChild:totalLabel z:2];
        
        // Init Left Score label, который показывает сколько осталось не использованных детей и если их меньше чем нужно для завершения уровня становится красным.
        leftScoreLabel = [CCLabelBMFont labelWithString:@"  " fntFile:@"levelNameText.fnt"];
        leftScoreLabel.anchorPoint = ccp(0, 1);
        leftScoreLabel.position = ccp(infopanel.contentSize.width * 0.77, screenSize.height - padding);
        leftScoreLabel.scale = originalScale;
        [self addChild:leftScoreLabel z:2];
        
        // Add Cover for center text, which would be sfx when text appear
        centerLabelSFX = [CCSprite spriteWithSpriteFrameName:@"level_name_sfx.png"];
        centerLabelSFX.position = ccp(screenSize.width*0.5, screenSize.height*0.5);
        centerLabelSFX.visible = NO;
        [self addChild:centerLabelSFX z:1];
        
        // Init Center information label for name of level and other info
        centerLabel = [CCLabelBMFont labelWithString:@"    " fntFile:@"levelNameText.fnt"];
        centerLabel.position = ccp(screenSize.width*0.5 + centerLabel.contentSize.width, screenSize.height*0.5);
        centerLabel.visible = NO;
        [self addChild:centerLabel z:2];
    }
    return self;
}

- (void) updateScore {
    
    [scoreLabel stopAllActions];
    GameManager *gameManager = [GameManager sharedGameManager];
    [gameManager setNeedToUpdateScore:FALSE];
    [scoreLabel setString:[NSString stringWithFormat:@"%i", gameManager.numOfSavedCells]];
    [totalLabel setString:[NSString stringWithFormat:@"%i", gameManager.numOfNeededCells]];
    [leftScoreLabel setString:[NSString stringWithFormat:@"%i", gameManager.numOfTotalCells]];
    
    // Turn Left Score to Red color when мало ячеек для окончания уровня.
    if ((gameManager.numOfTotalCells < (gameManager.numOfNeededCells - gameManager.numOfSavedCells)) && gameManager.numOfSavedCells < gameManager.numOfNeededCells) {
        leftScoreLabel.color = ccc3(0, 255, 255);
    }
    
    // Pop up the score
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.1 scale:originalScale * 1.1];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.1 scale:originalScale];
    CCSequence *sequence = [CCSequence actions:scaleUp, scaleBack, nil];
    [scoreLabel runAction:sequence];
}

- (BOOL)displayText:(NSString *)text
{
    [centerLabel stopAllActions];
    [centerLabel setString:text];
    centerLabel.opacity = 0;
    centerLabel.visible = YES;
    
    [centerLabelSFX stopAllActions];
    centerLabelSFX.opacity = 0;
    centerLabelSFX.visible = YES;
    
    id fadeIn = [CCFadeIn actionWithDuration:0.4];
    id fadeBack = [fadeIn reverse];
    id hide = [CCHide action];
    id delay = [CCDelayTime actionWithDuration:1.5];
    id sfxLabelFadingSeq = [CCSequence actions:fadeIn, delay, fadeBack, hide, nil];
    id textAction = [CCSequence actions:[[fadeIn copy] autorelease] , [[delay copy] autorelease], [[fadeBack copy] autorelease], hide, nil];
    
    [centerLabelSFX runAction:sfxLabelFadingSeq];
    [centerLabel runAction:textAction];
    return TRUE;
}

@end
