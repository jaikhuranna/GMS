//
//  AppwriteManager.swift
//  fleetManagementSystem
//
//  Created by Steve on 27/04/25.
//


import Appwrite

class AppwriteManager {
    static let shared = AppwriteManager()
    let client = Client()
    let account: Account
    let databases: Databases
    
    private init() {
        client
            .setEndpoint("https://fra.cloud.appwrite.io/v1")
            .setProject("696969696969")

        account = Account(client)
        databases = Databases(client)
    }
}

//https://fra.cloud.appwrite.io/v1
//696969696969
