//
//  ContentView.swift
//  JGitHubSearchSwiftUI
//
//  Created by 권회경 on 2023/01/23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = JGitHubMainViewModel()
    
    var body: some View {
        VStack {
            Button("Search") {
                self.viewModel.fetchGitHubSearchKeyworkWithCombine(with: "Swift Combine")
            }
            .padding()
            List(0...(viewModel.githubSearchModel?.items.count ?? 1)-1, id:\.self) { index in
                Text("\(self.viewModel.githubSearchModel?.items[index].full_name ?? "")" )
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
