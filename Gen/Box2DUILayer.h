//
//  Box2DUILayer.h
//  Gen
//
//  Created by Andrey Korikov on 23.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "cocos2d.h"

@interface Box2DUILayer : CCLayer

- (void) updateScore:(int)collected need:(int)need;

@end
