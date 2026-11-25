// ============================================================
// Polycopié — Cours 5 : Conteneurs logiciels & Docker
// Université de Rennes · IRISA / DiverSE
// Olivier Barais
// ============================================================

#set document(
  title: "Cours 5 — Conteneurs logiciels & Docker",
  author: "Olivier Barais",
  date: datetime(year: 2026, month: 9, day: 1),
)

#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 8pt, fill: luma(130))
      #grid(columns: (1fr, 1fr),
        [DevSecOps — Cours 5 · Université de Rennes],
        align(right)[Olivier Barais]
      )
      #line(length: 100%, stroke: 0.5pt + luma(200))
    ]
  },
  footer: context [
    #set text(size: 8pt, fill: luma(130))
    #line(length: 100%, stroke: 0.5pt + luma(200))
    #v(2pt)
    #grid(columns: (1fr, 1fr),
      [IRISA / DiverSE · 2026],
      align(right)[Page #counter(page).display("1")]
    )
  ]
)

#set text(font: "New Computer Modern", size: 10.5pt, lang: "fr")
#set par(justify: true, leading: 0.65em, spacing: 1.2em)
#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  v(1.5em)
  block(
    fill: rgb("#1e40af"),
    radius: 4pt,
    inset: (x: 10pt, y: 6pt),
    width: 100%,
    text(fill: white, size: 14pt, weight: "bold")[#it.body]
  )
  v(0.5em)
}

#show heading.where(level: 2): it => {
  v(0.8em)
  text(size: 12pt, weight: "bold", fill: rgb("#1d4ed8"))[#it.body]
  v(0.3em)
}

#show heading.where(level: 3): it => {
  v(0.5em)
  text(size: 11pt, weight: "bold", fill: rgb("#374151"))[#it.body]
  v(0.2em)
}

// Boîte d'alerte
#let alert(color: red, icon: "⚠", body) = block(
  fill: color.lighten(90%),
  stroke: 0.8pt + color,
  radius: 4pt,
  inset: 10pt,
  width: 100%,
)[
  #text(weight: "bold")[#icon  ] #body
]

// Boîte d'exemple
#let example(title, body) = block(
  fill: rgb("#f0f9ff"),
  stroke: (left: 3pt + rgb("#0ea5e9")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 8pt),
  width: 100%,
)[
  #text(weight: "bold", fill: rgb("#0369a1"))[Exemple — #title] \
  #v(4pt)
  #body
]

// Boîte de définition
#let definition(term, body) = block(
  fill: rgb("#f5f3ff"),
  stroke: (left: 3pt + rgb("#7c3aed")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 8pt),
  width: 100%,
)[
  #text(weight: "bold", fill: rgb("#6d28d9"))[Définition — #term] \
  #v(4pt)
  #body
]

// Boîte de retenir
#let keypoint(body) = block(
  fill: rgb("#fff7ed"),
  stroke: (left: 3pt + rgb("#ea580c")),
  inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 8pt),
  width: 100%,
)[
  #text(weight: "bold", fill: rgb("#c2410c"))[À retenir] \
  #v(4pt)
  #body
]

// Style des blocs de code
#show raw.where(block: true): it => block(
  fill: rgb("#0f172a"),
  radius: 4pt,
  inset: 10pt,
  width: 100%,
)[#text(fill: rgb("#94a3b8"), size: 9pt, font: "New Computer Modern")[#it]]

// ============================================================
// PAGE DE TITRE
// ============================================================

#align(center)[
  #v(2cm)
  #block(
    fill: rgb("#1e3a8a"),
    radius: 8pt,
    inset: 20pt,
    width: 90%,
  )[
    #text(fill: white, size: 11pt)[DevSecOps — Université de Rennes · IRISA / DiverSE]
    #v(8pt)
    #text(fill: white, size: 20pt, weight: "bold")[Cours 5]
    #v(4pt)
    #text(fill: rgb("#93c5fd"), size: 15pt)[Conteneurs logiciels & Docker]
    #v(4pt)
    #text(fill: rgb("#bfdbfe"), size: 11pt)[Virtualisation légère · CI/CD · Sécurité des images · Supply Chain]
  ]

  #v(1.5cm)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1cm,
    align(center)[
      #text(size: 10pt, fill: luma(80))[*Auteur*\ Olivier Barais]
    ],
    align(center)[
      #text(size: 10pt, fill: luma(80))[*Institution*\ IRISA / DiverSE\ Université de Rennes]
    ]
  )

  #v(0.5cm)
  #text(size: 9pt, fill: luma(120))[Année universitaire 2026–2027]

  #v(1.5cm)

  #block(
    fill: rgb("#f8fafc"),
    stroke: 0.5pt + luma(200),
    radius: 6pt,
    inset: 15pt,
    width: 90%,
  )[
    #text(size: 9.5pt, fill: luma(60))[
      *Résumé* — Ce polycopié accompagne le cours 5 du module DevSecOps. Il présente les conteneurs
      logiciels comme solution au problème de portabilité des applications, en détaillant l'architecture
      interne de Docker (cgroups, namespaces, UnionFS), les bonnes pratiques de construction d'images,
      l'intégration dans les pipelines CI/CD, et les enjeux de sécurité de la chaîne d'approvisionnement
      logicielle appliqués aux images de conteneurs.
    ]
  ]
]

