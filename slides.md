---
theme: seriph
background: https://cover.sli.dev
class: text-center
highlighter: shiki
lineNumbers: true
info: |
  ## Cours 5 — Conteneurs logiciels
  Université de Rennes · IRISA · DiverSE
  Olivier Barais
drawings:
  persist: false
transition: slide-left
title: "Cours 5 — Conteneurs logiciels"
mdc: true
pdf: true
export: true
comark: true
download: true
---

# Déploiement Continu :  
# Les Conteneurs à la Rescousse

**DevSecOps 2026** · Cours 5

<div class="pt-8 text-gray-400">
  Olivier Barais — Université de Rennes / IRISA
</div>

---
layout: default
---

# Plan du cours

<div class="grid grid-cols-2 gap-4 mt-8">

<div class="p-4 rounded-xl border border-blue-400/40 bg-blue-900/10">

### 1 · Comprendre
- Pourquoi les conteneurs ? *(le problème « ça marche sur ma machine »)*
- Conteneurs vs Machines Virtuelles

</div>

<div class="p-4 rounded-xl border border-emerald-400/40 bg-emerald-900/10">

### 2 · Fonctionner
- Comment Docker fonctionne
- Images, couches, namespaces & cgroups

</div>

<div class="p-4 rounded-xl border border-amber-400/40 bg-amber-900/10">

### 3 · Pratiquer
- Le Dockerfile & les commandes essentielles
- Registres, Compose, CI/CD & orchestration

</div>

<div class="p-4 rounded-xl border border-rose-400/40 bg-rose-900/10">

### 4 · Sécuriser
- Sécurité des conteneurs
- Scanner les images & la supply chain

</div>

</div>

---
layout: section
---

# 1. Pourquoi les conteneurs ?

---

# "Ça marche sur ma machine !"

**Le problème classique :**

```
Développeur          Serveur de staging     Production
─────────────        ──────────────────     ──────────
Ubuntu 24.04         Debian 12              CentOS 8
Python 3.12          Python 3.9             Python 3.6 ⚠️
Node 20.x            Node 18.x              Node 14.x ⚠️
PostgreSQL 16        PostgreSQL 14          PostgreSQL 10 ⚠️
```

**La promesse des conteneurs :**

> *"Build once, run anywhere"*

Le conteneur embarque l'application **et** son environnement d'exécution complet.

---

# L'analogie du conteneur maritime

<div class="grid grid-cols-2 gap-6 mt-4">
<div>

**Avant 1960 — le chaos**

Chaque marchandise avait sa propre forme, taille, et méthode de transport. Charger un navire prenait des jours. Les dommages et vols étaient fréquents.

</div>
<div>

**Après 1960 — la révolution**

Le conteneur ISO standardisé a tout transformé : même format, chargé sur n'importe quel navire, train, ou camion. Le commerce mondial a décollé.

</div>
</div>

<div class="text-center mt-6">
  <img src="/docker-shipping-container.png" class="mx-auto h-40 rounded shadow" />
</div>

> **Docker fait la même chose pour le logiciel :**  
> un conteneur = une application + toutes ses dépendances, tournant identiquement partout.

---

# Docker — naissance et adoption

<div class="grid grid-cols-2 gap-8 mt-4">
<div>

**L'histoire**

- **2013** — Solomon Hykes (ingénieur franco-américain) présente Docker lors de PyCon US
- **2014** — Docker 1.0 : adoption explosive
- **2017** — Projet Moby : 56 700 ⭐ GitHub, 1 843 contributeurs
- **2015** — OCI (Open Container Initiative) : standardisation des formats

</div>
<div>

**Qui utilise Docker ?**

```
✅ Google       ✅ Amazon (AWS)
✅ Microsoft    ✅ eBay
✅ Spotify      ✅ PayPal
✅ Netflix      ✅ Zalando
```

Disponible sur tous les PaaS :
AWS ECS, Google Cloud Run, Azure Container Instances, Heroku, Fly.io…

