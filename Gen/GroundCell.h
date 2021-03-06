//
//  GroundCell.h
//  Gen
//  Зеленая ячейка. Служит элементом оформления уровня. Не наносит урон
//  Created by Andrey Korikov on 10.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "BlockCell.h"

@interface GroundCell : BlockCell

+ (id) groundCellInWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name;

@end
