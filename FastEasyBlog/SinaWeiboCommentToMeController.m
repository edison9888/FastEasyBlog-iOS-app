//
//  SinaWeiboCommentToMeController.m
//  FastEasyBlog
//
//  Created by yanghua_kobe on 10/4/12.
//  Copyright (c) 2012 yanghua_kobe. All rights reserved.
//

#import "SinaWeiboCommentToMeController.h"

@interface SinaWeiboCommentToMeController ()

- (void)loadDataSource;

@end

@implementation SinaWeiboCommentToMeController

- (void)dealloc{
    [super dealloc];
}

- (id)initWithRefreshHeaderViewEnabled:(BOOL)enableRefreshHeaderView
          andLoadMoreFooterViewEnabled:(BOOL)enableLoadMoreFooterView{
    self=[super initWithRefreshHeaderViewEnabled:enableRefreshHeaderView andLoadMoreFooterViewEnabled:enableLoadMoreFooterView];
    if (self) {
        self.engine.delegate=self;
    }
    
    return self;
}

- (id)initWithRefreshHeaderViewEnabled:(BOOL)enableRefreshHeaderView
          andLoadMoreFooterViewEnabled:(BOOL)enableLoadMoreFooterView
                     andTableViewFrame:(CGRect)frame{
    self=[self initWithRefreshHeaderViewEnabled:enableRefreshHeaderView
                   andLoadMoreFooterViewEnabled:enableLoadMoreFooterView];
    if (self) {
        self.tableViewFrame=frame;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	super.bindCheckHandleDelegate=self;
    [self initBlocks];
    [self.tableView reloadData];
    self.tableView.hidden=YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)loadDataSource{
    [super loadDataSource];
    
	NSMutableDictionary *requestParams=[[NSMutableDictionary alloc]init];
    switch (self.loadtype) {
        case firstLoad:             
            [requestParams setObject:[NSString stringWithFormat:@"%d",self.count] 
                              forKey:@"count"];
            [requestParams setObject:[NSString stringWithFormat:@"%d",self.page] 
                              forKey:@"page"];
            break;
            
        case refresh:             
            [requestParams setObject:self.since_id forKey:@"since_id"];
            [requestParams setObject:[NSString stringWithFormat:@"%d",self.count] 
                              forKey:@"count"];
            [requestParams setObject:[NSString stringWithFormat:@"%d",self.page] 
                              forKey:@"page"];
            break;
            
        case loadMore:             
            [requestParams setObject:self.max_id forKey:@"max_id"];
            [requestParams setObject:[NSString stringWithFormat:@"%d",self.count] 
                              forKey:@"count"];
            [requestParams setObject:[NSString stringWithFormat:@"%d",self.page] 
                              forKey:@"page"];
            break;
    }
    
    [self.engine loadRequestWithMethodName:@"comments/to_me.json"
                           httpMethod:@"GET"
                               params:requestParams
                         postDataType:kWBRequestPostDataTypeNone
                     httpHeaderFields:nil];
    
    [requestParams release];
    
    [GlobalInstance showHUD:@"微博数据加载中,请稍后..." andView:self.view andHUD:self.hud];
	
	self.imageDownloadsInProgress=[NSMutableDictionary dictionary];
}

#pragma mark - WBEngineDelegate Methods
- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        
        switch (self.loadtype) {
            case firstLoad:             
                self.dataSource=[SinaWeiboManager resolveCommentToMeWeiboDataToArray:[dict objectForKey:@"comments"]];
                break;
                
            case refresh:				
            {        			
                NSMutableArray *newList=[[[NSMutableArray alloc]initWithArray:[SinaWeiboManager resolveCommentToMeWeiboDataToArray:[dict objectForKey:@"comments"]] copyItems:NO]autorelease];
                if ([newList count]!=0) {
                    [newList addObjectsFromArray:self.dataSource];
                    self.dataSource=newList;
                }
            }
                break;
                
            case loadMore:            
            {
                NSMutableArray *newList=[[[NSMutableArray alloc]initWithArray:self.dataSource copyItems:NO]autorelease];
                NSMutableArray *tmpArr=[SinaWeiboManager resolveCommentToMeWeiboDataToArray:[dict objectForKey:@"comments"]];
                if ([tmpArr count]!=0) {
                    [newList addObjectsFromArray:tmpArr];
                    self.dataSource=newList;
                }
            }
                break;
                
            default:
                break;
        }
        
        self.tableView.hidden=NO;
        [self.tableView reloadData];
        
        [GlobalInstance hideHUD:self.hud];
    }
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    [GlobalInstance hideHUD:self.hud];
    [GlobalInstance showMessageBoxWithMessage:@"获取数据失败"];
}

- (void)engineAuthorizeExpired:(WBEngine *)engine{
    [GlobalInstance hideHUD:self.hud];
}

- (void)engineNotAuthorized:(WBEngine *)engine{
    [GlobalInstance hideHUD:self.hud];
}

#pragma mark - Bind check notification handle -
- (void)handleBindNotification:(BOOL)isBound{
    if (isBound) {
        if (self.dataSource==nil) {
            [self loadDataSource];
        }
    }else {
        self.tableView.hidden=YES;
        self.dataSource=nil;
    }
}

#pragma mark - override super's method -
- (void)initBlocks{
    [super initBlocks];
    
    __block SinaWeiboCommentToMeController *blockedSelf=self;
    
    //load more
    self.loadMoreDataSourceFunc=^{
        blockedSelf.loadtype=loadMore;
        blockedSelf.page+=1;
        [blockedSelf loadDataSource];
        blockedSelf.isLoadingMore=YES;
    };
    
    //refresh
    self.refreshDataSourceFunc=^{
        blockedSelf.loadtype=refresh;
        [blockedSelf loadDataSource];
        blockedSelf.isRefreshing=YES;
    };
    
}

@end
