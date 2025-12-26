# MarunochiAI Build Instructions

**For:** Claude Code instance on M4 Pro MacBook (24GB)
**Purpose:** Build the MarunochiAI agent client that connects to BenchAI orchestrator
**Last Updated:** December 26, 2025

---

## Executive Summary

MarunochiAI is a **specialized coding agent** that runs on the M4 Pro MacBook and connects to BenchAI (the orchestrator running on a Linux server). This document provides complete instructions for building the MarunochiAI client.

### System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BenchAI (Orchestrator)                            │
│                    Linux Server @ 192.168.0.213:8085                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐  │
│  │ Research API│  │ Memory Sync │  │ Zettelkasten Knowledge      │  │
│  │ (Async)     │  │ (5 types)   │  │ Graph (Second Brain)        │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────────┘  │
└─────────┼────────────────┼─────────────────────┼────────────────────┘
          │                │                     │
          │      HTTP/REST A2A Protocol          │
          │         (via Twingate VPN)           │
          │                │                     │
┌─────────┼────────────────┼─────────────────────┼────────────────────┐
│         ▼                ▼                     ▼                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                   MarunochiAI (Programmer)                   │   │
│  │                   M4 Pro MacBook - 24GB                      │   │
│  │                                                              │   │
│  │  Models:                                                     │   │
│  │  - Qwen2.5-Coder-32B (Q4_K_M) - Primary coding              │   │
│  │  - Qwen2.5-Coder-14B (Q5_K_M) - Fast tasks                  │   │
│  │                                                              │   │
│  │  Capabilities:                                               │   │
│  │  - Code generation, review, refactoring                     │   │
│  │  - Test generation                                          │   │
│  │  - Debugging assistance                                     │   │
│  │  - Multi-language support (92+ languages)                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Part 1: What Needs to Be Built

### Components to Implement

| Component | Priority | Description |
|-----------|----------|-------------|
| `marunochi_agent.py` | HIGH | Main agent class with lifecycle management |
| `benchai_client.py` | HIGH | HTTP client for BenchAI API communication |
| `agent_config.py` | HIGH | Configuration and agent card definition |
| `research_client.py` | MEDIUM | Async research query submission |
| `experience_recorder.py` | MEDIUM | Record successes/failures to BenchAI |
| `context_manager.py` | MEDIUM | Share and retrieve context |
| `local_inference.py` | LOW | Optional local LLM for offline work |

### File Structure to Create

```
marunochi/
├── __init__.py
├── agent.py              # Main MarunochiAgent class
├── client/
│   ├── __init__.py
│   ├── benchai.py        # BenchAI HTTP client
│   ├── research.py       # Research query client
│   └── experience.py     # Experience recording client
├── config/
│   ├── __init__.py
│   ├── settings.py       # Configuration management
│   └── agent_card.json   # Agent capabilities definition
├── core/
│   ├── __init__.py
│   ├── context.py        # Context management
│   └── inference.py      # Local inference (optional)
├── cli.py                # CLI entry point
└── daemon.py             # Background daemon mode
```

---

## Part 2: BenchAI API Reference

### Base URL
```
http://192.168.0.213:8085
```

### Authentication
Currently no authentication required (internal network).
Future: Will add API key header `X-Agent-Key: <key>`

### Core Endpoints

#### 1. Agent Registration (REQUIRED on startup)
```http
POST /v1/agents/register
Content-Type: application/json

{
  "agent_id": "marunochiAI",
  "name": "MarunochiAI",
  "role": "programmer",
  "capabilities": ["coding", "code_review", "testing", "refactoring", "debugging"],
  "endpoint": "http://marunochi.local:8086",  // Optional callback endpoint
  "metadata": {
    "hardware": "M4 Pro 24GB",
    "models": ["qwen2.5-coder-32b", "qwen2.5-coder-14b"]
  }
}
```

**Response:**
```json
{
  "status": "registered",
  "agent_id": "marunochiAI",
  "message": "Agent registered successfully"
}
```

#### 2. Update Agent Status
```http
PUT /v1/agents/marunochiAI/status
Content-Type: application/json

{
  "status": "online"  // or "offline", "busy"
}
```

#### 3. Submit Research Query (Async)
```http
POST /v1/learning/research/submit
Content-Type: application/json

{
  "query": "Best practices for async Python error handling",
  "agent_id": "marunochiAI",
  "priority": "normal",  // "critical", "high", "normal", "low"
  "options": {
    "include_code_examples": true,
    "max_results": 5
  }
}
```

