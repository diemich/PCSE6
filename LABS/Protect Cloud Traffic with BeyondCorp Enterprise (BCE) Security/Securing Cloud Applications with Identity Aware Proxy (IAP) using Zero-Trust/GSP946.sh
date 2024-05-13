# Scenario
# You're building a minimal web application with Google App Engine, then exploring various ways to use Identity-Aware Proxy to restrict access to the application and provide user identity information to it. Your app will:

# Display a welcome page
# Access user identity information provided by IAP

#Task 1. Deploy the application and protect it using IAP
gcloud services enable iap.googleapis.com

git clone https://github.com/googlecodelabs/user-authentication-with-iap.git
cd user-authentication-with-iap

