//
//  ChildCell.h
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@interface ChildCell : Box2DSprite
{
    GameCharacter *exitCellSprite;
    NSString *_foodTextureName;
}

- (void)removeCellSprite;

@property (readwrite, assign) NSString *foodTextureName;
@property BOOL dontCount;
@property BOOL spActive;            // TRUE - когда активна суперсила, FALSE - когда суперсилы нет.

@end
