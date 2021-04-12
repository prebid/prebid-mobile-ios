//
//  Logs.swift
//  MockServer
//
//  Created by Volodymyr Parunakian on 12/4/19.
//  Copyright © 2019 OpenX. All rights reserved.
//

struct Requests: Decodable {
    let requests: [Log]
}

struct Log: Decodable {
    let path: String
    let host: String
    let method: String
    let body: String
    let queryString: [String: String]
}
