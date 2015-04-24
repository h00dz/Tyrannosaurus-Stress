//
//  main.m
//  Tyrannosaurus Stress
//
//  Created by Adam Schrader on 4/23/15.
//  Copyright (c) 2015 Random Nest. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
