# Storyboard to SwiftUI Converter

The Storyboard to SwiftUI Converter is a command-line tool that allows you to convert iOS Storyboard files to SwiftUI code. It provides a convenient way to migrate your existing Storyboard-based projects to SwiftUI, enabling you to leverage the power and flexibility of SwiftUI for UI development.

## Features

- Convert iOS Storyboard files (.storyboard) to SwiftUI code.
- Support for common UIKit elements such as views, view controllers, labels, text fields, and more.
- Customization options for adjusting conversion behavior via stencils or function overrides.
- Easy-to-use command-line interface.

## Installation

### Requirements

- macOS 13.0 operating system
- Swift 5.0 or later

### Installation Steps

1. Clone the repository to your local machine:
`git clone https://github.com/your/repository.git`


2. Navigate to the project directory:
`cd storyboard-to-swiftui-converter`


3. Build the project using Swift Package Manager:
`swift build -c release`


4. Find the compiled executable in the `.build/release` directory:
`cd .build/release`


5. Optionally, move the executable to a directory in your PATH for easier access:
`cp StoryboardToSwiftUI /usr/local/bin`

6. Otherwise, you can just run:
`./StoryboardToSwiftUI` 
and pass in the path to the .storyboard file when prompted.

## Usage

To convert a Storyboard file to SwiftUI code, run the following command:

`storyboard-to-swiftui-converter /path/to/YourStoryboard.storyboard`


Replace `/path/to/YourStoryboard.storyboard` with the path to your Storyboard file.

## Customization

You can customize the conversion behavior by providing stencils or overriding functions responsible for the conversion. Refer to the documentation for more information on customization options.


## Disclaimer

Please note that while this tool aims to provide a smooth transition from Storyboards to SwiftUI, it may not produce a perfect conversion due to variations in coding standards, preferences, and custom classes/configurations used in Storyboards. However, it should get you at least 80% of the way there and help reduce some of the tediousness of moving off of Storyboards. From the output code, it should be a minor lift to get it to meet your standards.


## Examples

Here's an example of the output:

```swift
import DesignSystem
import SwiftUI

public struct EarningsScreen: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .space16) {
                Text(youllReceiveOfTheTrip)
                    .textToken(.body)
                VStack(alignment: .leading, spacing: .space16) {
                    Text(example)
                        .textToken(.headerXS)
                    Text(yourAverageDailyPriceFor)
                        .textToken(.body)
                }
            }
        }
    }
}

extension EarningsScreen {
    var youllReceiveOfTheTrip: String {
        NSLocalizedString(
            "youll_receive_of_the_trip",
            value: "You’ll receive 75% of the trip price after your weekly/monthly discount, if applicable.",
            comment: <#T##String#>
        )
    }

    var example: String {
        NSLocalizedString(
            "example",
            value: "Example",
            comment: <#T##String#>
        )
    }

    var yourAverageDailyPriceFor: String {
        NSLocalizedString(
            "your_average_daily_price_for",
            value: "Your average daily price for the next seven days is $63.",
            comment: <#T##String#>
        )
    }
}
```

## Contact

For support or inquiries, please contact [Aryaman Sharda](mailto:aryaman@digitalbunker.dev).
