# HealthGPT Fog Node Setup

This README explains how to spin up a simple Fog Node for HealthGPT using Docker on Linux or macOS. If the Fog Node mode is picked during the HealthGPT setup, HealthGPT sends LLM requests to a node on your local network instead of running on‑device or using a cloud provider.

This setup is intentionally minimal: it does not include an authorization service and does not secure traffic with TLS. For production‑ready guidance (authN/Z and TLS), see the SpeziLLM Fog Node documentation:

- SpeziLLM Fog Node: https://github.com/StanfordSpezi/SpeziLLM/tree/main/FogNode
- SpeziLLMFog docs: https://swiftpackageindex.com/StanfordSpezi/SpeziLLM/documentation/spezillmfog


## What This Stack Provides

The `docker-compose.yml` in this directory starts:

- Traefik reverse proxy on port 80 that routes requests with Host header `spezillmfog.local` to the LLM backend.
- Ollama LLM inference service (models are persisted in the `ollama_storage` Docker volume).
- Avahi (Linux only) to advertise the Fog service via mDNS on the local network.

HealthGPT defaults to the host `spezillmfog.local` with HTTP and no auth, matching this compose file. No changes in the app are required when using these defaults.


## Prerequisites

- Docker and Docker Compose installed on Linux or macOS.
- Network access between the device running the HealthGPT app and the machine hosting the Fog Node (Devices must be connected to the **same network and subnet** with IP-level reachability).
- mDNS advertisement and discovery allowed on the network (required to resolve `.local` hostnames between HealthGPT and the Fog Node).


## Quick Start

1) Start the stack (from this `FogNode` directory):

```bash
docker compose up -d
```

If you prefer foreground logs, omit `-d` and open a new terminal for the next step.

2) Download a model inside the Ollama container (example: `llama3.1:8b`):

```bash
docker compose exec ollama ollama pull llama3.1:8b
```

Wait for the download to complete. You can check installed models with:

```bash
docker compose exec ollama ollama list
```


## macOS Service Advertisement (Bonjour)

On Linux, the Avahi container advertises the service via mDNS automatically.
On macOS, service advertisements must be done manually via Bonjour. Run this in a separate terminal on macOS to advertise the service:

```bash
dns-sd -R "SpeziLLMFog Service" _http._tcp spezillmfog.local 80
```

Keep this command running while you use the Fog Node. Stop with `Ctrl+C` when finished.



## Use with HealthGPT

- Build and run the HealthGPT app on a physical device (the iOS simulator is not supported).
- Choose the Fog option during onboarding or change it within the app's settings. With the defaults in this repo, the app discovers the `spezillmfog.local` fog node via a connection over HTTP with no auth.
- As long as the Fog Node is reachable on your local network and the selected model in the HealthGPT app (e.g., `llama3.1:8b`) is pulled on the fog node, you’re set.


## Notes and Limitations

- MVP only: No TLS and no authorization checks are performed in this setup.
- Service discovery:
  - Linux: mDNS via Avahi container (runs in host network mode) broadcasts an HTTP service on port 80.
  - macOS: use the `dns-sd` command above to advertise the service via Bonjour.
- macOS Docker: containers cannot use Apple Metal hardware acceleration; Ollama will run on CPU only and may be slow for larger models. For better performance on macOS, consider running Ollama natively.


## Stop and Cleanup

- Stop the stack (if started in detached mode, otherwise just `Ctrl+C`):

```bash
docker compose down
```

- Models are persisted in the `ollama_storage` volume. To reclaim space, remove the volume after bringing the stack down (volume name may vary by compose project name):

```bash
docker volume ls | grep ollama_storage
docker volume rm <your_volume_name>
```


## Troubleshooting

- Port 80 in use: Adjust the Traefik port mapping in `docker-compose.yml` or stop the conflicting service.
- Can’t discover or resolve `spezillmfog.local` fog node: confirm that your network supports mDNS advertisement and discovery. Some corporate or guest Wi-Fi networks block this. Also ensure both devices are on the same subnet and can reach each other directly.
- Logs: Use `docker compose logs -f traefik` and `docker compose logs -f ollama` to inspect issues.


## Production‑Ready Setup

For TLS termination, authorization, and more robust deployments (including cert management and token‑based auth), use the SpeziLLM Fog Node guides:

- SpeziLLM Fog Node: https://github.com/StanfordSpezi/SpeziLLM/tree/main/FogNode
- SpeziLLMFog docs: https://swiftpackageindex.com/StanfordSpezi/SpeziLLM/documentation/spezillmfog
