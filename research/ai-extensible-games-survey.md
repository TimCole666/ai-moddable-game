# AI 扩展型游戏调研报告(玩家可用 AI 自由扩展、重塑内容与规则的单机游戏)

- **调研日期**:2026-10-16
- **调研方法**:基于公开网络来源(官方网站、Steam 商店页、GitHub 仓库、arXiv 论文、开发者博客、媒体报道),通过搜索引擎与网页抓取核实各产品截至 2026 年 10 月的现状。所有关键论断附来源链接;无法从一手来源完全核实的细节标注"推测"。
- **目标读者**:计划立项做"AI 可扩展单机游戏"的独立开发者(擅长 TypeScript / Web)。

---

## A. 同类产品调研

### 分类框架

按照 AI 在游戏中扮演的角色,把同类产品分为五类:

1. **AI 生成内容**:AI 在运行时生成 NPC 台词、物品、图像等,但规则本身是固定的。
2. **AI 生成规则或代码**:玩家用自然语言描述玩法,AI 生成可执行的逻辑/mod。
3. **AI 当 GM 或世界模拟**:AI 扮演游戏主持人,动态解释玩家意图、演算世界状态。
4. **世界模型(生成式引擎)**:用神经网络逐帧生成游戏画面本身,没有传统游戏引擎。
5. **UGC 平台内置 AI 工具**:平台方为创作者提供生成式 AI 工具链。

> 参考:2026 年 7 月发表的学术综述《AI Native Games: A Survey and Roadmap》(arXiv:2607.00527)用"反事实标准"定义了 AI 原生游戏——如果把运行时生成式 AI 拿掉,核心玩法是否崩塌。该综述分析了 53 个公开可玩的 AI 原生游戏/原型,语料库见 https://github.com/igloomatics/Awesome-AI-native-games-collection 。其核心论断:AI 原生设计的中心问题是**"如何把语义开放性组织成稳定的玩法"**——这正是本项目的核心设计难题。另外 GDC 2026 上 Hilary Mason 等人复盘了已上线 AI 原生游戏"大规模起步、部分惨烈失败"的现状(https://medium.com/@hmason/the-state-of-ai-native-games-lessons-from-the-frontier-2d0bf47dc7cd ,事实)。

---

### A1. AI 生成内容

#### 1. Infinite Craft(Neal Agarwal)—— LLM 元素合成

