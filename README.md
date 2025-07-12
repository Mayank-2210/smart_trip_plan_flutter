# Smart Trip Planner

AI-powered travel assistant that generates day-wise itineraries based on natural language prompts.
--------------------------------------------------------------------------------------------------
Setup Instructions:

Prerequisites:
* Flutter 3.x
* Dart 3.x
* Firebase CLI
* Node.js (for Firebase functions)
* Ollama (local LLM server)

1. Install Dependencies
brew install firebase-cli
flutter pub get
npm install -g firebase-tools
ollama run llama3

2. Configure Firebase
flutterfire configure

3. Start Ollama Server
OLLAMA_HOST=0.0.0.0 ollama serve

----------------------------------------------------------------------------------------------------------------
 Architecture Diagram

```text
+---------------+         +-------------------+       +------------------+
|               |         |                   |       |                  |
|  Flutter App  +-------->+  Firebase Firestore+<---->+ Firebase Auth     |
|               |         |                   |       |                  |
+-------+-------+         +-------------------+       +--------+---------+
        |                                                          ^
        v                                                          |
+---------------+                                          +---------------+
|  Prompt input |                                          | ProfileScreen |
+-------+-------+                                          +-------+-------+
        |                                                          ^
        v                                                          |
+--------------------+   HTTP   +--------------------+       +-------------+
| GenerateItinerary() +-------> + Local Ollama Server+<------+ Tools/Model |
+--------------------+         +--------------------+       +-------------+
```

--------------------------------------------------------------------------------------------------------------------------------

Agent Flow

Step-by-Step Chain:

1. **User Prompt Input**: Natural language ("3-day trip to Manali for adventure")
2. **Request Sent**: POST to local Ollama with prompt
3. **Model Tooling**:

   * Understands prompt
   * Infers location, days, interests
   * Generates JSON output
4. **Validation Layer (in Flutter)**:

   * Ensures correct structure
   * Shows token usage info
5. **Rendering**:

   * UI renders each day of the trip with activities & places
6. **Refinement/Save**:

   * Prompt can be edited and retried
   * Final output saved to Firestore

------------------------------------------------------------------------------------------------------------------

Token Cost Table

| Prompt Type                   | Prompt Tokens | Response Tokens | Total | Estimated Cost (INR) |
| ----------------------------- | ------------- | --------------- | ----- | -------------------- |
| 3-day local city trip         | 45            | 180             | 225   | ₹0.0225              |
| 5-day international itinerary | 65            | 320             | 385   | ₹0.0385              |
| Detailed 7-day plan + hotels  | 90            | 520             | 610   | ₹0.0610              |

> Cost is based on ₹0.0001/token as per our internal simulation.

-----------------------------------------------------------------------------------------------------------------------

Demo Videos

1. [Smart Trip Planner - UI Walkthrough](https://drive.google.com/file/d/1rSy6_b7zoFc2G459koxpYP3jA4XQS4bd/view?usp=drivesdk)
2. [AI Itinerary Generation - End to End Flow](https://drive.google.com/file/d/1rMVKCPYL64Xxa8WlH6Uc97aEPsI6DKZI/view?usp=drivesdk)

-------------------------------------------------------------------------------------------------------------------------