#pagebreak()

// ============================================================
// TABLE DES MATIÈRES
// ============================================================

#outline(title: "Table des matières", depth: 2, indent: 1.5em)

#pagebreak()

// ============================================================
// 1. POURQUOI LES CONTENEURS ?
// ============================================================

= Pourquoi les conteneurs ?

== Le problème classique : « Ça marche sur ma machine »

Tout développeur ou équipe DevOps a un jour rencontré la situation suivante : une application
fonctionne parfaitement sur le poste de développement, mais échoue en staging ou en production
à cause de différences d'environnement. Ce phénomène, surnommé le problème du _"it works on
my machine"_, résulte de l'accumulation de divergences entre les environnements :

- Versions différentes du système d'exploitation (Ubuntu 24.04 en dev, CentOS 8 en prod)
- Versions différentes des runtimes applicatifs (Python 3.12 vs Python 3.6)
- Bibliothèques système absentes ou de versions incompatibles
- Variables d'environnement et configurations différentes

Avant les conteneurs, les solutions existantes (machines virtuelles, scripts de provisionnement,
Ansible, Chef, Puppet) résolvaient ce problème partiellement, mais introduisaient leur propre
complexité.

#definition("Conteneur logiciel")[
  Un conteneur est une unité logicielle standardisée encapsulant le code d'une application et
  toutes ses dépendances (bibliothèques, runtime, variables d'environnement, fichiers de
  configuration) afin que l'application s'exécute de manière identique quel que soit
  l'environnement d'accueil. @merkel2014docker
]

== L'analogie du conteneur maritime

L'idée centrale de Docker s'inspire de la révolution du transport maritime survenue dans les
années 1960. Avant l'invention du conteneur ISO standardisé par Malcom McLean, le fret maritime
était une activité laborieuse : chaque marchandise avait sa propre forme, nécessitait un
conditionnement spécifique, et son chargement et déchargement mobilisaient des équipes
importantes pendant des jours. Des dommages et des vols fréquents dégradaient encore le
processus.

L'adoption du conteneur standardisé a transformé le commerce mondial : un conteneur de 20 pieds
(TEU) se charge indifféremment sur n'importe quel navire porte-conteneurs, train ou camion.
Les manutentionnaires, les grues et les ports ont été standardisés en conséquence. Le coût du
transport maritime a chuté de 80 % en quelques décennies.

#keypoint()[
  Docker transpose exactement cette idée au logiciel : "un conteneur Docker = un service applicatif + toutes ses dépendances", packagées dans un format standardisé (OCI) qui s'exécute
  identiquement sur n'importe quelle machine disposant d'un moteur de conteneurs.
]

== Naissance et adoption de Docker

Docker a été présenté par Solomon Hykes (ingénieur franco-américain) lors de la conférence
PyCon US en mars 2013. En 2014, Docker 1.0 est lancé et connaît une adoption sans précédent
dans l'histoire des outils de développement. En 2017, le projet Moby (nom open source du
moteur Docker) comptait plus de 56 700 étoiles GitHub et 1 843 contributeurs.

En 2015, Docker et la Linux Foundation créent l'_Open Container Initiative_ (OCI)
@oci-runtime-spec pour standardiser les formats d'images et de runtimes, garantissant
l'interopérabilité entre les différents moteurs de conteneurs (Docker Engine, containerd,
Podman, CRI-O).