</div>
</div>

---
layout: section
---

# 2. Conteneurs vs Machines Virtuelles

---

# Conteneurs vs VMs — Architecture

<div class="text-center">
  <img src="/docker-vm-vs-containers-1.jpg" class="mx-auto h-72 rounded shadow" />
</div>

<div class="mt-4 text-sm">

> Les conteneurs partagent l'OS hôte et, si approprié, les bibliothèques — c'est ce qui les rend **légers et rapides**. Les VMs emportent chacune leur propre OS invité complet.

</div>

---

# L'avantage du système de fichiers en union

<div class="text-center">
  <img src="/docker-vm-vs-containers-2.jpg" class="mx-auto h-64 rounded shadow" />
</div>

<div class="mt-4 text-sm grid grid-cols-3 gap-4">
<div class="text-center">

**App originale**  
Pas d'OS superflu.  
Partage les bins/libs.

</div>
<div class="text-center">

**Copie de l'app**  
Pas d'OS. Peut partager  
les bins/libs avec l'originale.

</div>
<div class="text-center">

**App modifiée**  
Le système de fichiers union  
ne stocke que les *diffs*.

</div>
</div>

---
zoom: 0.9
---

# Comparaison VMs / Conteneurs

| Critère | Machine Virtuelle | Conteneur Docker |
|---------|------------------|-----------------|
| **Démarrage** | 1–5 minutes | < 1 seconde |
| **Taille** | 1–50 Go | 10–500 Mo |
| **Isolation** | Forte (OS séparé) | Modérée (kernel partagé) |
| **Overhead CPU/RAM** | Élevé | Très faible |
| **Portabilité** | Moyenne (image lourde) | Excellente |
| **Densité** | ~10–50 VMs/hôte | ~100–1000 conteneurs/hôte |
| **Sécurité périmètre** | Hyperviseur | Namespaces + cgroups |
| **Usage typique** | Isolation forte, OS hétérogènes | Microservices, CI/CD, cloud-native |

---
layout: section
---

# 3. Comment Docker fonctionne

---

# Glossaire Docker : l'Image

<div class="grid grid-cols-2 gap-6 mt-2">
<div>

**Image Docker :**
- Template en **lecture seule**
- Construite à partir d'un `Dockerfile`
- Composée de **couches superposées** (bootfs + rootfs + layers)
- Chaque couche = résultat d'une instruction `RUN`, `COPY`, `ADD`
- Stockée dans un registre (Docker Hub, GHCR, ECR…)
- Identifiée par un digest SHA-256

</div>
<div class="text-center">

<img src="/docker-image-layers-base.png" class="mx-auto h-52 rounded" />

</div>
</div>

```
docker pull debian:12          # télécharge toutes les couches
docker image inspect debian:12 # inspecte les métadonnées
```

---

# Glossaire Docker : Couches et Conteneur

<div class="grid grid-cols-2 gap-6 mt-2">
<div>

**Système de couches :**
- Chaque image référence son **image parente**
- Les couches sont partagées entre images → économie de disque
- `docker commit` crée une nouvelle couche

**Conteneur = Image + couche R/W :**
- Couche d'écriture ajoutée par-dessus les couches de l'image
- Éphémère : données perdues à l'arrêt (sauf volumes)
- Plusieurs conteneurs peuvent partager la même image sous-jacente

</div>
<div class="text-center">

<img src="/docker-layers-aufs.png" class="mx-auto h-56 rounded" />

</div>
</div>

---

# Sous le capot — le noyau Linux

<div class="grid grid-cols-2 gap-6 mt-2">
<div>

Docker repose sur des primitives du **noyau Linux** :

**cgroups (Control Groups)**  
Limitent et mesurent les ressources :
- CPU, Mémoire, I/O disque, Réseau
- Empêchent un conteneur de monopoliser l'hôte

