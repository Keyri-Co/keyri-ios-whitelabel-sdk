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
    var status: String
    var isDenial: Bool
    
    @State var shouldCall = true
    
    public var dismissalAction: ((Bool) -> ())?
    public var shouldCallDismissOnDissappear = true
    
    public init(session: Session) {
        UITableView.appearance().backgroundColor = .systemBackground
        UICollectionView.appearance().backgroundColor = .systemBackground
        
        _session = State(wrappedValue: session)
        status = session.riskAnalytics?.riskStatus ?? ""
        isDenial = status == "deny"
        
    }

    public var body: some View {
        Text(session.mobileTemplateResponse.title).foregroundColor(colorScheme == .light ? Color(hex: "595959") : Color(hex: "F5F5F5")).font(.system(size: 24)).padding(.top, 50)
        if let message = session.mobileTemplateResponse.message {
            Text(message).padding(.top, 12).padding(.trailing).padding(.leading).padding(.top, 10).foregroundColor(colorScheme == .light ? Color(hex: "595959") : Color(hex: "F5F5F5")).font(.system(size: 16))
        }
        
        if #available(iOS 16.0, *) {
            List {
                if let issue = session.mobileTemplateResponse.widget.issue {
                    cellWithIssue(image: "laptopcomputer.and.arrow.down", text: session.mobileTemplateResponse.widget.location, issue: issue, isDenied: isDenial).padding(.top, -20).listRowSeparator(.hidden)
                } else  {
                    cell(image: "laptopcomputer.and.arrow.down", text: session.mobileTemplateResponse.widget.location).padding(.top, -20).listRowSeparator(.hidden)
                }
                
                
                if let issue = session.mobileTemplateResponse.mobile.issue {
                    cellWithIssue(image: "iphone", text: session.mobileTemplateResponse.mobile.location, issue: issue, isDenied: isDenial).listRowSeparator(.hidden)
                } else  {
                    cell(image: "iphone", text: session.mobileTemplateResponse.mobile.location).listRowSeparator(.hidden)
                }
                
                
                if let issue = session.mobileTemplateResponse.userAgent.issue {
                    cellWithIssue(image: "laptopcomputer", text: session.mobileTemplateResponse.userAgent.name, issue: issue, isDenied: isDenial)
                } else {
                    cell(image: "laptopcomputer", text: session.mobileTemplateResponse.userAgent.name)
                }
                
            }.listStyle(.plain).lineSpacing(40).padding(.leading, 15).padding(.top, 20).scrollContentBackground(.hidden)
        } else {
            List {
                if let issue = session.mobileTemplateResponse.widget.issue {
                    cellWithIssue(image: "laptopcomputer.and.arrow.down", text: session.mobileTemplateResponse.widget.location, issue: issue, isDenied: isDenial).padding(.top, -20)
                } else  {
                    cell(image: "laptopcomputer.and.arrow.down", text: session.mobileTemplateResponse.widget.location).padding(.top, -20)
                }
                
                
                if let issue = session.mobileTemplateResponse.mobile.issue {
                    cellWithIssue(image: "iphone", text: session.mobileTemplateResponse.mobile.location, issue: issue, isDenied: isDenial)
                } else  {
                    cell(image: "iphone", text: session.mobileTemplateResponse.mobile.location)
                }
                
                
                if let issue = session.mobileTemplateResponse.userAgent.issue {
                    cellWithIssue(image: "laptopcomputer", text: session.mobileTemplateResponse.userAgent.name, issue: issue, isDenied: isDenial)
                } else {
                    cell(image: "laptopcomputer", text: session.mobileTemplateResponse.userAgent.name)
                }
                
            }.listStyle(.sidebar).lineSpacing(40).padding(.leading, 10)
        }
        
        if !isDenial {
            HStack {
                Spacer()
                Button(action: {
                    _ = session.deny()
                    if let dismissalAction = dismissalAction {
                        shouldCall = false
                        dismissalAction(false)
                    }
                }, label: {
                    HStack {
                        Image(systemName: "xmark").foregroundColor(Color(hex: "EF4D52"))
                        Text("No").foregroundColor(Color(hex: "EF4D52"))
                    }
                })
                    .buttonStyle(KeyriButton(color: Color(hex: "FCDADB")))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(hex: "EF4D52"), lineWidth: 1)
                    )
                Spacer()
                Button(action: {
                    _ = session.confirm()
                    if let dismissalAction = dismissalAction {
                        shouldCall = false
                        dismissalAction(true)
                    }
                }, label: {
                    HStack {
                        Image(systemName: "checkmark").foregroundColor(Color(hex: "03A564"))
                        Text("Yes").foregroundColor(Color(hex: "03A564"))
                    }
                })
                .buttonStyle(KeyriButton(color: Color(hex: "D2EFE3")))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "03A564"), lineWidth: 1)
                )
                Spacer()
            }
        } else {
            Button(action: {
                if let dismissalAction = dismissalAction {
                    shouldCall = false
                    dismissalAction(false)
                }
            }, label: {
                HStack {
                    Image(systemName: "xmark").foregroundColor(colorScheme == .light ? Color(hex: "595959") : Color(hex: "F5F5F5"))
                    Text("Close").foregroundColor(colorScheme == .light ? Color(hex: "595959") : Color(hex: "F5F5F5"))
                }
            })
            .buttonStyle(KeyriButton(color: colorScheme == .light ? .white : Color(hex: "1C1C1E"), isDenial: true))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(colorScheme == .light ? Color(hex: "595959") : Color(hex: "F5F5F5"), lineWidth: 1)
                )
        }
        Text("Powered by Keyri").font(.footnote).fontWeight(.light).padding(.bottom, 10).padding(.top).foregroundColor(colorScheme == .light ? Color(hex: "595959") : Color(hex: "F5F5F5"))
        
            .onDisappear() {
                if shouldCall {
                    dismissalAction?(false)
                }
            }
    }
}

