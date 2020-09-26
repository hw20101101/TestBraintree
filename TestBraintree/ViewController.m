//
//  ViewController.m
//  TestBraintree
//
//  Created by iOS developer on 2020/9/26.
//  Copyright © 2020 test. All rights reserved.
//

#import "ViewController.h"
#import "BraintreePayPal.h"
#import "SVProgressHUD.h"

@interface ViewController ()<BTViewControllerPresentingDelegate>

@property (strong, nonatomic) BTPayPalDriver *payPalDriver;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [button setTitle:@"paypal" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (BTPayPalDriver *)payPalDriver
{
    if (!_payPalDriver) {
        //TODO 替换为自己的 token
        BTAPIClient *braintreeClient = [[BTAPIClient alloc] initWithAuthorization:@"sandbox_pgqxxxzr_473xxxxxxdh"];
        _payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:braintreeClient];
        _payPalDriver.viewControllerPresentingDelegate = self;
    }
    return _payPalDriver;
}

- (void)buttonOnClick
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[UIColor lightGrayColor]];
    [SVProgressHUD show];
    
    NSString *price = @"199";
    NSString *orderNo = @"128xxxxxxxx038";
    BTPayPalRequest *request = [[BTPayPalRequest alloc] initWithAmount:price];
    request.currencyCode = @"USD";
    
    BTPayPalLineItem *item = [[BTPayPalLineItem alloc] initWithQuantity:@"1" unitAmount:price name:@"商品名称" kind:BTPayPalLineItemKindDebit];
    item.productCode = orderNo; //订单编号
    request.lineItems = @[item];

    [self.payPalDriver requestOneTimePayment:request completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
          
        if (tokenizedPayPalAccount) {
            NSLog(@"-->> paypal 支付成功 nonce:%@", tokenizedPayPalAccount.nonce);
            [SVProgressHUD showSuccessWithStatus:@"支付成功"];
            
            //todo 调用后台接口，传递 tokenizedPayPalAccount.nonce
            
        } else if (error) {
            // Handle error here...
            NSLog(@"paypal 支付失败 ：%@", error);
            [SVProgressHUD showErrorWithStatus:@"支付失败"];
            
        } else {
            // Buyer canceled payment approval
            [SVProgressHUD showErrorWithStatus:@"支付取消"];
        }
        
        [SVProgressHUD dismissWithDelay:3];
    }];
}

#pragma mark - BTViewControllerPresentingDelegate
// Required
- (void)paymentDriver:(id)paymentDriver requestsPresentationOfViewController:(UIViewController *)viewController
{
    [SVProgressHUD dismiss];
    [self presentViewController:viewController animated:YES completion:nil];
}

// Required
- (void)paymentDriver:(id)paymentDriver requestsDismissalOfViewController:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:^{
        [SVProgressHUD show];
    }];
}


@end
