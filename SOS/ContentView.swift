//
//  ContentView.swift
//  SOS
//
//  Created by kehinde on 09/03/2024.
//

import SwiftUI
import MapKit


struct ContentView: View {
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        GeometryReader{ reader in
            ZStack(alignment: .trailing) {
                Map(position: $position){
                    UserAnnotation()
                }.mapControls{
                    MapUserLocationButton()
                    MapPitchToggle()
                }
                HStack{
                    Button(action: {
                      //do stuff
                    }){
                        Text("HELP").foregroundStyle(.white)
                            .padding()
                    }
                }.background(.red)
                    .cornerRadius(15)
                    .padding()
            }.onAppear{
                CLLocationManager().requestWhenInUseAuthorization()
            }

        }

    }
}

#Preview {
    ContentView()
}
