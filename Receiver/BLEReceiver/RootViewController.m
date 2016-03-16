//
//  RootViewController.m
//  BLEReceiver
//
//  Created by Peter Brock on 08/03/2016.
//  Copyright © 2016 Atos. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "RootViewController.h"

@interface RootViewController ()

@property (strong, nonatomic) BeaconLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIView *viewKitchen;
@property (weak, nonatomic) IBOutlet UIView *viewReception;
@property (weak, nonatomic) IBOutlet UIView *viewDesk;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelScanning;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconDetails;

@end

@implementation RootViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[BeaconLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager initialiseLocationManager];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [_locationManager startMonitoring];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [_locationManager stopMonitoring];
}

- (NSString*)stringFromBeacon:(CLBeacon*)beacon {
    
    NSString *string = [NSString stringWithFormat:@"RSSI = %ld \nAccuracy = %.3fm \n", (long)beacon.rssi, beacon.accuracy];
    
    NSString *proximity;
    switch (beacon.proximity) {
        case CLProximityUnknown:
            proximity = @"CLProximityUnknown";
            break;
        case CLProximityFar:
            proximity = @"CLProximityFar";
            break;
        case CLProximityImmediate:
            proximity = @"CLProximityImmediate";
            break;
        case CLProximityNear:
            proximity = @"CLProximityNear";
            break;
    }
    
    string = [string stringByAppendingString:proximity];
    
    return string;
}

- (void)speak:(NSString*)speech {
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speech];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
    
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
}

#pragma mark BeaconLocationManagerDelegate

- (void)beaconManagerAuthorisationToContinue {
    
    [_locationManager startMonitoring];
}

- (void)beaconManagerAuthorisationError {
    NSLog(@"Beacon Manager didn't manage to authorise, won't work!");
}

- (void)beaconManagerStartedMonitoring {
    [_labelScanning setHidden:NO];
}

- (void)beaconManagerStoppedMonitoring {
    [_labelScanning setHidden:YES];
    [self beaconManagerDetectedNoBeacons];
}

- (void)beaconManagerDetectedNoBeacons {
    
    [_labelBeaconDetails setHidden:YES];
    [_labelStatus setHidden:YES];
    
    [_viewKitchen setHidden:YES];
    [_viewReception setHidden:YES];
    [_viewDesk setHidden:YES];
    
    [self speak:@"You have now left the area!"];
}

- (void)beaconManagerDetectedLocation:(BeaconLocation)currentLocation fromBeacon:(CLBeacon*)beacon {
    
    [_labelStatus setHidden:NO];
    [_labelBeaconDetails setHidden:NO];
    
    _labelBeaconDetails.text = [self stringFromBeacon:beacon];
    
    NSString *speech;
    
    switch (currentLocation) {
        case BeaconLocationKitchen:
            [_viewKitchen setHidden:NO];
            [_viewReception setHidden:YES];
            [_viewDesk setHidden:YES];
            speech = @"You Are Now In The Kitchen";
            break;
        case BeaconLocationReception:
            [_viewKitchen setHidden:YES];
            [_viewReception setHidden:NO];
            [_viewDesk setHidden:YES];
            speech = @"You Are Now In The Reception";
            break;
        case BeaconLocationDesk:
            [_viewKitchen setHidden:YES];
            [_viewReception setHidden:YES];
            [_viewDesk setHidden:NO];
            speech = @"You Are Now At Our Desks";
            break;
        case BeaconLocationNone:
        default:
            speech = @"You're Lost!";
            break;
    }
    
    [self speak:speech];
    
}

- (void)beaconManagerUpdatedLocation:(BeaconLocation)currentLocation fromBeacon:(CLBeacon*)beacon {
    
    _labelBeaconDetails.text = [self stringFromBeacon:beacon];
}


@end
