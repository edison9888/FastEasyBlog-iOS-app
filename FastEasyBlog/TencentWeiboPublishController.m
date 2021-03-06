//
//  TencentWeiboPublishController.m
//  FastEasyBlog
//
//  Created by yanghua_kobe on 9/28/12.
//  Copyright (c) 2012 yanghua_kobe. All rights reserved.
//

#import "TencentWeiboPublishController.h"
#import "TencentWeiboManager.h"
#import "PhotoPickerController.h"
#import "MapKitDragAndDropViewController.h"
#import "FollowedListController.h"
#import "TencentWeiboPublishOperation.h"

@interface TencentWeiboPublishController ()

@property (nonatomic,retain) PhotoPickerController *photoPicker;

@end

@implementation TencentWeiboPublishController


- (void)dealloc{
    [_photoPicker release],_photoPicker=nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil platform:TencentWeibo];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
	super.delegate=self;
    [super viewDidLoad];
	self.navigationItem.title=@"发表腾讯微博";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - PublishBaseControllerDelegate -
- (void)photoBtn_handle:(id)sender{
    if (!_photoPicker) {
        _photoPicker = [[PhotoPickerController alloc] initWithDelegate:self];
    }
    [self.photoPicker showWithPhotoLibrary];
}

- (void)cameraBtn_handle:(id)sender{
	if (!_photoPicker) {
        _photoPicker = [[PhotoPickerController alloc] initWithDelegate:self];
    }
    [self.photoPicker showWithCamera];
}

- (void)lbsPositionBtn_handle:(id)sender{
	[self.navigationController pushViewController:[[[MapKitDragAndDropViewController alloc]initWithNibName:@"MapKitDragAndDropViewController" bundle:nil]autorelease] animated:YES];
}

- (void)atBtn_handle:(id)sender{
	FollowedListController *followedListCtrller=[[FollowedListController alloc]initWithNibName:@"FollowedListView" bundle:nil platform:self.currentPlatform];
    followedListCtrller.delegate=self;
    
    UINavigationController *followedListNavCtrller=[[UINavigationController alloc]initWithRootViewController:followedListCtrller];
    [followedListCtrller release];
    
    [self presentModalViewController:followedListNavCtrller animated:YES];
    [followedListNavCtrller release];
}

- (void)topicBtn_handle:(id)sender{
	self.publishTxtView.text=[NSString stringWithFormat:@"%@ ## ",self.publishTxtView.text];
    NSRange selectedLoc=NSMakeRange([self.publishTxtView.text length]-2, 0);
    self.publishTxtView.selectedRange=selectedLoc;
}


- (void)publishBtn_handle:(id)sender{
    NSString *txt=self.publishTxtView.text;
    PublishOperation *publishOperation=[[[TencentWeiboPublishOperation alloc]initWithOperateParams:txt]autorelease];
    
    [((FastEasyBlogAppDelegate*)appDelegateObj).operationQueue addOperation:publishOperation];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - FollowedListDelegate -
- (void)didSelectedFollowed:(Followed *)aFollowed{
    [self.followedList addObject:aFollowed];
    self.publishTxtView.text=[NSString stringWithFormat:@"%@ @%@ ",self.publishTxtView.text,aFollowed.userId];
}

@end
