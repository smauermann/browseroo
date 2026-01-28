import AppKit

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
            -- Check if CoreServicesUIAgent has any windows (the confirmation dialog)
            if exists (process "CoreServicesUIAgent") then
                tell process "CoreServicesUIAgent"
                    set windowCount to count of windows
                    if windowCount > 0 then
                        tell window 1
                            -- Check if a "Use *" button exists, then click it directly
                            if exists (first button whose name starts with "Use ") then
                                click (first button whose name starts with "Use ")
                                return "clicked"
                            end if
                        end tell
                    end if
                end tell
            end if
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
    /// Returns the result of the execution.
    @discardableResult
    static func clickConfirmButton() -> ConfirmResult {
        var errorDict: NSDictionary?
        let script = NSAppleScript(source: clickConfirmButtonScript)

        guard let result = script?.executeAndReturnError(&errorDict) else {
            if let error = errorDict {
                let message = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                return .error(message)
            }
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

