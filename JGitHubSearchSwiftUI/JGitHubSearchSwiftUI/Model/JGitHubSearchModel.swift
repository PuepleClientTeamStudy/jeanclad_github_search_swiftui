//
//  JGitHubSearchModel.swift
//  JGithubSearch
//
//  Created by 권회경 on 2022/11/30.
//

import Foundation

struct JGitHubSearchModel: Codable {
    var total_count: Int
    var incomplete_results: Bool
    
    var items: [Item]
}

struct Item: Codable {
    var id: Int
    var name: String
    var full_name: String
}
