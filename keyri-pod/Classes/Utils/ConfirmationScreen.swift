//
//  ConfirmationScreen.swift
//  keyri-pod
//
//  Created by Aditya Malladi on 6/2/22.
//
import SwiftUI

public struct ConfirmationScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State var session: Session
    
    public var dismissalAction: ((Bool) -> ())?
    
    public init(session: Session) {
        UITableView.appearance().backgroundColor = .systemBackground
        _session = State(wrappedValue: session)
    }
    
    public var body: some View {
        Text("Are you trying to log in?").foregroundColor(.secondary).font(.title3).fontWeight(.semibold).padding()
        if session.riskAnalytics?.riskStatus == "warn" {
            Text(session.riskAnalytics?.riskFlagString ?? "").foregroundColor(.orange)
        }
        List {
            cell(image: "laptopcomputer.and.arrow.down", text: session.iPAddressWidget)
            cell(image: "iphone", text: session.iPAddressMobile)
            cell(image: "laptopcomputer", text: "\(session.widgetUserAgent.browser) on \(session.widgetUserAgent.os)")
            
        }.listStyle(.sidebar).lineSpacing(40)

        HStack {
            Spacer()
            Button(action: {
                _ = session.deny()
                if let dismissalAction = dismissalAction {
                    dismissalAction(false)
                }
            }, label: {
                HStack {
                    Image(systemName: "xmark").foregroundColor(Color(hex: "EF4D52"))
                    Text("No").foregroundColor(Color(hex: "EF4D52"))
                }
            })
                .buttonStyle(KeyriButton(color: Color(hex: "FEECED")))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "EF4D52"), lineWidth: 2)
                )
            Spacer()
            Button(action: {
                _ = session.confirm()
                if let dismissalAction = dismissalAction {
                    dismissalAction(true)
                }
            }, label: {
                HStack {
                    Image(systemName: "checkmark").foregroundColor(Color(hex: "03A564"))
                    Text("Yes").foregroundColor(Color(hex: "03A564"))
                }
            })
            .buttonStyle(KeyriButton(color: Color(hex: "E1F4ED")))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(hex: "03A564"), lineWidth: 2)
            )
            Spacer()
        }
        Text("Powered by Keyri").font(.footnote).fontWeight(.light).padding(.bottom)
    }
}

struct cell: View {
    var image: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: image).frame(width: 20, height: 20, alignment: .center).padding(.leading)
            Text(text).foregroundColor(.secondary).padding(.leading)

        }.frame(height: 50)
    }
    
    
}

struct KeyriButton: ButtonStyle {
    var color: Color
    public init(color: Color) {
        self.color = color
    }
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding()
            .opacity(400)
            .frame(width:100, height: 40, alignment: .center)
            .background(
                RoundedRectangle(
                    cornerRadius: 6,
                    style: .continuous
                ).fill(color)
        )
    }
}