**Response:**
```json
{
  "query_id": "rq-abc123",
  "status": "pending",
  "estimated_time_ms": 5000
}
```

#### 4. Get Research Results
```http
GET /v1/learning/research/result/{query_id}?wait=true&timeout=30000
```

**Response:**
```json
{
  "query_id": "rq-abc123",
  "status": "completed",
  "data": {
    "zettels": [...],
    "synthesis": "Found 3 relevant patterns...",
    "sources": [...]
  }
}
```

#### 5. Share Context
```http
POST /v1/agents/context
Content-Type: application/json

{
  "content": "Discovered that using asyncio.gather with return_exceptions=True is best for parallel API calls",
  "from_agent": "marunochiAI",
  "category": "procedural",  // "semantic", "episodic", "procedural", "agent"
  "importance": 3  // 1-5
}
```

#### 6. Get Shared Context
```http
GET /v1/agents/context?agent_id=marunochiAI
```

#### 7. Record Experience (Success)
```http
POST /v1/learning/experience/record
Content-Type: application/json

{
  "task": "Implement async file downloader",
  "domain": "coding",
  "approach": "Used aiohttp with semaphore for rate limiting",
  "trajectory": [
    {"step": 1, "action": "Analyzed requirements", "result": "Need concurrent downloads with rate limit"},
    {"step": 2, "action": "Chose aiohttp over requests", "result": "Better async support"},
    {"step": 3, "action": "Implemented semaphore pattern", "result": "Clean rate limiting"}
  ],
  "outcome": "success",
  "agent": "marunochiAI",
  "code_snippet": "async def download_all(urls, max_concurrent=5):...",
  "metrics": {
    "lines_of_code": 45,
    "execution_time_ms": 1200
  }
}
```

#### 8. Get Similar Experiences (for in-context learning)
```http
GET /v1/learning/experience/similar?task=implement+rate+limiter&limit=3
```

#### 9. Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "ok",
  "service": "benchai-router-v3.5",
  "features": {
    "streaming": true,
    "memory": true,
    "tts": true,
    "rag": true,
    "obsidian": true,
    "learning": true,
    "zettelkasten": true
  }
}
```

---

## Part 3: Implementation Guide

### Step 1: Create the BenchAI Client

```python
# marunochi/client/benchai.py
"""
BenchAI HTTP Client for MarunochiAI agent communication.
"""
import aiohttp
import asyncio
from typing import Optional, Dict, Any, List
from dataclasses import dataclass
from enum import Enum
import json
import os

class AgentStatus(Enum):
    ONLINE = "online"
    OFFLINE = "offline"
    BUSY = "busy"

class QueryPriority(Enum):
    CRITICAL = "critical"
    HIGH = "high"
    NORMAL = "normal"
    LOW = "low"

@dataclass
class ResearchResult:
    query_id: str
    status: str
    data: Optional[Dict] = None
    error: Optional[str] = None

