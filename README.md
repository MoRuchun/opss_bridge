完成任务：

Notebook 的开场白应当用一段短文说明研究对象与规范背景，并声明计算域与自由度维数；随即给出一格代码，清空域、设定模型为三维框架、载入可视化模块（推荐 `opsvis`），并固定单位制。随后在一格代码中建立跨径与墩台几何的参数化描述，给出四跨跨长、三个中跨墩位与两端桥台坐标，并沿中心线布置若干主节点，桥面将以 **elasticBeamColumn** 表示，其质量通过节点 `mass` 指令集中赋值，这与 OpenSeesPy 的节点质量命令一致；必要时也可在 `node` 指令里直接带 `-mass`，两种写法等价。([OpenSeesPy][2])

材料层面需要单独一格代码集中定义。混凝土采用 Concrete02，并给出保护层与受限核心两套参数以体现约束效应；钢筋采用 Steel02；这些命令在 OpenSees 与 OpenSeesPy 文档中均有一致签名，可直接照抄。该格请补充注释，标明强度、峰值应变、极限压碎应变与张拉软化斜率等含义，并引用拟合或规范来源。([OpenSeesPy][1])

截面与塑性展开需要单独一格。请以 FiberSection 命令构建圆形或箱形（按论文工程实际） RC 截面，用混凝土的 patch 与钢筋的 layer/straight 或 circular layer 描述配筋，随后以 forceBeamColumn 或非线性梁柱单元承载该纤维截面，实现分布式塑性。该过程的 FiberSection、patch、layer 与力基元单元的用法，可直接参照 OpenSeesPy 文档与 OpenSees 教程。此格完成后立即插入一个可视化格，调用 opsvis 的截面绘图例程或自定义散点图，直观核对钢筋与混凝土纤维布置。([OpenSeesPy][3])

柱端应变传递在另一格中实现。做法是在每根墩柱端面复制节点对，插入零长度**截面**单元，并在钢筋纤维上改用 Bond_SP01 以表示粘结滑移；OpenSees 的零长度单元与 Bond_SP01 用法可按社区与维基给出的范例设置，并在格末对单根柱做简短往复位移控制以检视滞回。([开放系统地震工程仿真][4])

基础柔度在专门一格实现。以零长度单元叠加三个平动与三个转动的线性弹簧，必要时可调用示例脚本 `ZeroLength1/3.tcl` 的思路实现平动与转动弹簧耦合，并在注释中给出来自地基变形模量换算的刚度来源。格末对单墩做自由振型或静力侧推，核对支承刚度感度。([开放系统地震工程仿真][5])

上部结构在随后的两格完成。第一格用 elasticBeamColumn 连通桥面各主节点，定义几何变换并在每个主节点赋予纵横向与扭转质量。第二格通过 `rigidLink beam` 将桥面横向刚性单元与墩顶刚结，以体现横向刚臂与横梁刚性，必要时在注释中说明等价的 equalDOF 使用边界。([OpenSeesPy][6])

随后几格分别封装并调用与桥台相关的部件函数。首先以一格定义“台后回填土”函数，函数体生成与桥台节点同轴的非线性弹簧。若运行环境提供“Hyperbolic Gap Softening”类的 OpenSees 单轴材料，则按文献实现其后峰降与残余分支；若环境未集成该扩展材料，则以 Hysteretic 材料输入与试验等效的三折线双曲包络作为替代，并在函数注释内明确二者接口等价与参数对照。这一处理与近年关于台后土体系超越峰值响应的 OpenSees 建模做法一致。([CompDyn 2023][7])

再用一格实现“桥台基础”函数，按台帽节点叠加双线性或弹塑性间隙弹簧，以表示在压缩、拉脱与小位移回转下的非线性支承；OpenSees 的 ElasticPP 与 ElasticPPGap、Bilin 材料均可直接调用。([OpenSeesPy][8])

接着单独一格实现“支座”函数。支座用零长度单元承载双线性滞回，参数包含初始刚度、屈服力与二次刚度；这一处理与 OpenSees 用户手册中对橡胶支座双线性剪切弹簧的实现保持一致。([开放系统地震工程仿真][9])

随后一格实现“剪力键”函数。三折线力—位移可用 Hysteretic 材料按正负向分别给定折点，并在注释中注明强度、刚度与残余段参数的物理意义与来源。([开放系统地震工程仿真][10])

再用一格实现“桥面—桥台碰撞”函数，直接以 ImpactMaterial 表示基于赫兹接触的压向间隙材料，含初始缝宽、屈服位移与双线性刚度；必要时可在注释里附上与经典赫兹阻尼接触模型的对应关系。([开放系统地震工程仿真][11])

完成单元部件后，专门用一格组装整桥。该格调用前述函数，对两端桥台与中跨三排四柱墩按**12 根柱**的数量进行循环；对桥面连续化并在支点处插入支座与剪力键；在端部节点处并联台后回填土、基础弹簧与碰撞缝元件；在桥面中心线节点集中质量，以保证整体动力特性与文献一致。组装完成后的同格或下一格应立即调用 `opsvis.plot_model` 或等效作图显示整桥与构件标签，核查连通性与约束是否正确。([OpenSeesPy][12])

载荷与地震输入在后续两格完成。第一格进行重力工况与初始静力平衡；第二格以 `timeSeries Path` 加 `pattern UniformExcitation` 引入地震加速度时程，必要时在台后自由场节点额外定义支承输入；记录器同时开启节点位移、构件内力与关键零长度元件的滞回响应，并给出常见的输出频率与文件格式。以上两类命令在 OpenSeesPy 文档中均有清晰接口。([OpenSeesPy][13])

