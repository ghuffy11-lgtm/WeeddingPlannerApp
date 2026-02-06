# AI AGENTS - READ THIS FIRST

Welcome to the Wedding Planner App project.

## CRITICAL: Building Flutter

**Flutter is NOT installed locally. Use Docker:**

```bash
cd /mnt/repo/WeeddingPlannerApp/wedding_planner

# Get dependencies
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -w /app ghcr.io/cirruslabs/flutter:latest flutter pub get

# Build APK
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -v "flutter_gradle:/root/.gradle" -w /app ghcr.io/cirruslabs/flutter:latest flutter build apk --debug
```

See `docs/FLUTTER_DOCKER_DEVELOPMENT.md` for all commands.

---

## Before You Do ANYTHING:

### Step 1: Read the Master Instructions
```
Open and read: PROJECT_MANAGEMENT/MASTER_INSTRUCTIONS.md
```

This file contains:
- Project overview
- Your responsibilities
- How to document your work
- Coding standards
- What NOT to do

### Step 2: Check Current Status
```
Open: PROJECT_MANAGEMENT/PROJECT_STATUS.md
```

### Step 3: Find Your Task
```
Open: PROJECT_MANAGEMENT/TASK_TRACKER.md
```

### Step 4: Read Feature Details
```
Open: PROJECT_MANAGEMENT/FEATURE_SPECS.md
```

---

## Quick Rules

1. **ALWAYS** update TASK_TRACKER.md when you start/finish a task
2. **ALWAYS** update CHANGELOG.md when you create/change files
3. **NEVER** guess - ask if something is unclear
4. **NEVER** skip documentation

---

## Project Structure

```
Wedding Planner App/
│
├── AI_AGENTS_START_HERE.md      ← You are here
├── AGENTS.md                    ← Quick reference for AI agents
│
├── PROJECT_MANAGEMENT/          ← All tracking & instructions
│   ├── MASTER_INSTRUCTIONS.md   ← READ THIS FIRST!
│   ├── PROJECT_STATUS.md
│   ├── TASK_TRACKER.md
│   ├── SESSION_LOG.md
│   ├── FEATURE_SPECS.md
│   └── CHANGELOG.md
│
├── docs/
│   ├── TECHNICAL_ARCHITECTURE.md
│   ├── DEVELOPMENT_SETUP.md
│   ├── FLUTTER_DOCKER_DEVELOPMENT.md  ← Docker commands for Flutter
│   └── SESSION_3_SUMMARY.md           ← Design overhaul notes
│
├── design_references/wedapp/    ← UI design from Google Stitch (React)
│
├── wedding_planner/             ← Flutter mobile app code
│
└── Wedding_Planner_Application.md  ← Original UI/UX design
```

---

## Your Documentation Checklist

Before finishing your session, confirm:

- [ ] I updated TASK_TRACKER.md with my progress
- [ ] I added my changes to CHANGELOG.md
- [ ] I documented any decisions in SESSION_LOG.md
- [ ] I documented any problems in SESSION_LOG.md

---

**DO NOT START CODING UNTIL YOU HAVE READ MASTER_INSTRUCTIONS.md**