class BenchAIClient:
    """Async HTTP client for BenchAI orchestrator."""

    def __init__(
        self,
        base_url: str = None,
        agent_id: str = "marunochiAI",
        timeout: int = 120
    ):
        self.base_url = base_url or os.environ.get(
            "BENCHAI_URL",
            "http://192.168.0.213:8085"
        )
        self.agent_id = agent_id
        self.timeout = aiohttp.ClientTimeout(total=timeout)
        self._session: Optional[aiohttp.ClientSession] = None

    async def __aenter__(self):
        self._session = aiohttp.ClientSession(timeout=self.timeout)
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self._session:
            await self._session.close()

    @property
    def session(self) -> aiohttp.ClientSession:
        if self._session is None:
            self._session = aiohttp.ClientSession(timeout=self.timeout)
        return self._session

    # ==================== Agent Lifecycle ====================

    async def register(
        self,
        name: str = "MarunochiAI",
        role: str = "programmer",
        capabilities: List[str] = None,
        endpoint: Optional[str] = None,
        metadata: Optional[Dict] = None
    ) -> Dict:
        """Register agent with BenchAI on startup."""
        capabilities = capabilities or [
            "coding", "code_review", "testing",
            "refactoring", "debugging", "documentation"
        ]

        payload = {
            "agent_id": self.agent_id,
            "name": name,
            "role": role,
            "capabilities": capabilities,
            "metadata": metadata or {
                "hardware": "M4 Pro 24GB",
                "models": ["qwen2.5-coder-32b", "qwen2.5-coder-14b"]
            }
        }

        if endpoint:
            payload["endpoint"] = endpoint

        async with self.session.post(
            f"{self.base_url}/v1/agents/register",
            json=payload
        ) as resp:
            return await resp.json()

    async def update_status(self, status: AgentStatus) -> Dict:
        """Update agent status (online/offline/busy)."""
        async with self.session.put(
            f"{self.base_url}/v1/agents/{self.agent_id}/status",
            json={"status": status.value}
        ) as resp:
            return await resp.json()

    async def heartbeat(self) -> bool:
        """Send heartbeat to indicate agent is alive."""
        try:
            await self.update_status(AgentStatus.ONLINE)
            return True
        except Exception:
            return False

    # ==================== Research Queries ====================

    async def submit_research(
        self,
        query: str,
        priority: QueryPriority = QueryPriority.NORMAL,
        options: Optional[Dict] = None
    ) -> str:
        """Submit async research query, returns query_id."""
        payload = {
            "query": query,
            "agent_id": self.agent_id,
            "priority": priority.value,
            "options": options or {}
        }

        async with self.session.post(
            f"{self.base_url}/v1/learning/research/submit",
            json=payload
        ) as resp:
            data = await resp.json()
            return data.get("query_id")

    async def get_research_result(
        self,
        query_id: str,
        wait: bool = True,
        timeout_ms: int = 30000
    ) -> ResearchResult:
        """Get result of a research query."""
        params = {
            "wait": str(wait).lower(),
            "timeout": timeout_ms
        }

        async with self.session.get(
            f"{self.base_url}/v1/learning/research/result/{query_id}",
            params=params
        ) as resp:
            data = await resp.json()
            return ResearchResult(
                query_id=query_id,
                status=data.get("status"),
                data=data.get("data"),
                error=data.get("error")
            )

    async def research(
        self,
        query: str,
        priority: QueryPriority = QueryPriority.NORMAL,
        wait: bool = True
    ) -> ResearchResult:
        """Convenience method: submit and wait for result."""
        query_id = await self.submit_research(query, priority)
        if wait:
            return await self.get_research_result(query_id, wait=True)
        return ResearchResult(query_id=query_id, status="pending")

    # ==================== Context Sharing ====================

    async def share_context(
        self,
        content: str,
        category: str = "procedural",
        importance: int = 3
    ) -> Dict:
        """Share knowledge/findings back to BenchAI."""
        payload = {
            "content": content,
            "from_agent": self.agent_id,
            "category": category,
            "importance": importance
        }

        async with self.session.post(
            f"{self.base_url}/v1/agents/context",
            json=payload
        ) as resp:
            return await resp.json()

    async def get_shared_context(self) -> List[Dict]:
        """Get context shared by other agents."""
        async with self.session.get(
            f"{self.base_url}/v1/agents/context",
            params={"agent_id": self.agent_id}
        ) as resp:
            return await resp.json()

    # ==================== Experience Recording ====================

    async def record_success(
        self,
        task: str,
        approach: str,
        trajectory: List[Dict],
        code_snippet: Optional[str] = None,
        metrics: Optional[Dict] = None
    ) -> Dict:
        """Record a successful task completion."""
        payload = {
            "task": task,
            "domain": "coding",
            "approach": approach,
            "trajectory": trajectory,
            "outcome": "success",
            "agent": self.agent_id
        }

        if code_snippet:
            payload["code_snippet"] = code_snippet
        if metrics:
            payload["metrics"] = metrics

        async with self.session.post(
            f"{self.base_url}/v1/learning/experience/record",
            json=payload
        ) as resp:
            return await resp.json()

    async def record_failure(
        self,
        task: str,
        approach: str,
        error: str,
        lesson_learned: str
    ) -> Dict:
        """Record a failed attempt with lessons learned."""
        payload = {
            "task": task,
            "domain": "coding",
            "approach": approach,
            "outcome": "failure",
            "error": error,
            "lesson_learned": lesson_learned,
            "agent": self.agent_id
        }

        async with self.session.post(
            f"{self.base_url}/v1/learning/experience/record",
            json=payload
        ) as resp:
            return await resp.json()

    async def get_similar_experiences(
        self,
        task: str,
        limit: int = 3
    ) -> List[Dict]:
        """Get similar past experiences for in-context learning."""
        async with self.session.get(
            f"{self.base_url}/v1/learning/experience/similar",
            params={"task": task, "limit": limit}
        ) as resp:
            return await resp.json()

    # ==================== Chat/Inference ====================

    async def chat(
        self,
        message: str,
        model: str = "auto",
        stream: bool = False
    ) -> str:
        """Send chat message to BenchAI for processing."""
        payload = {
            "model": model,
            "messages": [{"role": "user", "content": message}],
            "stream": stream
        }

        async with self.session.post(
            f"{self.base_url}/v1/chat/completions",
            json=payload
        ) as resp:
            data = await resp.json()
            return data["choices"][0]["message"]["content"]

    # ==================== Health ====================

    async def health_check(self) -> Dict:
        """Check BenchAI server health."""
        async with self.session.get(f"{self.base_url}/health") as resp:
            return await resp.json()

    async def is_available(self) -> bool:
        """Check if BenchAI is reachable."""
        try:
            health = await self.health_check()
            return health.get("status") == "ok"
        except Exception:
            return False
