# GeoLinked - Comprehensive Feature Guide 🌍

This document provides a detailed breakdown of every feature in GeoLinked, explaining how each screen works and how your interactions affect other users in the community.

---

## 📍 Page 1: The Interactive Community Map
The Map is your central hub for real-time local awareness.

### Features:
- **Marker Clustering**: When multiple events (Asks or Broadcasts) are close together, they group into a single numbered circle. Zoom in to see individual markers.
- **Dynamic Search**: Use the top search bar to find specific places. Tapping a result moves the map camera and focuses that area.
- **"My Location" Button**: Instantly centers the map on your blue dot.
- **Target Selection Mode**: When starting an Ask or Broadcast, you enter a special mode where tapping the map places a green pulse marker to define the center of your query.

### What happens when...
- **...you tap a Marker?** The app navigates you to the **Discussion Screen** for that specific post.
- **...you zoom out?** Markers merge into clusters to keep the interface clean and fast.

---

## 💬 Page 2: Community Asks (Query Feed)
The Ask screen is where you seek help from people physically located in a specific area.

### Features:
- **History List**: A list of all active questions you've asked or that are relevant to your current location.
- **Skeleton Loading**: Professional shimmers appear while the app fetches the latest queries from the community.
- **Empty States**: If no one is asking anything nearby, you'll see a friendly screen encouraging you to start the first conversation.

### The "Ask" Flow (User Interaction):
1. **User A (The Asker)**: Initiates an Ask, selects a 500m radius around a shop on the map, and attaches a photo of the shopfront.
2. **System**: The app calculates a **Geohash** for that location and stores it in Firestore.
3. **User B (The Neighbor)**: If User B is within that 500m radius, a notification (FCM) is triggered. The Ask appears in their feed and as a green icon on their map.
4. **Engagement**: User B taps the notification, views the photo (using pinch-to-zoom), and replies: *"Yes, they just opened!"*

---

## 🚨 Page 3: Local Broadcasts (Alert Feed)
Broadcasts are for sharing information (Traffic, Safety, Events) with a wider audience.

### Features:
- **Category Icons**: Unique visual markers for different types of alerts (Traffic, Road Blocks, Market Updates, etc.).
- **Severity Levels**: Alerts are color-coded (Blue for Info, Red for High/Critical) based on their urgency.
- **Image Thumbnails**: Small previews of attached photos with borders colored by the alert's severity.

### The "Broadcast" Flow (User Interaction):
1. **User A (The Reporter)**: Spots a road block, selects "Road Block" category, attaches a photo, and sets a 5km broadcast radius.
2. **User B (The Commuter)**: Sees a **Red Warning Marker** on their map while driving 3km away. 
3. **Detail View**: User B taps the marker, zooms into the photo to see the exact lane blocked, and hits "Verify" (Verified count increases).
4. **Verification**: As more neighbors verify, the alert gains credibility in the community.

---

## 📂 Page 4: Profile & Private Data
This page manages your identity and community settings.

### Features:
- **Community Score**: Tracks your "Helpfulness Score" based on how many of your replies are helpful or how many broadcasts you've verified.
- **Radius Settings**: Adjust your default "Search Radius." This controls how much of the community's noise you see on your main feed.
- **Privacy Policy**: A dedicated screen explaining that your location is used only for community matching and is never sold.
- **Account Deletion**: A secure, "Nuke" option that deletes your Auth record, Firestore profile, and all your media from Firebase Storage.

---

## 🖼️ Shared Feature: Pinch-to-Zoom Viewer
Available on any post with an image (Asks or Broadcasts).

### What happens when...
- **...you tap an image?** A full-screen black overlay opens.
- **...you pinch your fingers?** You can zoom in up to 2.5x to see fine details (like a sign on a door or a license plate in a traffic report).
- **...you swipe down?** The viewer closes smoothly with a Hero animation back to the card.

---

## ⚙️ Background Logic: How you stay "Linked"
GeoLinked uses **Background Location Sync** to keep you in the loop even when the app is in your pocket.

- **Periodic Sync**: Every 15-20 minutes, the app securely updates your location geohash.
- **Proximity Alerts**: If a new "Critical" Broadcast is made near your last synced location, the system sends a Push Notification to your device instantly.
