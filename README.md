# keyri-pod

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

`keyri-pod` is distributing as private pod, so be able using it consumer must have access to the [spec repo](https://github.com/anovoselskyi/keyri-specs), and must add the private repo to local Cocoapods installation with the command:

```ruby
pod repo add keyri-specs https://github.com/anovoselskyi/keyri-specs.git
```

## Installation

keyri-pod is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/anovoselskyi/keyri-specs.git'

pod 'keyri-pod'
```

## Author

anovoselskyi, anovoselskyi@gmail.com
