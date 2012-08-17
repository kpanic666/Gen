//
//  BubbleCell.h
//  Gen
//  Воздушный пузырь. В спокойном состоянии находится на уровне неподвижно, как только в него попадает один из ChildCell - начинает
//  всплывать и тянет за собой вверх все, что попало в пузырь. Чтобы остановить движение, нужно коснуться пузыря
//  Created by Andrey Korikov on 14.08.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DSprite.h"

@interface BubbleCell : Box2DSprite
{
    BOOL _wasUsed;
}

@property (nonatomic) BOOL wasUsed;

@end
