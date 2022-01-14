//
//  EditView.swift
//  BucketList
//
//  Created by Brandon Glenn on 1/12/22.
//

import SwiftUI

struct EditView: View {
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    @Environment (\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void
    
    @State private var name: String
    @State private var description: String
    
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Place Name", text: $name)
                    TextField("Place Description", text: $description)
                }
                
                Section("Nearby...") {
                    switch loadingState {
                    case .loading:
                        Text("Loading...")
                    case .loaded:
                        ForEach(pages, id:\.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ")
                            + Text (page.description)
                                .italic()
                        }
                    case .failed:
                        Text("Please try again later")
                    }
                }
                
            }
            .navigationTitle("Place Details")
            .toolbar {
                Button ("Save") {
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    onSave(newLocation)
                    
                    dismiss()
                }
            }
            .task {
                await fetchNearbyPlaces()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue:location.name)
        _description = State(initialValue:location.description)
         
    }
    
    func fetchNearbyPlaces ()  async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

        guard let url = URL(string: urlString) else {
            print ("Bad url: \(urlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("data loaded: \(data)")
            let items = try JSONDecoder().decode(Result.self, from: data)
            print ("Items Loaded")
            pages = items.query.pages.values.sorted()
            loadingState = .loaded
        } catch {
            loadingState = .failed
            
        }
        
    }
}

struct EditView_Previews: PreviewProvider {
    let location = Location.example
    
    static var previews: some View {
        EditView(location: Location.example) { _ in }
    }
}