Selon l'enquête annuelle CNCF 2023 @cncf-survey-2023, plus de 90 % des organisations
répondantes utilisent des conteneurs (pilotes et évaluations inclus), et 84 % utilisent ou
évaluent Kubernetes.

// ============================================================
// 2. CONTENEURS VS MACHINES VIRTUELLES
// ============================================================

= Conteneurs vs Machines Virtuelles

== Architecture comparée

Les machines virtuelles (VMs) et les conteneurs répondent au même besoin d'isolation, mais
avec des mécanismes fondamentalement différents @felter2015updated @bernstein2014containers.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    stroke: 0.5pt + luma(200),
    fill: (_, row) => if row == 0 { rgb("#1e40af") } else if calc.odd(row) { rgb("#f8fafc") } else { white },
    table.header(
      text(fill: white, weight: "bold")[Critère],
      text(fill: white, weight: "bold")[Machine Virtuelle],
      text(fill: white, weight: "bold")[Conteneur Docker],
    ),
    [*Couche d'isolation*], [Hyperviseur (Type 1 ou 2)], [Noyau Linux partagé],
    [*OS embarqué*], [OS invité complet (kernel inclus)], [Pas d'OS invité],
    [*Démarrage*], [1 à 5 minutes], [< 1 seconde],
    [*Taille image*], [1 à 50 Go], [10 à 500 Mo],
    [*Overhead mémoire*], [Élevé (OS invité)], [Très faible],
    [*Densité / hôte*], [~10 à 50 VMs], [~100 à 1 000 conteneurs],
    [*Isolation*], [Forte (kernel séparé)], [Modérée (kernel partagé)],
    [*Portabilité*], [Moyenne (images lourdes)], [Excellente],
    [*Usage typique*], [OS hétérogènes, isolation forte], [Microservices, CI/CD, cloud-native],
  ),
  caption: [Comparaison VMs et conteneurs @felter2015updated],
)

== Le système de fichiers en union

L'un des avantages clés des conteneurs est leur utilisation d'un _Union File System_ (UnionFS),
qui permet de superposer plusieurs répertoires en lecture seule avec un seul répertoire
d'écriture. Contrairement aux VMs où chaque copie d'application nécessite une VM complète,
le système de fichiers union permet de :

- Partager les couches communes entre plusieurs conteneurs (économie de disque)
- Ne stocker que les *différences* (_diffs_) entre une image et ses dérivées
- Instancier rapidement de nombreuses copies d'une même image

#example("Union FS — partage de couches")[
  Si 100 conteneurs Python s'exécutent simultanément à partir de la même image
  `python:3.12-slim`, les couches de base (Debian + Python) ne sont stockées qu'*une seule fois*
  sur le disque. Seule la couche d'écriture propre à chaque conteneur est individuelle.
]

// ============================================================
// 3. ARCHITECTURE INTERNE DE DOCKER
// ============================================================

= Architecture interne de Docker

== Les primitives du noyau Linux

Docker n'est pas une technologie de virtualisation au sens classique. C'est une abstraction
construite au-dessus de primitives existantes du noyau Linux, combinant deux mécanismes
fondamentaux @rice2020container @kernel-cgroups @kernel-namespaces.

=== cgroups (Control Groups)

Les _control groups_ (cgroups) sont une fonctionnalité du noyau Linux permettant de limiter,
mesurer et isoler l'utilisation des ressources par des groupes de processus. Docker utilise
les cgroups pour garantir qu'aucun conteneur ne peut monopoliser les ressources de l'hôte.

Les ressources contrôlées par les cgroups incluent :
- *CPU* — limitation du temps processeur alloué
- *Mémoire* — plafond de RAM et de mémoire virtuelle
- *I/O disque* — limitation du débit en lecture/écriture
- *Réseau* — priorité et bande passante (via tc/netem)

Depuis Linux 4.5, cgroups v2 unifie la hiérarchie en une arborescence unique, offrant un
meilleur contrôle et une meilleure isolation.

=== Namespaces

