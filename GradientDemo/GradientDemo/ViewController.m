//
//  ViewController.m
//  GradientDemo
//
//  Created by luqiang/00465337 on 2019/11/2.
//  Copyright © 2019年 frank. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *tableViewData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self loadSubviews];
}

- (void)loadSubviews {
    // setup data
    NSMutableArray *tableViewData = [NSMutableArray new];
    for (NSInteger i =0; i<100; i++) {
        tableViewData[i] = @(i);
    }
    self.tableViewData = [tableViewData copy];
    
    // load views
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = self.view.bounds;
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    
    self.tableView = tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = NSStringFromClass([self class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.tableViewData[indexPath.row]];

    UIColor *color1 = [UIColor colorWithRed:arc4random()%100/100.f green:arc4random()%100/100.f blue:arc4random()%100/100.f alpha:1];
    UIColor *color2 = [UIColor colorWithRed:arc4random()%100/100.f green:arc4random()%100/100.f blue:arc4random()%100/100.f alpha:1];
    NSArray *colors = @[(id)color1.CGColor,(id)color2.CGColor];
    // 蒙层实现渐变
    CAGradientLayer *layer = [self getGradientLayer:CGRectMake(100, 0, 40, 40) colors:colors];
    [cell.layer addSublayer:layer];
    
    // drawRect 实现渐变
    UIImage *gradientImage = [self getGradientImage:CGSizeMake(40, 40) colors:colors];
    cell.imageView.image = gradientImage;
    return cell;
}

- (CAGradientLayer *)getGradientLayer:(CGRect)frame colors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    gradientLayer.colors = colors;
    gradientLayer.startPoint = CGPointMake(0.5, 0.5);
    gradientLayer.endPoint = CGPointMake(0.5, 1.0);
    gradientLayer.mask = [CALayer layer];
    gradientLayer.mask.frame = gradientLayer.bounds;
    
    gradientLayer.mask.contents = (__bridge id _Nullable)([UIImage imageNamed:@"Thumbs"].CGImage);
    
    return gradientLayer;
}

- (UIImage *)getGradientImage:(CGSize)size colors:(NSArray *)colors {
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextScaleCTM(context, size.width, size.height);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, NULL);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.5, 0.5), CGPointMake(0.5, 1), kCGGradientDrawsBeforeStartLocation);
    
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *thumbsImage = [UIImage imageNamed:@"Thumbs"];
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [gradientImage drawInRect:frame];
    [thumbsImage drawInRect:frame blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return image;
}


@end
