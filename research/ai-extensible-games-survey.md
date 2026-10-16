# Survey: AI-Extensible Games (single-player games where players freely extend and reshape content and rules via AI)

- **Survey date**: 2026-10-16
- **Method**: based on public web sources (official sites, Steam store pages, GitHub repos, arXiv papers, developer blogs, media coverage), verifying each product's status as of October 2026 through search engines and web scraping. Every key claim carries a source link; details not fully verifiable from primary sources are marked "my analysis."
- **Target reader**: an indie developer (strong in TypeScript / Web) planning an "AI-extensible single-player game."
- **Language note**: translated to English per project policy (2026-10-17); the original Chinese version lives in git history (commit 62f101e).

---

## A. Comparable products

### Classification framework

By the role AI plays in the game, comparable products fall into five categories:

1. **AI-generated content**: AI generates NPC lines, items, images, etc. at runtime, but the rules themselves are fixed.
2. **AI-generated rules or code**: the player describes gameplay in natural language; the AI generates executable logic/mods.
3. **AI as GM / world simulation**: the AI acts as game master, dynamically interpreting player intent and evolving world state.
4. **World models (generative engines)**: a neural network generates the game's frames themselves; no traditional game engine.
5. **UGC platforms with built-in AI tools**: the platform ships generative AI tooling for its creators.

> Reference: the July 2026 academic survey "AI Native Games: A Survey and Roadmap" (arXiv:2607.00527) defines AI-native games with a counterfactual criterion — if you removed the runtime generative AI, would the core gameplay collapse? The survey analyzes 53 publicly playable AI-native games/prototypes; corpus at https://github.com/igloomatics/Awesome-AI-native-games-collection . Its central claim: the core problem of AI-native design is **"organizing semantic openness into stable gameplay"** — which is exactly this project's core design problem. GDC 2026 retrospectives (Hilary Mason et al.) likewise report that launched AI-native games have "started en masse, with some brutal failures" (https://medium.com/@hmason/the-state-of-ai-native-games-lessons-from-the-frontier-2d0bf47dc7cd , fact).

---

### A1. AI-generated content

#### 1. Infinite Craft (Neal Agarwal) — LLM element crafting

