//
//  main.m
//  RunTestsInInstruments
//
//  Created by Jim Dovey on 11-06-27.
//  Copyright 2011 Kobo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RunTestsInInstrumentsAppDelegate.h"

int main(int argc, char *argv[])
{
	int retVal = 0;
	@autoreleasepool {
	    retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([RunTestsInInstrumentsAppDelegate class]));
	}
	return retVal;
}
