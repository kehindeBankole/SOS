//
//  ContentView.swift
//  SOS
//
//  Created by kehinde on 09/03/2024.
//

import SwiftUI
import MapKit
import Contacts




struct ContentView: View {
    @State private var uicontacts : [CNContact] = []
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isHelp = false
    @State private var route : MKRoute?
    @State private var userLocation: CLLocation?

    @State private var userLocationName = ""
    
    func getContactList() {
        let CNStore = CNContactStore()
       
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            DispatchQueue.global(qos: .background).async {
                var contacts = [CNContact]()
         
                do {
                    let keys = [CNContactGivenNameKey as CNKeyDescriptor,
                                CNContactFamilyNameKey as CNKeyDescriptor,
                                CNContactPhoneNumbersKey as CNKeyDescriptor]
                    
                    let request = CNContactFetchRequest(keysToFetch: keys)
                    
                    try CNStore.enumerateContacts(with: request, usingBlock: { contact, _ in
                        contacts.append(contact)
                    })
                    
                    //update the UI on the main thread
                    DispatchQueue.main.async {
                        uicontacts = contacts
                    }
                    
                } catch {
                    print("Error fetching contacts: \(error)")
                
                    DispatchQueue.main.async {
                        // Show an error message to the user or update the UI accordingly
                    }
                }
            }
            
        case .denied:
            print("denied")
            
        case .notDetermined:
            CNStore.requestAccess(for: .contacts) { granted, error in
                if granted {
                    self.getContactList()
                }
            }
            
        default:
            print("do nothing...")
        }
    }
    
    func reverseGeocode(location: CLLocation) {
         let geocoder = CLGeocoder()
         geocoder.reverseGeocodeLocation(location) { placemarks, error in
             guard let placemark = placemarks?.first else {
                 print("Error reverse geocoding: \(error?.localizedDescription ?? "Unknown error")")
                 return
             }
             
             
             if let name = placemark.name {
                 self.userLocationName = name
             } else {
                 self.userLocationName = "Unknown Location"
             }
         }
     }
      
    
    
    var body: some View {
        
        ZStack(alignment: .trailing) {
            Map(position: $position){
                UserAnnotation()
            }.mapControls{
                MapUserLocationButton()
                MapPitchToggle()
            }
            HStack{
                Button(action: {
                    
                    isHelp.toggle()
                    
                }){
                    Text("HELP\(userLocationName)").foregroundStyle(.white)
                        .padding()
                }
            }.background(.red)
                .cornerRadius(15)
                .padding()
        }
        .sheet(isPresented: $isHelp){
            List{
                ForEach(Array(uicontacts.enumerated()), id: \.element.id){index ,  contactDetail in
                    HStack{
                        Text("\(contactDetail.givenName)")
                        Text("\(contactDetail.phoneNumbers.first?.value.stringValue ?? "")")
                    }.swipeActions{
                        Button(action: {
                           print(contactDetail)
                            return
                        }){
                            
                            Image(systemName: "message.fill")
                            
                        }.tint(.red)
                        
                    }.swipeActions(edge: .leading){
                        Button(action: {
                           print(contactDetail)
                            return
                        }){
                            
                            Image(systemName: "message.fill")
                            
                        }.tint(.red)
                        
                    }
                    
                    .padding(.vertical , 10)
                }.presentationDetents([.medium , .large])
            }
        }.id(uicontacts)
            .onAppear{
                getContactList()
                CLLocationManager().requestWhenInUseAuthorization()
                let locationManager = CLLocationManager()
                locationManager.startUpdatingLocation()
                           DispatchQueue.main.async {
                               self.userLocation = locationManager.location
                               if let location = self.userLocation {
                                   reverseGeocode(location: location)
                               }
                           }
            }
        
    }
}

#Preview {
    ContentView()
}
