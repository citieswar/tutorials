# Wiki Player Guide AI Review System - Setup Guide

## Overview
This system adds AI-powered automated review for player-submitted wiki guides using DeepSeek API.

## Components Created

### 1. Database Scripts
**File:** `e:\War\wiki\deploy\Wiki_AddAIReviewFields.sql`

Adds the following fields to `WikiPlayerGuide` table:
- `AIAction` (NVARCHAR(20)): 'approve' / 'review' / 'reject'
- `AIReason` (NVARCHAR(500)): AI explanation
- `AIScores` (NVARCHAR(200)): JSON scores {"safety":5,"relevance":4,...}
- `AIReviewTime` (DATETIME): When AI reviewed

Creates stored procedures:
- `Wiki_GetPendingAIGuides`: Get guides pending AI review
- `Wiki_UpdateAIReviewResult`: Update AI review results

### 2. AI Review Service
**File:** `e:\War\src\server\Common\AIReview.cs`

Encapsulates DeepSeek API calls with:
- Prompt building with game context awareness
- JSON response parsing
- Score-based decision logic (approve/reject/review)
- Error handling and logging

### 3. Data Access Layer
**File:** `e:\War\src\server\User\DataAccess\Account.cs`

Added methods:
- `GetPendingAIGuides(int maxCount)`: Fetch pending guides
- `UpdateAIReviewResult(...)`: Save AI review results

### 4. Background Batch Job
**File:** `e:\War\src\server\WarService\Alexh_BathEx.cs`

New timer `wikiAIReviewTimer` runs every ~1 hour:
- Fetches up to 50 pending guides
- Calls AI review for each
- Updates database with results
- Logs progress to debug.log

### 5. Test Page
**Files:** 
- `e:\War\src\server\WarService\test_ai_review.aspx`
- `e:\War\src\server\WarService\test_ai_review.aspx.cs`
- `e:\War\src\server\WarService\test_ai_review.aspx.designer.cs`

Web interface for testing:
- Single guide review form
- Pending guides list
- Recently reviewed guides table

---

## Setup Steps

### Step 1: Deploy Database Changes

Run the SQL script on your database:

```bash
sqlcmd -S DESKTOP-4RQF446\SQLEXPRESS -d local_war18 -U citieswar -P 198045 -i e:\War\wiki\deploy\Wiki_AddAIReviewFields.sql
```

Or execute directly in SSMS.

### Step 2: Configure DeepSeek API Key

Edit `e:\War\src\server\Common\AIReview.cs`:

```csharp
private static readonly string DEEPSEEK_API_KEY = "sk-your-actual-api-key-here";
```

Replace with your real DeepSeek API key from [platform.deepseek.com](https://platform.deepseek.com).

**Alternative:** Move this to `config.ini` for better security (recommended for production).

### Step 3: Build the Project

Open `War.sln` in Visual Studio 2019 and build, or use MSBuild:

```bash
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" War.sln /p:Configuration=Debug
```

### Step 4: Test the System

#### Option A: Use Test Web Page
Navigate to: `http://localhost/WarService/test_ai_review.aspx`

1. Fill in Title, Summary, Content
2. Click "Review with AI"
3. View AI scores and decision

#### Option B: Wait for Batch Job
The background job runs automatically every ~1 hour. Check `c:\war\log\debug.log` for:
```
[BATH_WikiAIReview] Starting AI review batch...
[BATH_WikiAIReview] Found X pending guides.
[BATH_WikiAIReview] GuideID=Y reviewed: Action=approve, Status=1
```

#### Option C: Submit a Real Guide
Use the game's wiki window to submit a guide (Status=0), then wait for batch processing.

---

## How It Works

### Review Decision Logic

| Condition | Action | New Status |
|-----------|--------|------------|
| All scores ≥ 4 | Auto Approve | 1 (Published) |
| Any score ≤ 2 | Auto Reject | 2 (Rejected) |
| Otherwise | Flag for Human Review | 0 (Pending) |

### AI Evaluation Dimensions (1-5 scale)

1. **Safety**: No sexual content, hate speech, personal info leaks, external ads
2. **Relevance**: Related to Cities War gameplay (military terms like army/attack/war are NORMAL)
3. **Substance**: Meaningful guidance, not spam/gibberish
4. **Quality**: Decent English writing
5. **Formatting**: Well-formed HTML, no malicious tags

---

## Troubleshooting

### AI Review Returns Null
Check `c:\war\log\debug.log` for errors:
- API key invalid → Check DEEPSEEK_API_KEY
- Network timeout → Verify server can reach api.deepseek.com
- JSON parse error → Check response format in logs

### Batch Job Not Running
- Verify `wikiAIReviewTimer` is initialized in `Alexh_BathEx.cs` constructor
- Check IIS application pool is running
- Look for initialization errors in Event Viewer

### Database Fields Missing
Re-run `Wiki_AddAIReviewFields.sql`. The script checks if fields exist before adding.

---

## Cost Estimation

DeepSeek-V3 pricing: ¥1 per million input tokens

Average guide (~1500 chars) ≈ 500 tokens  
Cost per review ≈ ¥0.0005  

For 100 guides/day: ¥0.05/day ≈ $0.007/day  
Monthly cost for 3000 guides: ~¥1.5 ($0.20)

**Very affordable!**

---

## Future Enhancements

1. **Admin Dashboard**: Bulk approve/reject AI-flagged guides
2. **API Key in config.ini**: Better security than hardcoding
3. **Retry Failed Reviews**: Queue system for API failures
4. **Statistics Page**: Track AI accuracy vs human decisions
5. **Custom Thresholds**: Configurable score cutoffs per dimension

---

## Notes

- AI review is **asynchronous** - doesn't block user submission
- Failed AI calls keep Status=0 for later retry
- Game military terminology is explicitly allowed in prompt
- All operations logged to `c:\war\log\debug.log`
