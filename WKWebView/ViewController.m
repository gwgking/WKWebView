//
//  ViewController.m
//  WKWebView
//
//  Created by guyun on 14-7-10.
//  Copyright (c) 2014年 guyun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) WKWebView  *webView;
@property (nonatomic, strong) WKUserContentController *userContentController;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView{
    [super loadView];
    
    //create user script
    NSString *myScriptSource = @"document.body.style.backgroundColor = '#00F' ";
    
    WKUserScript *myUserScript = [[WKUserScript alloc]
                                  initWithSource:myScriptSource
                                  injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                  forMainFrameOnly:YES];
    
    _userContentController = [[WKUserContentController alloc]init];
    [_userContentController addUserScript:myUserScript];
    
    
    //create sript message handler
    [_userContentController addScriptMessageHandler:self name:@"myName"];
    
    
    //set configuration
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = _userContentController;
    
    WKPreferences *prefernce = [[WKPreferences alloc] init];
    prefernce.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences =  prefernce;
    
    //create webview
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0,
                                                           self.view.bounds.size.width,
                                                           self.view.bounds.size.height)
                                  configuration:configuration];
    
    _webView.navigationDelegate = self;
    
    
    //send request
    NSURL *URL = [NSURL URLWithString:@"http://www.taobao.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [_webView loadRequest:request];
                                                           

    [self.view addSubview:_webView];
    
    
}


// customize the loading
- (void)timerFireMethod:(NSTimer*)theTimer
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    
}

- (void) webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    //add your custom loading...
    
    NSString *url = [navigationAction.request.URL absoluteString];
    
    //加载首页时，自定义page loading
    if(![url compare:@"http://www.taobao.com/"])
    {
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"开始加载了，我用力，我用力！" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
    
        //加载太快，所以用timer延迟提醒框的消失
        [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:alert
                                    repeats:NO];
    
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        
        NSString *myScriptSource = @"var message = { 'from' : 'hello wwdc2014' }; window.webkit.messageHandlers.myName.postMessage(message);";
        
        [_webView evaluateJavaScript:myScriptSource completionHandler:nil];
        
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}



- (void) webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    //add your custom loading...
    //可以在这里消除loading提示。。。
    
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}


-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSLog(@"Message: %@", message.body);
    NSString * mesText = [NSString stringWithFormat:@"不好意思，你被禁足了哦:\r\n %@ ",message.body];
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:mesText delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alert show];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:alert
                                    repeats:NO];
}


@end