- **一句话简介**:从一个"水"和"火"出发,任意两元素拖在一起即可合成新元素,合成结果由 LLM 即时判定,理论组合近乎无限。
- **AI 用在哪**:仅用于"两个元素 → 一个新元素名 + emoji"这一个判定点,LLM 完全不碰规则层(合成动作本身、UI、侧边栏都是传统代码)。
- **平台/形态**:纯 Web,浏览器休闲玩法(https://neal.fun/infinite-craft/ )。
- **技术栈(公开)**:2024 年 1 月底发布;社区通过抓包确认其后端调用 Llama 模型(经 Together AI 提供),首次合成结果会被缓存,后续玩家合成同一组合直接读缓存(事实,来源:neal.fun 站点本身及被 arXiv:2607.00527 收录为条目 [29])。
- **现状**:存活,免费,无内购(2026-10 仍可访问)。
- **可借鉴点**:**"LLM 判定 + 强缓存"是性价比最高的 AI 玩法形态**——同一输入永远复用已有输出,边际成本趋近于零;而且把 AI 的输出面压缩到"一个名词",天然规避了幻觉和规则失控问题。对单机游戏,"AI 只回答开放性语义问题,其他一切确定性"是极好的第一课。

#### 2. AI Roguelite(Max Loh)—— AI 生成内容驱动的 Roguelike

- **一句话简介**:Steam 上的 AI 驱动 Roguelike,实体(物品/敌人/技能)名称、图标、属性、战斗结果全由 LLM 生成,玩家可自定义生成参数甚至世界观规则。
- **AI 用在哪**:内容层 + 部分"语义判定"(AI 裁决攻击描述是否成立);有"实体生成"系统,玩家可以创造 AI 生成的物品和技能。
- **平台/形态**:Steam(PC),2D 文本+图像混合。
- **技术栈(公开)**:开发者博客披露其用 prompt 模板 + 结构化输出把 LLM 结果映射到游戏数值(来源:Steam 商店页 https://store.steampowered.com/app/1889620/AI_Roguelite/ ,事实)。
- **现状**:存活,付费买断(约 $10 档),已持续更新多年,评价"特别好评"数量可观但口碑两极(AI 生成质量不稳)。arXiv:2607.00527 将其作为"推理经济学与商业模式"案例 [70]。
- **可借鉴点**:证明**一个独立开发者可以独自做出并持续运营 AI 原生买断游戏**;也证明纯"AI 生成一切"容易导致玩法空洞——它的好评集中在"造物乐趣",差评集中在战斗深度。

#### 3. Whispers from the Star(星之低语,Anuttacon)—— 大厂级 AI 对话叙事

- **一句话简介**:通过实时(语音/文字)与一位被困外星的 AI 宇航员自由对话,玩家的每句话都是她唯一的求生线索,由前米哈游团队创办的 Anuttacon 开发。
- **AI 用在哪**:NPC 完全由 LLM 驱动,自由对话 + 实时语音 + AI 判定剧情分支。
- **平台/形态**:Steam(PC/iOS),3D 演出 + 对话。
- **技术栈(公开)**:官方仅公开为"in-house AI 模型 + 实时语音"(https://wfts.anuttacon.com/faq/ )。
- **现状**:2025 年 3 月公布并封测(https://game8.co/articles/latest/whispers-from-the-star-an-ai-driven-sci-fi-g),2025 年内开启 Early Access(Steam app 3730100),目前存活(事实)。
- **可借鉴点**:展示了**"自由对话必须绑定一个清晰的求生目标"**才能成为游戏而不是聊天机器人——开放语义输入 + 收敛的 ludic 结构(Steam 页面的目标、资源、时间压力)。

#### 4. 中国区补充:《历史模拟器:崇祯》《麦琪的花园》、Dev_Nulls_Tower 等

- **事实**:2025-2026 年国产 AI 原生/AI-NPC 游戏明显增多。arXiv:2607.00527 收录了《历史模拟器:崇祯》(Steam app 4304230,2026,玩家以文字/对话自由扮演崇祯,LLM 演算朝局)与《Dev_Nulls_Tower》(Steam app 4350940,2026,爬塔玩法与 AI 生成结合)[37][41];知乎的综述文章提到《麦琪的花园》(AI-NPC 开放沙盒)等国产项目(https://zhuanlan.zhihu.com/p/1964006892968846020 ;机核 https://www.gcores.com/articles/218280 )。
- **可借鉴点**:中文市场的 AI 原生买断游戏已在 Steam 站稳,验证了"中文 prompt 工程 + 买断制"的可行性;Steam 的 AI 内容披露政策(2024 起,来源:https://store.steampowered.com/news/group/4145017/view/3862463747997849618 )已迫使所有此类游戏打标签,立项时要预留合规工作。

---

### A2. AI 生成规则或代码(与本任务最相关)

#### 5. Voyager(Minecraft 中的 LLM Agent,NVIDIA/Caltech 等)—— 自动写代码积累技能库

- **一句话简介**:把 GPT-4 接入 Minecraft,Agent 每次遇到新任务就用自然语言规划、写 JavaScript 控制 Mineflayer API、执行失败则根据环境反馈自动迭代,成功的代码进入"技能库"长期复用。
- **AI 用在哪**:纯"AI 写代码扩展能力"范式——技能库是可检索、可组合、可被新任务复用的程序化资产。
- **平台/形态**:研究原型,Minecraft(Java)。
- **技术栈(公开)**:GPT-4 + Mineflayer(JavaScript/Minecraft API)+ 向量库检索技能;论文 arXiv:2305.16291(https://arxiv.org/abs/2305.16291 ),官方实现 https://github.com/MineDojo/Voyager(GPT-4 API 调用,事实)。
- **现状**:研究项目,已停更,但被广泛复现(包括下文的 Mindcraft)。
- **可借鉴点**:**这就是"玩家用 AI 扩展游戏"最成功的技术蓝图**——AI 不是直接"生成游戏",而是在一个稳定的 API 面上写小段代码,失败自动修正,成功即沉淀为永久能力。"技能库 = 玩家创造的 mod"模式可以直接搬到面向玩家的产品里。

#### 6. Mindcraft(开源)—— Voyager 的社区延续

- **一句话简介**:开源的 Minecraft LLM bot 项目,用 Node.js + Mineflayer + LLM 让 AI 角色在 Minecraft 里接受自然语言指令并自主行动。
- **AI 用在哪**:LLM 把玩家自然语言翻译成 Mineflayer 代码/动作序列;支持多 bot、BYOK(API key 自带)。
- **平台/形态**:开源项目(非游戏),GitHub https://github.com/kolbytn/mindcraft (活跃,2025 年仍在发版,后迁移至 mindcraft-bots/mindcraft 组织,事实)。
- **技术栈(公开)**:JavaScript/Node.js、Mineflayer、可接 OpenAI/本地 Ollama 等,基于 Voyager 思路改进(仓库 README,事实)。
- **现状**:活跃开源,MIT 类许可,社区庞大。
- **可借鉴点**:**BYOK + 开源 mod 的真实样本**:项目要求玩家填自己的 LLM API key,运行在玩家本地 Node.js 进程;其对"LLM 只能通过预定义 action API 操控游戏"的约束方式值得逐行研究。也提示了 TypeScript/Node 技术栈做这类项目完全够用。

#### 7. OneSpellFitsAll / "LLM 写 mod" 实践

- **事实**:研究者已有把"LLM 生成游戏内法术/逻辑代码"做成玩法的原型,如 OneSpellFitsAll(玩家用自然语言写法术,LLM 生成代码,来源:https://github.com/YenR/OneSpellFitsAll ,被 arXiv:2607.00527 作为"机制层创新"引用 [61])。
- **可借鉴点**:证明"玩家用 prompt 写出真正改变玩法的代码"在 2023-2024 年已被验证可行,缺的是把它包装成好游戏的商业产品——这是市场空隙。

---

### A3. AI 当 GM 或世界模拟

#### 8. AI Dungeon(Latitude)—— 开山之作

- **一句话简介**:无限自由的文字冒险,玩家任意输入,AI 即时续写剧情,是"AI 当 GM"类目的开创者(2019)。
- **AI 用在哪**:GM 层——解释任意玩家输入,决定世界如何回应;近年加入图像生成、世界观/剧情卡、多 agent 场景。
- **平台/形态**:Web / iOS / Android / Steam,纯文本 + 插图。
- **技术栈(公开)**:从 GPT-2/GPT-3 起家,后自研 Dragon 模型;现主要基于第三方大模型 + 自家微调(来源:https://play.aidungeon.com/pricing 及官方 Forge 更新说明 https://aidungeon.com/forge ,事实)。
- **现状**:存活,免费 + 订阅($14.99–$99.99/月,来源:官方定价页);2026 年推出 "Forge" 里程碑(扩展模型访问与图像模型)。注意:arXiv:2607.00527 严格来说把 AI Dungeon 归为"AI 边界产物"(AI 是核心但缺乏严格玩法结构)[28]——自由归自由,没有输赢与状态收敛。
- **可借鉴点**:① 订阅制覆盖推理成本是此类产品唯一跑通过的商业模式;② 20 余年历史的教训是**"完全自由 = 没有游戏"**,长期留存需要给自由加上目标;③ 其"Memory(记忆)、World Info(世界观词条注入)"机制是最早的实用化 RAG-in-game 方案。

#### 9. Hidden Door —— AI 叙事世界 + 粉丝版权合作

- **一句话简介**:把粉丝小说世界(如《绿野仙踪》《爱丽丝》)变成 AI 驱动的可扮演角色扮演舞台,玩家与朋友一起在 AI 主持的"戏剧"中即兴冒险,产出插图与故事记录。
- **AI 用在哪**:GM 层(LLM 主持叙事)+ 内容层(生成插图、角色卡);强调多人和收藏/分享。
- **平台/形态**:Web,文本+插画。
- **技术栈(公开)**:自研叙事引擎 + 生成式模型,与 IP 方(如整理公版作品)合作授权(来源:Variety 2025-08 报道 https://variety.com/2025/gaming/news/hidden-door-ai-role-playing-fan-fiction-game-platform-launches-1236494356/ ,事实)。
- **现状**:2025 年 8 月正式上线(此前多年研发/内测),目前存活,免费+订阅。团队由 Hilary Mason(数据科学/安全背景)领衔。
- **可借鉴点**:① 证明"AI GM + 视觉包装 + 社交分享"是让文本冒险大众化的组合拳;② 它与 GDC 2026 复盘(同团队)都在强调:**AI 原生游戏死于"没有节制的生成"与"推理成本失控"两件事**。

#### 10. Suck Up!(Proxima)—— 与 AI 角色自由对话的说服游戏

- **一句话简介**:你扮演吸血鬼,挨家挨户用语音/文字说服 AI 扮演的人类开门让你进去吸血,说服策略完全自由。
- **AI 用在哪**:每个 NPC 是 LLM 驱动的可说服角色,有自己的性格/秘密/软肋;AI 依据对话质量决定是否放行。
- **平台/形态**:Steam(PC),3D 演出 + 对话。
- **技术栈(公开)**:云端 LLM + 语音合成(来源:Steam 商店页 https://store.steampowered.com/app/2726370/Suck_Up/ 及 2025-10 报道 https://www.hypergridbusiness.com/2025/10/indie-vampire-game-highlights-future-for-ai-driven-games/ ,事实)。
- **现状**:2024 年爆红于 TikTok 直播,2025 年上 Steam 后评价转为"Mixed"(约 60%),第三方估算收入约 $74.7K(https://gamerevenuedata.com/games/suck-up/ ,估算非事实);持续运营中。
- **可借鉴点**:① 病毒式传播靠"看主播说服 AI"的观赏性——AI 自由交互本身就是内容;② 差评集中在**新鲜感耗尽后玩法变浅**和持续推理成本,警示"AI 对话"不能是全部玩法;③ 小团队(几人)做出过千万级播放,说明品类对独立开发者友好。

#### 11. 1001 Nights(Ada Eden)—— 玩家话语改变世界

- **一句话简介**:玩家扮演山鲁佐德,对国王讲述的故事内容(关键词、情绪、道具)会被 AI 拆解成真实世界中的武器/资源,故事说得好才能拿到武器杀死国王逃出去。
- **AI 用在哪**:内容层与机制层的桥梁——LLM 把叙事(非结构化)转化为游戏状态(结构化:武器属性、敌意值),arXiv 论文称之为"玩家驱动的叙事涌现"。
- **平台/形态**:Steam/itch.io(Windows/macOS),2D 手绘 + 文本(https://www.1001nights.ai/ ,https://ada-eden.itch.io/1001-nights-official ,Steam app 2542850《Book of Infinity: 1001 Nights》)。
- **技术栈(公开)**:论文《Player-driven emergence in LLM-driven game narrative》(arXiv:2404.17027,https://arxiv.org/abs/2404.17027 )详述了"叙事 → 机械状态"的转换管线。
- **现状**:存活,2024 年 Demo,后续正式版/续作《Book of Infinity》开发中(2026)。
- **可借鉴点**:**"自由叙事 → 结构化游戏状态"这条翻译管道就是 AI 扩展游戏的心脏**。它证明了即使游戏规则固定(战斗、数值),只要 AI 能把玩家的开放输入变成规则可消费的对象,玩家就会感到"我的话真的改变了世界"。

#### 12. Stanford Generative Agents / Smallville —— 25 个 AI 居民的小镇

- **一句话简介**:斯坦福研究的模拟小镇,25 个 LLM agent 各有人设与记忆,自主社交、传播信息、涌现出"办派对"等集体行为。
- **AI 用在哪**:多 agent 世界模拟——每个 agent 的观察、反思、计划、对话全由 LLM 生成。
- **平台/形态**:研究原型,2D 俯视像素小镇;代码开源 https://github.com/joonspk-research/generative_agents 。
- **技术栈(公开)**:论文 arXiv:2304.03442(https://arxiv.org/abs/2304.03442 ):**memory stream(按时间/重要性/相关性检索的记忆流)+ reflection(定期自我总结)+ planning**。这套记忆架构至今仍是 AI 游戏记忆系统的标准模板(后续工程化见 MemGPT,arXiv:2310.08560)。
- **现状**:研究项目(2023),代码 MIT 开源可用,大量后续项目(如 AI Town)基于它。
- **可借鉴点**:memory stream 的三因子检索(recency × importance × relevance)可以直接实现;同时它也暴露了成本问题——原论文每个 agent 每天多轮 LLM 调用,离线模拟一个小镇花费数千美元(论文披露,事实),**单机游戏必须做激进缓存与降频**。

#### 13. AI Town(Convex / a16z)—— 可自部署的 AI 小镇

- **一句话简介**:Smallville 的工程化开源复刻,MIT 许可的"AI 小镇"starter kit,可一键部署并自定义角色、地图与背景故事。
- **AI 用在哪**:agent 对话与移动决策。
- **平台/形态**:Web(2D 像素),开源 https://github.com/a16z-infra/ai-town 。
- **技术栈(公开)**:**TypeScript + Convex(数据/后端)+ React + PixiJS**,LLM 经 API 调用;仓库内有 ARCHITECTURE.md 详述 agent 循环与数据流(事实)。
- **现状**:开源项目,仍有维护与 fork 生态;适合直接作为参考工程而非产品。
- **可借鉴点**:**这是与用户技术栈(TS/Web)最匹配的参考代码**——其 agent 状态机(convex 事务表驱动)、对话记忆存取、角色卡结构可以低成本吸收进原型。

---

### A4. 世界模型(生成式引擎)

#### 14. Oasis(Decart)—— 实时生成的"引擎-less Minecraft"

- **一句话简介**:用视频生成模型逐帧"幻想"出一个类 Minecraft 世界,玩家用键盘鼠标操作,AI 实时生成画面响应,完全不经传统游戏引擎。
- **AI 用在哪**:整个游戏画面即模型输出(下一帧预测)。
- **平台/形态**:Web demo + 可下载;开放了模型权重与推理代码(https://oasis-model.github.io/ ,事实)。
- **技术栈(公开)**:2024-10 发布,基于 ViT/VQM 类自回归视频模型,初期 360p/20FPS,后续与 Etched 合作发布可本地运行的 C 版本与开源权重(TechCrunch:https://techcrunch.com/2024/10/31/decarts-ai-simulates-a-real-time-playable-version-of-minecraft/ ,事实)。
- **现状**:作为技术演示存活,Decart 已转向更广的世界模型/实时视频业务;并非商业游戏。
- **可借鉴点**:短期(3-5 年内)**不适合独立开发者走"世界模型替换引擎"路线**——算力、显存、一致性(它著名的"转头物品就漂移"问题)都不成熟;但它预示的方向值得持续跟踪。

#### 15. DeepMind Genie 系列(Genie 2 / Genie 3)—— 生成式交互世界模型

- **一句话简介**:输入一段文字提示,Genie 3(2025-08 发布)可生成可实时探索的交互式 3D 环境,支持动作控制与环境持久性(走出画面回来,场景保持一致)。
- **AI 用在哪**:整世界即模型输出。
- **平台/形态**:研究预览,未开放公众使用。
- **技术栈(公开)**:官方博客 https://deepmind.google/blog/genie-3-a-new-frontier-for-world-models/ :支持 720p、24FPS、数分钟连续交互,环境可导航、可指定天气/NPC 等事件;主要面向 agent 训练与教育场景(2026-07 博客更新仍以 API 限量预览形式提供,事实)。
- **现状**:未商品化,学术界/媒体普遍认为距消费级游戏尚远(TechCrunch 2025-08:https://techcrunch.com/2025/08/05/deepmind-thinks-genie-3-world-model-present-a-stepping-stone-toward-agi/ )。
- **可借鉴点**:同 Oasis——**关注但不要押注**;独立开发者能借力的"世界模型"时代至少还要等模型 API 变得便宜且低延迟。

---

### A5. UGC 平台内置 AI 工具

#### 16. Roblox:Studio AI 助手 + 开源 Cube 3D 模型

- **一句话简介**:Roblox 在 Studio 中内嵌生成式 AI 助手(写脚本、生成材质、建场景),并于 2025 年 3 月开源了 3D 生成基础模型 Cube 3D(文本→网格)。
- **AI 用在哪**:创作工具层(开发时 AI,不是运行时 AI)。
- **平台/形态**:Roblox 平台(3D UGC)。
- **技术栈(公开)**:官方公告 https://about.roblox.com/newsroom/2025/03/introducing-roblox-cube ,开源仓库 https://github.com/Roblox/cube (文本到 3D 物体,基于 RoCE 网格 token 化;事实)。
- **现状**:持续演进中,2025-2026 陆续扩展到 4D(动画)与场景级生成。
- **可借鉴点**:① 平台级 AI 工具证明了**"生成式 AI 最好的用武之地是把创作门槛降到零"**;② Cube 开源意味着我们的游戏可以直接拿它做"玩家文字→3D 资产"的本地/离线资产生成管线(推测:当前模型质量对美术要求高的产品仍偏玩具级)。

#### 17. Minecraft 生态的 AI 尝试(背景补充)

- **事实**:Minecraft 本体没有官方运行时 LLM 功能,但生态内 AI 实验密集:Voyager、Mindcraft(见 A2)、以及微软研究线的 Agent 综述均以 Minecraft 为标准试验场;Minecraft 官方的教育版与 Marketplace 亦有 AI 相关内容,但属于辅助工具。Minecraft 之所以成为 AI 游戏实验的第一场景,是因为它有**稳定的 API 面(Mineflayer/Mod API)+ 开放世界 + 明确目标结构**——这个组合本身值得复制。
- **可借鉴点**:给玩家自由扩展的前提是给 AI(或玩家代码)一个**小而稳定的 API 面**;Minecraft 生态的成功一半来自 mod API 的克制设计。

#### 18. Websim —— 提示词即网页(准游戏生成平台)

- **一句话简介**:输入一句话/贴一个链接,即时生成一个可交互的网页(大量用户拿它生成小游戏),并且支持把别人作品"remix"再创作。
- **AI 用在哪**:整个"游戏/网页"由 LLM 生成代码,本质是"LLM 写前端代码当游戏"。
- **平台/形态**:Web(https://websim.com ),2024 年起爆红,2025 年已发展出社区、创作者经济与付费订阅(来源:aixploria 2025-11 评测 https://www.aixploria.com/en/websim-ai-create-game-website/ 等第三方报道,事实)。
- **技术栈(公开)**:前端代码由 LLM 生成(HTML/CSS/JS,含 Three.js 等浏览器 3D),平台托管+沙箱执行(推测:基于 iframe/origin 隔离,Websim 未完整公开其安全架构)。
- **可借鉴点**:证明"**玩家描述 → LLM 写代码 → 立即可玩**"的循环用户真的爱用,且 remix 生态让 UGC 自我繁殖;这就是"AI mod 平台"的活样本——缺的只是"游戏性框架"。

### 横向小结(事实,综合上述来源)

| 产品 | AI 层级 | 形态 | 商业模式 | 一手来源 |
|---|---|---|---|---|
| AI Dungeon | GM 层 | 文本 | 订阅 $15-100/月 | play.aidungeon.com/pricing |
| Infinite Craft | 语义判定 | Web 2D | 免费+缓存 | neal.fun/infinite-craft |
| Hidden Door | GM+内容 | Web 文本+插画 | 免费+订阅 | hiddendoor.co |
| Suck Up! | AI NPC | 3D+对话 | 买断 | Steam 2726370 |
| 1001 Nights | 叙事→状态 | 2D 文本 | 买断/Demo | arXiv:2404.17027 |
| Voyager / Mindcraft | AI 写代码 | Minecraft mod | 开源/BYOK | arXiv:2305.16291, kolbytn/mindcraft |
| Generative Agents / AI Town | 多 agent 模拟 | 2D 像素 | 开源 | arXiv:2304.03442, a16z-infra/ai-town |
| Websim | AI 写代码(整站) | Web | 免费+订阅 | websim.com |
| Oasis / Genie 3 | 世界模型 | 引擎-less | 研究预览 | oasis-model.github.io, DeepMind blog |
| Roblox Cube | 创作工具 | 3D UGC 平台 | 免费+开源模型 | about.roblox.com/newsroom |

---

## B. 技术方案与架构模式

### B1. LLM 集成的三个层级与绑定方式

**层级选择**(参考 arXiv:2607.00527 的 N 轴分类与各产品实践):

- **内容层**(生成 NPC 台词/物品/剧情):风险最低,Suck Up!、AI Roguelite 属此类;LLM 输出经过窄接口(一句台词、一个物品定义)。
- **规则层**(玩家描述玩法,AI 生成逻辑):OneSpellFitsAll、Voyager 技能库、Websim 属此类;需要"AI 代码 + 沙箱执行"(见 B2)。
- **GM 层**(动态演算世界):AI Dungeon、Hidden Door、Generative Agents 属此类;需要记忆系统与状态收敛设计。
- **推荐组合**:内容层兜底可用性,规则层制造"扩展感",GM 层只做"裁决/翻译"而不做"叙事主力"(详见 C 部分)。

**结构化输出绑定游戏状态**:

- 主流方案是 JSON Schema 约束/function calling:Vercel AI SDK 的 `generateObject`/`generateText` + Zod schema(https://sdk.vercel.ai/docs ,TS 生态事实标准);模型侧有 grammar-constrained decoding 的学术基础(arXiv:2305.13971,https://arxiv.org/abs/2305.13971 )与开源实现 Outlines(https://github.com/dottxt-ai/outlines )。1001 Nights 的"叙事→武器属性"管线本质就是 schema 化输出(arXiv:2404.17027)。
- 事件驱动架构:AI 的每次输出被规范为一个"事件对象"(如 `{type:"spawn", entity:"...", props:{...}}`),由确定性引擎消费执行——这样 LLM 永远不直接改游戏状态,只能发事件。这是所有成熟案例的共同模式(推测归纳,Voyager/Mindcraft/AI Town 的代码结构均如此)。

**RAG 与记忆**:Generative Agents 的 memory stream(时间近因 × 重要性评分 × 相关性检索三因子加权,arXiv:2304.03442)仍是标准做法;工程化可参考 MemGPT 的分层记忆(工作记忆/归档记忆,arXiv:2310.08560)。单机场景可用本地向量库(lancedb / sqlite-vec / hnswlib,均支持嵌入式部署)。

**成本、延迟与缓存**:

- Infinite Craft 的全量缓存(组合→结果永久缓存)是最极端也最有效的策略(事实)。
- 分级调用:廉价模型做高频判定,贵模型做低频"大事件"生成——AI Dungeon 的订阅分层就是围绕模型档位设计的(事实)。
- 批处理与降频:Generative Agents 对反思/计划采用周期触发而非每轮触发(论文披露)。
- **单机 BYOK vs 本地推理**:
  - BYOK(玩家自带 API key):Mindcraft 的实践(玩家填 key,游戏直接调 OpenAI/兼容端点);优点是零推理成本、合规简单;缺点是门槛(玩家得会申请 key)、付费墙外玩家体验差、key 安全(保存在本地配置,不得上传)。Chrome 内置的 `window.ai` / Gemini Nano 与 WebLLM(https://github.com/mlc-ai/web-llm ,纯浏览器 WebGPU 推理)、llama.cpp(桌面端)使"零配置本地小模型"在 2025-2026 年已可用,3-8B 级模型在消费级 GPU 上可支撑"语义判定"级任务,但难以胜任长叙事生成(推测,基于 WebLLM 公开 benchmark)。
  - **可行组合**:默认本地小模型(判定/缓存未命中时可用)+ 玩家可选填 key 解锁高质量模型(推测性建议,无现成产品完整示范此组合,但技术上各组件均成熟)。

### B2. AI 生成代码的安全执行

- **Voyager 技能库模式**(arXiv:2305.16291):AI 只能调用暴露给它的 API(如 `bot.collectBlocks(...)`)写小段 JS;执行失败 → 错误回传 → AI 自修正;成功代码入库并向量化,供未来任务检索复用。**这个"窄 API + 自修正 + 技能库"三点组合是可直接抄的方案**。
- **沙箱方案对比**(均为事实性技术,适用性为我的分析):
  - **QuickJS**(https://bellard.org/quickjs/ ,且有 Rust 绑定 quickjs-rs / WASM 版):可解释执行 JS,天然无网络/文件系统访问,可注入宿主函数白名单;启动快、内存小,适合在游戏内跑 AI 生成的脚本。Web 游戏里还可用 Web Worker + 严格 structured clone 隔离。
  - **isolated-vm**(https://github.com/laverdet/isolated-vm ):Node.js 的 V8 isolate 封装,真正的堆隔离,性能好,适合桌面(Tauri/Electron)单机游戏跑玩家/AI mod。
  - **WASM**(wasmtime 等):最强隔离但开发体验差,适合性能敏感或需要多语言 mod 的远期。
  - **能力安全(capability-based)**:核心原则是"代码只能拿到被显式授予的能力对象"——即把游戏 API 做成一组细粒度对象(`ctx.spawn`, `ctx.gold.add`),AI 代码拿不到全局世界。Voyager/Mindcraft 的 API 注入即是朴素的 capability 模式(我的分析)。
- **限制 API 面**:教训来自平台安全——Websim 生成代码跑在独立 origin/iframe 中(推测);AI Dungeon 等服务则干脆不允许任何用户代码。对单机游戏,能力安全 + 无默认网络/IO 是底线(我的分析)。

### B3. 引擎与框架

- **Web 系(与用户技能栈最契合)**:
  - AI Town 证明 TypeScript + Convex + PixiJS 完全能跑 agent 世界(https://github.com/a16z-infra/ai-town/blob/main/ARCHITECTURE.md ,事实)。
  - Three.js/Phaser + Vercel AI SDK(结构化输出、流式、多 provider 切换,https://sdk.vercel.ai/docs )是目前上手最快的组合;WebLLM 提供浏览器内推理(https://github.com/mlc-ai/web-llm ,事实)。
  - 优势:即开即玩(Websim 的分发优势)、AI 生成 JS 代码可直接在沙箱里跑(与规则层天然契合)。劣势:3D 大世界性能与资产管线弱于原生引擎(我的分析)。
- **Godot**:开源、包体小、社区有 LLM 集成插件(如 godot-gdllm 等第三方插件生态,GitHub 搜索可见多个,均为社区项目);GDScript 对 AI 生成代码不友好(模型见得少、沙箱生态弱),但可用 GDExtension 挂 QuickJS/wasmtime 做脚本沙箱(推测,无成熟先例)。
- **Unity**:生态最大,有 Inworld AI 等 LLM-NPC 中间件合作案例(公开新闻);但授权条款对独立开发者的单机 AI 游戏无特殊优势,且运行时为 C#,跑 AI 生成代码需额外嵌脚本引擎(我的分析)。
- **"LLM 写 mod"的已有实践**:Voyager(专用 API)、Mindcraft(同)、OneSpellFitsAll(法术生成)、Websim(整站生成);**尚无"通用游戏 + 玩家 AI mod 市场"的成熟商业产品**——这是空位,也是风险(没有可抄的成品安全方案)。

### B4. 玩家分享 AI 模组的生态与安全

- **分享格式**建议为"声明式包":prompt 模板 + schema 定义 + 事件处理器(受限于 API 面的代码)+ 可选生成资产;天然可审查、可 diff、可版本化(我的分析,Voyager 技能库的 JSON 化变体)。
- **安全考量**(均有公开依据):
  - **Prompt 注入**:玩家分享的 mod 内嵌文本可能诱导 LLM 越权(经典论文 arXiv:2211.09527、间接注入 arXiv:2302.12173);缓解:mod 内容与系统提示分离、对生成事件做 schema 校验与白名单、对"AI 裁决结果"设确定性边界。学术界的游戏化注入研究(如 Hacc-man,DOI:10.1145/3656156.3665432)表明玩家会主动把"越狱 AI"当玩法——这既是风险也可转化为设计。
  - **恶意生成代码**:沙箱(见 B2)+ 最小权限 + 禁网络是底线;分享 mod 应默认不授予网络与文件系统能力。
  - **内容审核**:Steam 要求披露 AI 生成内容(https://store.steampowered.com/news/group/4145017/view/3862463747997849618 ,事实);LLM 侧可用 Llama Guard 类输入输出过滤(arXiv:2312.06674);分享 mod 需要举报/审核通道与本地内容标记(我的分析)。
  - **版权/模型依赖**:模型 API 更迭会导致 mod 行为漂移(arXiv:2307.09009 记录了模型行为随时间变化),分享的 mod 应记录模型与参数假设。

---

## C. 设计启示(给我们的立项建议)

以下每条均基于前文调研,个人推断处已标注。

**1. AI 放在"规则翻译层"与"内容层",GM 层只做裁决,不做叙事主力。**
调研中纯 GM 层产品(AI Dungeon)被严格定义归为"非游戏",且商业模式只能靠订阅补贴推理成本;而成功的游戏性案例(Infinite Craft、1001 Nights、Suck Up!)都是把 AI 输出压缩成**结构化的游戏对象**(一个元素名、一件武器属性、一个 NPC 的放行判定),再交给确定性规则消费。建议:游戏规则(数值、战斗、经济)完全确定性;AI 负责把玩家的自然语言/prompt 翻译成这些规则可消费的对象与事件。这同时解决了"幻觉毁掉游戏状态"的问题——AI 说得再离谱,落到状态机的都是合法事件。

**2. 游戏形态首选 Web(TS)2D,3D 列为二期。**
理由:① 分发零摩擦是 Websim 式"即开即玩"爆红的前提(事实);② 规则层扩展需要"AI 写代码 + 沙箱执行",JS/TS 生态的 QuickJS/isolated-vm/Worker 沙箱最成熟,而 AI 模型生成 JS 代码的质量也远高于 GDScript/C#(我的分析);③ AI Town 证明了 TS + PixiJS 跑 agent 世界工程上完全够;④ 3D 资产生成(Roblox Cube)虽开源,但对独立团队美术管线压力仍大(我的分析)。2D/文本为主的形态还能显著压低 AI 图像成本与延迟。

**3. "AI 扩展"的可感知形态优先做:玩家写 prompt → 生成可持续复用的技能/物品/规则包(技能库模式),而非"AI 即时续写剧情"。**
Voyager 的技能库证明"AI 写的代码沉淀为永久能力"带来的成长感和分享价值远高于一次性文本生成;1001 Nights 证明"玩家话语变成世界里的实体"是玩家最强的 agency 体验。建议:让玩家用自然语言创造"会留在存档里的东西"(技能、物品、NPC、房间规则),并用它驱动的不是对话而是可玩、可分享、可 remix 的玩法对象。分享 = 声明式 mod 包(prompt + schema + 受限代码),参考 B4。

**4. 第一个原型只验证一件事:玩家创造的规则/实体与固定核心玩法是否真的"好玩"。**
arXiv:2607.00527 反复强调,当前 53 个 AI 原生游戏的普遍失败模式是"生成很多,玩不了"("把语义开放性组织成稳定玩法"是未解的核心难题);Suck Up! 上 Steam 后口碑下滑也印证新鲜感不等于留存。建议原型为:一个极小的确定性核心(如一个房间/一场战斗)+ 玩家可让 AI 生成 3-5 类扩展对象,测试 30 分钟后玩家是否仍在使用 AI 扩展、生成的对象是否互相组合出策略。**不要在原型期做叙事、美术生成、多人**。

**5. 单机推理策略:默认便宜、可选更好,缓存到底。**
事实依据:Infinite Craft 靠全量缓存做到免费;AI Dungeon 靠订阅分层把成本转嫁给重度玩家;Generative Agents 的原始设计成本在单机产品里完全不可接受。建议:所有 AI 结果以 (输入哈希, 模型档) 为键落盘缓存;本地小模型(内置 llama.cpp 或 WebLLM,3-8B)承担默认判定,玩家可选填 API key(或内购 credits)解锁高质量生成;BYOK 模式参考 Mindcraft(key 只存本地)。这使买断制单机在财务上成立(我的分析,基于上述产品成本结构的推演)。

**6. 把安全与合规当作玩法边界的一部分,而不是事后补丁。**
理由:Steam AI 披露已是硬要求(事实);玩家分享 mod 一旦出现恶意代码或违规内容,单机游戏开发者同样承担声誉与平台风险;而"受限 API 面 + 能力安全"如果能做透明(玩家能看到 mod 能碰什么),反而可以变成卖点——"看得见的规则边界"与 arXiv:2607.00527 的核心结论一致:AI 原生游戏的设计价值恰恰在于**为无限生成构造可信的约束**。

---

## D. Product decision update (2026-10-17)

AI access will be dual-path, amending the BYOK framing of recommendation 5:

1. **Official AI entry (default)**: the game ships with a hosted, official API entry. Inference costs are absorbed by the cache-first design — every generated result is persisted into the theme pack, so identical requests never re-bill (the Infinite Craft pattern, see A1).
2. **Own-agent path (advanced players/creators)**: the theme pack is engine-validated pure JSON, so creators can author mods with their own AI agents or tools and import them without touching our service. Export doubles as the mod-format spec by example; import validation rejects malformed packs safely.

Rationale: removes the "apply for an API key" onboarding wall for the majority of players while keeping an open, agent-friendly mod format for the creator ecosystem. Implemented and asserted in the prototype (`validatePack` + `importPack` round-trip; see branch `prototype/theme-mod-loop`).

---

## 附:关键来源清单

- arXiv:2607.00527《AI Native Games: A Survey and Roadmap》(2026) https://arxiv.org/html/2607.00527v1 ;游戏语料库 https://github.com/igloomatics/Awesome-AI-native-games-collection
- arXiv:2304.03442 Generative Agents;arXiv:2305.16291 Voyager;arXiv:2404.17027 1001 Nights;arXiv:2310.08560 MemGPT;arXiv:2305.13971 语法约束解码;arXiv:2312.06674 Llama Guard;arXiv:2302.12173 间接 prompt 注入
- AI Dungeon:https://play.aidungeon.com/pricing 、https://aidungeon.com/forge
- Infinite Craft:https://neal.fun/infinite-craft/ ;Hidden Door:https://www.hiddendoor.co/ 与 https://variety.com/2025/gaming/news/hidden-door-ai-role-playing-fan-fiction-game-platform-launches-1236494356/
- Suck Up!:https://store.steampowered.com/app/2726370/Suck_Up/ ;1001 Nights:https://www.1001nights.ai/
- Mindcraft:https://github.com/kolbytn/mindcraft ;AI Town:https://github.com/a16z-infra/ai-town ;OneSpellFitsAll:https://github.com/YenR/OneSpellFitsAll
- Oasis:https://oasis-model.github.io/ ;Genie 3:https://deepmind.google/blog/genie-3-a-new-frontier-for-world-models/ ;Roblox Cube:https://about.roblox.com/newsroom/2025/03/introducing-roblox-cube 、https://github.com/Roblox/cube
- Whispers from the Star:https://store.steampowered.com/app/3730100/Whispers_from_the_Star/ ;Websim:https://websim.com
- WebLLM:https://github.com/mlc-ai/web-llm ;Vercel AI SDK:https://sdk.vercel.ai/docs ;QuickJS:https://bellard.org/quickjs/ ;isolated-vm:https://github.com/laverdet/isolated-vm
- GDC 2026 AI 原生游戏复盘(Hilary Mason):https://medium.com/@hmason/the-state-of-ai-native-games-lessons-from-the-frontier-2d0bf47dc7cd ;Steam AI 披露政策:https://store.steampowered.com/news/group/4145017/view/3862463747997849618
