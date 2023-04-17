# HealthGPT

HealthGPT is an iOS app that allows users to interact with their health data stored in the Apple Health app using natural language. Built on top of CardinalKit and OpenAI, HealthGPT offers an easy-to-extend solution for those looking to make GPT-powered apps within the Apple Health ecosystem.

## Features

- Chat-style interface for user-friendly health data interaction
- Integration with the Apple Health app to ensure seamless synchronization
- Extensible architecture built on CardinalKit for easy customization
- GPT-4 support throught the OpenAI module

## Set Up

1. Clone this repository.
2. Open it in Xcode. Wait for all dependencies to install and indexing to finish.
3. Replace the OpenAI API key in `MessageInputView.swift` with your own from OpenAI's dashboard.
4. Run the app (on device or in the simulator) and play with HealthGPT on your own data 🚀

Note: if you're using the simulator, you will need to manually add data in the Health app. Otherwise, all of your results will read zero.

For any other quick changes, refer to the CardinalKit repo.

## TODOs (feel free to create a PR!)

- [ ] stream GPT responses to the client in order to hide latency
- [ ] store the API key in a config/plist file (or generally in a more secure way)
- [ ] enable users to disconnect health data streams at will
- [ ] provide support for more HealthKit types
