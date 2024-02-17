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
`cp storyboard-to-swiftui-converter /usr/local/bin`


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


## Contact

For support or inquiries, please contact [Aryaman Sharda](mailto:aryaman@digitalbunker.dev).
