//
//  TreeUniverse.h
//  HashLife
//
//  Copyright © 2017 nspool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeNode.h"

@interface TreeUniverse : NSObject

@property TreeNode* root;

-(void) stats;
-(void) runStep;
-(void)setBit:(int)x :(int)y;

@end