Les _namespaces_ Linux permettent d'isoler différents aspects des ressources système afin que
chaque groupe de processus ait sa propre vue du système @kernel-namespaces. Docker utilise
six types de namespaces :

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    stroke: 0.5pt + luma(200),
    fill: (_, row) => if row == 0 { rgb("#1e40af") } else if calc.odd(row) { rgb("#f8fafc") } else { white },
    table.header(
      text(fill: white, weight: "bold")[Namespace],
      text(fill: white, weight: "bold")[Ressource isolée],
      text(fill: white, weight: "bold")[Effet sur le conteneur],
    ),
    [`pid`], [Espace de processus], [PID 1 dans le conteneur],
    [`net`], [Interfaces réseau], [Interface réseau virtuelle propre],
    [`mnt`], [Points de montage], [Système de fichiers isolé],
    [`uts`], [Hostname / domainname], [Hostname propre au conteneur],
    [`ipc`], [IPC (semaphores, shared memory)], [Communication IPC isolée],
    [`user`], [UIDs/GIDs], [Root dans le conteneur ≠ root sur l'hôte],
  ),
  caption: [Namespaces Linux utilisés par Docker],
)

== Le système de fichiers en couches (UnionFS)

Docker utilise un _Union File System_ (historiquement AuFS, aujourd'hui OverlayFS par défaut)
pour construire ses images en couches superposées.

```
  ┌────────────────────────────┐  Couche R/W (conteneur)
  │  modifications runtime     │  ← éphémère, spécifique à l'instance
  ├────────────────────────────┤
  │  RUN apt install apache2   │  ← couche image (lecture seule)
  ├────────────────────────────┤
  │  RUN apt install emacs     │  ← couche image (lecture seule)
  ├────────────────────────────┤
  │  Debian 12 rootfs          │  ← image de base (lecture seule)
  ├────────────────────────────┤
  │  bootfs                    │  ← démonté après le démarrage (kernel = celui de l'hôte)
  └────────────────────────────┘
```

Chaque instruction `RUN`, `COPY`, ou `ADD` dans un Dockerfile crée une nouvelle couche.
Les couches sont identifiées par leur hash SHA-256 et mises en cache, ce qui accélère
les builds successifs. Les drivers de stockage disponibles sont : *OverlayFS* (défaut Linux
moderne), Device Mapper, Btrfs, ZFS.

== ⚠ Les conteneurs ne sont pas des sandboxes

#alert(color: rgb("#dc2626"), icon: "⚠")[
  *"Containers do NOT Contain !"* — citation de la documentation Docker originale.

  Les conteneurs *partagent le noyau Linux de l'hôte*. Une vulnérabilité dans le kernel
  peut compromettre tous les conteneurs en cours d'exécution. Les conteneurs n'offrent
  *pas* le même niveau d'isolation que les machines virtuelles.
]

Les vecteurs d'attaque spécifiques aux conteneurs incluent @lin2018measurement @combe2016docker :
- *Évasion de conteneur* (_container escape_) : exploitation d'une vulnérabilité kernel pour
  accéder à l'hôte
- *Escalade de privilèges* : un conteneur lancé avec `--privileged` a un accès quasi-total
  à l'hôte
- *Attaque de voisinage* : un conteneur malveillant peut tenter d'épuiser les ressources de
  l'hôte au détriment des autres conteneurs

Pour renforcer l'isolation, Docker supporte nativement SELinux et AppArmor (profils MAC),
Seccomp (filtrage des appels système), et les _rootless containers_ (exécution sans privilèges
root).

// ============================================================
// 4. DOCKER EN PRATIQUE
// ============================================================

= Docker en pratique

== Le Dockerfile

Le `Dockerfile` est le fichier déclaratif décrivant comment construire une image Docker.
Il s'agit d'une suite d'instructions exécutées séquentiellement dans un environnement isolé.

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt + luma(200),
    fill: (_, row) => if row == 0 { rgb("#1e40af") } else if calc.odd(row) { rgb("#f8fafc") } else { white },
    table.header(
      text(fill: white, weight: "bold")[Instruction],
      text(fill: white, weight: "bold")[Rôle],
    ),
    [`FROM`], [Image de base (obligatoire, première instruction)],
    [`RUN`], [Exécute une commande et crée une nouvelle couche],
    [`COPY` / `ADD`], [Copie des fichiers de l'hôte dans l'image],
    [`WORKDIR`], [Définit le répertoire de travail],
    [`ENV`], [Définit une variable d'environnement],
    [`EXPOSE`], [Documente le port exposé (ne publie pas)],
    [`USER`], [Définit l'utilisateur d'exécution],
    [`CMD` / `ENTRYPOINT`], [Commande lancée au démarrage du conteneur],
    [`ARG`], [Variable de build (non disponible en runtime)],
    [`LABEL`], [Métadonnée (version, auteur, etc.)],
  ),
  caption: [Instructions Dockerfile courantes],
)

