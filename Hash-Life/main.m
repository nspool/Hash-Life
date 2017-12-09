//
//  main.m
//  Hash-Life
//
//  Copyright © 2017 nspool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeUniverse.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {

    id univ = [TreeUniverse new];
  
    [univ setBit:1 :2];
//    [univ setBit:2 :1];
//    [univ setBit:0 :0];
//    [univ setBit:1 :0];
//    [univ setBit:2 :0];
//    [univ setBit:3 :0];

  for(int i=0;i<3;i++){
      [univ stats];
      [univ runStep];
    }
  }
    return 0;
}
