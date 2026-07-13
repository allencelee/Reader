// This file is part of Kpapp for iOS.

import SwiftUI

/// on iPhone when using numberPad, there's no submit button
/// so we need to use a keyboard toolbar button to save
///
/// on iPad the keyboard can be dismissed (lost focus)
/// we need to save (and validate) in that case as well
///
/// on macOS we save the port number value when:
/// - switching to another settings tab
/// - closing the settings window
/// - changing to another window (without closing settings)
struct PortInput: View {
    
    let focusOnPortInput: Bool
    @ObservedObject private var portNumber = PortNumber()
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack {
            Text(LocalString.hotspot_settings_port_number)
            TextField("", text: $portNumber.stringValue)
            #if os(iOS)
                .keyboardType(.numberPad)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(LocalString.common_button_done) {
                            isFocused = false
                        }
                    }
                }
                .onChange(of: isFocused) { focused in
                    if !focused {
                        portNumber.save()
                    }
                }
            #endif
                .focused($isFocused)
                .frame(maxWidth: 100)
                .textFieldStyle(.roundedBorder)
                .onChange(of: portNumber.stringValue, perform: portNumber.onChange(newValue: ))
                .onSubmit {
                    portNumber.save()
                }
        }
        .task {
            // move the initial focus to the port number if needed
            isFocused = focusOnPortInput
        }
    }
}

/// Input filter and validator for PortInput
/// as of Apple docs from: https://developer.apple.com/documentation/swiftui/textfield
/// "If the value is a string, the text field updates this value continuously
/// as the user types or otherwise edits the text in the field.
/// For non-string types, it updates the value when the user commits their edits,
/// such as by pressing the Return key."
///
/// Which means we need to use a string input, otherwise we won't get updates
/// and non number input chars will appear in the text field
/// We convert the string and validate it as Int
/// if all OK save it as Int
///
/// We are fixing the minimum value only on save!
/// Otherwise it's really hard to input low numbers (1...9)
/// or to delete the text input value to empty and start over
///
final class PortNumber: ObservableObject {
    @Published var stringValue: String = "\(Defaults[.hotspotPortNumber])"
    
    func onChange(newValue: String) {
        let filtered = Self.filtered(newValue)
        if filtered != newValue {
            stringValue = filtered
        }
    }
    
    static func filtered(_ value: String) -> String {
        let filtered = value.filter(\.isNumber)
        guard var intValue = Int(filtered) else {
            return filtered
        }
        guard intValue != 0 else {
            return ""
        }
        while Hotspot.maxPort < intValue {
            intValue /= 10 // cut back the digits to be below max
        }
        return "\(intValue)"
    }
    
    func save() {
        // fix the value with minPort on save
        let intValue = Int(stringValue) ?? Hotspot.minPort
        let valueToSave = max(Hotspot.minPort, intValue)
        stringValue = "\(valueToSave)"
        Defaults[.hotspotPortNumber] = valueToSave
    }
}