Exemple de Dockerfile pour une application Python :

```dockerfile
FROM python:3.12-slim

# Utilisateur non-root (bonne pratique de sécurité)
RUN useradd -m -u 1000 appuser

WORKDIR /app

# Les dépendances d'abord (tire profit du cache Docker)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

EXPOSE 8080
USER appuser

CMD ["python", "-m", "uvicorn", "src.main:app",
     "--host", "0.0.0.0", "--port", "8080"]
```

#keypoint()[
  *Ordre des instructions dans un Dockerfile* : placez les instructions qui changent rarement
  en premier (installation des dépendances système), et celles qui changent fréquemment en
  dernier (copie du code source). Cela maximise l'utilisation du cache de couches.
]

== Le multi-stage build

Le _multi-stage build_ est une technique permettant de séparer l'environnement de compilation
de l'environnement d'exécution dans le même Dockerfile. L'intérêt est double : réduire la
taille de l'image finale et éliminer les outils de build (compilateurs, outils de test) du
runtime de production.

```dockerfile
# Stage 1 : build (image complète avec outils)
FROM python:3.12 AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# Stage 2 : runtime (image minimale, sans les outils de build)
FROM python:3.12-slim
COPY --from=builder /install /usr/local
COPY src/ /app/src/
WORKDIR /app
USER nobody
CMD ["python", "src/main.py"]
```

L'image finale ne contient que le runtime et les dépendances compilées, sans pip, sans les
sources des packages, et sans les outils de build. La réduction de taille peut atteindre 60 %
à 80 % selon les applications.

== Commandes Docker essentielles

Les opérations quotidiennes avec Docker s'articulent autour de trois groupes de commandes :

*Gestion des images :*
```bash
docker build -t mon-app:1.0.0 .          # construire une image
docker build --no-cache -t mon-app:1.0.0 .  # sans cache
docker images                             # lister les images locales
docker pull nginx:1.25                    # télécharger une image
docker push ghcr.io/org/mon-app:1.0.0   # pousser vers un registre
docker rmi mon-app:1.0.0                 # supprimer une image
```

*Gestion des conteneurs :*
```bash
docker run -d -p 8080:8080 --name mon-app mon-app:1.0.0
docker run -it mon-app:1.0.0 bash       # mode interactif
docker ps                                # conteneurs actifs
docker ps -a                             # tous les conteneurs
docker logs -f mon-app                   # logs en temps réel
docker exec -it mon-app bash             # shell dans le conteneur
docker stop mon-app && docker rm mon-app
```

*Volumes et réseau :*
```bash
docker volume create mon-volume
docker run -v mon-volume:/data mon-app:1.0.0
docker network create mon-reseau
docker run --network mon-reseau mon-app:1.0.0
```

== Docker Compose

Docker Compose est un outil de définition et d'exécution d'applications multi-conteneurs.
Un fichier `compose.yml` (ou `docker-compose.yml`) décrit l'ensemble des services, réseaux
et volumes nécessaires à l'application.

