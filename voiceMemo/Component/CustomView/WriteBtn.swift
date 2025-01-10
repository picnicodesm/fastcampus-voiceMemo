//
//  WriteBtn.swift
//  voiceMemo
//
//

import SwiftUI

// MARK: - 1
public struct WriteBtnViewModifier: ViewModifier { // public 권장 <- 이유 강의에 있는데 잘 모르겠다.
    let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(
                        action: action,
                        label: { Image("writeBtn") }
                    )
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 50)
        }
    }
}


// MARK: - 2

// MARK: - 3
