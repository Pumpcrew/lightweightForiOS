import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A read-only, selectable, scrolling text view (UITextView / NSTextView): what the failure alert shows its message in,
/// so a long reason can be read in full and copied
struct ScrollableTextView: View {
    let text: String
    var body: some View { Representable(text: text) }

    #if canImport(UIKit)
    struct Representable: UIViewRepresentable {
        let text: String
        func makeUIView(context: Context) -> UITextView {
            let v = UITextView()
            v.isEditable = false
            v.isSelectable = true
            v.isScrollEnabled = true
            v.backgroundColor = .clear
            v.font = .preferredFont(forTextStyle: .callout)
            v.adjustsFontForContentSizeCategory = true
            v.textColor = .label
            v.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
            v.dataDetectorTypes = []
            v.accessibilityIdentifier = "failure.message"
            return v
        }
        func updateUIView(_ v: UITextView, context: Context) { if v.text != text { v.text = text; v.setContentOffset(.zero, animated: false) } }
    }
    #else
    struct Representable: NSViewRepresentable {
        let text: String
        func makeNSView(context: Context) -> NSScrollView {
            let scroll = NSTextView.scrollableTextView()
            scroll.drawsBackground = false
            scroll.hasVerticalScroller = true
            if let tv = scroll.documentView as? NSTextView {
                tv.isEditable = false
                tv.isSelectable = true
                tv.drawsBackground = false
                tv.font = .preferredFont(forTextStyle: .callout)
                tv.textColor = .labelColor
                tv.textContainerInset = NSSize(width: 4, height: 8)
                tv.setAccessibilityIdentifier("failure.message")
            }
            return scroll
        }
        func updateNSView(_ v: NSScrollView, context: Context) {
            if let tv = v.documentView as? NSTextView, tv.string != text { tv.string = text }
        }
    }
    #endif
}

/// An alert for a failure whose message is a TextView, not a label: a title, the reason in a scrolling, selectable
/// text view, and a button. Shown over everything, like a system alert
struct FailureAlert: ViewModifier {
    @Binding var failure: Failure?

    func body(content: Content) -> some View {
        content.overlay {
            if let f = failure {
                ZStack {
                    Color.black.opacity(0.35).ignoresSafeArea()
                        .onTapGesture {}
                    VStack(spacing: 0) {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title)
                                .foregroundStyle(.orange)
                            Text(verbatim: f.title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            ScrollableTextView(text: f.message)
                                .frame(minHeight: 120, idealHeight: 220, maxHeight: 280)
                                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(20)
                        Divider()
                        HStack(spacing: 0) {
                            Button {
                                copy(f.message)
                            } label: {
                                Text("Copy").frame(maxWidth: .infinity, minHeight: 44)
                            }
                            Divider().frame(height: 44)
                            Button {
                                failure = nil
                            } label: {
                                Text("OK").bold().frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                        .buttonStyle(.borderless)
                    }
                    .frame(maxWidth: 360)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 20)
                    .padding(24)
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isModal)
                }
                .transition(.opacity.combined(with: .scale(scale: 1.05)))
            }
        }
        .animation(.easeOut(duration: 0.18), value: failure)
    }

    private func copy(_ s: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = s
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
        #endif
    }
}

extension View {
    func failureAlert(_ failure: Binding<Failure?>) -> some View { modifier(FailureAlert(failure: failure)) }
}
