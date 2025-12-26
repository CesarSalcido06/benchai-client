# BenchAI Master System Inventory

**Last Updated:** December 25, 2025
**Purpose:** Complete inventory of all technologies, services, and features

---

## Quick Health Check

```bash
# Run this to verify system status
curl -s http://localhost:8085/health | python3 -m json.tool
ss -tlnp | grep -E "8085|8091|8092|8093"
docker ps --format "{{.Names}}: {{.Status}}"
nvidia-smi --query-compute-apps=pid,used_memory --format=csv
```

---

## 1. Hardware Configuration

### GPU
| Property | Value |
|----------|-------|
| Model | NVIDIA GeForce RTX 3060 |
| VRAM | 12,288 MiB |
| Driver | 580.82.09 |
| CUDA | 13.0 |
| Compute Capability | 8.6 |

### CPU & RAM
| Property | Value |
|----------|-------|
| RAM | 46 GB |
| Swap | 19 GB |
| Available RAM | ~30 GB (typical) |

### Storage
| Mount | Size | Purpose |
|-------|------|---------|
| `/home/user` | System | Main storage |
| `/media/data` | External | Torrents, large files |
| `~/llm-storage` | Symlink | LLM models and data |

---

## 2. Running Services

### Core BenchAI Services

| Service | Port | Process | Status | Mode |
|---------|------|---------|--------|------|
| **BenchAI Router** | 8085 | python3 llm_router.py | ✅ Running | FastAPI/Uvicorn |
| **Phi-3 Mini** | 8091 | llama-server | ✅ Running | CPU (-ngl 0) |
| **Qwen2.5 7B** | 8092 | llama-server | ✅ Running | CPU (-ngl 0) |
| **DeepSeek Coder** | 8093 | llama-server | ✅ Running | GPU (-ngl 35) |
| **Qwen2-VL** | 8094 | llama-server | ❌ On-demand | GPU (when started) |

### Docker Containers

| Container | Port | Purpose | Status |
|-----------|------|---------|--------|
| **open-webui** | 3000 | Web chat interface | ✅ Healthy |
| **searxng** | 8081 | Private web search | ✅ Running |
| **twingate-connector** | - | VPN access | ✅ Healthy |
| **nginx-proxy-manager** | 80/443 | Reverse proxy | ✅ Running |
| **glance** | - | Dashboard | ✅ Running |
| **jellyfin** | 8096 | Media server | ✅ Healthy |
| **sonarr** | 8989 | TV automation | ✅ Running |
| **radarr** | 7878 | Movie automation | ✅ Running |
| **lidarr** | 8686 | Music automation | ✅ Running |
| **prowlarr** | 9696 | Indexer manager | ✅ Running |
| **qbittorrent** | 8080 | Torrent client | ✅ Running |
| **flaresolverr** | 8191 | Cloudflare bypass | ✅ Running |
| **gluetun** | - | VPN container | ✅ Healthy |

---

## 3. LLM Models

### Installed Models

| Model | File | Size | Port | Hardware | Purpose |
|-------|------|------|------|----------|---------|
| Phi-3 Mini 4K | phi-3-mini-4k-instruct.Q4_K_M.gguf | 2.3 GB | 8091 | CPU | General/fast |
| Qwen2.5 7B | qwen2.5-7b-instruct.Q4_K_M.gguf | 4.4 GB | 8092 | CPU | Planner |
| DeepSeek Coder 6.7B | deepseek-coder-6.7b-instruct.Q4_K_M.gguf | 3.9 GB | 8093 | GPU | Code |
| Qwen2-VL 7B | Qwen2-VL-7B-Instruct-Q4_K_M.gguf | 4.4 GB | 8094 | GPU | Vision |
| LLaVA Mistral 7B | llava-v1.6-mistral-7b.Q4_K_M.gguf | 4.1 GB | - | - | Vision (alt) |
| Mistral 7B v0.2 | mistral-7b-instruct-v0.2.Q4_K_M.gguf | 4.1 GB | - | - | General (alt) |

### Vision Model Projectors

| File | Size | For Model |
|------|------|-----------|
| mmproj-Qwen2-VL-7B-Instruct-f16.gguf | 1.3 GB | Qwen2-VL |
| llava-v1.6-mistral-7b-mmproj.f16.gguf | 596 MB | LLaVA |

