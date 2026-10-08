# Ceylona — Design System & Screen Reference

You are helping me build the UI (visual design only, no backend logic needed yet) 
for a Flutter app called "Ceylona" — a Local Event & Festival Discovery App for Sri Lanka.

## DESIGN SYSTEM

- Primary color: Golden yellow (#FFC107 or similar warm amber/gold)
- Secondary/accent: Black (#000000) for primary buttons and emphasis text
- Background: White / light grey (#F8F8F8)
- Text: Dark grey/black for body text, medium grey for secondary/meta text
- Cards: White background, rounded corners (12-16px radius), subtle shadow
- Buttons: Full-width, rounded (8-10px radius), black fill for primary actions, 
  outlined/white for secondary actions
- Typography: Clean sans-serif (e.g. Inter, Poppins, or Roboto), bold headers, 
  regular body text
- Status badges: colored pills — green (Approved/Published), yellow/orange (Pending), 
  red (Rejected), blue (Changes Requested)
- Icons: simple line icons (Material Icons style)
- Spacing: consistent 16px screen padding, 8-12px between elements

## APP HAS 3 USER ROLES, EACH WITH THEIR OWN BOTTOM NAVIGATION BAR

### ROLE 1: EVENT SEEKER
Bottom nav: Home | Search | Saved | Notifications | Profile

**Screen: Home**
- Greeting header "Hello, [Name]! Ready to explore Sri Lanka?"
- Search bar (rounded, with search icon)
- Horizontal scrollable category pills (All, Cultural, Music, Festivals, Campus, etc.)
- "Popular Now in Sri Lanka" section — horizontal scrollable event cards 
  (image, verified badge, title, date/time, location)
- "Nearby Suggestions" section — similar card style
- Multiple category sections below (Music Events, Cultural Events, Food Events, 
  University Events, Technology Events, Sports Events, Others), each with a 
  "See All →" link and horizontal scrollable cards

**Screen: Search & Filter**
- Keyword search field
- Location dropdown field
- Date Range field (e.g. "This Weekend")
- Category chips (multi-select): Music, Sports, Tech, Art, Business, Education, 
  Cultural, Others
- "Apply Filters" full-width black button
- "Clear All" text link top-right

**Screen: Search Results**
- Header: "03 Events Found Matching Criteria"
- Filter chips row (Colombo, This Weekend, Music)
- Vertical list of event cards: thumbnail (left), title, verified badge, 
  date/time, location (right)
- "Search Again" button at bottom

**Screen: Event Details**
- Full-width hero image with back button overlay
- Event title (bold, large)
- "Verified Organizer" badge chip
- Date/time row with calendar icon
- Venue/location row with pin icon
- Ticket price range (e.g. "LKR 3,500 - LKR 7,500") with "Presale Active" tag
- "About the Event" section — long description text
- Lineup/performer list if applicable
- Action buttons row: "View Map" | "Set Reminder" | "View Schedule" (outlined buttons)
- "Get Tickets" full-width black button
- "View Photo Gallery" link
- Related events horizontal carousel at bottom ("Music Events See All →")

**Screen: Event Location (Map & Directions)**
- Map area (grey placeholder box with center pin icon), rounded corners
- Venue name (bold) + address (grey) + distance ("~3.2 km from your location")
- "Suggested Transport" section — 3 equal-width boxes side by side: 
  Bus (route number), Taxi (Uber/PickMe), Train (station name)
- "Get Directions" full-width black button at bottom

**Screen: Schedule & Facilities**
- "Event Timeline" section — vertical list, each row: time (left, bold) + 
  activity description (right), e.g. "6:00 PM  Gates Open & Opening Ambient Sets"
- "On-Site Facilities" section — vertical list, each row: icon in grey circle 
  (left) + facility name (bold) + description (grey, below), covering: 
  Parking, Public Transport, Food & Drinks, Restrooms, First Aid

**Screen: Saved Events**
- "Upcoming Saved Events (3)" header
- Vertical list of saved event cards (same card style as search results)
- Empty state: icon + "No More Saved Events" + "Browse events and tap the 
  bookmark icon to save them here"
- Calendar icon button in app bar (top right) to go to Calendar screen

**Screen: Calendar & Reminders**
- Monthly calendar card at top: month/year header with ◀▶ arrows, day labels 
  (S M T W T F S), date grid, selected date shown as filled black circle
- "Events on This Day" section — card with small thumbnail + event title, 
  date, time
- "Reminder Settings" section — dropdown (e.g. "1 day before") with bell icon
- Green confirmation text: "Reminder set for Oct 22 at 6:00 PM"
- "Add to Calendar" full-width black button at bottom

**Screen: Notifications**
- Filter tabs: All | Updates | Reminders
- Vertical list of notification cards, each with icon + title + description + 
  timestamp ("2h ago"), types: Event Reminder, Venue Updated, Schedule Change, 
  New Event Added, General Update

**Screen: Event Discussion**
- Event summary card at top (image, title, date)
- "Discussion for this event" / "All Comments - Newest" section
- Comment input box with optional rating (stars) and photo attach, 
  "Post Comment" button
- List of existing comments: avatar/initial circle, name, timestamp, comment 
  text, Reply link, like count

**Screen: Profile & Settings**
- Profile photo (circular) + name + email at top
- Vertical settings list with icons: Personal Information, Language, 
  Notification Settings, Privacy & Security, Help & Support, About Us
- "Become an Organizer" highlighted button/row
- "Log Out" button at bottom

**Screen: Photo Gallery**
- Year filter tabs: All | 2025 | 2024 | 2023
- Vertical list of event albums: thumbnail, event name, date, photo count 
  ("25 photos")

### ROLE 2: EVENT ORGANIZER
Bottom nav: Home | Events | Create | Analytics | Profile

**Screen: Organizer Hub (Dashboard)**
- "Welcome, [Name]" header
- Key Metrics: 4 stat cards in a grid (Total Registrations, Event Views, 
  Interested, Upcoming Events) — big number + label + small % change indicator
- "Manage Events" section — "See All" link, vertical list of event cards with 
  status badge (Live/Published/Pending) and registration count

**Screen: Create Event**
- "Upload Event Poster" — dashed-border drop zone with upload icon, 
  "Drag & drop or tap to browse (16:9 recommended)"
- Event Name text field (e.g. "SLIIT CodeFest 2026")
- Category dropdown ("Select Event Category")
- Description multi-line text area
- Date field (calendar picker) + Time field (clock picker) side by side
- Venue Name field + Exact Address field
- Map Preview box (small, auto-generated from address)
- Ticket Price (LKR) field — "0.00 (Leave free if no charge)"
- Registration Link field — "https://your-registration-portal.com"
- Parking & Transport Info multi-line field
- Two buttons at bottom: "Save Draft" (outlined) and "Publish Event" (black, filled)

**Screen: Manage Event**
- Event summary card: poster thumbnail, title, date, venue (each with small 
  edit pencil icon)
- Key metrics row: Registrations | Attended | Views
- "Event Schedule" section with "Add Agenda Item" button, list of time + 
  activity rows
- "Notify Attendees" card — explanation text + Send Email / Push Notification 
  toggle switches
- "Cancel" and "Publish Updates" buttons at bottom

**Screen: Registrations & Analytics**
- Stat row: Registrations | Attended | Views (large numbers)
- "Registration Trend" — bar chart, days of week (Mon-Sun) on x-axis, with 
  "+24% vs Last Week" badge
- "Attendance Breakup" — donut/pie chart showing Attended vs Pending with 
  percentage labels
- "Registered Attendees (420)" — search bar + scrollable list, each row: 
  avatar initial circle, name, email, status badge (Checked-in/Pending)

### ROLE 3: EVENT AUTHORITY OFFICER (ADMIN)
Bottom nav: Dashboard | Approvals | Notifications | Profile
(same 4-item nav bar repeats identically at the bottom of every admin screen)

**Screen: Admin Dashboard**
- Top-right: circular avatar with initials (e.g. "AP")
- Greeting header: "Welcome Back, [Name]" + subtext "You have 12 pending event 
  submissions awaiting action."
- 4 stat cards in a row, equal width, white cards with big bold number + grey 
  label underneath: Pending (12) | Approved (38) | Rejected (7) | Total (57)
- Search bar: "Search events or organizers" (rounded, search icon left)
- Recent activity feed below — compact list rows, each: small icon/tag 
  (e.g. "approval", "submission", "reminder", "urgent") + one-line description 
  + relative timestamp right-aligned (grey, small), e.g.:
  - "Colombo Cultural Festival was approved and will become publicly visible 
    in Ceylona Fest." — 2 hours ago
  - "Colombo Food Festival has been submitted for review by Kasun Jayawardena." 
    — 3 hours ago
  - "University Robot Battle requires immediate venue safety verification." 
    — tagged "urgent" — 5 hours ago

**Screen: Event Approvals (list)**
- Search bar: "Search events or organizers"
- "Filters" button (top-right, outlined, filter icon) opens filter sheet with:
  Status (All statuses / Pending Review / Approved / Rejected / Changes 
  Requested) dropdown, Category dropdown, Event date field, "Apply Filters" 
  black button, "Clear Filters" text link
- Status filter chips row, horizontally scrollable, selected chip filled black
- Vertical list of submission cards, white rounded cards, each showing:
  - Event title (bold)
  - "by [Organizer Name]" (grey, smaller, below title)
  - Category tag + Event date + Venue/location (small grey rows with icons)
  - Status badge pill, top-right of card, color-coded:
    🟡 Pending Review (yellow/amber) · 🟢 Approved (green) · 
    🔴 Rejected (red) · 🔵 Changes Requested (blue)
  - "View Details" link, bottom-right of card
  - "Submitted [date]" small grey text, bottom-left of card
  Example cards: "Colombo Cultural Festival" (Pending Review, by Nadeesha 
  Perera · Ceylon Arts Collective), "Sri Lankan Holi Fest" (Rejected, by 
  Dilan Wijesinghe)

**Screen: Submission Details**
- Back arrow + "Back to Approvals" link at top
- Event poster image (full width, 16:9)
- "Event summary" section — label rows (not boxes), each: grey label left 
  ("Category", "Event date", "Venue / location"), value right/below (bold):
  e.g. Category: "Culture & Festival", Event date: "24 October 2026 · 
  10:00 AM-8:00 PM", Venue: "Viharamahadevi Park, Colombo 07"
- "Description" section — paragraph text below summary
- "Organizer" card — boxed section with header "Organizer", containing:
  Full Name, Organization, Email Address, Phone Number rows (label + value)
- "Submitted media & documents" section — file chip rows with file-type icon 
  + filename, e.g. "Event poster.jpg", "Venue permit.pdf", "Safety plan.pdf"
- "Continue to Decision" full-width black button at bottom

**Screen: Review Checklist**
- Header: "Review Checklist" + subtitle "Verify every item before deciding 
  on [Event Name]."
- "Verification progress" label + fraction indicator "5/6" (right-aligned or 
  as a progress bar)
- "Required checks" section — vertical checklist, each row: checkmark circle 
  (✓ filled green when checked, empty grey circle when not) + check label:
  - Event information is complete ✓
  - Organizer and contact verified ✓
  - Date and venue are valid ✓
  - Description is clear and accurate ✓
  - Media meets quality requirements ✓
  - Policy compliance confirmed (unchecked — the 6th item)
- "Review notes" text area — free text, e.g. "Venue permit is present. 
  Confirm final crowd capacity and emergency exit signage with organizer."
- "Submit Decision" full-width black button at bottom

**Screen: Submit Decision**
- Event summary mini-card at top (title + organizer)
- "Status" section — three large side-by-side or stacked buttons:
  Approve (green fill), Request Changes (yellow/amber outline or fill), 
  Reject (red outline or fill)
- When Request Changes or Reject is tapped, reveal:
  - "Reason categories" — checkbox list: Incomplete event information, 
    Organizer verification needed, Venue or date issue, Media quality issue, 
    Policy or safety concern
  - "Admin feedback *" required multi-line text box — helper text: "The 
    organizer will be notified immediately. Rejection requires a new 
    submission." Example content: "Please confirm the approved crowd 
    capacity and upload a revised venue plan showing all emergency exits."
  - "Internal notes" separate multi-line text box — helper text: "Follow up 
    within three working days. Not visible to organizer." (visually distinct, 
    e.g. grey background, to show it's private)
  - "Cancel" (outlined) and "Submit Decision" / confirm action button (black) 
    at bottom
- Confirmation screen after submit — centered layout: green checkmark circle 
  icon, "Event Approved" heading (or "Rejection Notice Sent" / "Changes 
  Requested"), one-line summary text ("Colombo Cultural Festival has 
  successfully been approved."), "View Next Submission" button below

**Screen: Admin Notifications**
- Header: "Notifications" + "5 unread" subtitle, "Mark all read" link top-right
- Filter tabs row: All | Unread | Submissions
- Vertical list of notification cards, each: small category tag top 
  ("submission" / "approval" / "reminder" / "urgent", shown as a tiny pill or 
  label), bold one-line title, grey description text below, relative 
  timestamp right-aligned (e.g. "Yesterday", "2 days ago", "4 days ago")
  Examples:
  - "New Event Submission" — "Colombo Food Festival has been submitted for 
    review by Kasun Jayawardena." — tag: submission
  - "Submission Updated" — "Traditional Pond Fair updated their description 
    and contact info." — tag: submission
  - "Approval Reminder" — "Sri Lankan Heritage Walk is pending review for 
    more than 3 days." — tag: reminder, styled as urgent/overdue (e.g. 
    red/orange accent)
  - "Event Approved" — "Colombo Cultural Festival has successfully been 
    approved." — tag: approval
  - "Rejection Notice Sent" — "Sri Lankan Holi Fest was rejected. Reason: 
    Incorrect permit." — tag: urgent

**Screen: Admin Profile**
- Top: circular avatar with initials (e.g. "AP"), name "Amal Perera", role 
  label "Senior Admin" below name, small "Edit Profile" link/icon near name
- "Account Information" card — label + value rows: Email Address 
  (amal.perera@ceylona.lk), Phone Number (+94 77 123 4567), Member Since 
  (Jan 2024), Last Login (Today at 9:42 AM)
- "Security" section card:
  - Two-Factor Authentication — toggle switch
  - Change Password — row with ">" chevron, subtext "Updated 2mos ago"
- "Notification Preferences" section card — toggle switches for: Email 
  Notifications, Push Notifications, SMS Alerts, Weekly Summary Digest, 
  Weekly Check-in
- "Log Out" button/link at the very bottom (red text or outlined button)

### ONBOARDING & AUTH SCREENS

**Screen: Splash + Onboarding (4 slides)**
- Ceylona logo on yellow background
- 4 swipeable slides, each: illustration placeholder + headline + description + 
  page dots indicator + "Skip" top-right + next arrow button
  1. "Discover Events You'll Love"
  2. "100% Trust Every Event"  
  3. "Plan Your Journey Easily"
  4. "Never Miss an Update"

**Screen: Welcome / Role Selection**
- "Welcome to Ceylona" + tagline
- 3 buttons: "Login As a Event Seeker", "Login As a Event Organizer", 
  "Login As a Event Authority Officer"

**Screen: Login / Register**
- Email field, Password field (with show/hide icon)
- "Continue with Email" black button
- "Or" divider
- "Continue with Google" outlined button with Google icon
- Toggle link: "Already have an account? Login" / "Already haven't an 
  account? Register"
- "Forgot Password" link

**Screen: Email Verification (OTP)**
- "We've sent a verification code to your email" text
- 6 individual digit input boxes
- "Verify" button
- "Didn't receive a code? Send Again" link

**Screen: Forgot/Reset Password**
- Forgot: email field + "Submit" button
- Reset: New Password + Confirm Password fields + "Reset Password" button
