//
//  RecipeListView.swift
//  Recipe_App
//
//  Created by Sungwoo Lee on 8/21/24.
//

import SwiftUI
import SDWebImageSwiftUI

enum NavStack: Hashable {
    case DetailedView(RecipeThumbnailModel)
}

struct RecipeListView: View {
    @State var showView = false
    @State var searchQuery = ""
    @State var navPath = NavigationPath()
    
    @State var recipeThumbnails: [RecipeThumbnailModel] = []
    var recs: [RecipeThumbnailModel] {
        if searchQuery.isEmpty {
            return recipeThumbnails
        } else {
            return recipeThumbnails.filter { $0.name.localizedCaseInsensitiveContains(searchQuery)}
        }
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            if showView {
                List(recs) { recipeThumbnail in
                    RecipeThumbnailView(recipeThumbnail: recipeThumbnail, navPath: $navPath)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 24, trailing: 0))
                }
                .listStyle(PlainListStyle())
                .searchable(text: $searchQuery, placement: .toolbar, prompt: "Search")
                .navigationDestination(for: NavStack.self) { view in
                    switch view {
                    case .DetailedView(let recipeThumbnail):
                        DetailedView(recipeThumbnail: recipeThumbnail)
                    }
                }
                .navigationTitle("Desserts")
                
            } else {
                ProgressView()
                    .scaleEffect(2)
                    .task {
                        await getRecipes()
                    }
            }
        }
    }
    
    func getRecipes() async {
        let backendCheckoutUrl = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
        var request = URLRequest(url: backendCheckoutUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String:[[String: Any]]] ?? [:]
            
            var recipes = json["meals"]?.compactMap ({ RecipeThumbnailModel(id: $0["idMeal"] as! String, name: $0["strMeal"] as! String, imageURL: $0["strMealThumb"] as! String) }) ?? []
            recipes.sort(by: { $0.name < $1.name }) //sort alphabetically
            recipeThumbnails = recipes
            showView = recipeThumbnails.count > 0
        } catch {
            print("GetRecipeThumbnails Error: \(error)")
        }
    }
}

#Preview {
    RecipeListView()
}

struct RecipeThumbnailView: View {
    let recipeThumbnail: RecipeThumbnailModel
    @Binding var navPath: NavigationPath
    
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: URL(string: recipeThumbnail.imageURL))
                .resizable()
                .scaledToFill()
                .frame(height: 400, alignment: .center)
                .clipped()
            Text(recipeThumbnail.name)
                .bold()
                .font(.title2)
                .padding(.horizontal, 8)
        }
        .onTapGesture {
            navPath.append(NavStack.DetailedView(recipeThumbnail))
        }
    }
}
