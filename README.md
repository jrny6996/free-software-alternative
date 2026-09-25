# Free Software Alternatives

Companion repo for the video by [Jonathan Clark](https://youtube.com/@jonathan-clark).

Self-host the subscription replacements that run well in Docker. Desktop / freemium apps are linked below — install those natively.

## Quick start

Each service has a `scaffold.sh` that copies `.env`, creates folders, pulls images, and starts the stack.

```bash
# from repo root
./scaffold.sh --list
./scaffold.sh nextcloud
./scaffold.sh immich
./scaffold.sh jellyfin
./scaffold.sh n8n
./scaffold.sh ollama --webui --pull llama3.2
./scaffold.sh ollama --gpu --webui          # NVIDIA
./scaffold.sh comfyui                       # NVIDIA (default)
./scaffold.sh comfyui --cpu                 # no GPU
./scaffold.sh cloudflare-tunnel   # needs TUNNEL_TOKEN in .env first

# or per folder
cd nextcloud && ./scaffold.sh
```

Edit `.env` passwords after the first run (or before, if you prefer).

| Service | Replaces | Port | Scaffold |
| --- | --- | --- | --- |
| [Nextcloud](./nextcloud) | Google Drive / Docs | `8080` | `./scaffold.sh nextcloud` |
| [Immich](./immich) | Google Photos | `2283` | `./scaffold.sh immich` |
| [Jellyfin](./jellyfin) | Netflix / Hulu / Spotify | `8096` | `./scaffold.sh jellyfin` |
| [n8n](./n8n) | Zapier | `5678` | `./scaffold.sh n8n` |
| [Ollama](./ollama) | ChatGPT / Claude (local) | `11434` | `./scaffold.sh ollama` |
| [ComfyUI](./comfyui) | Firefly / media gen | `8188` | `./scaffold.sh comfyui` |
| [Cloudflare Tunnel](./cloudflare-tunnel) | Public HTTPS access | — | `./scaffold.sh cloudflare-tunnel` |

Optional Ollama chat UI: `./scaffold.sh ollama --webui` → http://localhost:3000

### CPU vs GPU (Ollama & ComfyUI)

Both AI stacks ship **CPU and GPU** compose files. Expect slower (sometimes much slower) results on CPU — that’s part of the privacy vs. cloud TCO tradeoff in the video.

| Stack | CPU | GPU (NVIDIA) |
| --- | --- | --- |
| **Ollama** | `docker-compose.yaml` (default) · `./scaffold.sh ollama` | `docker-compose.gpu.yaml` override · `./scaffold.sh ollama --gpu` |
| **ComfyUI** | `docker-compose.cpu.yaml` · `./scaffold.sh comfyui --cpu` | `docker-compose.yaml` (default) · `./scaffold.sh comfyui` |

```bash
# Ollama CPU (small models work; large ones crawl)
cd ollama && docker compose up -d
# Ollama GPU
cd ollama && docker compose -f docker-compose.yaml -f docker-compose.gpu.yaml up -d

# ComfyUI GPU
cd comfyui && docker compose up -d
# ComfyUI CPU (minutes per image; video usually not practical)
cd comfyui && docker compose -f docker-compose.cpu.yaml up -d
```

GPU stacks need the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html).

## Expose to the public internet — Cloudflare Tunnel

Use [`cloudflare-tunnel/`](./cloudflare-tunnel) so Immich / Nextcloud / etc. are reachable without opening router ports. Create a tunnel in [Cloudflare Zero Trust](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/), paste the token into `.env`, map hostnames to `localhost:<port>`.

## Download / install (not Docker)

These are desktop apps or freemium tools — get them from the official site.

| App | Replaces | Link |
| --- | --- | --- |
| Nextcloud Desktop | Drive sync client | https://nextcloud.com/install/#desktop-files |
| Immich mobile | Google Photos app | App Store / Play Store — connect to your Immich URL |
| Krita | Photoshop (drawing) | https://krita.org/en/download |
| GIMP | Photoshop (general) | https://www.gimp.org/downloads |
| DaVinci Resolve | Premiere Pro | https://www.blackmagicdesign.com/products/davinciresolve |
| [Quick Cut](https://quick-cut.app/) | Premiere Pro (web, freemium + AI) | https://quick-cut.app/ — shout-out |
| LM Studio | ChatGPT desktop GUI | https://lmstudio.ai |
| Ollama (native) | Same as Docker Ollama | https://ollama.com/download |

## Cost context (from the video)

- Average US subscription spend: ~$111–$219/mo — [Resubs](https://resubs.app/resources/subscription-spending-statistics)
- Unused subscriptions waste ~$250+/yr — [CNET](https://www.cnet.com/tech/services-and-software/subscription-survey-2026/)
- Dropbox plans for comparison — https://www.dropbox.com/plans

**TCO reminder:** a free stack is only “free” if setup time, hardware, electricity, and missing features don’t outweigh the subscription you’re replacing. Jellyfin especially — no discovery / no streaming catalog — often loses on TCO unless you already own the library.

## Suggested order for the video

1. Nextcloud (files) → Immich (photos) → Cloudflare Tunnel
2. Jellyfin (media) — demo upload, then TCO caveat
3. n8n (automations) — optionally wired to local Ollama
4. Ollama / LM Studio + ComfyUI (AI)
5. Adobe stack via Krita, GIMP, Resolve / [Quick Cut](https://quick-cut.app/) (links above)
