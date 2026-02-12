import AppKit
import Foundation

class ConfirmationDialogHandler {
    /// AppleScript source that finds and clicks the "Use [Browser]" button
    /// in the CoreServicesUIAgent confirmation dialog.
    ///
    /// The script targets the CoreServicesUIAgent process which displays the
    /// default browser confirmation dialog. It looks for a button whose name
    /// starts with "Use " and clicks it to confirm the change.
    ///
    /// If no dialog is present (e.g., already the default browser), the script
    /// completes without error.
    static let clickConfirmButtonScript = """
        tell application "System Events"
            repeat 50 times
                if exists (process "CoreServicesUIAgent") then
                    tell process "CoreServicesUIAgent"
                        if (count of windows) > 0 then
                            tell window 1
                                if exists (first button whose name starts with "Use ") then
                                    click (first button whose name starts with "Use ")
                                    return "clicked"
                                end if
                            end tell
                        end if
                    end tell
                end if
                delay 0.1
            end repeat
        end tell
        return "no_dialog"
        """

    /// Result of executing the confirmation script.
    enum ConfirmResult {
        case clicked       // Successfully clicked the confirmation button
        case noDialog      // No dialog was present (already default or dialog didn't appear)
        case error(String) // An error occurred during execution
    }

    /// Executes the AppleScript to click the confirmation button.
    /// Uses NSAppleScript directly (requires sandbox to be disabled and
    /// Accessibility permission granted to Browseroo).
    /// Returns the result of the execution.
    @discardableResult
    static func clickConfirmButton() -> ConfirmResult {
        var errorDict: NSDictionary?
        let script = NSAppleScript(source: clickConfirmButtonScript)

        guard let result = script?.executeAndReturnError(&errorDict) else {
            if let error = errorDict {
                let errorNumber = error[NSAppleScript.errorNumber] as? Int
                let errorMessage = error[NSAppleScript.errorMessage] as? String
                let errorBriefMessage = error[NSAppleScript.errorBriefMessage] as? String

                print("[Browseroo] AppleScript execution failed:")
                print("[Browseroo]   errorNumber: \(errorNumber ?? -1)")
                print("[Browseroo]   errorMessage: \(errorMessage ?? "nil")")
                print("[Browseroo]   errorBriefMessage: \(errorBriefMessage ?? "nil")")
                print("[Browseroo]   Full error dictionary: \(error)")

                return .error(errorMessage ?? "Unknown error")
            }
            print("[Browseroo] AppleScript execution failed: Script returned nil with no error")
            return .error("Script execution failed")
        }

        let resultString = result.stringValue ?? ""
        if resultString == "clicked" {
            return .clicked
        } else {
            return .noDialog
        }
    }
}