分析流程与可视化以若干收尾格给出。先做模态分析并用 `opsvis.plot_mode_shape` 展示一二阶振型，再做地震反应并用 `opsvis.plot_defo` 或 `plot_deformedshape` 在若干时间截面上显示形态与关键单元滞回；这些绘图接口与使用示例如 OpenSeesPy 文档与 opsvis 文档中所示。([OpenSeesPy][14])

为保持 Notebook 的清晰结构，请在文首集中声明并遵守以下函数与单元格组织约定。所有“部件函数”仅返回在 OpenSees 域内已创建的构件标签集合与便于记录的元数据，不做任何求解或作图；所有求解与作图仅出现在相应“分析与可视化”单元格中，以便逐段运行与复现实验。桥台函数负责创建台后回填土与基础弹簧，支座函数负责零长度双线性，剪力键函数负责三折线滞回，碰撞函数负责 ImpactMaterial 间隙，墩柱与柱端函数负责纤维截面与 Bond_SP01。以上约定与 OpenSeesPy 的命令接口一一对应，且都能在其官方文档与 OpenSees 维基中查到定义与示例。([OpenSeesPy][1])

为了减小歧义，Notebook 头部应包含一格“参数面板”，集中给出跨长、箱梁截面参数、配筋、材料强度、支座与剪力键标高与间距、台后土等效刚度与极限位移、缝宽与回弹系数、地震工况文件路径与积分步长等；其后每格函数调用均仅依赖这一参数集。FiberSection、零长度、质量、刚性连接、时间历程与记录器等命令在 OpenSeesPy 文档中的签名与本提示完全一致，建议在每处代码旁将对应文档页号或链接以注释形式写出，便于读者即时核验。([OpenSeesPy][3])

如需核对接触与间隙模型的物理含义，可参考 OpenSees 的 ImpactMaterial 说明与赫兹阻尼接触模型讨论；若研究进一步涉及回填土后峰降，则可对照近期提出的“Hyperbolic Gap Softening”模型的公开论文与会议资料，以便在具备扩展库时切换到原生实现。([OpenSeesPy][15])

以上即为用于驱动另一位 AI 在 Notebook 中逐格构建与可视化该四跨四柱式连续箱梁桥 OpenSeesPy 模型的完整提示语。将其保存为 `README.md` 后直接投喂到对方模型，即可按段落要求自动生成：域与单位初始化、几何与节点—单元网表、材料与纤维截面、柱端应变传递、基础弹簧、桥面与刚性连接、台后回填与基础、支座、剪力键、碰撞缝、整桥组装、静力与模态、地震输入与记录、以及贯穿其间的形态与滞回可视化。整个过程严格遵循 OpenSees / OpenSeesPy 的命令体系与材料定义，并对应上文给出的权威出处。

[1]: https://openseespydoc.readthedocs.io/en/latest/src/Concrete02.html?utm_source=chatgpt.com "4.14.2.2. Concrete02 — OpenSeesPy 3.5.1.3 documentation"
[2]: https://openseespydoc.readthedocs.io/en/latest/src/modelcmds.html?utm_source=chatgpt.com "4. Model Commands — OpenSeesPy 3.5.1.3 documentation"
[3]: https://openseespydoc.readthedocs.io/en/latest/src/fibersection.html?utm_source=chatgpt.com "4.16.2. Fiber Section — OpenSeesPy 3.5.1.3 documentation"
[4]: https://opensees.berkeley.edu/wiki/index.php/ZeroLength_Element?utm_source=chatgpt.com "ZeroLength Element - OpenSeesWiki"
[5]: https://opensees.berkeley.edu/OpenSees/manuals/ExamplesManual/HTML/803.htm?utm_source=chatgpt.com "ZeroLength1.tcl"
[6]: https://openseespydoc.readthedocs.io/en/stable/src/elasticBeamColumn.html?utm_source=chatgpt.com "4.2.3.1. Elastic Beam Column Element - OpenSeesPy"
[7]: https://2023.compdyn.org/proceedings/pdf/21227.pdf?utm_source=chatgpt.com "BACKFILL SYSTEMS - Compdyn 2023"
[8]: https://openseespydoc.readthedocs.io/en/stable/src/ElasticPP.html?utm_source=chatgpt.com "4.13.3.2. Elastic-Perfectly Plastic Material - OpenSeesPy"
[9]: https://opensees.berkeley.edu/OpenSees/manuals/usermanual/3188.htm?utm_source=chatgpt.com "Model to include buckling behavior of an elastomeric bearing"
[10]: https://opensees.berkeley.edu/wiki/index.php/Hysteretic_Material?utm_source=chatgpt.com "Hysteretic Material - OpenSeesWiki"
[11]: https://opensees.berkeley.edu/wiki/index.php/Impact_Material?utm_source=chatgpt.com "Impact Material - OpenSeesWiki"
[12]: https://openseespydoc.readthedocs.io/en/stable/src/ops_vis_plot_model.html?utm_source=chatgpt.com "13.2.1. plot_model (ops_vis) - OpenSeesPy - Read the Docs"
[13]: https://openseespydoc.readthedocs.io/en/latest/src/pathTs.html?utm_source=chatgpt.com "4.7.7. Path TimeSeries — OpenSeesPy 3.5.1.3 documentation"
[14]: https://openseespydoc.readthedocs.io/en/stable/src/ops_vis_plot_mode_shape.html?utm_source=chatgpt.com "13.2.3. plot_mode_shape (ops_vis) - OpenSeesPy"
[15]: https://openseespydoc.readthedocs.io/en/latest/src/ImpactMaterial.html?utm_source=chatgpt.com "4.14.5.12. Impact Material - OpenSeesPy - Read the Docs
