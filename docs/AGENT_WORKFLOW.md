# Agent Workflow - MANDATORY REVIEW BEFORE CHANGES

> **STOP!** Before making ANY code changes, complete the pre-change checklist below.

---

## Pre-Change Checklist

Before making ANY code changes, agents MUST:

- [ ] Read `/docs/SKILLS.md` - Check if issue is already documented
- [ ] Read `/docs/ERROR_TRACKER.md` - Check current error status
- [ ] Read `/docs/API_ENDPOINT_MAPPING.md` - Verify correct API URLs
- [ ] Check `/PROJECT_MANAGEMENT/CHANGELOG.md` - Review recent changes
- [ ] Verify the issue in browser/logs before attempting fix

---

## Post-Change Checklist

After making changes, agents MUST:

- [ ] Test the fix manually (build & run)
- [ ] Verify in browser console - NO related errors
- [ ] Update `ERROR_TRACKER.md` with fix details
- [ ] Update `SKILLS.md` if new pattern discovered
- [ ] Add entry to `CHANGELOG.md`
- [ ] Mark verification status (not just "FIXED")

---

## Verification Status Levels

| Status | Meaning |
|--------|---------|
| `OPEN` | Issue identified, not yet addressed |
| `IN_PROGRESS` | Currently being worked on |
| `FIXED_UNVERIFIED` | Code change made, not tested |
| `FIXED_VERIFIED` | Tested and confirmed working |
| `REOPENED` | Previously fixed but issue returned |

**Important:** Never mark an issue as `FIXED_VERIFIED` without actually testing it in browser/app.

---

## Documentation Hierarchy

When investigating or fixing issues, read documents in this order:

```
1. /docs/ERROR_TRACKER.md      <- Active errors with root causes
2. /docs/SKILLS.md             <- Past solutions and patterns
3. /docs/API_ENDPOINT_MAPPING.md <- Correct API URLs
4. /docs/README.md             <- Project overview
```

---

## Common Mistakes to Avoid

### 1. Marking Issues as "FIXED" Without Testing
**Wrong:** Making a code change and immediately marking as FIXED
**Right:** Build the app, test in browser, verify no console errors, THEN mark as FIXED_VERIFIED

### 2. Not Checking Existing Documentation
**Wrong:** Investigating an issue for 30 minutes
**Right:** Check SKILLS.md first - solution may already exist

### 3. Using Wrong API URLs
**Wrong:** Assuming `/api/v1/tasks` exists because Flutter code uses it
**Right:** Check API_ENDPOINT_MAPPING.md for actual backend routes

### 4. Not Updating Documentation
**Wrong:** Fixing a bug and moving on
**Right:** Add to SKILLS.md, update ERROR_TRACKER.md, add to CHANGELOG.md

---

## Error Fix Workflow

```
1. USER REPORTS ERROR
        |
        v
2. CHECK ERROR_TRACKER.md
   - Is this a known error?
   - What's the current status?
        |
        v
3. CHECK SKILLS.md
   - Has this been fixed before?
   - Is there a related pattern?
        |
        v
4. CHECK API_ENDPOINT_MAPPING.md
   - Is Flutter calling the right URL?
   - Does the endpoint exist?
        |
        v
5. INVESTIGATE ROOT CAUSE
   - Check browser console
   - Check backend logs
   - Check Flutter code
        |
        v
6. IMPLEMENT FIX
   - Make minimal changes
   - Follow existing patterns
        |
        v
7. TEST FIX
   - Rebuild app
   - Test in browser
   - Check console for errors
        |
        v
8. UPDATE DOCUMENTATION
   - ERROR_TRACKER.md: Update status
   - SKILLS.md: Add new skill if applicable
   - CHANGELOG.md: Add entry
```

---

## Quick Reference Commands

### Build Flutter Web App
```bash
cd /mnt/repo/WeeddingPlannerApp/wedding_planner
docker run --rm -v "$(pwd)":/app -v "flutter_pub_cache:/root/.pub-cache" -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  flutter build web --release --dart-define=API_BASE_URL=http://10.1.13.98:3010/api/v1
```

### Restart Web Server
```bash
docker restart wedding_planner_web_test
```

### Check Backend Health
```bash
curl http://10.1.13.98:3010/health
```

### View Backend Logs
```bash
docker logs wedding_planner_api --tail 100
```

---

## File Locations Reference

| Type | Location |
|------|----------|
| Technical Docs | `/docs/` |
| Project Management | `/PROJECT_MANAGEMENT/` |
| Flutter App | `/wedding_planner/` |
| Backend | `/backend/` |
| Error Tracking | `/docs/ERROR_TRACKER.md` |
| Skills/Fixes | `/docs/SKILLS.md` |
| API Reference | `/docs/API_ENDPOINT_MAPPING.md` |
