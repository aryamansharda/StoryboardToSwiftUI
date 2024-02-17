# Storyboard to SwiftUI Converter

The Storyboard to SwiftUI Converter is a command-line tool that allows you to convert iOS Storyboard files to SwiftUI code. It provides a convenient way to migrate your existing Storyboard-based projects to SwiftUI, enabling you to leverage the power and flexibility of SwiftUI for UI development.

## Features

- Convert iOS Storyboard files (.storyboard) to SwiftUI code.
- Support for common UIKit elements such as views, view controllers, constraints, and more.
- Customization options for adjusting conversion behavior via stencils or function overrides.
- Easy-to-use command-line interface.

## Installation

### Requirements

- macOS operating system
- Swift 5.0 or later

### Installation Steps

1. Clone the repository to your local machine:
git clone https://github.com/your/repository.git


2. Navigate to the project directory:
cd storyboard-to-swiftui-converter


3. Build the project using Swift Package Manager:
swift build -c release


4. Find the compiled executable in the `.build/release` directory:
cd .build/release


5. Optionally, move the executable to a directory in your PATH for easier access:
cp storyboard-to-swiftui-converter /usr/local/bin


## Usage

To convert a Storyboard file to SwiftUI code, run the following command:

`storyboard-to-swiftui-converter /path/to/YourStoryboard.storyboard`


Replace `/path/to/YourStoryboard.storyboard` with the path to your Storyboard file.

## Customization

You can customize the conversion behavior by providing stencils or overriding functions responsible for the conversion. Refer to the documentation for more information on customization options.

## Examples

Here's an example of converting a Storyboard file named `Main.storyboard`:


## Contact

For support or inquiries, please contact [Aryaman Sharda](mailto:aryaman@digitalbunker.dev).



