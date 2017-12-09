//
//  TreeUniverse.m
//  HashLife
//
//  Copyright © 2017 nspool. All rights reserved.
//

#import "TreeUniverse.h"

@implementation TreeUniverse

int generationCount = 0;
@synthesize root;

-(id)init {
  self = [super init];
  if(self){
    root = [TreeNode createRoot];
  }
  return self;
}

-(void)stats {
  NSLog(@"%d ] gen %d pop %d", root.level, generationCount, [root population]);
}

-(void)runStep {
  while (root.level < 3 ||
         root.nw.population != root.nw.se.se.population ||
         root.ne.population != root.ne.sw.sw.population ||
         root.sw.population != root.sw.ne.ne.population ||
         root.se.population != root.se.nw.nw.population) {
    root = [root expandUniverse];
  }
  root = [root nextGeneration];
  generationCount++ ;
}

-(void)setBit:(int)x :(int)y {
//  NSLog(@"setBit %d %d %d", x, y, (1 << (root.level - 1)));
  while (true) {
    int maxCoordinate = pow(2,root.level - 1);
    if (-maxCoordinate <= x && x <= maxCoordinate-1 &&
        -maxCoordinate <= y && y <= maxCoordinate-1)
      break;
    root = [root expandUniverse];
  }
  root = [root setBitAtX:x Y:y];
}

@end
