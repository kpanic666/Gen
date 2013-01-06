//
//  ProcessingLayer.m
//  Gen
//
//  Created by Andrey Korikov on 26.12.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ProcessingLayer.h"

@implementation ProcessingLayer

- (id)initWithColor:(ccColor4B)color
{
    if ((self = [super initWithColor:color]))
    {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        self.isTouchEnabled = YES;
        
        CCSprite *processIcon = [CCSprite spriteWithSpriteFrameName:@"process_icon.png"];
        processIcon.anchorPoint = ccp(0.42, 0.5);
        processIcon.position = ccp(screenSize.width * 0.5, screenSize.height * 0.5);
        [self addChild:processIcon];
        
        float fontSize = 16;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            fontSize *= 2;
        }
        CCLabelTTF *processText = [CCLabelTTF labelWithString:@"Processing..." fontName:@"Tahoma" fontSize:fontSize];
        processText.color = ccc3(147, 224, 255);
        processText.position = ccp(screenSize.width * 0.5, screenSize.height * 0.5 - processIcon.contentSize.height * 0.75);
        [self addChild:processText];
        
        [processIcon runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:360]]];
    }
    return self;
}

#pragma mark Touch Delegates
- (void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:INT_MIN swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

@end