struct cell: View {
    @Environment(\.colorScheme) var colorScheme

    var image: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: image).frame(width: 18, height: 18, alignment: .center).foregroundColor(colorScheme == .light ? Color(hex: "595959") : Color(hex: "F5F5F5"))
            Text(text).foregroundColor(colorScheme == .light ? Color(hex: "595959") : Color(hex: "F5F5F5")).padding(.leading).font(.system(size: 16))

        }.frame(height: 65)
    }
    
    
}

struct cellWithIssue: View {
    @Environment(\.colorScheme) var colorScheme
    
    var image: String
    var text: String
    var issue: String
    
    var isDenied: Bool
    
    var body: some View {
        HStack {
            Image(systemName: image).frame(width: 18, height: 18, alignment: .center).foregroundColor(Color(hex: isDenied ? "EF4D52" : "F5704C"))
            VStack(spacing: 5) {
                Text(text).foregroundColor(Color(hex: isDenied ? "EF4D52" : "F5704C")).padding(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 16))
                HStack(spacing: 0) {
                    Text(issue).foregroundColor(Color(hex: isDenied ? "F59598" : "FF9A73")).fixedSize(horizontal: true, vertical: false).padding(.leading).padding(.trailing, 10).frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 16))
                    Image(systemName: "exclamationmark.circle.fill").frame(width: 18, height: 18, alignment: .leading).foregroundColor(Color(hex: isDenied ? "F59598" : "FF9A73")).frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Spacer()
                }
            }.padding(.top, 5)
        }.frame(height: 65)
    }
    
    
}

struct KeyriButton: ButtonStyle {
    var color: Color
    var width: CGFloat
    
    public init(color: Color, isDenial: Bool = false) {
        self.color = color
        if isDenial {
            width = 320
        } else {
            width = 142
        }
    }
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding()
            .opacity(400)
            .frame(width: width, height: 51, alignment: .center)
            .background(
                RoundedRectangle(
                    cornerRadius: 6,
                    style: .continuous
                ).fill(color)
        )
    }
}
