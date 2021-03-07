//
//  ContentView.swift
//  lab10
//
//  Created by Cristian Zuniga on 6/3/21.
//

import SwiftUI

struct pokemonTCG : Codable {
    
    struct Cards:  Identifiable, Codable {
        let id : String
        let name: String
        let images: Images
    }
    
    struct Images:  Codable {
        let small: String
        let large: String
    }
    
    let data: [Cards]
}

extension Image {
    func data(url:URL) -> Self {
        if let data = try? Data(contentsOf: url) {
            guard let image = UIImage(data: data) else {
                return Image(systemName: "square.fill")
            }
            return Image(uiImage: image)
                .resizable()
        }
        return self
            .resizable()
    }
}

class PokemonCardsViewModel: ObservableObject {
    @Published var messages = "Message inside the observable object"
    
    @Published var pokemonCards: [pokemonTCG.Cards] = [
        //        .init(id: "00",
        //            name:"Course1")
    ]
    
    func changeMessage(){
        self.messages = "New Message"
    }
    
    func fetchCards(name: String){
        guard let url = URL(string: "https://api.pokemontcg.io/v2/cards?q=name:\(name)") else {
            print("Your API end point is Invalid")
            return
        }
        let request = URLRequest(url: url)
        // The shared singleton session object.
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data {
                if let response = try? JSONDecoder().decode(pokemonTCG.self, from: data) {
                    DispatchQueue.main.async {
                        //print (response)
                        self.pokemonCards = response.data
                    }
                    return
                }
            }
            
        }.resume()
    }
}

struct ContentView: View {
    
    @ObservedObject var pkmCardsVM = PokemonCardsViewModel()
    @State var searchText: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                //Text(coursesVM.messages)
                ForEach(self.pkmCardsVM.pokemonCards.prefix(20)){ card in
                    VStack{
                        HStack{
                            Text(String(card.name))
                        }
                        if let cardURL = URL(string: card.images.small) {
                            Image(systemName: "square.fill").data(url: cardURL)
                                .frame(width: 150.0, height: 200.0)
                        }
                        
                    }
                }
                if self.pkmCardsVM.pokemonCards.count == 0
                {
                    HStack{
                        Text(String("No results found!"))
                    }
                }
            }.navigationBarTitle("Pokemon Cards")
            .navigationBarItems(
                leading: TextField("Search", text: $searchText)
                     .padding(7)
                     .frame(width: 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                     .background(Color(.systemGray6))
                     .cornerRadius(8),
                
                trailing:Button(
                    action:{
                        print("Fetching json data")
                        self.pkmCardsVM.fetchCards(name: searchText)
                    },
                    label:{
                        Text("Seach Card")
                    }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