### Model Location
```
~/llama.cpp/models/ → /media/user/New Volume/LLM (symlink)
```

---

## 4. Databases

### SQLite Memory Database
| Property | Value |
|----------|-------|
| Path | ~/llm-storage/memory/benchai_memory.db |
| Mode | WAL (Write-Ahead Logging) |
| Size | 217 KB |
| Total Memories | 24 |
| Total Conversations | 100 |
| FTS5 Enabled | Yes |
| FTS5 Indexed | 24 |

### ChromaDB Vector Database
| Property | Value |
|----------|-------|
| Path | ~/llm-storage/rag/chroma_db |
| Mode | Library (embedded) |
| Documents | 346 |
| Status | Ready |

---

## 5. API Endpoints

### Health & Status
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/health` | Service health + features |
| GET | `/v1/models` | List available models |

### Chat
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/v1/chat/completions` | Main chat (OpenAI compatible) |

### Memory
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/v1/memory/add` | Save memory |
| GET | `/v1/memory/search?q=` | Search memories (FTS5) |
| GET | `/v1/memory/recent?n=` | Recent memories |
| GET | `/v1/memory/stats` | Database stats |
| POST | `/v1/memory/optimize` | Vacuum/analyze |
| POST | `/v1/memory/migrate-fts` | Migrate to FTS5 |

### RAG
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/v1/rag/index` | Index documents |
| GET | `/v1/rag/search?q=` | Semantic search |
| GET | `/v1/rag/stats` | RAG stats |

### Multimedia
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/v1/audio/speech` | Text-to-speech |
| POST | `/v1/images/generations` | Image generation |

---

## 6. Feature Status

### Core Features (Working)
| Feature | Status | Notes |
|---------|--------|-------|
| Chat API | ✅ | OpenAI-compatible |
| Streaming | ✅ | SSE format |
| Model Routing | ✅ | Auto-detects intent |
| Health Monitoring | ✅ | 60s interval |
| Auto-restart | ✅ | Crashed models recovered |
| Memory Store | ✅ | SQLite + FTS5 |
| Memory Search | ✅ | Full-text search |
| RAG Indexing | ✅ | ChromaDB |
| RAG Search | ✅ | Semantic search |
| Code Generation | ✅ | DeepSeek on GPU |

### Optional Features (Configured)
| Feature | Status | Requirement |
|---------|--------|-------------|
| TTS | ✅ | Piper installed |
| Web Search | ✅ | SearXNG running |
| Open WebUI | ✅ | Docker container |
| Image Generation | ⚠️ | ComfyUI (check if running) |

### Optional Features (Not Configured)
| Feature | Status | Requirement |
|---------|--------|-------------|
| Obsidian | ❌ | Local REST API plugin |
| Email | ❌ | Hydroxide bridge |
| Vision | ⚠️ | Starts on-demand (GPU swap) |

### Stub Features (Not Implemented)
| Feature | Status |
|---------|--------|
| Browser automation | ❌ Stub |
| PDF processing | ❌ Stub |
| Excel/spreadsheet | ❌ Stub |
| Diagram generation | ❌ Stub |
| Transcription | ❌ Stub |
| SQL database query | ❌ Stub |

---

## 7. File Locations

### BenchAI Server
```
/home/user/benchai/
├── router/llm_router.py      # Main application (6,436 lines)
├── configs/.env.example       # Environment template
├── configs/requirements.txt   # Python dependencies
├── docker/docker-compose.yml  # Container definitions
├── docs/                      # Documentation (5 files)
├── services/benchai.service   # SystemD service
└── services/hydroxide.service # Email bridge service
```

### BenchAI Client
```
/home/user/benchai-client/
├── benchai                    # CLI tool (245 lines)
├── install.sh                 # Installer (279 lines)
├── configs/                   # IDE configurations (6 files)
└── *.md                       # Documentation (10 files)
```

### LLM Infrastructure
```
/home/user/llama.cpp/
├── build/bin/llama-server    # Inference server
├── models/                   # Model files (symlink)
├── cache/                    # KV cache persistence
└── router/llm_router.py      # Active router (symlink/copy)

