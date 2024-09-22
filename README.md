![Client](https://deploy-badge.vercel.app/vercel/intelliscribble?style=for-the-badge) ![Backend](https://deploy-badge.vercel.app/?url=https%3A%2F%2Fintelliscribble.vercel.app%2F&style=for-the-badge&logo=render&name=Render)

# IntelliScribble

IntelliScribble is a cross-platform application built with Flutter that runs on Android and web. It provides an intelligent whiteboard where users can draw complex equations, graphs, and diagrams, then solve them using AI. Users can also save their work for future reference.

## Features

- **Interactive Whiteboard**: Draw equations, graphs, and diagrams with ease.
- **AI-Powered Problem Solving**: Utilizes Gemini AI to solve complex problems.
- **Cross-Platform**: Works on Android devices and web browsers.
- **Save Functionality**: Store your work for later use.

## Technologies Used

- Flutter
- Gemini AI
- Supabase
- Flask (Python backend)

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Python 3.7+
- Git

### Installation

1. Clone the repository:

```
git clone https://github.com/mukundsolanki/intelliscribble.git 
cd intelliscribble
```


2. Set up Flutter dependencies:

3. Set up Supabase credentials:
- Copy `lib/example_supabase_credentials.dart` to `lib/supabase_credentials.dart`
- Update `supabase_credentials.dart` with your Supabase project details

4. Set up backend environment:
- Navigate to the `/backend` directory
- Copy `.example.env` to `.env`
- Update `.env` with your environment variables (API keys, etc.)

5. Install backend dependencies:

```
cd backend 
pip install -r requirements.txt
```


### Running the App

1. Start the Flask backend:

2. Run the Flutter app:
- For Android: `flutter run`
- For web: `flutter run -d chrome`

## Contributing

We welcome contributions to IntelliScribble! Here's how you can contribute:

1. Fork the repository
2. Create a new branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

Please ensure your code adheres to the project's coding standards and includes appropriate documentation.

