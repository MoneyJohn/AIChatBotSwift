//  ContentView.swift
//  AIChatApp
//
//  Created by John Money on 3/29/23.
//
import OpenAISwift
import SwiftUI
import UIKit

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "Insert api key here (DO NOT SHARE YOUR PERSONAL TOKEN KEY")
    }
    func send(text: String,
              completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, model: .gpt3(//Insert the language model you want eg: .Davinci, .Curie, .Ada, or .Babbage), maxTokens: 500, completionHandler: { result in switch result {
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
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(models, id: \.self) {string in
                    Text(string)
                }
                Spacer()
                
                HStack {
                    TextField("Ask Money!....", text: $text)
                    Button("-->") {
                        ask()
                    }
                    
                }
            }
            .onAppear {
                viewModel.setup()
            }
            .padding()
            
            .background(
                LinearGradient(gradient: Gradient(colors: [.black, .teal]), startPoint: .top, endPoint: .bottom)
                           .frame(width: 1000, height: 6000)
                       .edgesIgnoringSafeArea(.all))
        }
    }
    func ask() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        models.append("Me: \(text)")
        viewModel.send(text: text) {response in
            DispatchQueue.main.async {
                self.models.append("moneyAI: "+response)
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

}