```yaml
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
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

Commandes Compose :
```bash
docker compose up -d        # démarrer en arrière-plan
docker compose down         # arrêter et supprimer
docker compose logs -f api  # suivre les logs d'un service
docker compose ps           # état des services
```

#keypoint()[
  Docker Compose est adapté au développement local et aux déploiements simples sur un seul
  hôte. Pour des besoins de *haute disponibilité, scaling automatique et self-healing* sur
  plusieurs machines, Kubernetes @burns2022kubernetes est l'outil standard de l'industrie.
]

== Registres d'images

Les registres (_registries_) sont des serveurs stockant et distribuant les images Docker. On
distingue les registres publics et les registres privés :

#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt + luma(200),
    fill: (_, row) => if row == 0 { rgb("#1e40af") } else if calc.odd(row) { rgb("#f8fafc") } else { white },
    table.header(
      text(fill: white, weight: "bold")[Registre],
      text(fill: white, weight: "bold")[Type],
      text(fill: white, weight: "bold")[Caractéristiques],
    ),
    [Docker Hub (`docker.io`)], [Public], [Registre historique, millions d'images officielles],
    [GHCR (`ghcr.io`)], [Public/Privé], [Intégré à GitHub, gratuit pour les projets publics],
    [Quay.io], [Public/Privé], [Red Hat / IBM, focus sécurité],
    [GitLab Container Registry], [Public/Privé], [Intégré à GitLab CI/CD],
    [AWS ECR], [Privé], [Intégré à l'écosystème AWS (ECS, EKS)],
    [Google Artifact Registry], [Privé], [Intégré à GKE et Cloud Build],
    [Azure Container Registry], [Privé], [Intégré à AKS et Azure DevOps],
    [Harbor], [Auto-hébergé], [Open source, focus sécurité, scan intégré],
  ),
  caption: [Principaux registres d'images Docker],
)

// ============================================================
// 5. DOCKER & INTÉGRATION CONTINUE
// ============================================================

= Docker & Intégration Continue

== Le pipeline CI/CD avec Docker

L'intégration de Docker dans un pipeline CI/CD permet d'assurer la reproductibilité des builds
et de standardiser les environnements de test et de déploiement @pahl2015containerisation.
Le pipeline typique comprend les étapes suivantes :

```
  Code push (git)
       │
       ▼
  1. Checkout du code
  2. Restauration du cache Docker (layers)
  3. Build de l'image : docker build -t app:$SHA .
  4. Scan de sécurité  : trivy image app:$SHA
  5. Tests unitaires   : docker run app:$SHA pytest
  6. Tests d'intégration (docker compose up → tests → down)
  7. Push vers le registre : docker push ghcr.io/org/app:$SHA
  8. Déploiement (Kubernetes, ECS, Compose en prod...)
```

L'épinglage de l'image sur le SHA du commit (`app:$SHA`) garantit la *traçabilité* : chaque
déploiement peut être associé exactement au commit qui l'a produit.

== GitHub Actions + Docker

```yaml
name: Build, Scan and Push Docker image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build image
        uses: docker/build-push-action@v5
        with:
          push: false
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          load: true

      - name: Scan avec Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ghcr.io/${{ github.repository }}:${{ github.sha }}
          format: sarif
          output: trivy-results.sarif
          exit-code: '1'
          severity: 'CRITICAL,HIGH'

      - name: Push image
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
```

== Docker et les microservices

Les conteneurs sont particulièrement bien adaptés à l'architecture microservices
@burns2016borg : chaque service est packagé dans son propre conteneur, déployé et mis à jour
indépendamment. Cette indépendance permet :

- Des cycles de déploiement indépendants par service
- Un scaling horizontal sélectif (n'augmenter que le service saturé)
- Un isolement des pannes (un service défaillant n'entraîne pas les autres)
- Des technologies différentes par service (polyglottisme)

Pour des architectures microservices en production, l'orchestration par *Kubernetes* est
devenue le standard. Kubernetes gère automatiquement le déploiement, le scaling, la
haute disponibilité et la découverte de services @burns2022kubernetes.

// ============================================================
// 6. SÉCURITÉ DES CONTENEURS ET SUPPLY CHAIN
// ============================================================

= Sécurité des conteneurs et Supply Chain

== La surface d'attaque d'une image Docker

Une image Docker est un artefact composite : elle contient l'OS de base, le runtime applicatif,
les bibliothèques tierces, et le code applicatif. Chaque composant peut introduire des
vulnérabilités @shu2017study @combe2016docker.

Une étude de Shu et al. @shu2017study portant sur 356 218 images Docker Hub a révélé que
plus de 80 % des images officielles et communautaires contenaient au moins une vulnérabilité
de sévérité HIGH, avec en moyenne plus de 180 vulnérabilités par image. Ces vulnérabilités
proviennent principalement des paquets système présents dans l'image de base.

```
  FROM python:3.12-slim
         ↓
  ┌─────────────────────────────────────────┐
  │  Paquets système Debian                 │  ← CVE dans libc, openssl...
  │  Python 3.12 et bibliothèques stdlib    │  ← CVE dans Python
  │  Dépendances pip (requirements.txt)     │  ← CVE dans vos packages
  │  Code applicatif                        │  ← Bugs, secrets codés en dur
  │  Configuration (ports, variables...)    │  ← Mauvaise configuration
  └─────────────────────────────────────────┘
