//
//  ParentTableViewController.h
//  NavController Core Data Version
//
//  Created by Aditya Narayan on 9/23/14.
//  Copyright (c) 2014 NM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAO.h"
#import "ChildTableViewController.h"
#import "TerrysNetworkManager.h"
#import "TerrysReachabilityManager.h"
#import "DatabaseCustomManager.h"

@class TerrysNetworkManager;
@class TerrysReachabilityManager;
@class DAO;
@class DatabaseCustomManager;

@interface ParentTableViewController :UITableViewController

@property CompanyPresentationLayer *selectedCompany;
@property (strong, nonatomic) DAO *dao;
@property (strong, nonatomic) DatabaseCustomManager *terrysDatabaseCustomManager;

@property (strong, nonatomic) TerrysNetworkManager *terrysNetworkManager;
@property (strong, nonatomic) TerrysReachabilityManager *terrysReachabilityManager;

@end
