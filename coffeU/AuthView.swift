import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(isLogin ? "Log In" : "Register") {
                // Placeholder for authentication logic
                print("Authentication attempt")
            }
            
            Button(isLogin ? "Need an account? Register" : "Have an account? Log In") {
                isLogin.toggle()
            }
        }
        .padding()
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
