//
//  Box2DUILayer.m
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DUILayer.h"

@interface Box2DUILayer()
{
    CCLabelTTF *scoreLabel;
}

@end

@implementation Box2DUILayer

- (id) init {
    
    if ((self = [super init])) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        scoreLabel = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:22];
        scoreLabel.color = ccc3(0, 0, 0);
        scoreLabel.anchorPoint = ccp(0, 1);
        scoreLabel.position = ccp(0, screenSize.height);
        [self addChild:scoreLabel];
    }
    return self;
}

- (void) updateScore:(int)collected need:(int)need {
    
    [scoreLabel stopAllActions];
    [scoreLabel setString:[NSString stringWithFormat:@"%i of %i collected", collected, need]];
    
    // Pop up the score
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:0.2 scale:1.2];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:0.1 scale:1.0];
    CCSequence *sequence = [CCSequence actions:scaleUp, scaleBack, nil];
    [scoreLabel runAction:sequence];
}

@end
