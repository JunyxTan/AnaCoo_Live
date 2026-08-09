import receive_sharing_intent

/// Receives a message shared from WhatsApp (or anywhere else) and hands it to
/// the app, which parses it into a pre-filled New Job form.
///
/// `RSIShareViewController` does the work: it writes the shared payload into
/// the shared App Group container and opens the host app over the
/// `ShareMedia-<bundle id>` URL scheme.
///
/// If Xcode reports "no such module 'receive_sharing_intent'", open Build
/// Phases on the Runner target and move `Embed Foundation Extension` above
/// `Thin Binary`.
class ShareViewController: RSIShareViewController {

    /// Skip the compose sheet — there is nothing for the tailor to type here,
    /// and the app's own import screen is where the editing happens.
    override func shouldAutoRedirect() -> Bool {
        return true
    }
}
