//
//  GalaryHelper.m
//  Galary
//
//  Created by joshuali on 16/6/24.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "GalaryHelper.h"
#import "GalaryRootTableViewController.h"
#import "GalaryGridViewController.h"
#import "GalaryPagingViewController.h"

@interface PortraitNavViewController : UINavigationController

@end

@implementation PortraitNavViewController

- (BOOL)shouldAutorotate{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end

@interface GalaryHelper ()
@property (nonatomic, weak) UINavigationController * curNav;
@end

@implementation GalaryHelper

+ (instancetype) sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (void) presentGalary : (UIViewController *) viewController withIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete withCustomPicker : (NSArray<UIImage*>*) customPickers withCustomPickerHandler : (void (^)(NSUInteger index)) customPickerHandler maxCount : (NSUInteger) maxCount
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"Authorized");
            dispatch_async(dispatch_get_main_queue(), ^{
                PortraitNavViewController * nav = [[PortraitNavViewController alloc] init];
                [nav setViewControllers:@[[[GalaryRootTableViewController alloc] initWithIncrementalCount:incrementalCount withPickComplete:pickComplete withCustomPicker:customPickers withCustomPickerHandler:customPickerHandler maxCount:maxCount], [[GalaryGridViewController alloc]  initWithIncrementalCount:incrementalCount withPickComplete:pickComplete withCustomPicker:customPickers withCustomPickerHandler:customPickerHandler maxCount:maxCount]]];
                [viewController presentViewController:nav animated:YES completion:nil];
                self.curNav = nav;
            });
        }else{
            NSLog(@"Denied or Restricted");
        }
    }];
}

- (void) presentPagingGalary : (UIViewController *) viewController withIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete withAssets : (NSArray<PHAsset*>*) assets index : (NSInteger) index
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"Authorized");
            dispatch_async(dispatch_get_main_queue(), ^{
                GalaryPagingViewController * galaryPaging = [[GalaryPagingViewController alloc] initWithIncrementalCount:incrementalCount withPickComplete:pickComplete maxCount:assets.count];
                galaryPaging.assets = assets;
                galaryPaging.index = index;
                NSMutableArray * checkedImgs = [NSMutableArray new];
                for(int i = 0 ; i < assets.count; i ++){
                    [checkedImgs addObject:[NSNumber numberWithInt:i]];
                }
                galaryPaging.checkedImgs = checkedImgs;
                PortraitNavViewController * nav = [[PortraitNavViewController alloc] initWithRootViewController:galaryPaging];
                [viewController presentViewController:nav animated:YES completion:nil];
            });
        }else{
            NSLog(@"Denied or Restricted");
        }
    }];
}

- (void) dismiss
{
    [self.curNav dismissViewControllerAnimated:YES completion:nil];
}

- (UINavigationController *) getCurNav
{
    return _curNav;
}

+ (NSString *) convertAlbumName : (NSString *) name
{
    if(name){
        if([name isEqualToString:@"Recently Added"]){
            return @"最近添加";
        }else if([name isEqualToString:@"Screenshots"]){
            return @"屏幕快照";
        }else if([name isEqualToString:@"All Photos"]){
            return @"全部照片";
        }
    }
    return name;
}

@end
