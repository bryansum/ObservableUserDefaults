# ObservableUserDefaults

[![CI](https://github.com/bryansum/ObservableUserDefaults/workflows/CI/badge.svg)](https://actions-badge.atrox.dev/bryansum/ObservableUserDefaults/goto)

Property wrapper for UserDefaults that can be mocked for testing or observed using a Combine Publisher.

## Usage
```swift

struct UserDefaults {
  @UserDefault(name: "authToken") var authToken: String?
}
```

This can be mocked like so:

```swift
extension UserDefaults {
  static let loggedOut = UserDefaults(authToken: .constant(nil))
}

```

Used in something like [Pointfree](https://www.pointfree.co)'s global `Environment` concept for managing dependencies:

```swift
struct Environment {
  var userDefaults: UserDefaults
}

var Current = Environment(userDefaults: .loggedOut)

```

This can be observed like so, which will receives updates on any changes:

```swift
Current.userDefaults.$authToken
  .sink(receiveValue: { authToken in
     if let authToken = authToken {
        print("authToken", authToken)
     }
  })
  .store(in: &cancellables)

```
