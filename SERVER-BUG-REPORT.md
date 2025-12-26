# CRITICAL: BenchAI Server Bug - Chat Endpoint Hangs

## Issue
The `/v1/chat/completions` endpoint is completely broken and never responds.

## Evidence

### Health Endpoint: WORKS
```bash
$ curl http://192.168.0.213:8085/health
{"status":"ok","service":"benchai-router-v3","features":{"streaming":true,"memory":true,"tts":true,"rag":true,"obsidian":true}}
# Response time: < 1 second
```

### Chat Endpoint: BROKEN
```bash
$ curl -X POST http://192.168.0.213:8085/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "auto",
    "messages": [{"role": "user", "content": "say hello"}],
    "max_tokens": 50,
    "stream": false
  }'

# Result: HANGS INDEFINITELY
# Waited: 120+ seconds
# Bytes received: 0
# Status: Connection established, no response
```

## Impact

This is why Neovim appears to "infinitely generate":
1. Neovim sends request to `/v1/chat/completions`
2. Server never responds
3. Neovim times out after 30 seconds
4. User sees hang/freeze

**This is NOT a client issue - it's a server bug.**

## What Needs to be Fixed on Server

Check `/benchai/router/llm_router.py`:

### 1. Chat Completions Endpoint Handler
```python
# Find the /v1/chat/completions endpoint
# Check if it's:
# - Actually being called
# - Hanging on model inference
# - Waiting on a dead backend service
# - Missing error handling
```

### 2. Model Backend Connection
```python
# Check if model servers are responding:
# - http://localhost:8091 (Phi-3)
# - http://localhost:8092 (Qwen2.5)
# - http://localhost:8093 (DeepSeek)
# - http://localhost:8094 (Qwen2-VL)
```

### 3. Streaming vs Non-Streaming
```python
# The request was stream=false
# Check if non-streaming mode is implemented
# Maybe only streaming works?
```

## Diagnostic Commands (Run on Homeserver)

### Check if BenchAI router is running
```bash
sudo systemctl status benchai
sudo journalctl -u benchai -n 50
```

### Check if model backends are accessible
```bash
# Test each model server
curl http://localhost:8091/health
curl http://localhost:8092/health
curl http://localhost:8093/health
curl http://localhost:8094/health
```

### Test chat endpoint locally on server
```bash
curl -X POST http://localhost:8085/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "general",
    "messages": [{"role": "user", "content": "test"}],
    "max_tokens": 10,
    "stream": false
  }' \
  --max-time 10
```

### Check server logs while testing
```bash
# Terminal 1: Watch logs
sudo journalctl -u benchai -f

# Terminal 2: Send request
curl -X POST http://localhost:8085/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "auto", "messages": [{"role": "user", "content": "hi"}]}'
```

Look for:
- Errors in logs
- Which model is being selected
- If request even reaches the handler
- Where it's hanging

## Quick Fix Attempts

### 1. Restart BenchAI Service
```bash
sudo systemctl restart benchai
# Wait 10 seconds
curl http://192.168.0.213:8085/health
# Test chat again
```

### 2. Check Model Containers
```bash
docker ps | grep -E "phi|qwen|deepseek"
# All 4 model containers should be running
```

### 3. Restart Model Containers
```bash
docker restart $(docker ps -q --filter "name=phi")
docker restart $(docker ps -q --filter "name=qwen")
docker restart $(docker ps -q --filter "name=deepseek")
```

### 4. Check Router Code
```bash
cd ~/BenchAI/benchai/router
cat llm_router.py | grep -A 20 "/v1/chat/completions"
# Look for the endpoint definition
```

## Expected Behavior

When working correctly:
```bash
$ curl -X POST http://192.168.0.213:8085/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "auto", "messages": [{"role": "user", "content": "say hi"}], "max_tokens": 10}'

# Should return within 5-10 seconds:
{
  "choices": [{
    "message": {"role": "assistant", "content": "Hello!"},
    "finish_reason": "stop"
  }]
}
```

## Temporary Workaround

**NONE** - The server must be fixed. No amount of client configuration will solve a broken server endpoint.

## Files to Check on Server

1. `/benchai/router/llm_router.py` - Main router code
2. `/benchai/router/requirements.txt` - Dependencies
3. `/benchai/docker/docker-compose.yml` - Service definitions
4. Systemd logs: `journalctl -u benchai`
5. Docker logs: `docker logs <container>`

## Priority

**CRITICAL** - This blocks ALL IDE integration functionality.

Without a working chat endpoint:
- Neovim integration is unusable
- VS Code Continue.dev won't work
- CLI tool won't work
- Only the health check works

## Next Steps

1. Check this file on homeserver (pull from git)
2. Run diagnostic commands above
3. Check server logs for errors
4. Fix the `/v1/chat/completions` endpoint
5. Test with curl before testing with clients
6. Report findings

---

**Created:** 2024-12-25
**Tested From:** Mac (192.168.0.x network)
**Server:** 192.168.0.213:8085
**Status:** BenchAI router responds to /health but /v1/chat/completions hangs indefinitely