```

### Step 2: Create the Main Agent Class

```python
# marunochi/agent.py
"""
MarunochiAI Agent - Specialized coding agent for BenchAI network.
"""
import asyncio
import signal
from typing import Optional, Callable, Dict, Any
from contextlib import asynccontextmanager
from datetime import datetime
import logging

from .client.benchai import BenchAIClient, AgentStatus, QueryPriority

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("marunochi")

class MarunochiAgent:
    """
    MarunochiAI - A specialized coding agent that connects to BenchAI.

    Features:
    - Auto-registration with BenchAI on startup
    - Heartbeat to maintain online status
    - Async research queries to BenchAI's knowledge base
    - Experience recording for continuous learning
    - Context sharing with other agents
    """

    def __init__(
        self,
        benchai_url: str = None,
        heartbeat_interval: int = 60,
        auto_register: bool = True
    ):
        self.client = BenchAIClient(base_url=benchai_url)
        self.heartbeat_interval = heartbeat_interval
        self.auto_register = auto_register
        self._running = False
        self._heartbeat_task: Optional[asyncio.Task] = None
        self._current_task: Optional[str] = None

    async def start(self):
        """Start the agent and register with BenchAI."""
        logger.info("Starting MarunochiAI agent...")

        # Check BenchAI availability
        if not await self.client.is_available():
            logger.error("BenchAI is not available. Check network connection.")
            raise ConnectionError("Cannot connect to BenchAI")

        # Register with BenchAI
        if self.auto_register:
            result = await self.client.register()
            logger.info(f"Registered with BenchAI: {result}")

        # Start heartbeat loop
        self._running = True
        self._heartbeat_task = asyncio.create_task(self._heartbeat_loop())

        logger.info("MarunochiAI agent started successfully")

    async def stop(self):
        """Stop the agent and notify BenchAI."""
        logger.info("Stopping MarunochiAI agent...")
        self._running = False

        if self._heartbeat_task:
            self._heartbeat_task.cancel()
            try:
                await self._heartbeat_task
            except asyncio.CancelledError:
                pass

        # Update status to offline
        try:
            await self.client.update_status(AgentStatus.OFFLINE)
        except Exception as e:
            logger.warning(f"Could not update offline status: {e}")

        await self.client.session.close()
        logger.info("MarunochiAI agent stopped")

    async def _heartbeat_loop(self):
        """Send periodic heartbeats to BenchAI."""
        while self._running:
            try:
                await self.client.heartbeat()
                logger.debug("Heartbeat sent")
            except Exception as e:
                logger.warning(f"Heartbeat failed: {e}")

            await asyncio.sleep(self.heartbeat_interval)

    # ==================== Core Operations ====================

    async def research(
        self,
        query: str,
        priority: QueryPriority = QueryPriority.NORMAL,
        wait: bool = True
    ):
        """
        Query BenchAI's knowledge base.

        Example:
            result = await agent.research("Python async best practices")
            print(result.data['synthesis'])
        """
        return await self.client.research(query, priority, wait)

    async def share_learning(
        self,
        content: str,
        category: str = "procedural",
        importance: int = 3
    ):
        """
        Share a discovery or learning with the BenchAI network.

        Example:
            await agent.share_learning(
                "Using TypedDict instead of Dict improves IDE support",
                category="procedural",
                importance=4
            )
        """
        return await self.client.share_context(content, category, importance)

    async def get_context(self):
        """Get shared context from other agents."""
        return await self.client.get_shared_context()

    async def record_success(
        self,
        task: str,
        approach: str,
        steps: list,
        code: str = None,
        metrics: dict = None
    ):
        """
        Record a successful task completion for learning.

        Example:
            await agent.record_success(
                task="Implement rate limiter",
                approach="Token bucket algorithm with asyncio",
                steps=[
                    {"step": 1, "action": "Analyzed requirements"},
                    {"step": 2, "action": "Implemented token bucket"},
                    {"step": 3, "action": "Added tests"}
                ],
                code="class RateLimiter:...",
                metrics={"lines": 50, "tests": 5}
            )
        """
        trajectory = [
            {"step": i+1, "action": s.get("action", s), "result": s.get("result", "")}
            for i, s in enumerate(steps)
        ]
        return await self.client.record_success(
            task=task,
            approach=approach,
            trajectory=trajectory,
            code_snippet=code,
            metrics=metrics
        )

    async def record_failure(
        self,
        task: str,
        approach: str,
        error: str,
        lesson: str
    ):
        """
        Record a failed attempt for learning.

        Example:
            await agent.record_failure(
                task="Implement distributed lock",
                approach="Used file-based locking",
                error="Race condition in multi-process scenario",
                lesson="File locks don't work across network shares, use Redis"
            )
        """
        return await self.client.record_failure(task, approach, error, lesson)

    async def get_examples(self, task: str, limit: int = 3):
        """
        Get similar past experiences for in-context learning.

        Example:
            examples = await agent.get_examples("implement caching")
            for ex in examples:
                print(f"Previous approach: {ex['approach']}")
        """
        return await self.client.get_similar_experiences(task, limit)

    async def chat(self, message: str, model: str = "auto") -> str:
        """
        Send a message to BenchAI for processing.

        Example:
            response = await agent.chat("Explain Python decorators")
        """
        return await self.client.chat(message, model)

    # ==================== Task Context ====================

    @asynccontextmanager
    async def task(self, description: str):
        """
        Context manager for task tracking.

        Example:
            async with agent.task("Implementing user auth"):
                # Your code here
                pass
        """
        self._current_task = description
        await self.client.update_status(AgentStatus.BUSY)
        try:
            yield
        finally:
            self._current_task = None
            await self.client.update_status(AgentStatus.ONLINE)


