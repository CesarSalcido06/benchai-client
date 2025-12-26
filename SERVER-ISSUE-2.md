# BenchAI Server Issue - Empty Model Responses

**Date:** December 25, 2024
**Time:** Current session
**Reporter:** Mac client

## Issue

BenchAI server returns error: **"code generation failed: empty response from model"**

## Symptoms

1. Health endpoint works: `http://192.168.0.213:8085/health` returns OK
2. Chat completions endpoint hangs/times out after 30+ seconds
3. No response from model backends
4. User gets error: "code generation failed: empty response from model"

## Test Results

### Health Check - ✅ WORKING
```bash
curl http://192.168.0.213:8085/health
# Response: {"status":"ok","service":"benchai-router-v3",...}
```

### Chat Completion - ❌ FAILING
```bash
curl -X POST http://192.168.0.213:8085/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "auto",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": false
  }'

# Result: Hangs for 30+ seconds, no response
```

## Root Cause

Model backends (ports 8091-8094) are likely:
- Not running
- Crashed
- Not responding to requests
- Network connectivity issues

## Required Action

**Homeserver team: Please check and restart model backends**

1. Check if model containers are running:
```bash
docker ps | grep -E "8091|8092|8093|8094"
```

2. Check model logs for errors:
```bash
docker logs <model-container-name>
```

3. Restart model services if needed

4. Test that models respond:
```bash
curl http://localhost:8091/health  # or whichever port
```

## Impact

- ❌ Neovim plugin not working (gets empty responses)
- ❌ CLI tool not working
- ❌ VS Code Continue.dev not working
- ✅ Router is running (health check works)

## Previous Occurrence

This happened earlier in the session and was fixed by restarting the model backends. The issue has recurred.

## Suggested Permanent Fix

Add health monitoring and auto-restart for model backends to prevent this from happening repeatedly.

---

**Status:** Waiting for homeserver fix
