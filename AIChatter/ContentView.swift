//
//  ContentView.swift
//  AIChatter
//
//  Created by Rafał Gawlik on 13/12/2022.
//

import SwiftUI
import OpenAISwift

final class ViewModel: ObservableObject {
    init(){}
    
    private var client: OpenAISwift?
    
    
    func setup(){
            client = OpenAISwift(authToken: "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")
    }
    
    func send(text: String, completion: @escaping (String)->Void){
        client?.sendCompletion(with: text,
                               maxTokens: 1000,
                               completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
            case .failure:
                break
            }
        })
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(models, id: \.self){ string in
                Text(string)
                
            }
            Spacer()
            
            HStack{
                TextField("Type here...", text: $text)
                Button("Send"){
                    send()
                }
            }
        }
        .onAppear{
            viewModel.setup()
        }
        .padding()
    }
    
    func send(){
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }
        models.append("Me: \(text)")
        viewModel.send(text: text){ response in
            DispatchQueue.main.async{
                self.models.append("Bot: "+response)
                self.text = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
