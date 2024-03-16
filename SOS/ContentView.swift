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
    @State private var contacts : [CNContact] = []
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isHelp = false
    
    func getContactList(){
        let CNStore = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            do{
                let keys = [CNContactGivenNameKey as CNKeyDescriptor , CNContactFamilyNameKey as CNKeyDescriptor , CNContactPhoneNumbersKey as CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                try CNStore.enumerateContacts(with: request, usingBlock: { contact , _ in
                    
                    contacts.append(contact)
                    
                })
            }catch{
                
            }
        case .denied:
            print("denined")
        case .notDetermined:
            CNStore.requestAccess(for: .contacts, completionHandler:{ granted , error in
                if(granted){
                    getContactList()
                }
            })
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
                ForEach(Array(contacts.enumerated()), id: \.element.id){index ,  contactDetail in
                    HStack{
                        Text("\(contactDetail.givenName)")
                        Text("\(contactDetail.phoneNumbers.first?.value.stringValue ?? "")")
                    }
                    
                    .padding(.vertical , 10)
                }.presentationDetents([.medium , .large])
            }
        }.id(contacts)
            .onAppear{
                getContactList()
                CLLocationManager().requestWhenInUseAuthorization()
            }
        
    }
}

#Preview {
    ContentView()
}