```

#alert(color: rgb("#dc2626"), icon: "⚠")[
  *Chaque couche est un vecteur d'attaque.* Une image basée sur `ubuntu:latest` peut contenir
  des centaines de paquets dont vous n'avez pas besoin — et autant de vulnérabilités potentielles.
]

== Bonnes pratiques de sécurité

=== Minimiser la surface d'attaque

Le principe de moindre surface impose de n'inclure dans l'image que ce qui est strictement
nécessaire à l'exécution de l'application.

#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt + luma(200),
    fill: (_, row) => if row == 0 { rgb("#1e40af") } else if calc.odd(row) { rgb("#f8fafc") } else { white },
    table.header(
      text(fill: white, weight: "bold")[Image],
      text(fill: white, weight: "bold")[Taille],
      text(fill: white, weight: "bold")[Caractéristiques],
    ),
    [`python:3.12`], [~1 Go], [Image complète avec outils de debug, déconseillée en prod],
    [`python:3.12-slim`], [~130 Mo], [OS Debian minimal, sans paquets superflus],
    [`python:3.12-alpine`], [~50 Mo], [Basée sur Alpine Linux, musl libc (compatibilité à vérifier)],
    [`gcr.io/distroless/python3`], [~50 Mo], [Sans shell, sans gestionnaire de paquets — surface minimale],
    [Image from scratch], [0 + app], [Binaire statique uniquement (Go, Rust) — surface quasi nulle],
  ),
  caption: [Images de base et surface d'attaque],
)

=== Ne pas exécuter en root

Par défaut, les processus dans un conteneur Docker s'exécutent en tant que `root` (uid 0).
Si un attaquant exploite une vulnérabilité de l'application, il obtient les droits root *à
l'intérieur* du conteneur. Dans un conteneur standard (non _rootless_), certaines capabilities
root sont préservées et peuvent permettre une évasion.

```dockerfile
# Toujours créer et utiliser un utilisateur non-root
RUN useradd -m -u 1000 -s /sbin/nologin appuser
USER appuser
```

=== Épingler les images sur leurs digests

Utiliser un tag comme `:latest` ou même `:3.12` ne garantit pas la reproductibilité. Un tag
peut être réattribué à une nouvelle image à tout moment.

```bash
# ❌ Tag non épinglé : non déterministe
FROM python:3.12-slim

# ✅ Digest SHA-256 : garantit exactement la même image
FROM python:3.12-slim@sha256:a4d3f4b9e1b2c3d4e5f6a7b8c9d0e1f2...
```

== Scanner les images avec Trivy

Trivy @trivy-aquasec est un outil open source de référence pour la détection de vulnérabilités
dans les images Docker. Il analyse les paquets système, les dépendances applicatives (pip,
npm, Maven, Cargo...), les fichiers de configuration, et les secrets.

```bash
# Scan d'une image avec rapport
trivy image python:3.12-slim
trivy image --severity HIGH,CRITICAL mon-app:1.0.0

# Scan avec rapport SARIF (intégrable dans GitHub Security)
trivy image --format sarif -o results.sarif mon-app:1.0.0

# Scan d'un Dockerfile (analyse statique)
trivy config Dockerfile

# Générer un SBOM (Software Bill of Materials)
trivy image --format cyclonedx mon-app:1.0.0 > sbom.json
```

== Software Bill of Materials (SBOM)

Le SBOM est l'inventaire exhaustif des composants logiciels contenus dans un artefact. Il
est devenu un élément central de la sécurité de la supply chain logicielle depuis l'Executive
Order 14028 (mai 2021) aux États-Unis, qui impose aux fournisseurs du gouvernement fédéral
américain de produire un SBOM @ntia-sbom-2021.

La NTIA (National Telecommunications and Information Administration) définit les *éléments
minimaux* d'un SBOM @ntia-sbom-2021 :

- Nom du fournisseur, nom du composant, version du composant
- Identifiants uniques (PURL, CPE)
- Relations de dépendance
- Auteur du SBOM et horodatage

Les deux formats principaux sont *CycloneDX* et *SPDX*. Des outils comme Syft, Trivy, ou
Grype permettent de générer et analyser ces SBOMs automatiquement.

== Signature des images avec Cosign

Cosign @sigstore-cosign est l'outil principal du projet Sigstore (Linux Foundation) pour signer
cryptographiquement les images de conteneurs. La signature permet de vérifier qu'une image
provient bien d'un éditeur de confiance et qu'elle n'a pas été altérée depuis sa publication.
Docker propose aussi un mécanisme historique, le Docker Content Trust (DCT), basé sur Notary,
pour signer et vérifier les images — Cosign/Sigstore en est l'approche moderne, standardisée au
niveau OCI.

```bash
# Générer une paire de clés
cosign generate-key-pair