**Namespaces**  
Isolent les processus :
- `pid` — espace de processus séparé
- `net` — interface réseau virtuelle
- `mnt` — système de fichiers isolé
- `uts` — hostname propre
- `ipc` — IPC séparé

</div>
<div class="text-center">

<img src="/docker-arch-internals.png" class="mx-auto h-56 rounded" />

</div>
</div>

---

# Sous le capot — AuFS et OverlayFS

**Union File System** : superpose plusieurs répertoires en lecture seule + un répertoire d'écriture

```
  Couche R/W  (conteneur)      ← modifications runtime ici
  ─────────────────────────
  Layer 3 : add Apache         ← RUN apt install apache2
  Layer 2 : add emacs          ← RUN apt install emacs
  Layer 1 : Debian rootfs      ← FROM debian:12
  ─────────────────────────
  bootfs (kernel)              ← partagé avec l'hôte
```

<img src="/docker-layers-aufs.png" class="mx-auto h-36 mt-2 rounded" />

**Drivers disponibles :** AuFS (historique), OverlayFS (défaut Linux moderne), Device Mapper, Btrfs

---

# ⚠️ Les conteneurs ne sont PAS des sandboxes !

<div class="bg-orange-50 border border-orange-300 rounded p-4 mt-4">

> **"Containers do NOT Contain !"**  
> — citation directe de la documentation Docker originale

</div>

<div class="mt-4 grid grid-cols-2 gap-4">
<div>

**Ce que les conteneurs isolent :**
- Processus (namespaces pid)
- Réseau (interface virtuelle)
- Système de fichiers (OverlayFS)
- Ressources (cgroups)

</div>
<div>

**Ce qu'ils n'isolent PAS par défaut :**
- Le **kernel Linux** est partagé
- Les syscalls non filtrés
- Les capabilities root (sans restriction)
- Certains pseudo-systèmes de fichiers

</div>
</div>

**Renforcement nécessaire :** SELinux / AppArmor, Seccomp, rootless containers, user namespaces

---
layout: section
---

# 4. Docker en pratique

---

# Le Dockerfile

```dockerfile
# Dockerfile
FROM python:3.12-slim

# Bonnes pratiques : user non-root
RUN useradd -m -u 1000 appuser

WORKDIR /app

# Copier d'abord les dépendances pour profiter du cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Puis le code source
COPY src/ ./src/

# Exposer le port
EXPOSE 8080

# Changer d'utilisateur
USER appuser

# Commande par défaut
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

---

# Commandes Docker essentielles

```bash
# Construction d'une image
docker build -t mon-app:1.0.0 .
docker build -t mon-app:1.0.0 --no-cache .

# Lancer un conteneur
docker run -d -p 8080:8080 --name mon-app mon-app:1.0.0
docker run -it mon-app:1.0.0 bash    # Mode interactif

# Gérer les conteneurs
docker ps                            # Conteneurs en cours
docker ps -a                         # Tous les conteneurs
docker logs mon-app                  # Logs du conteneur
docker exec -it mon-app bash         # Shell dans le conteneur
docker stop mon-app && docker rm mon-app

# Images et registres
docker images
docker pull nginx:1.25
docker push ghcr.io/org/mon-app:1.0.0
```

---
zoom: 0.88
---

# Docker Compose

```yaml
# docker-compose.yml
services:
  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: postgresql://postgres:secret@db:5432/app
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./uploads:/app/uploads

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: app
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready"]
      interval: 10s

volumes:
  postgres_data:
```

---

# Docker Hub et les registres

```
  docker pull nginx:1.25
  ┌────────────────────────────────────┐
  │  docker.io / library / nginx : 1.25│
  │  registre  /  namespace /  image : tag │
  └────────────────────────────────────┘
