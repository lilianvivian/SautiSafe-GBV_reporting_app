# **GBV Reporting Application (Sauti Safe)**
### [Click Here to View Live Demo] (https://gbv-reporting-app-d097d.web.app)
This is a Flutter-based mobile application designed to provide a secure and confidential platform for reporting incidents of Gender-Based Violence (GBV). It empowers survivors and witnesses to safely document incidents, seek immediate help, and access vital resources.

The app is built with a backend on Firebase, ensuring that data is stored securely and can be accessed by authorized administrators for intervention.

## **🚀 Core Features**

Secure User Authentication: Safe and secure email/password login and registration.

**Role-Based Access:**

User Role: Can access all user-facing features.

Admin Role: Can access a special Admin Panel to view all submitted reports and live SOS alerts.

Real-Time SOS Alert: A one-touch button that captures the user's current GPS location and sends it to a live sos_alerts collection in the database.

Emergency Help: Quick-access buttons to immediately call or SMS local helplines (e.g., 116 in Kenya).

Incident Reporting: A comprehensive form to report an incident, including location and a detailed description.

Evidence Upload: Users can attach evidence (photos, videos, or audio recordings) to their reports, which are uploaded securely to Firebase Storage.

Panic Exit Feature: Users can shake their device to immediately log out and close the app, redirecting to a "camouflage" screen for safety.

## 💡 **Application Logic (How it Works)**

This section details the technical flow for the app's most important features.

### **1. Admin Access (Role-Based Logic)**

A user logs in using Firebase Authentication.

Upon successful login, the app's HomePage triggers.

The initState on the HomePage calls the _checkUserRole function.

This function takes the user.uid from Firebase Auth and uses it to query the Cloud Firestore database for a specific document: users/{user.uid}.

It checks that document for a field: role == "admin".

If true, a state variable _isAdmin is set, and the Admin Panel tab is dynamically added to the bottom navigation bar.

### **2. Real-Time SOS Alert Flow**

The user taps the "Send SOS Alert" button on the RealTimeSOSPage.

The geolocator package requests location permissions and fetches the device's current GPS latitude and longitude.

This data, along with a FieldValue.serverTimestamp(), is written as a new document to the sos_alerts collection in Cloud Firestore.

The action is secured by Firestore Rules, which only allow this write (allow create) if the user is authenticated (request.auth != null).

### **3. Report Submission with Evidence**

The user fills out the form on ReportCasePage and attaches files (e.g., a photo) using image_picker or file_picker.

When "Submit" is pressed, the app first loops through the list of File objects.

For each file, it uploads the file to Firebase Storage in a folder named evidence/.

After the upload is complete, the app gets the file's permanent downloadUrl.

Once all files are uploaded, the app creates a single document in the reports collection in Cloud Firestore. This document contains the text from the form fields and a list (evidenceUrls) containing all the downloadUrl strings.

### **4. Panic Exit (Shake Detection)**

The PanicExitPage.initialize() method is called when the app starts.

This starts a listener on the sensors_plus package, subscribing to the userAccelerometerEvents stream.

The app monitors the G-force on the device. If the force exceeds a set threshold (e.g., 2.7 G's), it triggers the triggerPanicExit function.

This function uses Get.offAll() to immediately clear the entire navigation history (removing all sensitive pages from memory) and replace the screen with a harmless CamouflagePage.

## **🛠️ Technology Stack**

Framework: Flutter (Dart)

Backend: Firebase

Database: Cloud Firestore

File Storage: Firebase Storage

Authentication: Firebase Authentication

## **Key Packages:**

cloud_firestore & firebase_auth & firebase_storage

sensors_plus (for shake-to-exit)

geolocator (for live SOS location)

image_picker & file_picker & record (for evidence)

url_launcher (for calling/texting helplines)

get (for state management and navigation)

## **⚙️ Getting Started (Setup Instructions)**

To run this project locally for evaluation, follow these steps.

Prerequisites

Flutter SDK

A code editor (like VS Code or Android Studio)

An Android device or emulator

### **1. Clone the Repository**

git clone [https://your-repository-url.git](https://your-repository-url.git)
cd gbv_reporting_app


### **2. Install Dependencies**

flutter pub get


### **3. Configure Firebase**

This is the most important step. The app will not run without a Firebase project.

Create a Firebase Project:

Go to the Firebase Console.

Click "Add project" and follow the setup steps.

Upgrade to the "Blaze" Plan:

In your new project, click the "Upgrade" button on the bottom-left (it's next to the "Spark" plan).

You must add a billing account. This is required to use Firebase Storage. You will not be charged, as you will stay within the generous free tier.

This step is required to fix the file upload error.

Add Your Android App:

In the Project Overview, click the Android icon (</>).

Package Name: com.example.gbv_reporting_app (You can find this in android/app/build.gradle.kts).

Download the google-services.json file.

Place google-services.json:

Move the downloaded google-services.json file into the android/app/ directory in your project.

Enable Firebase Services:

Authentication: Go to the "Authentication" tab, click "Get started," and enable Email/Password as a sign-in provider.

Firestore Database: Go to the "Firestore Database" tab, click "Create database," and start in production mode.

Storage: Go to the "Storage" tab, click "Get started," and follow the prompts (it will work now that your project is on the "Blaze" plan).

### **4. Set Up Security Rules**

You must update the security rules for both Firestore and Storage to allow your app to work.

### **A. Firestore Rules**

Go to Firestore Database -> Rules tab.

Copy the entire contents and paste them into the console's editor, replacing any existing text.

Click "Publish".

### **5. Create an Admin User**

To test the Admin Panel, you must manually give your user an "admin" role.

Run the app (flutter run) and sign up for a new account with your email.

Go to the Firebase Console -> Authentication tab. Find your user and copy their User UID.

Go to the Firestore Database tab.

Create a new collection named users.

Click "Add document" and paste your User UID as the Document ID.

Add one field

Save the document.

Log out of the app and log back in. The "Admin" tab will now appear.

### **6. Run the App**

You are all set!
``
flutter run
```
