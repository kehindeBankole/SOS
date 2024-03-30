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
                    Text("HELP").foregroundStyle(.white)
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
            }
        
    }
}

#Preview {
    ContentView()
}