# ==================== CLI Entry Point ====================

async def main():
    """CLI entry point for MarunochiAI agent."""
    import argparse

    parser = argparse.ArgumentParser(description="MarunochiAI Agent")
    parser.add_argument("--url", help="BenchAI URL", default=None)
    parser.add_argument("--daemon", action="store_true", help="Run as daemon")
    parser.add_argument("--research", help="Submit research query")
    parser.add_argument("--chat", help="Send chat message")
    parser.add_argument("--status", action="store_true", help="Check status")

    args = parser.parse_args()

    agent = MarunochiAgent(benchai_url=args.url)

    # Handle shutdown signals
    loop = asyncio.get_event_loop()
    for sig in (signal.SIGTERM, signal.SIGINT):
        loop.add_signal_handler(sig, lambda: asyncio.create_task(agent.stop()))

    try:
        await agent.start()

        if args.status:
            health = await agent.client.health_check()
            print(f"BenchAI Status: {health}")

        elif args.research:
            result = await agent.research(args.research)
            print(f"Research Result:\n{result.data}")

        elif args.chat:
            response = await agent.chat(args.chat)
            print(f"Response:\n{response}")

        elif args.daemon:
            print("Running as daemon. Press Ctrl+C to stop.")
            while agent._running:
                await asyncio.sleep(1)

        else:
            # Interactive mode
            print("MarunochiAI Interactive Mode")
            print("Commands: research <query>, chat <message>, share <content>, exit")
            while True:
                try:
                    cmd = input("marunochi> ").strip()
                    if cmd.startswith("exit"):
                        break
                    elif cmd.startswith("research "):
                        result = await agent.research(cmd[9:])
                        print(result.data.get("synthesis", result.data))
                    elif cmd.startswith("chat "):
                        response = await agent.chat(cmd[5:])
                        print(response)
                    elif cmd.startswith("share "):
                        await agent.share_learning(cmd[6:])
                        print("Shared successfully")
                    else:
                        print("Unknown command")
                except EOFError:
                    break

    finally:
        await agent.stop()