- **In one line**: starting from "Water" and "Fire", drag any two elements together to craft a new one; an LLM judges the result on the fly, with near-unlimited combinations.
- **Where AI sits**: a single judgment point — "two elements → one new element name + emoji". The LLM never touches the rules layer (the crafting action, UI, and sidebar are all traditional code).
- **Platform/form**: pure web, browser toy (https://neal.fun/infinite-craft/ ).
- **Known stack**: released late January 2024; the community confirmed via packet capture that the backend calls a Llama model (served via Together AI), and first-craft results are cached — later players crafting the same pair read the cache (fact; sources: the neal.fun site itself, and arXiv:2607.00527 which lists it as entry [29]).
- **Status**: alive, free, no IAP (still reachable as of 2026-10).
- **Takeaway**: **"LLM judgment + aggressive caching" is the highest-leverage shape of AI gameplay** — the same input forever reuses its output, so marginal cost trends to zero; and compressing the AI's output surface to "one noun" structurally avoids hallucination and rule breakage. For a single-player game, "AI answers only open semantic questions, everything else is deterministic" is lesson number one.

#### 2. AI Roguelite (Max Loh) — AI-generated content drives a roguelike

- **In one line**: a Steam AI-driven roguelike where entity (item/enemy/skill) names, icons, stats, and combat outcomes are all LLM-generated; players can tune generation parameters and even world-view rules.
- **Where AI sits**: content layer plus some "semantic adjudication" (the AI judges whether an attack description holds); an "entity generation" system lets players create AI-generated items and skills.
- **Platform/form**: Steam (PC), 2D text+image hybrid.
- **Known stack**: the developer blog documents prompt templates + structured output mapping LLM results onto game stats (source: Steam store page https://store.steampowered.com/app/1889620/AI_Roguelite/ , fact).
- **Status**: alive, paid (~$10 tier), updated for years, "Very Positive" count is substantial but reviews are polarized (AI generation quality is unstable). arXiv:2607.00527 cites it as a case in "inference economics and business models" [70].
- **Takeaway**: proves **one indie developer can ship and keep operating an AI-native premium (buy-to-play) game**; also proves that pure "AI generates everything" tends to hollow out gameplay — its praise concentrates on the joy of creation, its criticism on shallow combat.

#### 3. Whispers from the Star (Anuttacon) — big-studio AI dialogue narrative

- **In one line**: talk (voice or text) in real time with an AI astronaut stranded on an alien world; every sentence you say is her only lifeline. Made by a studio founded by ex-miHoYo staff.
- **Where AI sits**: NPCs fully LLM-driven — free dialogue + real-time voice + AI-judged story branches.
- **Platform/form**: Steam (PC/iOS), 3D presentation + dialogue.
- **Known stack**: officially disclosed only as "in-house AI model + real-time voice" (https://wfts.anuttacon.com/faq/ ).
- **Status**: announced and playtested March 2025 (https://game8.co/articles/latest/whispers-from-the-star-an-ai-driven-sci-fi-g), entered Early Access within 2025 (Steam app 3730100); currently alive (fact).
- **Takeaway**: shows that **"free dialogue must be bound to a clear survival goal" to be a game rather than a chatbot** — open semantic input inside a converging ludic structure (the Steam page's goals, resources, time pressure).

#### 4. China region supplement: "History Simulator: Chongzhen" (历史模拟器:崇祯), "Maggie's Garden" (麦琪的花园), Dev_Nulls_Tower, etc.

- **Facts**: AI-native/AI-NPC games from Chinese teams clearly increased through 2025-2026. arXiv:2607.00527 includes "History Simulator: Chongzhen" (Steam app 4304230, 2026; the player role-plays Emperor Chongzhen freely via text/dialogue while an LLM simulates the court) and "Dev_Nulls_Tower" (Steam app 4350940, 2026; tower-climbing fused with AI generation) [37][41]; a Zhihu survey piece mentions "Maggie's Garden" (AI-NPC open sandbox) and other Chinese projects (https://zhuanlan.zhihu.com/p/1964006892968846020 ; GCORES https://www.gcores.com/articles/218280 ).
- **Takeaway**: Chinese-language AI-native premium games have established themselves on Steam, validating "Chinese-language prompt engineering + buy-to-play"; Steam's AI disclosure policy (since 2024, source: https://store.steampowered.com/news/group/4145017/view/3862463747997849618 ) forces all such games to carry labels — budget for that compliance work at kickoff.

---

### A2. AI-generated rules or code (most relevant to our task)

#### 5. Voyager (LLM agent in Minecraft, NVIDIA/Caltech et al.) — writes code, banks a skill library

- **In one line**: GPT-4 plugged into Minecraft; the agent plans in natural language for each new task, writes JavaScript against the Mineflayer API, auto-iterates on failure from environment feedback, and banks successful code into a "skill library" for long-term reuse.
- **Where AI sits**: the pure "AI writes code to extend capability" paradigm — the skill library is a searchable, composable, reusable programmatic asset.
- **Platform/form**: research prototype, Minecraft (Java).
- **Known stack**: GPT-4 + Mineflayer (JavaScript/Minecraft API) + a vector store for skill retrieval; paper arXiv:2305.16291 (https://arxiv.org/abs/2305.16291 ), official implementation https://github.com/MineDojo/Voyager (GPT-4 API calls, fact).
- **Status**: research project, unmaintained, but widely reproduced (including Mindcraft below).
- **Takeaway**: **this is the most successful technical blueprint for "players extend the game with AI"** — the AI doesn't "generate a game"; it writes small pieces of code against a stable API surface, self-corrects failures, and deposits successes as permanent capability. The "skill library = player-created mod" pattern transfers directly to a consumer product.

#### 6. Mindcraft (open source) — Voyager's community continuation

- **In one line**: an open-source Minecraft LLM-bot project: Node.js + Mineflayer + LLM lets AI characters take natural-language commands and act autonomously.
- **Where AI sits**: the LLM translates player natural language into Mineflayer code/action sequences; supports multiple bots and BYOK (bring your own key).
- **Platform/form**: open-source project (not a game), GitHub https://github.com/kolbytn/mindcraft (active; still shipping releases in 2025; later migrated to the mindcraft-bots/mindcraft org, fact).
- **Known stack**: JavaScript/Node.js, Mineflayer; connects to OpenAI/local Ollama etc.; built on Voyager's approach with improvements (repo README, fact).
- **Status**: active open source, permissive license, large community.
- **Takeaway**: **a real-world sample of BYOK + open modding**: players paste their own LLM API key and it runs in a local Node.js process; its way of constraining "the LLM can only drive the game through a predefined action API" deserves line-by-line study. Also evidence that a TypeScript/Node stack is fully sufficient for this kind of project.

#### 7. OneSpellFitsAll / "LLM writes mods" practice

- **Facts**: researchers have prototyped "LLM generates in-game spell/logic code" as gameplay, e.g. OneSpellFitsAll (players write spells in natural language, the LLM generates code; source: https://github.com/YenR/OneSpellFitsAll , cited by arXiv:2607.00527 as a mechanics-layer innovation [61]).
- **Takeaway**: proves "players write prompt-authored code that genuinely changes gameplay" was already feasible in 2023-2024; what's missing is wrapping it into a good commercial game — that's the open market gap.

---

### A3. AI as GM / world simulation

#### 8. AI Dungeon (Latitude) — the genre founder

- **In one line**: infinitely free text adventure; the player types anything and the AI continues the story — the founding "AI as GM" product (2019).
- **Where AI sits**: GM layer — interprets arbitrary player input and decides how the world responds; recently added image generation, world/plot cards, multi-agent scenes.
- **Platform/form**: Web / iOS / Android / Steam, pure text + illustrations.
- **Known stack**: started on GPT-2/GPT-3, later in-house "Dragon" models; now mainly third-party large models + own fine-tunes (sources: https://play.aidungeon.com/pricing and the official Forge update notes https://aidungeon.com/forge , fact).
- **Status**: alive, free + subscription ($14.99–$99.99/month, source: official pricing page); a "Forge" milestone landed in 2026 (expanded model access and image models). Note: arXiv:2607.00527 strictly classifies AI Dungeon as an "AI-bound artifact" (AI is core but gameplay structure is missing) [28] — total freedom, no winning/losing, no state convergence.
- **Takeaway**: (1) subscription pricing covering inference cost is the only business model that has worked for this category; (2) the lesson of its long life is **"total freedom = no game"** — long-term retention needs goals added to freedom; (3) its "Memory" and "World Info" (world-view entry injection) mechanisms are the earliest practical RAG-in-game schemes.

#### 9. Hidden Door — AI narrative world + fan-IP partnerships

- **In one line**: turns fan-fiction worlds (e.g. Oz, Alice) into AI-driven role-play stages; players improvise adventures with friends in AI-hosted "plays", producing illustrations and story records.
- **Where AI sits**: GM layer (LLM-hosted narrative) + content layer (generated illustrations, character cards); strong multiplayer and collect/share loops.
- **Platform/form**: web, text + illustration.
- **Known stack**: in-house narrative engine + generative models; licensing partnerships with IP holders (public-domain works first) (source: Variety, Aug 2025 https://variety.com/2025/gaming/news/hidden-door-ai-role-playing-fan-fiction-game-platform-launches-1236494356/ , fact).
- **Status**: formally launched August 2025 (after years of R&D/beta); alive; free + subscription. Led by Hilary Mason (data science/security background).
- **Takeaway**: (1) proves "AI GM + visual wrapper + social sharing" is the combo that popularizes text adventures; (2) it and the GDC 2026 retrospective (same team) both stress: **AI-native games die of "unrestrained generation" and "runaway inference cost"**.

#### 10. Suck Up! (Proxima) — persuading AI characters, door to door

- **In one line**: you play a vampire talking your way into houses; persuade the AI-played humans (voice or text) to let you in. Persuasion strategy is fully free.
- **Where AI sits**: every NPC is an LLM-driven persuadable character with personality/secrets/weaknesses; the AI decides admission based on conversation quality.
- **Platform/form**: Steam (PC), 3D presentation + dialogue.
- **Known stack**: cloud LLM + speech synthesis (source: Steam page https://store.steampowered.com/app/2726370/Suck_Up/ and Oct 2025 coverage https://www.hypergridbusiness.com/2025/10/indie-vampire-game-highlights-future-for-ai-driven-games/ , fact).
- **Status**: went viral via TikTok clips in 2024; Steam release 2025, reviews slid to "Mixed" (~60%); third-party revenue estimate ~$74.7K (https://gamerevenuedata.com/games/suck-up/ , estimate, not fact); still operating.
- **Takeaway**: (1) virality came from watchability — "watch a streamer persuade an AI" is content in itself; (2) negative reviews concentrate on **shallow gameplay after the novelty burns off** and ongoing inference cost — a warning that "AI conversation" cannot be the whole game; (3) a small team reached tens of millions of views, so the category is indie-friendly.

#### 11. 1001 Nights (Ada Eden) — player speech changes the world

- **In one line**: you play Scheherazade; what you tell the king (keywords, emotions, props) is decomposed by AI into real in-world weapons/resources. Tell stories well enough to arm yourself, kill the king, and escape.
- **Where AI sits**: a bridge between content and mechanics — the LLM converts narrative (unstructured) into game state (structured: weapon stats, hostility), which the arXiv paper calls "player-driven narrative emergence".
- **Platform/form**: Steam/itch.io (Windows/macOS), 2D hand-drawn + text (https://www.1001nights.ai/ , https://ada-eden.itch.io/1001-nights-official , Steam app 2542850 "Book of Infinity: 1001 Nights").
- **Known stack**: the paper "Player-driven emergence in LLM-driven game narrative" (arXiv:2404.17027, https://arxiv.org/abs/2404.17027 ) documents the "narrative → mechanical state" pipeline.
- **Status**: alive; demo 2024; a full release/sequel "Book of Infinity" in development (2026).
- **Takeaway**: **the "free narrative → structured game state" translation pipeline is the heart of an AI-extensible game**. It proves that even with fixed rules (combat, stats), as long as the AI converts the player's open input into objects the rules can consume, players feel "my words really changed the world".

#### 12. Stanford Generative Agents / Smallville — a town of 25 AI residents

- **In one line**: the Stanford research simulation: 25 LLM agents with personas and memories socialize autonomously and exhibit emergent group behavior (e.g. organizing a party).
- **Where AI sits**: multi-agent world simulation — every agent's observation, reflection, planning, and dialogue are LLM-generated.
- **Platform/form**: research prototype, 2D top-down pixel town; code open-sourced at https://github.com/joonspk-research/generative_agents .
- **Known stack**: paper arXiv:2304.03442 (https://arxiv.org/abs/2304.03442 ): **memory stream (retrieval weighted by recency × importance × relevance) + reflection (periodic self-summarization) + planning**. This memory architecture is still the standard template for AI-game memory systems (later engineered in MemGPT, arXiv:2310.08560).
- **Status**: research project (2023), MIT-licensed code, many descendants (e.g. AI Town).
- **Takeaway**: the memory stream's three-factor retrieval is directly implementable; it also exposed the cost problem — the original paper reports thousands of dollars to simulate one town offline (disclosed in the paper, fact), **so a single-player game must cache aggressively and call sparingly**.

#### 13. AI Town (Convex / a16z) — a self-hostable AI town

- **In one line**: an engineered open-source remake of Smallville; an MIT-licensed "AI town" starter kit — deploy in one click, customize characters, maps, and backstories.
- **Where AI sits**: agent dialogue and movement decisions.
- **Platform/form**: web (2D pixel), open source https://github.com/a16z-infra/ai-town .
- **Known stack**: **TypeScript + Convex (data/backend) + React + PixiJS**, LLMs via API; the repo's ARCHITECTURE.md details the agent loop and data flow (fact).
- **Status**: open-source project, still maintained with a fork ecosystem; best treated as reference engineering, not a product.
- **Takeaway**: **the reference codebase closest to our stack (TS/web)** — its agent state machine (Convex transaction tables), dialogue memory storage, and character-card structure can be absorbed into a prototype at low cost.

---

### A4. World models (generative engines)

#### 14. Oasis (Decart) — real-time generated "engine-less Minecraft"

- **In one line**: a video-generation model "hallucinates" a Minecraft-like world frame by frame; the player drives with keyboard/mouse and the AI generates each frame in response — no traditional game engine involved.
- **Where AI sits**: the entire game screen is model output (next-frame prediction).
- **Platform/form**: web demo + downloadable; model weights and inference code open-sourced (https://oasis-model.github.io/ , fact).
- **Known stack**: released 2024-10; an autoregressive video model (ViT/VQM family), initially 360p/20FPS; later a C version runnable locally and open weights, in partnership with Etched (TechCrunch: https://techcrunch.com/2024/10/31/decarts-ai-simulates-a-real-time-playable-version-of-minecraft/ , fact).
- **Status**: alive as a tech demo; Decart has moved on to broader world-model/realtime-video business; not a commercial game.
- **Takeaway**: for the next 3-5 years **independent developers should not bet on "world models replace engines"** — compute, VRAM, and consistency (its famous "objects drift when you turn your head" problem) are all immature; but the direction is worth tracking.

#### 15. DeepMind Genie series (Genie 2 / Genie 3) — generative interactive world models

- **In one line**: from a text prompt, Genie 3 (announced 2025-08) generates a real-time explorable interactive 3D environment with action control and environmental persistence (leave and return; the scene stays consistent).
- **Where AI sits**: the whole world is model output.
- **Platform/form**: research preview, not publicly available.
- **Known stack**: official blog https://deepmind.google/blog/genie-3-a-new-frontier-for-world-models/ : 720p, 24FPS, minutes-long continuous interaction; navigable environments with specifiable events (weather/NPCs); aimed mainly at agent training and education (as of a 2026-07 blog update, still a limited API preview, fact).
- **Status**: not productized; academia and media agree consumer gaming is far off (TechCrunch 2025-08: https://techcrunch.com/2025/08/05/deepmind-thinks-genie-3-world-model-present-a-stepping-stone-toward-agi/ ).
- **Takeaway**: same as Oasis — **watch, don't bet**; the "world model" era reaches indies only when model APIs get cheap and low-latency.

---

### A5. UGC platforms with built-in AI tools

#### 16. Roblox: Studio AI assistant + open-sourced Cube 3D model

- **In one line**: Roblox embeds a generative AI assistant in Studio (scripting, materials, scene building), and in March 2025 open-sourced its 3D generation foundation model Cube 3D (text → mesh).
- **Where AI sits**: the creation-tool layer (development-time AI, not runtime AI).
- **Platform/form**: the Roblox platform (3D UGC).
- **Known stack**: official announcement https://about.roblox.com/newsroom/2025/03/introducing-roblox-cube , open repo https://github.com/Roblox/cube (text-to-3D object, mesh tokenization; fact).
- **Status**: continuously evolving; expanding toward 4D (animation) and scene-level generation through 2025-2026.
- **Takeaway**: (1) platform-grade AI tools prove **"generative AI's best use is dropping creation cost to zero"**; (2) Cube being open-source means our game could use it directly as a "player text → 3D asset" local/offline pipeline (my analysis: current model quality is still toy-grade for art-demanding products).

#### 17. AI experiments in the Minecraft ecosystem (background)

- **Facts**: Minecraft itself has no official runtime LLM features, but the ecosystem's AI experiments are dense: Voyager, Mindcraft (see A2), and Microsoft-research agent surveys all use Minecraft as the standard testbed; the official Education Edition and Marketplace carry AI-adjacent content, but as assistive tooling. Minecraft became the first scene for AI-game experiments because it offers **a stable API surface (Mineflayer/Mod API) + an open world + clear goal structure** — that combination itself is worth copying.
- **Takeaway**: the precondition for letting players (or AI) extend freely is **a small, stable API surface**; half of the Minecraft ecosystem's success comes from its restrained mod API design.

#### 18. Websim — prompt-as-webpage (quasi-game generation platform)

- **In one line**: type a sentence (or paste a link) and get an interactive webpage instantly (many users generate mini-games), with "remix" to build on others' work.
- **Where AI sits**: the whole "game/webpage" is LLM-written code — essentially "LLM writes frontend code as a game".
- **Platform/form**: web (https://websim.com ), viral since 2024; by 2025 it had grown a community, creator economy, and paid subscriptions (source: third-party reviews e.g. aixploria 2025-11 https://www.aixploria.com/en/websim-ai-create-game-website/ , fact).
- **Known stack**: frontend code (HTML/CSS/JS, incl. browser 3D via Three.js) LLM-generated; platform hosts + sandboxes execution (my analysis: likely iframe/origin isolation; Websim hasn't published its security architecture).
- **Takeaway**: proves the loop "**player describes → LLM writes code → instantly playable**" is genuinely loved, and a remix ecosystem makes UGC self-propagate; this is the living sample of an "AI mod platform" — missing only a "gameplay framework".

### Cross-cutting summary (fact, synthesized from the sources above)

| Product | AI layer | Form | Business model | Primary source |
|---|---|---|---|---|
| AI Dungeon | GM layer | text | sub $15-100/mo | play.aidungeon.com/pricing |
| Infinite Craft | semantic judgment | web 2D | free + cache | neal.fun/infinite-craft |
| Hidden Door | GM + content | web text+art | free + sub | hiddendoor.co |
| Suck Up! | AI NPC | 3D + dialogue | premium | Steam 2726370 |
| 1001 Nights | narrative → state | 2D text | premium/demo | arXiv:2404.17027 |
| Voyager / Mindcraft | AI writes code | Minecraft mod | open source/BYOK | arXiv:2305.16291, kolbytn/mindcraft |
| Generative Agents / AI Town | multi-agent sim | 2D pixel | open source | arXiv:2304.03442, a16z-infra/ai-town |
| Websim | AI writes code (whole site) | web | free + sub | websim.com |
| Oasis / Genie 3 | world model | engine-less | research preview | oasis-model.github.io, DeepMind blog |
| Roblox Cube | creation tooling | 3D UGC platform | free + open model | about.roblox.com/newsroom |

---

## B. Technical approaches and architecture patterns

### B1. The three LLM integration layers and how to bind them

**Layer choice** (following the N-axis taxonomy of arXiv:2607.00527 and the products above):

- **Content layer** (NPC lines/items/plot): lowest risk — Suck Up!, AI Roguelite live here; the LLM output passes through a narrow interface (one line, one item definition).
- **Rules layer** (the player describes gameplay; the AI generates logic): OneSpellFitsAll, Voyager's skill library, Websim live here; requires "AI code + sandboxed execution" (see B2).
- **GM layer** (dynamic world adjudication): AI Dungeon, Hidden Door, Generative Agents live here; requires memory systems and state-convergence design.
- **Recommended combination**: content layer guarantees baseline usability, rules layer creates the "extension feel", GM layer only adjudicates/translates and never carries the narrative (details in C).

**Binding structured output to game state**:

- The mainstream approach is JSON-Schema-constrained decoding / function calling: Vercel AI SDK's `generateObject`/`generateText` + Zod schemas (https://sdk.vercel.ai/docs , the de-facto standard in the TS ecosystem); on the model side, grammar-constrained decoding has an academic basis (arXiv:2305.13971, https://arxiv.org/abs/2305.13971 ) and open-source implementations like Outlines (https://github.com/dottxt-ai/outlines ). 1001 Nights' "narrative → weapon stats" pipeline is essentially schema-shaped output (arXiv:2404.17027).
- Event-driven architecture: every AI output is normalized into an "event object" (e.g. `{type:"spawn", entity:"...", props:{...}}`) that the deterministic engine consumes and executes — the LLM never mutates game state directly; it can only emit events. This is the shared pattern across the mature cases (my analysis by synthesis; Voyager/Mindcraft/AI Town code all look this way).

**RAG and memory**: Generative Agents' memory stream (recency × importance × relevance, arXiv:2304.03442) remains the standard; engineering-level layering is documented in MemGPT (working memory/archival memory, arXiv:2310.08560). Single-player can use embedded local vector stores (lancedb / sqlite-vec / hnswlib all support embedded deployment).

**Cost, latency, caching**:

- Infinite Craft's total caching (combination → result, cached forever) is the most extreme and most effective strategy (fact).
- Tiered calls: cheap models for high-frequency judgments, expensive models for low-frequency "big moment" generation — AI Dungeon's subscription tiers are designed around model tiers (fact).
- Batching and reduced frequency: Generative Agents triggers reflection/planning periodically, not every turn (disclosed in the paper).
- **Single-player BYOK vs local inference**:
  - BYOK (players bring their own key): Mindcraft's practice (players paste a key; the game calls OpenAI/compatible endpoints directly). Pros: zero inference cost for us, compliance is simple; cons: onboarding friction (players must obtain a key), poor experience for non-paying players, key safety (stored in local config, never uploaded). Chrome's built-in `window.ai` / Gemini Nano and WebLLM (https://github.com/mlc-ai/web-llm , pure-browser WebGPU inference), plus llama.cpp (desktop), make "zero-config local small models" viable in 2025-2026: 3-8B models on consumer GPUs can handle "semantic judgment"-grade tasks but not long-form narrative generation (my analysis, based on public WebLLM benchmarks).
  - **Workable combination**: local small model by default (for judgments and cache misses) + optional player key (or purchasable credits) unlocking high-quality generation (speculative recommendation; no shipping product demonstrates the full combination, but every component is mature).

### B2. Safe execution of AI-generated code

- **The Voyager skill-library pattern** (arXiv:2305.16291): the AI may only call exposed APIs (e.g. `bot.collectBlocks(...)`) and write small pieces of JS; execution failure → error back to the model → self-correction; successes are banked, vectorized, and retrieved for future tasks. **The triad "narrow API + self-correction + skill library" is directly liftable.**
- **Sandbox options compared** (all are factual technologies; applicability is my analysis):
  - **QuickJS** (https://bellard.org/quickjs/ , plus Rust bindings and WASM builds): interprets JS with no network/filesystem access by default; host functions can be injected as a whitelist; fast startup, small footprint — a good fit for running AI-generated scripts inside a game. In web games, a Web Worker + strict structured-clone isolation also works.
  - **isolated-vm** (https://github.com/laverdet/isolated-vm ): a V8-isolate wrapper for Node.js; real heap isolation, good performance — suited to desktop (Tauri/Electron) single-player games running player/AI mods.
  - **WASM** (wasmtime etc.): strongest isolation, worst developer experience — fits performance-sensitive or multi-language mod futures.
  - **Capability-based security**: the core principle is "code can only touch explicitly granted capability objects" — model the game API as fine-grained objects (`ctx.spawn`, `ctx.gold.add`); AI code never sees the global world. Voyager/Mindcraft's API injection is a naive capability pattern (my analysis).
- **Restrict the API surface**: the lesson from platform security — Websim runs generated code in a separate origin/iframe (my analysis); AI Dungeon-type services simply disallow user code. For a single-player game, capability security + no default network/IO is the baseline (my analysis).

### B3. Engines and frameworks

- **Web stack (best fit for our skills)**:
  - AI Town proves TypeScript + Convex + PixiJS can run an agent world (https://github.com/a16z-infra/ai-town/blob/main/ARCHITECTURE.md , fact).
  - Three.js/Phaser + Vercel AI SDK (structured output, streaming, multi-provider switching, https://sdk.vercel.ai/docs ) is the fastest on-ramp; WebLLM provides in-browser inference (https://github.com/mlc-ai/web-llm , fact).
  - Pros: zero-friction distribution (Websim's growth advantage), and AI-written JS runs directly in a sandbox (a natural fit for the rules layer). Cons: 3D large worlds and asset pipelines trail native engines (my analysis).
- **Godot**: open source, small binaries, third-party LLM plugins exist (several community projects visible on GitHub); GDScript is less AI-codegen-friendly (rare in training data, weak sandbox ecosystem), but QuickJS/wasmtime can be attached via GDExtension as a script sandbox (my analysis; no mature precedent).
- **Unity**: biggest ecosystem, LLM-NPC middleware partnerships (e.g. Inworld, public news); licensing offers no specific advantage for indie single-player AI games, and running AI-generated code on the C# runtime requires embedding a script engine (my analysis).
- **Existing "LLM writes mods" practice**: Voyager (dedicated API), Mindcraft (same), OneSpellFitsAll (spell generation), Websim (whole-site generation); **there is still no mature commercial "general game + player AI-mod marketplace"** — that's both the opening and the risk (no shippable security blueprint to copy).

### B4. Sharing AI mods: ecosystem and safety

- **Sharing format** recommended as a "declarative pack": prompt templates + schema definitions + event handlers (code bounded by the API surface) + optional generated assets; naturally auditable, diffable, versionable (my analysis; a JSON-ified variant of Voyager's skill library).
- **Safety considerations** (all with public grounding):
  - **Prompt injection**: text embedded in shared mods can induce the LLM to exceed its role (classic paper arXiv:2211.09527; indirect injection arXiv:2302.12173). Mitigations: keep mod content and system prompts separate; schema-validate and whitelist generated events; put deterministic bounds on "AI adjudications". Academic gamified-injection research (e.g. Hacc-man, DOI:10.1145/3656156.3665432) shows players will treat "jailbreaking the AI" as gameplay — both a risk and a design opportunity.
  - **Malicious generated code**: sandbox (B2) + least privilege + no network is the floor; shared mods should never be granted network or filesystem capabilities by default.
  - **Content moderation**: Steam requires disclosure of AI-generated content (https://store.steampowered.com/news/group/4145017/view/3862463747997849618 , fact); LLM-side filtering via Llama Guard-class models (arXiv:2312.06674); shared mods need reporting/review channels and local content flags (my analysis).
  - **Copyright / model drift**: model API changes make mod behavior drift (arXiv:2307.09009 documents behavioral drift over time); shared mods should record the model and parameter assumptions they were authored against.

---

## C. Design implications (our project recommendations)

Each item is grounded in the survey above; my own inferences are marked.

**1. Put AI in the "rules-translation layer" and the "content layer"; the GM layer only adjudicates and never carries the narrative.**
Pure GM-layer products (AI Dungeon) get classified as "not a game" under the strict definition, and their business model depends on subscriptions to subsidize inference; the successful gameplay cases (Infinite Craft, 1001 Nights, Suck Up!) all compress AI output into **structured game objects** (an element name, a weapon's stats, an admission verdict) consumed by deterministic rules. Recommendation: keep game rules (stats, combat, economy) fully deterministic; the AI translates the player's natural language/prompt into objects and events those rules can consume. This also solves "hallucination corrupts game state" — however wild the AI's prose, what lands in the state machine are legal events.

**2. Ship web (TS) 2D first; 3D is phase two.**
Reasons: (1) zero-friction distribution is the precondition of Websim-style "open and play" virality (fact); (2) rules-layer extension needs "AI writes code + sandboxed execution" — the JS/TS ecosystem has the most mature sandboxes (QuickJS/isolated-vm/Worker), and AI models generate JS far better than GDScript/C# (my analysis); (3) AI Town proves TS + PixiJS can carry an agent world; (4) 3D asset generation (Roblox Cube) is open-sourced but still art-pipeline-heavy for an indie team (my analysis). A 2D/text-first form also cuts AI image cost and latency substantially.

**3. The perceivable form of "AI extension" should be: players write prompts → generate durably reusable skill/item/rule packs (the skill-library pattern), not "AI continues the story on the fly".**
Voyager's skill library proves the growth feel and sharing value of "AI-written code becomes permanent capability" far exceeds one-shot text generation; 1001 Nights proves "player speech becomes world entities" is the strongest agency experience. Recommendation: let players create "things that persist in the save" with natural language (skills, items, NPCs, room rules) — and have them drive playable, shareable, remixable gameplay objects rather than dialogue. Sharing = a declarative mod pack (prompt + schema + sandboxed code), see B4.

**4. The first prototype validates exactly one thing: whether player-created rules/entities plus a fixed core loop are actually fun.**
arXiv:2607.00527 emphasizes repeatedly that the common failure mode across 53 AI-native games is "generation without play" ("organizing semantic openness into stable gameplay" is the unsolved core problem); Suck Up!'s post-launch review slide confirms novelty ≠ retention. Suggested prototype: one tiny deterministic core (a room, a battle) + 3-5 categories of AI-generated extensions; test whether after 30 minutes players still reach for AI extension and whether generated objects combine into strategy. **Do not build narrative, image generation, or multiplayer during the prototype phase.**

**5. Single-player inference strategy: cheap by default, better optionally, cache everything.**
Factual basis: Infinite Craft is free via total caching; AI Dungeon shifts cost to heavy users via subscription tiers; Generative Agents' original design cost is unacceptable in a single-player product. Recommendation: persist every AI result keyed by (input hash, model tier); a local small model (bundled llama.cpp or WebLLM, 3-8B) handles default judgments; players optionally paste an API key (or buy credits) to unlock high-quality generation; BYOK modeled on Mindcraft (key stays local). This is what makes a premium single-player game financially viable (my analysis, extrapolated from the cost structures above).

**6. Treat safety and compliance as part of the gameplay boundary, not an afterthought.**
Reasons: Steam's AI disclosure is mandatory (fact); if shared mods carry malicious code or rule-breaking content, a single-player developer still bears the reputational and platform risk; and "restricted API surface + capability security", made transparent (players can see what a mod may touch), can become a selling point — "visible rule boundaries" matches arXiv:2607.00527's core conclusion: the design value of AI-native games lies precisely in **building trustworthy constraints around unlimited generation**.

---

## D. Product decision update (2026-10-17)

AI access will be dual-path, amending the BYOK framing of recommendation 5:

1. **Official AI entry (default)**: the game ships with a hosted, official API entry. Inference costs are absorbed by the cache-first design — every generated result is persisted into the theme pack, so identical requests never re-bill (the Infinite Craft pattern, see A1).
2. **Own-agent path (advanced players/creators)**: the theme pack is engine-validated pure JSON, so creators can author mods with their own AI agents or tools and import them without touching our service. Export doubles as the mod-format spec by example; import validation rejects malformed packs safely.

Rationale: removes the "apply for an API key" onboarding wall for the majority of players while keeping an open, agent-friendly mod format for the creator ecosystem. Implemented and asserted in the prototype (`validatePack` + `importPack` round-trip; see branch `prototype/theme-mod-loop`).

---

## Appendix: key sources

- arXiv:2607.00527 "AI Native Games: A Survey and Roadmap" (2026) https://arxiv.org/html/2607.00527v1 ; game corpus https://github.com/igloomatics/Awesome-AI-native-games-collection
- arXiv:2304.03442 Generative Agents; arXiv:2305.16291 Voyager; arXiv:2404.17027 1001 Nights; arXiv:2310.08560 MemGPT; arXiv:2305.13971 grammar-constrained decoding; arXiv:2312.06674 Llama Guard; arXiv:2302.12173 indirect prompt injection
- AI Dungeon: https://play.aidungeon.com/pricing , https://aidungeon.com/forge
- Infinite Craft: https://neal.fun/infinite-craft/ ; Hidden Door: https://www.hiddendoor.co/ and https://variety.com/2025/gaming/news/hidden-door-ai-role-playing-fan-fiction-game-platform-launches-1236494356/
- Suck Up!: https://store.steampowered.com/app/2726370/Suck_Up/ ; 1001 Nights: https://www.1001nights.ai/
- Mindcraft: https://github.com/kolbytn/mindcraft ; AI Town: https://github.com/a16z-infra/ai-town ; OneSpellFitsAll: https://github.com/YenR/OneSpellFitsAll
- Oasis: https://oasis-model.github.io/ ; Genie 3: https://deepmind.google/blog/genie-3-a-new-frontier-for-world-models/ ; Roblox Cube: https://about.roblox.com/newsroom/2025/03/introducing-roblox-cube , https://github.com/Roblox/cube
- Whispers from the Star: https://store.steampowered.com/app/3730100/Whispers_from_the_Star/ ; Websim: https://websim.com
- WebLLM: https://github.com/mlc-ai/web-llm ; Vercel AI SDK: https://sdk.vercel.ai/docs ; QuickJS: https://bellard.org/quickjs/ ; isolated-vm: https://github.com/laverdet/isolated-vm
- GDC 2026 AI-native games retrospective (Hilary Mason): https://medium.com/@hmason/the-state-of-ai-native-games-lessons-from-the-frontier-2d0bf47dc7cd ; Steam AI disclosure policy: https://store.steampowered.com/news/group/4145017/view/3862463747997849618
