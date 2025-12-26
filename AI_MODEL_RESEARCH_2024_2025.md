# Specialized AI Models for Distributed Agent System (2024-2025)

A comprehensive research document covering the best AI models for a distributed agent system with three specialized nodes:
- **MarunochiAI** (24GB VRAM) - Coding/Programming
- **DottscavisAI** (32GB VRAM) - Creative/Multimodal
- **BenchAI** (Orchestrator) - Research/Reasoning

---

## Table of Contents

1. [Coding/Programming Models (MarunochiAI - 24GB)](#1-codingprogramming-models-marunochiAI---24gb)
2. [Creative/Multimodal Models (DottscavisAI - 32GB)](#2-creativemultimodal-models-dottscavisAI---32gb)
3. [Research/Reasoning Models (BenchAI - Orchestrator)](#3-researchreasoning-models-benchAI---orchestrator)
4. [Model Sizes and Quantization](#4-model-sizes-and-quantization)
5. [Final Recommendations](#5-final-recommendations)

---

## 1. Coding/Programming Models (MarunochiAI - 24GB)

### 1.1 Model Comparison

| Model | Parameters | HumanEval | MBPP | SWE-Bench | Context | License |
|-------|------------|-----------|------|-----------|---------|---------|
| **Qwen2.5-Coder-32B** | 32B | 92.7% | 90.2% | 69.6% | 128K | Apache 2.0 |
| **DeepSeek-Coder-V2** | 236B MoE | 90.2% | 76.2% | 10%+ | 128K | DeepSeek |
| **StarCoder2-15B** | 15B | ~55% | ~65% | - | 16K | BigCode OpenRAIL-M |
| **CodeLlama-34B** | 34B | ~48% | ~55% | - | 16K | Llama 2 |

### 1.2 Detailed Model Analysis

#### Qwen2.5-Coder-32B-Instruct (RECOMMENDED)

**Why it's the top choice:**
- **State-of-the-art open-source coding model** matching GPT-4o capabilities
- Scores **92.7% on HumanEval**, highest among open-source models
- **69.6% on SWE-Bench Verified** - real-world GitHub issue fixing
- Supports **92 programming languages** with 128K context
- Trained on **5.5 trillion tokens** of diverse code data
- Runs comfortably on 24GB with Q4_K_M quantization (~19GB VRAM)

**Aider Benchmark Performance:**
- Claude 3.5 Sonnet: 84%
- Claude 3.5 Haiku: 75%
- **Qwen2.5 Coder 32B: 74%** (4th place overall)
- GPT-4o: 71%

**Model Sizes Available:** 0.5B, 1.5B, 3B, 7B, 14B, 32B

**Sources:**
- [Qwen2.5-Coder Technical Report](https://qwenlm.github.io/blog/qwen2.5-coder/)
- [Qwen2.5-Coder Family Blog](https://qwenlm.github.io/blog/qwen2.5-coder-family/)
- [Qwen AI Coding Review - Index.dev](https://www.index.dev/blog/qwen-ai-coding-review)

#### DeepSeek-Coder-V2

**Strengths:**
- First open-source model to surpass GPT-4 Turbo in code tasks
- **90.2% on HumanEval**, 76.2% on MBPP
- Supports **338 programming languages** (up from 86 in V1)
- 128K context window
- MoE architecture (236B total, ~21B active)

**Considerations:**
- Large model size may require quantization
- DeepSeek-V3 (general purpose successor) offers 671B params with 37B active

**Sources:**
- [DeepSeek-Coder-V2 GitHub](https://github.com/deepseek-ai/DeepSeek-Coder-V2)
- [DeepSeek-Coder-V2 Paper](https://arxiv.org/html/2406.11931v1)

#### StarCoder2-15B

**Strengths:**
- Best-in-class for 15B parameter range
- Matches or outperforms CodeLlama-34B
- Trained on **4+ trillion tokens** from 600+ languages
- Excellent for low-resource programming languages
- Strong math and code reasoning benchmarks

**Best for:** Resource-constrained environments, multi-language support

**Sources:**
- [StarCoder2 Paper](https://arxiv.org/abs/2402.19173)
- [StarCoder2 Hugging Face](https://huggingface.co/docs/transformers/en/model_doc/starcoder2)

### 1.3 Best Fine-Tuning Datasets for Coding

| Dataset | Size | Description | Use Case |
|---------|------|-------------|----------|
| **Code Alpaca** | 20K instructions | Instruction-following code generation | General fine-tuning |
| **CodeSearchNet** | Multi-language | Code retrieval via NL queries | Code search/understanding |
| **KodCode** | Large-scale | Instruction-solution-test triplets | Diverse coding challenges |
| **CodeNet (IBM)** | 14M samples | 4000 problems, 50+ languages | Program understanding |
| **AlpaGasus** | 9K filtered | High-quality filtered Alpaca data | Quality over quantity |
| **The Stack v2** | Massive | 600+ languages source code | Pre-training |

**Sources:**
- [Code Alpaca GitHub](https://github.com/sahil280114/codealpaca)
- [KodCode Paper](https://arxiv.org/html/2503.02951v1)

### 1.4 Coding Model Recommendations for 24GB VRAM

| Priority | Model | Quantization | VRAM Usage | Speed |
|----------|-------|--------------|------------|-------|
| **Primary** | Qwen2.5-Coder-32B | Q4_K_M | ~19GB | 38 tok/s |
| **Alternative** | DeepSeek-Coder-V2-Lite | Q4_K_M | ~18GB | 42 tok/s |
| **Fast** | Qwen2.5-Coder-14B | Q5_K_M | ~12GB | 55 tok/s |
| **Lightweight** | StarCoder2-15B | Q6_K | ~14GB | 50 tok/s |

---

## 2. Creative/Multimodal Models (DottscavisAI - 32GB)

### 2.1 Vision-Language Models (VLMs)

| Model | Parameters | Architecture | Strengths | Context |
|-------|------------|--------------|-----------|---------|
| **Qwen2.5-VL** | 3B/7B/72B | ViT + LLM | OCR, video, 3D patches | 128K |
| **InternVL 2.5/3** | 2B/8B/78B | ViT + LLM | GPT-4o alternative | 128K |
| **LLaVA-OneVision** | 0.5B/7B/72B | ViT + LLM | Reproducible, versatile | 128K |

#### Qwen2.5-VL (RECOMMENDED for 32GB)

**Capabilities:**
- Advanced OCR for text recognition in images
- **3D Conv patches** for efficient video processing
- Object recognition and scene interpretation
- Multimodal reasoning and visual question answering
- Trained on **5 billion image-text pairs**

**Model Evolution:**
- Qwen2-VL (Aug 2024) → QvQ-72B-Preview (Dec 2024) → Qwen2.5-VL (Jan 2025) → Qwen3-VL (2025)

**Sources:**
- [Qwen-VL GitHub](https://github.com/QwenLM/Qwen-VL)
- [Best Open Source Multimodal Vision Models 2025 - Koyeb](https://www.koyeb.com/blog/best-multimodal-vision-models-in-2025)

#### InternVL 2.5/3

**Strengths:**
- Positioned as "open-source alternative to GPT-4o"
- CVPR 2024 Oral paper
- State-of-the-art perception and reasoning
- Variable Visual Position Encoding
- Native Multimodal Pre-Training

**InternVL3.5-241B-A28B** achieves SOTA among open-source MLLMs across general multimodal, reasoning, and agentic tasks.

**Sources:**
- [InternVL GitHub](https://github.com/OpenGVLab/InternVL)

### 2.2 Image Generation

| Model | Type | VRAM (Min) | Quality | Speed |
|-------|------|------------|---------|-------|
| **FLUX.1 Dev** | Diffusion | 12GB+ | Excellent | Medium |
| **FLUX.2** | Diffusion | 12GB+ | Best | Medium |
| **Stable Diffusion 3.5** | Diffusion | 8GB+ | Very Good | Fast |
| **SDXL** | Diffusion | 8GB+ | Good | Fast |

#### FLUX.1/FLUX.2 (RECOMMENDED)

**Key Features:**
- Developed by Black Forest Labs (former Stability AI founders)
- **Best open-source image model** as of 2024
- Surpasses SDXL and SD3 in quality
- FLUX.2 released November 2025 with Apache 2.0 licensing

**VRAM Requirements:**
- **Q4 GGUF:** 8GB minimum
- **FP8:** 16GB recommended
- **FP16:** 24GB for highest quality

**Variants:**
- **FLUX.1 Schnell:** Fast generation (768x512)
- **FLUX.1 Dev:** High quality, personal/non-commercial
- **FLUX 1.1 Pro:** Production quality
- **FLUX 2.0 Ultra:** 4MP resolution support

**Deployment Options:**
- ComfyUI (native support)
- Stable Diffusion WebUI Forge
- OllamaDiffuser (CLI + Web UI)
- Stability Matrix (easy install)

**Sources:**
- [FLUX Wikipedia](https://en.wikipedia.org/wiki/Flux_(text-to-image_model))
- [How to run Flux with low VRAM](https://stable-diffusion-art.com/flux-forge/)
- [FLUX Installation Guide](https://www.stablediffusiontutorials.com/2024/08/flux-installation.html)

### 2.3 Video Understanding & Generation

| Model | Type | Parameters | Strengths |
|-------|------|------------|-----------|
| **HunyuanVideo** | Generation | 13B | Best open-source, cinematic quality |
| **Mochi 1** | Generation | 10B | Smooth motion, creative |
| **Wan 2.1/2.2** | Generation | 14B | MoE, anime/2D excellent |
| **LTX-Video** | Generation | - | Fast, near real-time |
| **Kandinsky 5.0** | Generation | - | Apache 2.0, production-ready |

#### HunyuanVideo (RECOMMENDED for Generation)

**Strengths:**
- **13B parameters** with 3D VAE architecture
- Outperforms Runway Gen-3, Luma 1.6
- Cinematic-quality with high text-video alignment
- Developed by Tencent (December 2024)

#### Video Understanding Models

- **LLaVA-MR:** Video moment retrieval
- **Holmes-VAD:** Video anomaly detection
- **VideoLLM-online:** Streaming video understanding

**Sources:**
- [Hugging Face Video Gen Blog](https://huggingface.co/blog/video_gen)
- [Best Open Source Video Models 2025](https://www.runpod.io/blog/open-source-model-roundup-2025)

### 2.4 3D Model Generation

| Model | Speed | Input | Output | License |
|-------|-------|-------|--------|---------|
| **TripoSR** | <0.5s | Single image | 3D mesh | MIT |
| **SF3D** | Slower | Single/multi | Better consistency | - |

#### TripoSR (RECOMMENDED)

**Capabilities:**
- **Sub-0.5 second** 3D reconstruction from single image
- Developed by Tripo AI + Stability AI
- Runs without GPU (though slower)
- MIT License for commercial use

**Integration:**
- Official Blender add-on
- Unity plugin
- ComfyUI nodes

**Sources:**
- [TripoSR GitHub](https://github.com/VAST-AI-Research/TripoSR)
- [TripoSR Official](https://www.triposrai.com/)

### 2.5 Audio/Music Generation

| Model | Type | Capabilities | License |
|-------|------|--------------|---------|
| **YuE** | Lyrics-to-song | Full songs, 5 min, multi-language | Apache 2.0 |
| **MusicGen (Meta)** | Text-to-music | 20K hours trained, balanced quality | Open |
| **Stable Audio 2.0** | Text/audio-to-audio | 3 min, 44.1kHz stereo | - |
| **DiffRhythm** | Diffusion | Long-form music | Open |

#### YuE (RECOMMENDED for Full Songs)

**Released January 2025:**
- First open-source lyrics-to-song model
- Generates up to **5 minutes** with synchronized vocals
- Multi-language and genre support (including EDM)
- Advanced vocal fine-tuning (timing, pitch, emotion)
- **Apache 2.0 license**

#### MusicGen (Meta AudioCraft)

**Strengths:**
- Transformer-based, trained on 20K hours
- Text descriptions or melody input
- Residual Vector Quantization for quality
- Strong community modifications

**Sources:**
- [YuE GitHub](https://github.com/multimodal-art-projection/YuE)
- [Meta AudioCraft](https://ai.meta.com/resources/models-and-libraries/audiocraft/)
- [Best Open Source Music Models 2025](https://www.siliconflow.com/articles/en/best-open-source-music-generation-models)

### 2.6 Creative Models Recommendations for 32GB VRAM

| Use Case | Model | Quantization | VRAM |
|----------|-------|--------------|------|
| **Vision-Language** | Qwen2.5-VL-32B | Q4_K_M | ~20GB |
| **Image Generation** | FLUX.1 Dev | FP16 | 24GB |
| **Video Generation** | HunyuanVideo | Q4 | 28GB |
| **3D Generation** | TripoSR | FP16 | <4GB |
| **Music Generation** | YuE | - | ~16GB |

---

## 3. Research/Reasoning Models (BenchAI - Orchestrator)

### 3.1 Planning and Reasoning Models

| Model | Architecture | Reasoning | Tool Use | Context |
|-------|--------------|-----------|----------|---------|
| **DeepSeek-R1** | Dense | Excellent | Good | 128K |
| **Qwen3-30B-A3B** | MoE | Excellent | Excellent | 128K |
| **GLM-4.5-Air** | - | Good | Excellent | 128K |

#### DeepSeek-R1 (RECOMMENDED for Complex Reasoning)

**Strengths:**
- **Top choice for complex strategic planning**
- Deep reasoning with long-horizon task sequences
- Baked-in reasoning optimization (no mode switching needed)
- Multi-stage RL fine-tuning on chain-of-thought data
- Lower VRAM per inference due to dense optimization
- **DeepSeek-R1-0528** (May 2025) approaches OpenAI o3

**Performance:**
- Fastest per-token generation
- Consistent structured step-by-step outputs
- Strong on mathematics and coding

**Sources:**
- [DeepSeek R1 Technical Guide](https://www.bentoml.com/blog/the-complete-guide-to-deepseek-models-from-v3-to-r1-and-beyond)
- [Qwen 3 vs DeepSeek R1 Comparison](https://composio.dev/blog/qwen-3-vs-deepseek-r1-complete-comparison)

#### Qwen3-235B-A22B / Qwen3-30B-A3B

**Strengths:**
- **Outperforms DeepSeek-R1 on 17/23 benchmarks** with fewer active params
- MoE architecture (efficient inference)
- **Thinking Mode:** Deep step-by-step reasoning
- **Non-Thinking Mode:** Fast direct responses
- 119 languages and dialects
- Apache 2.0 license

**Benchmark Highlights:**
- ArenaHard: 95.6 (ahead of DeepSeek-R1)
- CodeForces Elo: 2056 (highest)
- AIME 2024/2025: Top performer

**Sources:**
- [Qwen3 Technical Report](https://arxiv.org/pdf/2505.09388)
- [Qwen3 DataCamp Overview](https://www.datacamp.com/blog/qwen3)

### 3.2 Tool Use and Function Calling

| Model | Tool Calling Score | Speed | Memory | Best For |
|-------|-------------------|-------|--------|----------|
| **Llama 3.1 70B** | 96% | Slower | 48GB+ | Production |
| **Llama 3.1 8B** | 91% | 1.2s | 8GB | Best overall balance |
| **Mistral 7B** | 86% | 0.8s | 7GB | Resource-constrained |
| **GLM-4.5-Air** | High | Fast | - | Agent workflows |

#### Llama 3.1/3.2 for Tool Use

**Capabilities:**
- JSON-based tool calling (native)
- Pythonic tool calling (Llama 3.2+)
- Parallel tool calls (Llama 4 only)
- 128K context with tool integration

**Best Practice:** Use Llama 3.1 8B for production systems (best reliability/performance ratio)

**Sources:**
- [Tool Calling in Llama 3 - Composio](https://composio.dev/blog/tool-calling-in-llama-3-a-guide-to-build-agents)
- [Best Ollama Models for Function Calling 2025](https://collabnix.com/best-ollama-models-for-function-calling-tools-complete-guide-2025/)

### 3.3 Long-Context Models for Research

| Model | Context Window | RAG Optimized | Notes |
|-------|---------------|---------------|-------|
| **Gemma 3 27B** | 128K | Yes | Excellent needle-in-haystack |
| **Qwen 3 14B** | 128K | Yes | Fits 24GB with Q4 |
| **Command R7B** | 128K | Yes | Built for RAG, less hallucination |
| **Granite 4.0 H-Small** | 128K+ | Yes | 32B/9B active MoE |

**Key Finding:** Most LLMs only show increasing RAG performance up to **16-32K tokens**. Beyond that, the "Lost-in-the-Middle" phenomenon affects retrieval.

**Sources:**
- [Long Context RAG Performance - Databricks](https://www.databricks.com/blog/long-context-rag-performance-llms)
- [5 Local LLMs with Longest Context](https://scifilogic.com/open-source-llm-with-longest-context-length/)

### 3.4 RAG-Optimized Embedding Models

| Model | Dimensions | Context | Accuracy | Speed |
|-------|------------|---------|----------|-------|
| **bge-m3** | 1024 | 8K | 72% (best) | Medium |
| **mxbai-embed-large** | 1024 | 8K | 59.25% | Medium |
| **nomic-embed-text** | 1024 | 8K | 57.25% | Slower |
| **Nomic Embed V2** | 1024 | 8K | 86.2% top-5 | Slower |

#### Recommendations by Use Case:
- **Best overall accuracy:** bge-m3
- **Storage-constrained:** mxbai-embed-large
- **Short queries:** nomic-embed-text
- **Multilingual:** Nomic Embed Text V2

**Sources:**
- [Best Embedding Models 2025 - Elephas](https://elephas.app/blog/best-embedding-models)
- [Finding Best Embedding Model for RAG - Timescale](https://www.tigerdata.com/blog/finding-the-best-open-source-embedding-model-for-rag)

### 3.5 Reasoning Frameworks

| Framework | Description | Use Case |
|-----------|-------------|----------|
| **Chain of Thought (CoT)** | Step-by-step reasoning | Complex task decomposition |
| **Tree of Thoughts (ToT)** | Multiple reasoning paths | Exploring alternatives |
| **ReAct** | Reasoning + Action | Tool integration |
| **Pre-Act** | Multi-step planning with reasoning | Agent workflows |
| **Reflexion** | Self-criticism and refinement | Learning from mistakes |

**Best Practice:** Use **Reason + Evaluate + Execute** pattern instead of simple ReAct for production systems.

**Sources:**
- [LLM Powered Autonomous Agents - Lil'Log](https://lilianweng.github.io/posts/2023-06-23-agent/)
- [Reliable Planning with LLMs - Interloom](https://www.interloom.com/en/blog/reliable-planning-with-llms)

---

## 4. Model Sizes and Quantization

### 4.1 VRAM Guidelines by GPU Tier

| VRAM | Optimal Model Size | Quantization | Example Models |
|------|-------------------|--------------|----------------|
| **8GB** | 7B | Q4_K_M | Llama 3.1 8B, Mistral 7B |
| **12GB** | 12-14B | Q4_K_M | Gemma 3 12B, Qwen3 14B, Phi-4 14B |
| **16GB** | 20-22B | Q4_K_M | Gemma 3 27B (tight) |
| **24GB** | 30-35B | Q4_K_M | Qwen2.5-32B, DeepSeek R1 32B |
| **32GB** | 35-45B | Q4_K_M / Q5_K_M | Larger models, less quantization |
| **48GB+** | 70B+ | Q4_K_M | Llama 3.3 70B, Qwen2.5 72B |

### 4.2 GGUF Quantization Quality Comparison

| Quant Level | Quality Retention | Size Reduction | Perplexity Impact | Recommendation |
|-------------|------------------|----------------|-------------------|----------------|
| **Q8_0** | 98-99% | 50% | Negligible | Near-lossless |
| **Q6_K** | ~95% | 60% | Minor softening | High quality work |
| **Q5_K_M** | ~90% | 65% | Noticeable | Good balance |
| **Q4_K_M** | 75-85% | 75% | Visible loss | **Recommended default** |
| **Q4_K_S** | 70-80% | 78% | Significant | Size priority |
| **Q3_K_S** | 60-70% | 82% | Substantial | Extreme compression |

### 4.3 Quantization Recommendations

#### Production Workloads:
- **Q5_K_M or Q6_K** for minimal quality loss
- Safer for regression-sensitive applications

#### Development/Testing:
- **Q4_K_M** for best size/quality balance
- Enables running larger models

#### Resource-Constrained:
- **Q4_K_S** when VRAM is critical
- Accept quality tradeoffs

**Key Insight:** K-quants (Q4_K_M, Q5_K_M, etc.) are almost always better than legacy formats (Q4_0, Q4_1) for the same bit level.

**Sources:**
- [GGUF Quantization Guide 2025](https://apatero.com/blog/gguf-quantized-models-complete-guide-2025)
- [Practical Quantization Guide - Enclave AI](https://enclaveai.app/blog/2025/11/12/practical-quantization-guide-iphone-mac-gguf/)
- [Demystifying LLM Quantization Suffixes](https://medium.com/@paul.ilvez/demystifying-llm-quantization-suffixes-what-q4-k-m-q8-0-and-q6-k-really-mean-0ec2770f17d3)

### 4.4 Speed vs Quality Tradeoffs

| Scenario | Quantization | Speed | Quality | VRAM |
|----------|--------------|-------|---------|------|
| **Real-time chat** | Q4_K_M | Fast | Good | Low |
| **Code generation** | Q5_K_M | Medium | Better | Medium |
| **Creative writing** | Q6_K | Slower | High | Higher |
| **Critical reasoning** | Q8_0 | Slowest | Best | Highest |

---

## 5. Final Recommendations

### 5.1 MarunochiAI (24GB) - Coding Agent

| Component | Recommendation | Alternative |
|-----------|---------------|-------------|
| **Primary Model** | Qwen2.5-Coder-32B-Instruct (Q4_K_M) | DeepSeek-Coder-V2-Lite |
| **Fast Tasks** | Qwen2.5-Coder-14B (Q5_K_M) | StarCoder2-15B |
| **Fine-tuning Data** | Code Alpaca + KodCode | The Stack v2 |
| **Quantization** | Q4_K_M (primary), Q5_K_M (quality) | - |

**Configuration:**
```yaml
models:
  primary:
    name: qwen2.5-coder:32b-instruct-q4_K_M
    vram: ~19GB
    context: 32768
  fast:
    name: qwen2.5-coder:14b-instruct-q5_K_M
    vram: ~12GB
    context: 32768
```

### 5.2 DottscavisAI (32GB) - Creative Agent

| Component | Recommendation | Alternative |
|-----------|---------------|-------------|
| **Vision-Language** | Qwen2.5-VL-32B (Q4_K_M) | InternVL 2.5-26B |
| **Image Generation** | FLUX.1 Dev (FP16) | Stable Diffusion 3.5 |
| **Video Generation** | HunyuanVideo | Wan 2.1 |
| **3D Generation** | TripoSR | SF3D |
| **Music Generation** | YuE | MusicGen |

**Configuration:**
```yaml
models:
  vision:
    name: qwen2.5-vl:32b-q4_K_M
    vram: ~20GB
  image_gen:
    name: flux.1-dev
    vram: ~24GB (FP16)
  3d_gen:
    name: triposr
    vram: <4GB
```

### 5.3 BenchAI (Orchestrator) - Research/Reasoning Agent

| Component | Recommendation | Alternative |
|-----------|---------------|-------------|
| **Reasoning** | DeepSeek-R1-32B (Q4_K_M) | Qwen3-30B-A3B |
| **Tool Use** | Llama 3.1 8B-Instruct | Mistral 7B |
| **Long Context** | Gemma 3 27B | Command R7B |
| **Embeddings** | bge-m3 | nomic-embed-text v2 |

**Configuration:**
```yaml
models:
  reasoning:
    name: deepseek-r1:32b-q4_K_M
    vram: ~20GB
    context: 128K
  tool_use:
    name: llama3.1:8b-instruct-q5_K_M
    vram: ~6GB
    context: 128K
  embeddings:
    name: bge-m3
    dimensions: 1024
```

### 5.4 System Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      BenchAI (Orchestrator)                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐│
│  │ DeepSeek-R1-32B │  │ Llama 3.1 8B    │  │ bge-m3       ││
│  │ (Reasoning)     │  │ (Tool Use)      │  │ (Embeddings) ││
│  └────────┬────────┘  └────────┬────────┘  └──────┬───────┘│
│           │                    │                   │        │
└───────────┼────────────────────┼───────────────────┼────────┘
            │                    │                   │
    ┌───────▼────────┐   ┌───────▼────────┐         │
    │  MarunochiAI   │   │  DottscavisAI  │         │
    │    (24GB)      │   │     (32GB)     │         │
    ├────────────────┤   ├────────────────┤         │
    │ Qwen2.5-Coder  │   │ Qwen2.5-VL     │◄────────┘
    │ -32B (Primary) │   │ FLUX.1 Dev     │
    │ -14B (Fast)    │   │ HunyuanVideo   │
    │ StarCoder2-15B │   │ TripoSR        │
    │                │   │ YuE            │
    └────────────────┘   └────────────────┘
```

### 5.5 Key Takeaways

1. **Qwen2.5 family dominates** both coding (Qwen2.5-Coder) and vision (Qwen2.5-VL) tasks
2. **DeepSeek-R1** excels at complex reasoning with efficient dense architecture
3. **FLUX.1/FLUX.2** is the clear winner for image generation
4. **Q4_K_M quantization** provides optimal balance for consumer GPUs
5. **bge-m3** is the most accurate embedding model for RAG
6. **128K context** is now standard, but RAG performance peaks at 16-32K tokens

---

## Appendix: Useful Resources

### Model Repositories
- [Hugging Face Models](https://huggingface.co/models)
- [Ollama Library](https://ollama.com/library)

### Benchmarks
- [HumanEval](https://github.com/openai/human-eval)
- [MBPP](https://github.com/google-research/google-research/tree/master/mbpp)
- [SWE-Bench](https://www.swebench.com/)
- [Aider Leaderboard](https://aider.chat/docs/leaderboards/)

### Tools
- [LM Studio](https://lmstudio.ai/) - Local model runner
- [Ollama](https://ollama.com/) - Local model management
- [ComfyUI](https://github.com/comfyanonymous/ComfyUI) - Image/video generation
- [vLLM](https://github.com/vllm-project/vllm) - Fast inference

---

*Document generated: December 2024*
*Last research update: December 2025*