if __name__ == "__main__":
    asyncio.run(main())
```

### Step 3: Create Agent Card

```json
// marunochi/config/agent_card.json
{
  "agent_id": "marunochiAI",
  "name": "MarunochiAI",
  "version": "1.0.0",
  "role": "programmer",
  "description": "Specialized coding agent for code generation, review, testing, and debugging",

  "capabilities": [
    "code_generation",
    "code_review",
    "refactoring",
    "testing",
    "debugging",
    "documentation",
    "multi_language_support"
  ],

  "supported_languages": [
    "python", "javascript", "typescript", "rust", "go",
    "java", "c", "cpp", "swift", "kotlin"
  ],

  "hardware": {
    "device": "MacBook Pro",
    "chip": "M4 Pro",
    "memory_gb": 24,
    "unified_memory": true
  },

  "models": {
    "primary": {
      "name": "qwen2.5-coder-32b-instruct",
      "quantization": "Q4_K_M",
      "vram_gb": 19,
      "context_length": 32768,
      "use_case": "Complex coding tasks, architecture"
    },
    "fast": {
      "name": "qwen2.5-coder-14b-instruct",
      "quantization": "Q5_K_M",
      "vram_gb": 12,
      "context_length": 32768,
      "use_case": "Quick completions, simple tasks"
    }
  },

  "protocols": ["benchai-a2a-v1", "http-rest"],

  "endpoints": {
    "health": "http://marunochi.local:8086/health",
    "task": "http://marunochi.local:8086/task",
    "callback": "http://marunochi.local:8086/callback"
  },

  "memory_sharing": {
    "supports_sync": true,
    "sync_protocol": "push_on_complete",
    "categories": ["procedural", "semantic", "experience"]
  },

  "availability": {
    "typical_hours": "09:00-23:00 PST",
    "auto_sleep": true,
    "wake_on_request": false
  }
}
```

### Step 4: Create Installation Script

```bash
#!/bin/bash
# install.sh - Install MarunochiAI agent

set -e

echo "Installing MarunochiAI Agent..."

# Create directory structure
mkdir -p ~/.marunochi/{config,logs,cache}

# Install Python dependencies
pip3 install aiohttp asyncio-throttle

# Copy files
cp -r marunochi ~/.local/lib/python3.11/site-packages/

# Create CLI wrapper
cat > ~/.local/bin/marunochi << 'EOF'
#!/bin/bash
python3 -m marunochi.agent "$@"
EOF
chmod +x ~/.local/bin/marunochi

# Copy config
cp marunochi/config/agent_card.json ~/.marunochi/config/

# Create systemd user service (optional)
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/marunochi.service << 'EOF'
[Unit]
Description=MarunochiAI Agent
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/python3 -m marunochi.agent --daemon
Restart=on-failure
RestartSec=10
Environment=BENCHAI_URL=http://192.168.0.213:8085

[Install]
WantedBy=default.target
EOF

echo "Installation complete!"
echo ""
echo "Usage:"
echo "  marunochi --status        # Check BenchAI connection"
echo "  marunochi --daemon        # Run as background daemon"
echo "  marunochi --chat 'hello'  # Send chat message"
echo "  marunochi                  # Interactive mode"
echo ""
echo "To enable auto-start:"
echo "  systemctl --user enable marunochi"
echo "  systemctl --user start marunochi"
```

---

## Part 4: Testing Checklist

### Connection Tests
```bash
# 1. Test BenchAI is reachable
curl http://192.168.0.213:8085/health

# 2. Test agent registration
curl -X POST http://192.168.0.213:8085/v1/agents/register \
  -H "Content-Type: application/json" \
  -d '{"agent_id":"test","name":"Test","role":"test","capabilities":["test"]}'

# 3. Test research API
curl -X POST http://192.168.0.213:8085/v1/learning/research/submit \
  -H "Content-Type: application/json" \
  -d '{"query":"test","agent_id":"test","priority":"low"}'
```

### Python Tests
```python
# test_connection.py
import asyncio
from marunochi.client.benchai import BenchAIClient