```

**Registres publics :**
- **Docker Hub** (`docker.io`) — le registre historique, millions d'images
- **GitHub Container Registry** (`ghcr.io`) — intégré aux workflows GitHub Actions
- **Quay.io** — Red Hat / IBM, focus sécurité

**Registres privés :**
- AWS ECR, Google Artifact Registry, Azure Container Registry
- GitLab Container Registry
- Harbor (auto-hébergé, open source)

> **Bonne pratique :** n'utilisez pas d'images `latest` en production. Épinglez sur un **digest SHA-256**.

<style>
/* style.css */
.slidev-layout.two-cols-header {
  grid-template-columns: 4fr 2fr;
}
li {
  font-size: 0.9em;
  margin-top: 0em;
  margin-bottom: 0em;
}
</style>


---
layout: section
---

# 5. Docker & Intégration Continue

---

# Le pipeline CI/CD avec Docker

```
  Code push (git)
       │
       ▼
  ┌─────────────────────────────────────────────────────────┐
  │  CI Pipeline                                            │
  │                                                         │
  │  1. pull image de base ──► docker pull python:3.12-slim │
  │  2. build image         ──► docker build -t app:sha .   │
  │  3. scan sécurité       ──► trivy image app:sha         │
  │  4. tests unitaires     ──► docker run app:sha pytest   │
  │  5. push registre       ──► docker push ghcr.io/…/app  │
  └─────────────────────────────────────────────────────────┘
       │
       ▼
  Déploiement (Kubernetes, Compose, ECS…)
```

---

# Scénario développeur avec Docker

**Workflow typique :**

```bash
# 1. Pull l'image de base depuis le Hub
docker pull python:3.12-slim

# 2. Développer et personnaliser
# (éditer le Dockerfile, ajouter les dépendances)
docker build -t mon-app:dev .

# 3. Tester localement
docker run -it -p 8080:8080 mon-app:dev

# 4. Publier l'image personnalisée comme nouvelle base
docker tag mon-app:dev ghcr.io/mon-org/mon-app:1.0.0
docker push ghcr.io/mon-org/mon-app:1.0.0
```

> L'image publiée devient la base des builds CI et des déploiements suivants.

---
zoom: 0.9
---

# GitHub Actions + Docker

```yaml
name: Build and push Docker image

on: 
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

# Microservices et orchestration

<div class="grid grid-cols-2 gap-6 mt-2">
<div>

**Avantage des conteneurs pour les microservices :**
- Chaque service dans son propre conteneur
- Sprints indépendants par service
- Mises à jour partielles sans redéploiement global
- Scaling horizontal par service

