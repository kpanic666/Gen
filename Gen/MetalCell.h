//
//  MetalCell.h
//  Gen
//
//  Created by Andrey Korikov on 19.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Block.h"

@interface MetalCell : Block

+ (id) metalCellInWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name;

@end