/home/user/llm-storage/       # → /media/user/New Volume/LLM
├── memory/                   # SQLite database
├── rag/                      # ChromaDB
└── cache/                    # Audio cache
```

### Docker Server
```
/home/user/docker-server/
├── docker-compose.yml        # All containers
├── data/                     # Persistent data
└── configs/                  # Container configs
```

---

## 8. Dependencies

### Python (Router)
```
fastapi>=0.104.0
uvicorn>=0.24.0
httpx>=0.25.0
pydantic>=2.5.0
aiosqlite>=0.19.0
python-multipart>=0.0.6
python-dotenv>=1.0.0
chromadb>=0.4.0
sentence-transformers>=2.2.0
piper-tts>=1.2.0 (optional)
```

### System
```
llama.cpp (CUDA build)
NVIDIA Driver 580.82.09
CUDA 13.0
Docker + Docker Compose
Python 3.10+
Piper TTS
```

### Optional
```
ComfyUI (image generation)
SearXNG (web search)
Obsidian + Local REST API
Hydroxide (ProtonMail bridge)
```

---

## 9. Network Configuration

### Internal Ports
| Port | Service | Access |
|------|---------|--------|
| 8085 | BenchAI Router | LAN (0.0.0.0) |
| 8091 | Phi-3 | Localhost only |
| 8092 | Qwen2.5 | Localhost only |
| 8093 | DeepSeek | Localhost only |
| 8094 | Vision | Localhost only |
| 3000 | Open WebUI | LAN |
| 8081 | SearXNG | LAN |

### External Access
- **Twingate VPN**: Remote access configured
- **Server IP**: 192.168.0.213 (LAN)

---

## 10. Maintenance Commands

### Service Management
```bash
# Router
sudo systemctl status benchai
sudo systemctl restart benchai
sudo journalctl -u benchai -f

# View logs
tail -f /tmp/benchai-router.log
tail -f /var/log/benchai-router.log
```

### Model Management
```bash
# Check running models
ps aux | grep llama-server | grep -v grep

# Check GPU usage
nvidia-smi

# Manually start model
~/llama.cpp/build/bin/llama-server \
  -m ~/llama.cpp/models/MODEL.gguf \
  --host 127.0.0.1 --port PORT \
  -ngl LAYERS -c CONTEXT -t THREADS
```

### Database Maintenance
```bash
# Memory stats
curl http://localhost:8085/v1/memory/stats

# Optimize database
curl -X POST http://localhost:8085/v1/memory/optimize

# RAG stats
curl http://localhost:8085/v1/rag/stats
```

### Docker
```bash
# Status
docker ps

# Logs
docker logs -f CONTAINER_NAME

# Restart
docker restart CONTAINER_NAME

# Full stack
cd ~/docker-server && docker compose up -d
```

---

## 11. Backup Checklist

### Critical Data
- [ ] `~/llm-storage/memory/benchai_memory.db` - User memories
- [ ] `~/llm-storage/rag/chroma_db/` - RAG index
- [ ] `~/benchai/router/.env` - Configuration
- [ ] `~/.config/nvim/lua/plugins/benchai.lua` - Neovim config

### Models (Large, re-downloadable)
- [ ] `~/llama.cpp/models/*.gguf` - All model files

### Configuration
- [ ] `~/docker-server/docker-compose.yml`
- [ ] `~/benchai-client/configs/`

---

## 12. Known Issues & Workarounds

| Issue | Workaround |
|-------|------------|
| Models crash (SIGSEGV) | Auto-restart handles it |
| Avante.nvim hangs | Use BenchAI Simple instead |
| ChromaDB stale data | Restart router to refresh |
| Vision model not started | Starts on-demand (GPU swap) |
| Streaming format mismatch | Disable streaming in IDE plugins |

---

## 13. Quick Reference

### Test Commands
```bash
# Health
curl http://localhost:8085/health

# Chat
curl -X POST http://localhost:8085/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"auto","messages":[{"role":"user","content":"Hello"}]}'

# Memory search
curl "http://localhost:8085/v1/memory/search?q=test"

# RAG search
curl "http://localhost:8085/v1/rag/search?q=docker"
```

### CLI
```bash
benchai "question"           # Quick query
benchai -i                   # Interactive mode
benchai -m code "write..."   # Force code model
benchai --status             # Check health
benchai --memory-stats       # Memory info
```

---

*Document auto-generated from system audit*
*Last verified: December 25, 2025*
