//
//  JGitHubMainVIewModel.swift
//  JGithubSearch
//
//  Created by 권회경 on 2022/11/29.
//

import Foundation
import Combine

class JGitHubMainViewModel: ObservableObject {
    var cancelBag = Set<AnyCancellable>()
    
    @Published public var githubSearchModel: JGitHubSearchModel?
    
    init() { }
    
    // MARK: Private
    
    public func fetchGitHubSearchKeyworkWithCombine(with keyword: String) {
        APIService().searchReposeCombine(with: keyword, type: JGitHubSearchModel.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                print("recived = \($0)")
            }, receiveValue: { [weak self] response in
                self?.githubSearchModel = response
            })
            .store(in: &cancelBag)
    }
}
