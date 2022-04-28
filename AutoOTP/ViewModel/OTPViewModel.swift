//
//  OTPViewModel.swift
//  AutoOTP
//
//  Created by Chirag on 4/28/22.
//

import SwiftUI
import Firebase
class OTPViewModel: ObservableObject {
    // MARK:  Login Data.....
    @Published var number: String = ""
    @Published var code: String = ""
    
    @Published var otpText: String = ""
    @Published var otpFields: [String] = Array(repeating: "", count: 6)
    
    // MARK: OTP Credentials
    @Published var verificationCode: String = ""
    
    @Published var isLoading: Bool = false
    // MARK: Error
    @Published var showAlert:Bool = false
    @Published var errorMsg: String = ""
    
    @Published var navigationTag: String?
    
    @AppStorage("log_status") var log_status = false
    // MARK: SendingOTP
    func sendOTP()async{
        if isLoading {
            return
        }
        do {
            isLoading = true
            let result = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(code)\(number)", uiDelegate: nil)
            DispatchQueue.main.async {
                self.isLoading = false
                self.verificationCode = result
                self.navigationTag = "VERIFICATION"
            }
        }catch {
            handleError(error: error.localizedDescription)
        }
    }
    
    func handleError(error: String){
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMsg = error
            self.showAlert.toggle()
        }
    }
    
    func verifyOTP()async{
        do {
            isLoading = true
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationCode, verificationCode: otpText)
            let _ = try await Auth.auth().signIn(with: credential)
            DispatchQueue.main.async { [self] in
                isLoading = false
                log_status = true
            }
        }catch {
            handleError(error: error.localizedDescription)
        }
    }
}
