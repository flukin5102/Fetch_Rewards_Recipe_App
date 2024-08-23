//
//  DetailedView.swift
//  Recipe_App
//
//  Created by Sungwoo Lee on 8/21/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailedView: View {
    var recipeThumbnail: RecipeThumbnailModel
    @State var recipe: RecipeModel? = nil
    @State var hasRecipeInited = false //indicate whether recipe has been successfully fetched in initial attempt
    @State var isRefreshable = false //allow refresh if necessary after initial fetching
    @State var isInstrExpanded = false
    @State var selectedTab = 0
    
    let tabs_text = ["Ingredients", "Instructions"]

    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: URL(string: recipeThumbnail.imageURL))
                .resizable()
                .scaledToFill()
                .frame(height: 300, alignment: .center)
                .clipped()
            
            
            Group {
                if !hasRecipeInited { //recipe hasn't been fetched from API yet
                    ProgressView()
                } else if recipe == nil { //There was an error while fetching recipe; suggest user to refresh
                    Text("Refresh and try again.")
                } else { //recipe has been successfuly fetched
                    VStack {
                        //tabs
                        HStack(spacing: 0) {
                            ForEach(0..<2) { index in
                                Button(action: {
                                    selectedTab = index
                                }) {
                                    VStack(spacing: 6) {
                                        Text(tabs_text[index])
                                            .foregroundColor(selectedTab == index ? .blue : .primary)
                                            .bold()
                                            .font(.title3)
                                            
                                        Rectangle()
                                            .frame(height: 2)
                                            .foregroundColor(selectedTab == index ? .blue : .clear)
                                    }
                                }
                            }
                        }
                        .background(Color.clear)
                        .padding(.bottom, -8)
                        
                        //content views
                        TabView(selection: $selectedTab) {
                            Group {
                                if let ingredients = recipe?.ingredients {
                                    List(ingredients) { ingredient in
                                        HStack {
                                            Text(ingredient.name)
                                            Spacer()
                                            Text(ingredient.measurement)
                                        }
                                    }
                                    .listStyle(PlainListStyle())
                                }
                            }
                            .tag(0)
                            
                            Group {
                                if let instructions = recipe?.instructions { //if instructions exist
                                    ScrollView {
                                        Text(instructions)
                                            .padding(8)
                                    }
                                } else { //if instructions do not exist and is not an error occured while fetching
                                    Text("No instructions") //indicate that there are no instructions with recipe
                                        .bold()
                                        .font(.title3)
                                }
                            }
                            .tag(1)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
        }
        .task {
            await getDetailedRecipe()
        }
        .navigationTitle(recipeThumbnail.name)
        .refreshable {
            if isRefreshable {
                await getDetailedRecipe()
            }
        }
    }
    
    func getDetailedRecipe() async {
        let backendCheckoutUrl = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(recipeThumbnail.id)")!
        var request = URLRequest(url: backendCheckoutUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String:[[String: Any]]] ?? [:]
            
            //get instructions
            let instructions = json["meals"]?[0]["strInstructions"] as! String
            
            //get ingredients without empty spaces and sorted by order
            var ingredientNames: [String] = []
            let sortedData = json["meals"]?[0].sorted(by: {$0.key < $1.key}) ?? []
            sortedData.forEach { key, value in
                if key.hasPrefix("strIngredient"), let stringValue = value as? String, !stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    ingredientNames.append(stringValue)
                }
            }
            
           //get measurements without empty spaces sorted by order
            var measurements: [String] = []
            sortedData.forEach { key, value in
                if key.hasPrefix("strMeasure"), let stringValue = value as? String, !stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    measurements.append(stringValue)
                }
            }
            
            //merge ingredients and measurements into dict assuming they always have equal pair
            var ingredients: [IngredientModel] = []
            for i in stride(from: 0, to: ingredientNames.count, by: 1) { //make sure to use ingredientNames.count
                ingredients.append(IngredientModel(name: ingredientNames[i], measurement: measurements[i]))
            }

            recipe = RecipeModel(recipeThumbnail: recipeThumbnail, ingredients: ingredients, instructions: instructions)
            hasRecipeInited = true
            isRefreshable = recipe == nil //error while fetching recipe; enable API to be re-callable when refreshing
        } catch {
            print("GetRecipeThumbnails Error: \(error)")
        }
    }
}

#Preview {
    DetailedView(recipeThumbnail: RecipeThumbnailModel.sampleData[0])
}