async def test():
    async with BenchAIClient() as client:
        # Test health
        health = await client.health_check()
        print(f"Health: {health}")

        # Test registration
        result = await client.register()
        print(f"Registration: {result}")

        # Test research
        research = await client.research("test query", wait=True)
        print(f"Research: {research}")

asyncio.run(test())
```

---

## Part 5: Network Setup (Prerequisites)

### Option A: Same Network
If MacBook is on same local network as BenchAI server:
```bash
export BENCHAI_URL=http://192.168.0.213:8085
```

### Option B: Twingate VPN (Recommended for remote)
1. Install Twingate client on MacBook
2. Connect to network: `cesarsalcido.twingate.com`
3. BenchAI resource should be added (ask server admin)
4. Once connected: `export BENCHAI_URL=http://192.168.0.213:8085`

### Option C: SSH Tunnel (Fallback)
```bash
ssh -L 8085:localhost:8085 user@server-ip
export BENCHAI_URL=http://localhost:8085
```

---

## Part 6: Recommended Models for M4 Pro

### Primary: Qwen2.5-Coder-32B-Instruct
```bash
# Using Ollama
ollama pull qwen2.5-coder:32b-instruct-q4_K_M

# Or download GGUF for llama.cpp
# https://huggingface.co/Qwen/Qwen2.5-Coder-32B-Instruct-GGUF
```

**Specs:**
- VRAM: ~19GB
- Context: 32K tokens
- HumanEval: 92.7%
- Best for: Complex coding, architecture decisions

### Fast: Qwen2.5-Coder-14B-Instruct
```bash
ollama pull qwen2.5-coder:14b-instruct-q5_K_M
```

**Specs:**
- VRAM: ~12GB
- Context: 32K tokens
- Best for: Quick completions, simple tasks

---

## Part 7: Development Workflow

### Typical Agent Session

```python
import asyncio
from marunochi import MarunochiAgent

async def coding_session():
    agent = MarunochiAgent()
    await agent.start()

    try:
        # 1. Get context from other agents
        context = await agent.get_context()
        print(f"Shared context: {context}")

        # 2. Research before starting task
        research = await agent.research(
            "Best practices for Python async HTTP clients"
        )
        print(f"Research: {research.data['synthesis']}")

        # 3. Get similar past experiences
        examples = await agent.get_examples("implement HTTP client")

        # 4. Do the work...
        async with agent.task("Implementing async HTTP client"):
            # Your coding here
            pass

        # 5. Record success
        await agent.record_success(
            task="Implement async HTTP client",
            approach="Used aiohttp with connection pooling",
            steps=[
                {"action": "Researched best practices"},
                {"action": "Implemented base client"},
                {"action": "Added retry logic"},
                {"action": "Added tests"}
            ],
            code="class AsyncClient:...",
            metrics={"lines": 120, "tests": 15}
        )

        # 6. Share learning
        await agent.share_learning(
            "aiohttp TCPConnector with limit=100 provides good balance "
            "between concurrency and resource usage",
            category="procedural",
            importance=4
        )

    finally:
        await agent.stop()

asyncio.run(coding_session())
```

---

## Quick Reference

### Environment Variables
```bash
BENCHAI_URL=http://192.168.0.213:8085  # BenchAI server URL
MARUNOCHI_LOG_LEVEL=INFO               # Logging level
MARUNOCHI_HEARTBEAT=60                 # Heartbeat interval (seconds)
```

### CLI Commands
```bash
marunochi --status           # Check connection
marunochi --daemon           # Run as daemon
marunochi --research "query" # Submit research
marunochi --chat "message"   # Chat with BenchAI
marunochi                    # Interactive mode
```

### API Quick Reference
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v1/agents/register` | POST | Register agent |
| `/v1/agents/{id}/status` | PUT | Update status |
| `/v1/learning/research/submit` | POST | Submit research |
| `/v1/learning/research/result/{id}` | GET | Get result |
| `/v1/agents/context` | POST/GET | Share/get context |
| `/v1/learning/experience/record` | POST | Record experience |
| `/v1/learning/experience/similar` | GET | Get examples |

---

## Questions?

If you encounter issues:
1. Check BenchAI server is running: `curl http://192.168.0.213:8085/health`
2. Verify network connectivity (Twingate connected?)
3. Check logs: `~/.marunochi/logs/agent.log`
4. Contact BenchAI admin or check GitHub issues

---

*Generated by Claude Code on BenchAI Server*
*December 26, 2025*
