对当前 PGE 项目做一次“改建方案”设计，不要做战略设计，不要重新定义愿景。

目标：
把现有 PGE 从当前偏单轮、skeleton-first 的执行框架，改造成更接近 Anthropic long-running harness 的多轮稳定执行系统。

主目标不是写概念文档，而是产出一组可执行的改建方案文档，指导后续代码改造。

核心目标：
围绕 Anthropic long-running harness 的多轮稳定执行能力，重点补齐下面 5 个 Critical Gates：

1. Planner raw-prompt ownership
   Planner 能从短 prompt / raw intent 扩展出 run-level spec、product frame、roadmap，而不是只处理一个 bounded round。

2. Preflight multi-turn negotiation
   Generator 和 Evaluator 在实现前围绕 sprint contract 多轮协商，明确 done criteria、evidence、threshold、non-goals。
   没有 locked sprint contract，不允许 Generator 开始实现。

3. Generator sprint / feature granularity
   Generator 不是只跑一个 round，而是能按 sprint / feature 多轮推进一个较大的 run。

4. Evaluator hard-threshold grading
   Evaluator 不能只做存在性检查或宽松 PASS。
   必须有 explicit criteria、threshold、blocking dimensions，并能 fail weak work。

5. Runtime long-running execution and recovery
   Runtime 必须支持 durable state、progress、evidence、verdict、route、checkpoint、handoff、resume。
   不依赖单次 Claude conversation 的上下文记忆。

参考资料：
这些资料只是学习对象，不是要复制：

1. Anthropic harness design for long-running apps
   作为主参考，重点学习 Planner / Generator / Evaluator、多轮 sprint、preflight negotiation、hard evaluator threshold、long-running runtime。

2. OpenSpec
   只学习 spec / change / proposal / tasks 的 artifact 组织方式。
   不复制它的命令体系，不把 PGE 改成 OpenSpec。

3. gsd-build/get-shit-done
   只学习 How It Works 中的 context engineering、roadmap-before-code、phase/handoff、context rot 防治。
   不复制它的完整 workflow。

4. garrytan/gstack
   重点参考 plan-eng-review 以及工程 review 的压力：
   architecture、data flow、edge cases、test coverage、performance、parallelization。
   不复制 gstack 的角色体系。

5. obra/superpowers
   重点参考 brainstorming，用于 raw intent -> clearer spec 的前置澄清。
   不复制 superpowers 的完整 skill 体系。

6. shanraisshan/claude-code-best-practice
   参考 DEVELOPMENT WORKFLOWS，学习开发流程纪律、验证优先、小步推进、上下文管理。
   不复制其目录和规则。

工作方式：
请先阅读当前 repo 的真实结构和关键文件，再写方案。

必须阅读：
- README.md
- .claude-plugin/plugin.json
- agents/
- skills/
- skills/pge-execute/SKILL.md
- skills/pge-execute/ORCHESTRATION.md
- skills/pge-execute/contracts/
- docs/
- bin/ 中和本地运行、安装相关的脚本

输出目录：
所有最终文档放在 docs/design/ 下。
如果 docs/design/ 下已有相关目录，优先复用，不要随意新建混乱目录。

请产出以下文档：

1. docs/design/pge-rebuild-plan.md

内容：
- 当前 PGE 的真实状态
- 当前已经具备的能力
- 当前和 Anthropic 5 个 Critical Gates 的差距
- 改建目标
- 改建非目标
- 分阶段改建路线
- 每阶段验收标准

注意：
这不是战略设计文档，不要写愿景口号。
重点是“怎么把当前项目改造成目标形态”。

2. docs/design/pge-multiround-runtime-design.md

内容：
- run / sprint / round 的层次关系
- runtime-state 结构
- progress 结构
- evidence 结构
- verdict 结构
- route 结构
- checkpoint / handoff / resume 机制
- PASS / RETRY / BLOCK / ESCALATE / DONE 的状态流转
- 如何支持多 sprint 稳定执行
- 如何从文件恢复上下文

3. docs/design/pge-contract-negotiation-design.md

内容：
- Planner 如何生成 sprint contract proposal
- Generator 如何 review contract
- Evaluator 如何 review contract
- 多轮 negotiation 如何收敛
- locked contract 的条件
- 没有 locked contract 时禁止 implementation
- contract 应包含哪些字段：
  - objective
  - scope
  - non-goals
  - files likely touched
  - acceptance criteria
  - evidence required
  - evaluator thresholds
  - retry policy
  - stop condition

4. docs/design/pge-evaluator-threshold-design.md

内容：
- Evaluator 当前问题
- hard-threshold grading 模型
- blocking criteria
- score dimensions
- weak deliverable fixture
- evidence requirements
- verdict schema
- RETRY / BLOCK / ESCALATE 的判定边界
- 如何避免 evaluator 只做文件存在性检查

5. docs/design/pge-reference-learning-notes.md

内容：
按参考项目分别说明：
- 学什么
- 不学什么
- 学到 PGE 哪个模块里
- 为什么不复制整个项目

必须覆盖：
- Anthropic
- OpenSpec
- GSD
- gstack
- Superpowers
- claude-code-best-practice DEVELOPMENT WORKFLOWS

6. docs/design/pge-rebuild-review-report.md

内容：
做至少两轮 review：
- Round 1：基于当前 repo 的初稿 review
- Round 2：以 Anthropic 5 个 Critical Gates 为验收标准 review
- 最终结论
- 仍然未解决的问题
- 后续代码改造建议

Review 要具体，不要泛泛说“需要加强”。
每个问题要写：
- 问题是什么
- 影响哪个 Critical Gate
- 应该改哪个模块
- 需要新增或修改哪些 artifact
- 如何验收

重要约束：
1. 不要做战略设计。
2. 不要重新发明 PGE 的定位。
3. 不要扩大成通用 AI 开发平台。
4. 不要新增一堆 agent。
5. 默认仍然是 Planner / Generator / Evaluator 三个稳定角色。
6. 不要每个 task 新建一组三 agent。
7. 不要复制 OpenSpec / GSD / gstack / Superpowers。
8. 不要只画流程图，必须落到 repo 文件、runtime artifacts、contracts、acceptance checks。
9. 不要把未来目标写成当前已实现。
10. 明确区分：
    - current confirmed state
    - inferred design gap
    - proposed rebuild change
    - later implementation work

最终返回：
- 新增/修改了哪些 docs 文件
- 每个文件的核心内容摘要
- 当前 PGE 和 5 个 Critical Gates 的差距表
- 推荐的下一步代码改造顺序
