//
//  ProgressView.swift
//  SwiftGenUIMac
//
//  Created by Alfian Losari on 21/02/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import SwiftUI

struct ProgressView: NSViewRepresentable {
    
    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ProgressView>) {
        nsView.style = .spinning
        nsView.startAnimation(self)
    }
    
    
    func makeNSView(context: NSViewRepresentableContext<ProgressView>) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        return indicator

    }
    
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}