**Orchestration (au-delà de Compose) :**
- **Kubernetes** — standard industriel, déploiement, scaling, self-healing
- **Docker Swarm** — plus simple, natif Docker (moins utilisé aujourd'hui)
- **Nomad** (HashiCorp) — alternatif léger

</div>
<div>

```yaml
# Microservices avec Docker Compose
services:
  frontend:
    image: app/frontend:1.2
    ports: ["3000:3000"]

  api-users:
    image: app/users:2.1
    ports: ["8081:8080"]

  api-orders:
    image: app/orders:1.5
    ports: ["8082:8080"]

  db-users:
    image: postgres:16-alpine

  db-orders:
    image: postgres:16-alpine
```

</div>
</div>

---
layout: section
---

# 6. Sécurité des conteneurs & Supply Chain

---

# La surface d'attaque d'une image Docker

```
  FROM python:3.12-slim
         │
         ▼ Contient :
  ┌──────────────────────────────────────┐
  │  OS Debian (paquets apt)             │  ← CVE dans les paquets système
  │  Python 3.12 runtime                 │  ← CVE dans Python
  │  pip packages (requirements.txt)     │  ← CVE dans vos dépendances
  │  Votre code applicatif               │  ← Bugs / secrets hardcodés
  │  Configuration (ports, users…)       │  ← Mauvaise configuration
  └──────────────────────────────────────┘
```

**Chaque couche est un vecteur d'attaque.**

---

# Bonnes pratiques de sécurité Docker

**1. Images de base minimales :**
```dockerfile
# ❌ Image complète (~ 1 Go de surface d'attaque)
FROM python:3.12

# ✅ Image slim (~100 Mo)
FROM python:3.12-slim

# ✅ Image distroless (~50 Mo, pas de shell)
FROM gcr.io/distroless/python3
```

**2. Multi-stage build (séparer build et runtime) :**
```dockerfile
# Stage 1 : build
FROM python:3.12 AS builder
RUN pip install --prefix=/install -r requirements.txt

# Stage 2 : runtime (image minimale)
FROM python:3.12-slim
COPY --from=builder /install /usr/local
COPY src/ /app/src/
CMD ["python", "/app/src/main.py"]
```

---

# Scanner les images Docker

```bash
# Trivy (outil open source recommandé)
trivy image python:3.12-slim
trivy image --severity HIGH,CRITICAL mon-app:1.0.0

# Dans le pipeline CI/CD (GitHub Actions)
- name: Scan image avec Trivy
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'mon-app:${{ github.sha }}'
    format: 'table'
    exit-code: '1'
    severity: 'CRITICAL,HIGH'
    
# Générer un SBOM depuis l'image
trivy image --format cyclonedx mon-app:1.0.0 > sbom-image.json
syft mon-app:1.0.0 -o cyclonedx-json > sbom-image.json
```

---

# Registres d'images et confiance

**Docker Hub vs registres privés :**
```
  docker pull nginx:1.25
       │
       ▼
  Registre public (docker.io)
  → Qui a construit cette image ?
  → Est-ce la vraie image nginx ou une contrefaçon ?
  → A-t-elle été modifiée en transit ?
```

**Docker Content Trust (DCT) et Cosign :**
```bash
# Signer une image avec Cosign (Sigstore)
cosign sign --key cosign.key ghcr.io/org/mon-app:1.0.0

# Vérifier la signature
cosign verify --key cosign.pub ghcr.io/org/mon-app:1.0.0

# Générer un SBOM et l'attacher à l'image
syft mon-app:1.0.0 | cosign attest --predicate - ghcr.io/org/mon-app:1.0.0
```

---
layout: center
class: text-center
---

# À retenir

<div class="grid grid-cols-3 gap-4 mt-8 text-left">

<div class="p-5 rounded-xl border border-amber-400/40 bg-amber-900/10 flex flex-col">
<div class="text-3xl mb-2">📦</div>
<div class="font-semibold text-amber-300">Pas une boîte magique</div>
<p class="text-sm mt-2">Un conteneur, c'est un <b>ensemble d'artefacts</b> — OS, runtime, libs, code — dont <b>chacun peut contenir des vulnérabilités</b>.</p>
</div>

<div class="p-5 rounded-xl border border-blue-400/40 bg-blue-900/10 flex flex-col">
<div class="text-3xl mb-2">🧱</div>
<div class="font-semibold text-blue-300">Kernel partagé</div>
<p class="text-sm mt-2">Les conteneurs <b>partagent le kernel</b> de l'hôte : ce ne sont <b>pas des sandboxes</b>.</p>
</div>

<div class="p-5 rounded-xl border border-emerald-400/40 bg-emerald-900/10 flex flex-col">
<div class="text-3xl mb-2">🔍</div>
<div class="font-semibold text-emerald-300">Scanner = auditer</div>
<p class="text-sm mt-2"><b>Scanner ses images, c'est auditer sa supply chain binaire.</b></p>
</div>

</div>

<div class="mt-10 p-4 rounded-lg border border-rose-400/40 bg-rose-900/10 text-center">
<b>Cours suivant :</b> Comprendre les menaces et mettre en place des contres mesures.
</div>

---
layout: default
---

# Merci

Questions ?

**Ressources :**
- [Docker docs](https://docs.docker.com/)
- [Trivy](https://trivy.dev/)
- [Cosign / Sigstore](https://sigstore.dev/)
- [SLSA pour les images](https://slsa.dev/)
- [OCI — Open Container Initiative](https://opencontainers.org/)
- [cgroups v2](https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html)
