//
//  ViewController.m
//  CurrencyConverter
//
//  Created by NAVEEN  on 7/13/13.
//  Copyright (c) 2013 NAVEEN . All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface ViewController ()

@end

@implementation ViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self updateCurrenciesAndExchangeRates];
    }
    return self;
}

- (NSString *)pathForSavedCurrencyData
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"currencies"];
}

- (void)updateCurrenciesAndExchangeRates
{
  
    NSString *yahooCurrencies = @"http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json";
    NSData *currencyData = [NSData dataWithContentsOfURL:[NSURL URLWithString:yahooCurrencies]];
    if (currencyData == nil) {
        currencyData = [NSData dataWithContentsOfFile:[self pathForSavedCurrencyData]];
        if (currencyData == nil) {
        NSString *defaultCurrenciesPath = [[NSBundle mainBundle] pathForResource:@"defaultcurrencies" ofType:@".txt"];
        currencyData = [NSData dataWithContentsOfFile:defaultCurrenciesPath];
        }
    }
    NSError *JSONError;
    NSDictionary *currencyDict = [NSJSONSerialization JSONObjectWithData:currencyData options:0 error:&JSONError];
   
    if (JSONError) {
        NSLog(@"Error parsing data %@", JSONError);
    } else {
        conversionDict = [NSMutableDictionary dictionary];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setAllowsFloats:YES];
        for (NSDictionary *rate in [[currencyDict objectForKey:@"list"] objectForKey:@"resources"]) {
            NSDictionary *current = [[rate objectForKey:@"resource"] objectForKey:@"fields"];
            NSString *foreignCurrency = [[current objectForKey:@"symbol"] stringByReplacingOccurrencesOfString:@"=X"
                                                                                                    withString:@""];
            NSNumber *foreignRate = [formatter numberFromString:[current objectForKey:@"price"]];
            [conversionDict setObject:foreignRate forKey:foreignCurrency];
        }
        formatter = nil;
        currencies = [[conversionDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        [currencyData writeToFile:[self pathForSavedCurrencyData] atomically:NO];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _pickerView.backgroundColor=[UIColor whiteColor];
    _outputAmount.clipsToBounds = YES;
    _outputAmount.layer.cornerRadius = 8;
	// Do any additional setup after loading the view, typically from a nib.
    [_inputText addTarget:self action:@selector(textFieldDidChange:)
     forControlEvents:UIControlEventEditingChanged];
    [self currencyConversionShouldChangeForRowInPickerView:0];
   // float defaultValue;
   // [self makeINRdefault];
  //  defaultValue=(float)600/[self makeINRdefault];
  //  _inputText.text=[NSString stringWithFormat:@"%f",defaultValue];
    [self DisplayCurrentLocationCode];
}
-(float )makeINRdefault
{
    _inputText.text=[NSString stringWithFormat:@"%d",1];
    float conversion;
    NSString *currencyCode = @"INR";
    for(int i=0;i<[currencies count];i++)
    {
        if([[currencies objectAtIndex:i] isEqualToString:currencyCode])
        {
            if (currencies == nil) {
                _outputAmount.text = @"Error";
                break;
            }
           
            float amt;
            if ([[_inputText text] isEqualToString:@""]) {
               
                amt = 0;
            } else {
                amt = [[_inputText text] floatValue];
            }
           
            NSNumber *conversionRate = [conversionDict objectForKey:[currencies objectAtIndex:i]];
            
           conversion = amt * [conversionRate floatValue];
            
        }
    }
   
    return conversion;

}

-(void)DisplayCurrentLocationCode
{
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *currencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
    for(int i=0;i<[currencies count];i++)
    {
        if([[currencies objectAtIndex:i] isEqualToString:currencyCode])
        {
            [self currencyConversionShouldChangeForRowInPickerView:i];

        }
    }
}
- (void)currencyConversionShouldChangeForRowInPickerView:(NSInteger)row
{
  
    if (currencies == nil) {
        _outputAmount.text = @"Please check your internet connection.";
        return;
    }
    float amt;
    if ([[_inputText text] isEqualToString:@""]) {
      
        amt = 0;
    } else {
        amt = [[_inputText text] floatValue];
    }
    NSNumber *conversionRate = [conversionDict objectForKey:[currencies objectAtIndex:row]];
    float conversion = amt * [conversionRate floatValue];
    NSString *amountString = [NSString stringWithFormat:@"%.2f", conversion];
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *currencySymbol = [theLocale objectForKey:NSLocaleCurrencySymbol];
    //NSString *displayString = [currencySymbol stringByAppendingFormat:@"  %@",amountString];
    NSString *displayString = [amountString stringByAppendingFormat:@" %@", [currencies objectAtIndex:row]];
    _outputAmount.text = displayString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [currencies count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [currencies objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self currencyConversionShouldChangeForRowInPickerView:row];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_inputText resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSInteger currentRowInPickerView = [_pickerView selectedRowInComponent:0];
    [self currencyConversionShouldChangeForRowInPickerView:currentRowInPickerView];
}
@end
