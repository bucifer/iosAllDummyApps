//
//  DAOManager.m
//  NavController Core Data Version
//
//  Created by Aditya Narayan on 10/10/14.
//  Copyright (c) 2014 NM. All rights reserved.
//

#import "DatabaseCustomManager.h"

@implementation DatabaseCustomManager


- (void) startUpDatabaseLaunchLogic {
    
    [self setDatabaseChoice:CoreData]; //set to Core Data or SQLite Here
    
    if (self.databaseChoice  == CoreData) {
        NSLog(@"Running Core Data version of your app");

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if([userDefaults boolForKey:@"notFirstLaunch"] == false)
        {
            NSLog(@"this is first time you are running the app - create CD Data");
            self.parentTableViewController.dao = [[DAO alloc] coreDataInitFirstTime];
            [self.parentTableViewController.dao saveChanges];
            self.parentTableViewController.dao.databaseManager = self;

            //after first launch, you set this NSDefaults key so that for consequent launches, this block never gets run
            [userDefaults setBool:YES forKey:@"notFirstLaunch"];
            [userDefaults synchronize];
            
        }
        else {
            //if it's not the first time you are running the app, you fetch from Core Data and set your presentation layer;
            NSLog(@"not the first time you are running the app - fetching CD data");
            self.parentTableViewController.dao = [[DAO alloc]init];
            self.parentTableViewController.dao.databaseManager = self;
            [self.parentTableViewController.dao fetchFromCoreDataAndSetYourPresentationLayerData];
            [self.parentTableViewController.tableView reloadData];
        }
    }
    else if (self.databaseChoice == SQLite) {
        NSLog(@"Running SQLite version of your app");
        self.parentTableViewController.dao = [[DAO alloc]init];
        self.parentTableViewController.dao.databaseManager = self;
        [self copyOrOpenSQLiteDB];
    }
    
}





#pragma mark SQLite

-(void)copyOrOpenSQLiteDB
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    dbPathString = [docPath stringByAppendingPathComponent:@"terry.sqlite3"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:dbPathString]) {
        //if we don't find something at the datapath, we copy one from the desktop.
        NSLog(@"we couldn't find a database at your dbPathstring so we are going to copy from desktop");
        NSError *copyError;
        NSString *desktopDBPath = @"/Users/adityanarayan/Desktop/terry.sqlite3";
        BOOL readFromDesktopSuccess = [fileManager fileExistsAtPath:desktopDBPath];
        if (readFromDesktopSuccess) {
            BOOL copySuccess;
            copySuccess = [fileManager copyItemAtPath:desktopDBPath toPath:dbPathString error:&copyError];
            NSLog(@"Copied database from desktop to internal device location!");
            [self readCompanyFromSQLDatabase];
            [self readProductsFromSQLDatabase];
            if (!copySuccess) NSAssert1(0, @"Failed with message '%@'.", [copyError localizedDescription]);
        }
        else {
            NSLog(@"Failed to locate desktop database");
        }
    }
    else {
        //But if we do find something already existing, then we just open it
        NSLog(@"We found an existing db file at your dbPathString so reading from internal device data");
        [self readCompanyFromSQLDatabase];
        [self readProductsFromSQLDatabase];
    }
}


- (void) readCompanyFromSQLDatabase {
    
    //we read from SQLite AND convert them into Presentation Layer Companies and stuff them into the dao.companies array
    
    NSMutableArray *fetchedArray = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement = NULL;
    if (sqlite3_open([dbPathString UTF8String], &navctrlDB)==SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM COMPANY"];
        const char *query_sql = [querySQL UTF8String];
        if (sqlite3_prepare(navctrlDB, query_sql, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                NSString *name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *image = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *stockSymbol = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                CompanySQLite *company = [[CompanySQLite alloc]init];
                company.name = name;
                company.image = image;
                company.stockSymbol = stockSymbol;
                company.products = [[NSMutableArray alloc] init];
                [fetchedArray addObject:company];
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(navctrlDB);
    NSLog(@"We read from the Company Table SQLite");
    
    self.parentTableViewController.dao.companies =     [self convertSQLiteCompaniesInArrayToPresentationLayerCompanies:fetchedArray];
}


- (void) readProductsFromSQLDatabase {

    NSMutableArray *fetchedArray = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement = NULL;
    if (sqlite3_open([dbPathString UTF8String], &navctrlDB)==SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM PRODUCT"];
        const char *query_sql = [querySQL UTF8String];
        if (sqlite3_prepare(navctrlDB, query_sql, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                NSNumber *unique_id = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, 0)];
                NSString *name = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *image = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                NSString *url = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                NSString* company = [[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];

                
                ProductSQLite *product = [[ProductSQLite alloc]init];
                product.unique_id = unique_id;
                product.name = name;
                product.image = image;
                product.url = url;
                product.company = company;

                [fetchedArray addObject:product];
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(navctrlDB);
    NSLog(@"We read from the Product Table");
    
    //Then we convert to presentation Layer
    
    self.parentTableViewController.dao.products =  [self convertSQLiteProductsInArrayToPresentationLayerProducts:fetchedArray];
}

-(void)deleteDataFromSQLite:(NSString *)deleteQuery {
    sqlite3_stmt *statement ;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    dbPathString = [docPath stringByAppendingPathComponent:@"terry.sqlite3"];
    const char *dbPath = [dbPathString UTF8String];
    if (sqlite3_open(dbPath, &navctrlDB)==SQLITE_OK) {
        if (sqlite3_prepare_v2(navctrlDB, [deleteQuery UTF8String], -1, &statement, NULL)==SQLITE_OK) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete" message:@"Product Deleted" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
            if (sqlite3_step(statement) == SQLITE_DONE) {
                //NSLog(@"Sqlite3 step done");
            }
        }
        else {
            NSLog(@"Database Error Message : %s", sqlite3_errmsg(navctrlDB));
        }
        sqlite3_finalize(statement);
        sqlite3_close(navctrlDB);
    }
}




#pragma mark convert-methods from SQLite/Core to Presentation

- (NSMutableArray *) convertSQLiteCompaniesInArrayToPresentationLayerCompanies: (NSMutableArray *)unconvertedArray{
    
    NSMutableArray *convertedResultArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i < unconvertedArray.count; i++) {
        CompanySQLite *selectedCompany = unconvertedArray[i];
        CompanyPresentationLayer *companyPresentationLayer = [[CompanyPresentationLayer alloc]init];
        companyPresentationLayer.name = selectedCompany.name;
        companyPresentationLayer.image = selectedCompany.image;
        companyPresentationLayer.stockSymbol = selectedCompany.stockSymbol;
        [convertedResultArray addObject:companyPresentationLayer];
    }
    
    return convertedResultArray;
}


- (NSMutableArray *) convertSQLiteProductsInArrayToPresentationLayerProducts: (NSMutableArray *)unconvertedArray{
    
    NSMutableArray *convertedResultArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i < unconvertedArray.count; i++) {
        ProductSQLite *selectedProduct = unconvertedArray[i];
        ProductPresentationLayer *productPresentationLayer = [[ProductPresentationLayer alloc]init];
        productPresentationLayer.company = selectedProduct.company;
        productPresentationLayer.name = selectedProduct.name;
        productPresentationLayer.image = selectedProduct.image;
        productPresentationLayer.unique_id = selectedProduct.unique_id;
        productPresentationLayer.url = selectedProduct.url;
        productPresentationLayer.order_id = selectedProduct.order_id;
        [convertedResultArray addObject:productPresentationLayer];
    }
    
    return convertedResultArray;
}










@end
