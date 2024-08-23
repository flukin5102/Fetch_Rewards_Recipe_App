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
    @State var recipeThumbnails: [RecipeThumbnailModel] = []
    @State var searchQuery = ""
    @State var navPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navPath) {
            if showView {
                List($recipeThumbnails) { $recipeThumbnail in
                    RecipeThumbnailView(recipeThumbnail: recipeThumbnail, navPath: $navPath)
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
                        recipeThumbnails = await getRecipes()
                        showView = recipeThumbnails.count > 0
                    }
            }
        }
    }
    
    func getRecipes() async -> [RecipeThumbnailModel] {
        let backendCheckoutUrl = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
        var request = URLRequest(url: backendCheckoutUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String:[[String: Any]]] ?? [:]
            
            
            let recipes = json["meals"]?.compactMap ({ RecipeThumbnailModel(id: $0["idMeal"] as! String, name: $0["strMeal"] as! String, imageURL: $0["strMealThumb"] as! String) })
            return recipes ?? []
        } catch {
            print("GetRecipeThumbnails Error: \(error)")
            return []
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
                .frame(height: 300, alignment: .center)
                .clipped()
            Text(recipeThumbnail.name)
        }
        .onTapGesture {
            navPath.append(NavStack.DetailedView(recipeThumbnail))
        }
    }
}
