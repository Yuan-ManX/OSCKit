# OSCKit Method IDs Example

This example demonstrates how to get the most out of OSCKit, including:

- taking advantage of `OSCAddressSpace` pattern matching and using method IDs
- OSC message value validation and strong-typing using `masked()`

## Entitlements

If you are adding OSCKit to a macOS project that has the Sandbox entitlement, ensure that the network options are enabled. These entitlement options are already set in the example project.

![sandbox-network-connections](Images/sandbox-network-connections.png)

## Build Note

If Xcode builds but the app does not run, it may be because Xcode is defaulting to the wrong Scheme. Ensure the example app's Scheme is selected then try again.