# Signer une image après son push
cosign sign --key cosign.key ghcr.io/org/mon-app:1.0.0

# Vérifier la signature avant le déploiement
cosign verify --key cosign.pub ghcr.io/org/mon-app:1.0.0

# Attacher un SBOM signé à l'image
syft mon-app:1.0.0 -o cyclonedx-json > sbom.json
cosign attest --key cosign.key \
  --predicate sbom.json \
  ghcr.io/org/mon-app:1.0.0
```

Les signatures Cosign sont stockées dans le même registre OCI que l'image, ce qui rend la
vérification simple et ne nécessite pas d'infrastructure supplémentaire.

#keypoint()[
  La combinaison *Trivy (scan) + Cosign (signature) + SBOM* constitue les trois piliers
  de la sécurité de la supply chain des images de conteneurs, conformément aux recommandations
  du NIST SP 800-190 @nist-sp800-190 et du framework SLSA @slsa-framework.
]

== Framework SLSA pour les images

Le framework SLSA (_Supply-chain Levels for Software Artifacts_) @slsa-framework définit
quatre niveaux de maturité de la sécurité de la supply chain, applicables aux images Docker :

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt + luma(200),
    fill: (_, row) => if row == 0 { rgb("#1e40af") } else if calc.odd(row) { rgb("#f8fafc") } else { white },
    table.header(
      text(fill: white, weight: "bold")[Niveau SLSA],
      text(fill: white, weight: "bold")[Exigences],
    ),
    [*SLSA 1*], [Build automatisé, provenance générée],
    [*SLSA 2*], [Service de build hébergé, provenance signée],
    [*SLSA 3*], [Service de build durci, sources et builds vérifiables],
    [*SLSA 4*], [Build reproductible, revues deux personnes, build hermétique],
  ),
  caption: [Niveaux SLSA appliqués aux images de conteneurs],
)

// ============================================================
// 7. CONCLUSION
// ============================================================

= Conclusion

Les conteneurs logiciels représentent une évolution majeure dans la façon de packager, distribuer
et exécuter les applications. En standardisant l'environnement d'exécution autour d'un format
portable (OCI), ils ont résolu le problème de reproducibilité qui ralentissait les équipes de
développement depuis des décennies.

Cependant, l'adoption des conteneurs introduit de nouvelles responsabilités :

+ *Les conteneurs ne sont pas des sandboxes.* Ils partagent le noyau Linux de l'hôte et ne
  remplacent pas une isolation par VM lorsqu'une forte séparation est requise.

+ *Chaque image est une supply chain.* Une image Docker contient des centaines de composants
  logiciels tiers, chacun susceptible de contenir des vulnérabilités. Scanner ses images
  (Trivy), les signer (Cosign) et générer leur SBOM sont des pratiques essentielles.

+ *La sécurité doit être intégrée dans le pipeline CI/CD.* Un scan de vulnérabilités en
  fin de pipeline est trop tardif. Il convient d'appliquer les principes de _shift left_ :
  Dockerfile lint, scan lors du build, gate sur les sévérités CRITICAL/HIGH.

+ *Kubernetes est l'étape suivante.* Docker Compose suffit pour le développement et les
  déploiements simples, mais les architectures microservices en production nécessitent
  l'orchestration, le scaling automatique et la haute disponibilité que Kubernetes offre.

#keypoint()[
  *Scanner ses images, c'est auditer sa supply chain binaire.*
  Un conteneur n'est pas une boîte noire magique : c'est un ensemble d'artefacts (OS, runtime,
  bibliothèques, code) dont chacun peut contenir des vulnérabilités exploitables.
  La sécurité des conteneurs est une pratique continue, pas une vérification ponctuelle.
]

// ============================================================
// BIBLIOGRAPHIE
// ============================================================

#pagebreak()

#bibliography("refs.bib", title: "Références", style: "ieee")
