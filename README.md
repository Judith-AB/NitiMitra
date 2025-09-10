#  NitiMitra

### Problem Statement
For millions of young Indians (18–30), navigating government schemes, taxes, and financial policies is overwhelming. Complex jargon, scattered information, and lack of awareness lead to missed benefits, poor financial planning, and low trust in official processes. Tier-2 and Tier-3 city youth are especially excluded due to language barriers, digital inaccessibility, and lack of personalized guidance. This creates a critical gap where policies designed to empower youth remain underutilized.

---

###  Proposed Solution – NitiMitra
**NitiMitra** is a youth-first digital assistant that:
- Simplifies finance, taxes, and government schemes into **clear, 3–4 line explainers**.  
- Provides **personalized recommendations** based on user profile (age, income, student/working, state).  
- Ensures **trust and transparency** by linking every response to **official government APIs**.  
- Supports **multi-language access** for inclusivity.  
- Features a **voice-enabled chatbot** for natural, multilingual queries with instant, verified answers.  
- Goes **beyond awareness** → step-by-step guidance on how to apply, required documents, deadlines, and **real-time policy updates**.  

By making policy access affordable, inclusive, and transparent, NitiMitra directly contributes to **financial empowerment, digital inclusion, and social equity** for India’s next billion users.  

---

###  Novelty of NitiMitra
- **Youth-first & Personalized** → Built exclusively for young Indians, delivering context-aware guidance tailored to their profile.  
- **Voice-enabled Chatbot** → Natural-language, multilingual queries with instant, verified answers for greater inclusivity.  
- **Clarity + Action with Trust** → Simplifies policies into 3–4 line explainers, cites official sources, and guides users step-by-step to apply.  

---

###  Tech Stack
- **Frontend:** Flutter (Dart) – cross-platform mobile app  
- **Backend & Database:** Firebase (Firestore, Auth, Cloud Functions)  
- **APIs:** Government APIs (API Setu, OGD, IRDAI, RBI, Surepass)  

---

###  Designs / Prototype
Check out our Figma prototype here 👉 [NitiMitra Figma Link](https://www.figma.com/community/file/1547658165259400280/nitimitra-app-ui-design)  

---


###  Work Split-up

#### 🔹 A – Frontend (Flutter – UI/UX)
- Authentication screens (OTP/Google Login)  
- Profile setup (name, age, occupation, state, language)  
- Dashboard design (welcome banner, reel-style personalized cards, quick actions)  
- Navigation flow (Dashboard → Explore → Profile → Calculator)  

#### 🔹 J – Frontend (Flutter – Features)
- Explore section (schemes, taxes, insurance cards)  
- Scheme/policy detail pages (eligibility, apply now, learn more)  
- Document locker upload UI  
- Notifications & alerts UI (push cards, deadline reminders)  

#### 🔹 P – Backend (FastAPI/Flask + Firebase integration)
- Authentication API (OTP, Google, biometric login)  
- Profile management API (CRUD for user data)  
- Notifications API (push alerts, deadlines, reminders)  
- Document locker backend (secure storage, retrieval)  
- Tax calculator API  

#### 🔹 G – AI Development
- Build the AI Assistant logic (answering queries about schemes, taxes, insurance)  
- Prompt engineering for HuggingFace/OpenAI APIs  
- Create eligibility-check algorithm based on user profile (age, income, occupation, state)  
- Implement personalized recommendation engine (ranking and suggesting relevant schemes)  
- Design conversational flow (how AI responds inside the app)  

#### 🔹 M – AI Integration & Testing
- Connect AI Assistant with backend APIs (FastAPI/Flask)  
- Manage data flow between Firebase ↔ AI ↔ Frontend  
- Optimize API calls (rate limits, error handling)  
- Work on AI response formatting (turning raw AI output into clean cards in Flutter)  
- Testing & debugging AI outputs (correctness, relevance, reducing hallucinations)  
- Deployment & monitoring (ensuring AI works smoothly on production)  

#### 🔹 M – Database, Govt API Integration & Testing
- Firebase Firestore for profile, preferences, alerts storage  
- Firebase Storage for document locker  
- Govt portal integration (redirects, DigiLocker, ITR APIs)  
- End-to-end integration testing (Frontend ↔ Backend ↔ AI)  
- Deployment support (Firebase hosting + backend server)  

---
