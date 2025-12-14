# Giftwise

Giftwise is a Ruby on Rails application that helps you plan gifts for the people in your life  
With it you can:
* Create an account via email/password sign-up and log in
  * Giftwise supports Google sign-in using OmniAuth
* Add **recipients** with details like age, gender, relationship, likes, and dislikes
* Create **events** (e.g., birthdays, holidays) with dates, locations, and budgets
* Associate recipients with events and view event-specific recipient lists
* Organize ideas into **gift lists** and concrete **gifts**
  * Gift lists grouped by event/recipient, plus individual gifts with status fields (idea, purchased, etc.)
* Ask an **AI assistant** (OpenAI) to generate gift suggestions based on recipient attributes, likes/dislikes, and event context
  * Suggestions are cached and can be re-used
## To use locally
### Clone the repository
Using HTTPS:
`git clone https://github.com/hjmjohnsonSELT2025/giftwiseproject-selt_2025_team_02.git`\
Using SSH:
`git clone git@github.com:hjmjohnsonSELT2025/giftwiseproject-selt_2025_team_02.git`

### Install Ruby Gems
`bundle install`

### Configure Environment Variables



**Add Google OAuth credentials**\
To enable Google login locally, you must set the following environment variables:

On macOS/Linux:
`export GOOGLE_CLIENT_ID="your-google-client-id"`
`export GOOGLE_CLIENT_SECRET="your-google-client-secret"`

On Windows PowerShell:
`$env:GOOGLE_CLIENT_ID="your-google-client-id"`
`$env:GOOGLE_CLIENT_SECRET="your-google-client-secret"`

Or manually set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET in .env on in your IDE
\
\
**OpenAI**\
Giftwise uses AiGiftService to talk to the OpenAI API. It expects an OPENAI_API_KEY in the environment\
To enable OpenAI locally, you must set the following environment variables:

On macOS/Linux:
`export OPENAI_API_KEY="your-real-openai-api-key"`

On Windows PowerShell:
`$env:OPENAI_API_KEY="your-real-openai-api-key"`

Or manually set OPENAI_API_KEY in .env on in your IDE

**Google Search API**\
Giftwise uses SerpAPI to integrate gift item search data as gift offers. It expects a SERPAPI_API_KEY in the environment\
To enable SerpAPI locally, you must set the following environment variables:

On macOS/Linux:
`export SERPAPI_API_KEY="your-real-serpapi-api-key"`

On Windows PowerShell:
`$env:SERPAPI_API_KEY="your-real-serpapi-api-key"`

Or manually set SERPAPI_API_KEY in .env on in your IDE

### Set Up the Database

This app uses SQLite with development and test databases stored under storage

Run:\
`bin/rails db:prepare`\
`bin/rails db:seed`

`db:prepare` will create the dev/test databases and load the schema from db/schema.rb
`db:seed` loads sample data defined in `db/seeds.rb`:
* Creates a default user
* Creates sample recipients
* Creates a sample event and associates recipients with it

### Start the Rails Server
Once dependencies and the database are set up, run:\
`bin/rails server`

### Using the App
* Open http://localhost:3000 in your browser
* Log in using the seeded account, sign-in using Google OmniAuth, or sign up with a new account via the Sign Up page
* Add recipients with their demographic info and preferences
* Create events and associate recipients with those events
* Create gift lists and gifts linked to events and/or recipients
* From a recipient or event view, use “Get suggestions” to request AI-generated gift ideas
