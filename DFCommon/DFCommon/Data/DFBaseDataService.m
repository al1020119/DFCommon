//
//  HCBaseDataService.m
//  Heacha
//
//  Created by Allen Zhong on 15/1/12.
//  Copyright (c) 2015年 Datafans Inc. All rights reserved.
//

#import "DFBaseDataService.h"
#import "DFReachabilityUtil.h"

@implementation DFBaseDataService

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [[AFHTTPRequestOperationManager alloc] init];
        _manager.requestSerializer.timeoutInterval = NetworkTimeoutInterval;
        _requestType = DFRequestTypeGet;
        _params = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - Method

-(void) execute
{
    //网络不可用
    if (![DFReachabilityUtil isNetworkAvailable]) {
        
        NSError *error = [NSError errorWithDomain:CustomErrorDomain code:CustomErrorConnectFailed userInfo:nil];
        [self onError:error];
        return;
    }
    
    NSLog(@"path: %@  params: %@", [self getRequestUrl], [self getRequestParameters]);
    
    switch (_requestType) {
        case DFRequestTypeGet:
        {
            [_manager GET:[self getRequestUrl] parameters:[self getRequestParameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self onSuccess:responseObject];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self onError:error];
            }];
            break;
        }
            
        case DFRequestTypePost:
        {
            
            break;
        }
        case DFRequestTypePostMultipart:
        {
            
            break;
        }
        default:
            break;
    }
    
    
}

-(NSString *) getRequestUrl
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[self getRequestDomain],[self getRequestPath]];
    return  url;
}

-(NSString *) getRequestDomain
{
    return @"";
}

-(NSString *) getRequestPath
{
    return @"";
}

-(NSMutableDictionary *) getRequestParameters
{
    [self setRequestParams:_params];
    return _params;
}

-(void) setRequestParams:(NSMutableDictionary *)params
{
    
}

-(void) onSuccess:(id)result
{
    
    if (result) {
        DFBaseResponse *response =  [[DFBaseResponse alloc] initWithData:result];
        
        if (response.status == 1) {
            
            [self parseResponse:response];
            
            if (_delegate && [_delegate conformsToProtocol:@protocol(DFDataServiceDelegate)] && [_delegate respondsToSelector:@selector(onStatusOk:classType:)]) {
                [_delegate onStatusOk:response classType:[self class]];
            }
        }else{
            if (_delegate && [_delegate conformsToProtocol:@protocol(DFDataServiceDelegate)] && [_delegate respondsToSelector:@selector(onStatusError:)]) {
                
                if (response.errorMsg == nil) {
                    response.errorMsg = @"出错啦!";
                }
                
                [_delegate onStatusError:response];
            }
        }
    }
    
}

-(void) onError:(NSError *)error
{
    if (_delegate && [_delegate conformsToProtocol:@protocol(DFDataServiceDelegate)] && [_delegate respondsToSelector:@selector(onRequestError:)]) {
        [_delegate onRequestError:error];
    }
    
    
}

-(void) parseResponse:(DFBaseResponse *)response
{
}

@end