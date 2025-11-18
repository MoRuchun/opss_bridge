# bridge_model_v1 桥梁模型建模技术说明（OpenSeesPy）

本文档基于 `bridge_model_v1.ipynb`（对应导出的 `bridge_model_v1.py`）编写，逐步说明模型中的参数设置、建模步骤和各函数的技术做法。读者只需具备 Python 和 OpenSeesPy 运行环境，即可依据本文档在任意新环境中复现相同的桥梁模型与分析流程。

本文档不讨论建模优劣，仅客观描述代码中的实现方式。

---

## 1. 环境与总体设置

### 1.1 依赖与导入

Notebook 中使用的主要依赖：

- `math`: 数学运算。
- `dataclasses.dataclass`: 定义参数配置类。
- `itertools.count`: 生成自增标签计数器。
- `typing.Dict, List, Tuple`: 类型标注。
- `numpy`: 读取地震动 TXT 文件。
- `pathlib.Path`: 处理文件路径。
- `openseespy.opensees as ops`: OpenSeesPy 求解器接口。
- `opsvis as opsv`: 可选的模型可视化（建模本身不依赖）。

在 Notebook 运行前，需要在 Python 环境中安装 OpenSeesPy，并能够

```python
import openseespy.opensees as ops
```

成功导入。

### 1.2 模型域与单位

在 Notebook 的前部代码中（导出脚本 `bridge_model_v1.py` 中大致为 119 行附近）：

```python
import openseespy.opensees as ops
import opsvis as opsv
from dataclasses import dataclass
from itertools import count
from typing import Dict, List, Tuple

PI = math.pi
G = 9.8
UBIG = 1.0e20
CONCRETE_UNIT_WEIGHT = 25_000.0  # N/m^3

ops.wipe()
ops.model('basic', '-ndm', 3, '-ndf', 6)
units = {"length": "m", "force": "N", "mass": "kg"}
```

设置说明：

- `ops.model('basic', '-ndm', 3, '-ndf', 6)`：建立一个 3 维空间、每节点 6 自由度的基本模型。
- 单位体系通过 `units` 字典给出：长度 m、力 N、质量 kg。
- `G` 为重力加速度；`CONCRETE_UNIT_WEIGHT` 为混凝土体积重，用于按截面面积计算单位长度自重。

后续所有与 `ops.*` 相关的命令都在此模型域中执行。

---

## 2. 几何与节点参数

### 2.1 全局几何参数

Notebook 在一开始定义若干全局几何与布置参数（导出脚本中约 13–27 行）：

```python
deck_width = 15          # 桥面宽度
nodes_per_span = 7       # 每跨桥面节点数量

num_spans = 3            # 跨数
span_length = 20         # 每跨跨度
cols_per_pier = 2        # 每墩柱子数量
nodes_per_col = 8        # 每柱节点数量
col_height = 8.0         # 柱高
edge_clear = 1.5         # 墩柱外排距边缘净距

abut_nodes = 8           # 桥台节点数量（备用）
```

这些参数驱动后续的节点生成函数：

- `num_spans, span_length` 控制桥长与墩位置。
- `cols_per_pier, nodes_per_col, col_height, deck_width, edge_clear` 控制墩柱数量与横向/竖向布置。
- `nodes_per_span` 控制主梁离散精度。

---

## 3. 参数类与设计配置

### 3.1 dataclass 配置

脚本中使用一组 `dataclass` 封装截面与构件设计参数：

1. `PierSectionDesign`: 墩柱截面设计参数（强度、配筋率、截面尺寸、纤维划分等）。
2. `CapBeamSectionDesign`: 盖梁截面设计参数（截面尺寸、配筋、纤维划分等）。
3. `BearingDesign`: 支座刚度与屈服力参数，以及单个墩顶的多个支座在横向 `y` 方向上的相对位置 `positions`。
4. `GirderSectionDesign`: 主梁截面弹性参数，包括面积 `A`、弹性模量 `E`、Poisson 比 `nu`、扭转惯性矩 `J`、两个主惯性矩 `Iy, Iz`、以及单位长度质量 `mass_per_length`。

代码中会创建全局默认实例：

```python
PIER_DESIGN = PierSectionDesign()
CAPBEAM_DESIGN = CapBeamSectionDesign()
BEARING_DESIGN = BearingDesign()
GIRDER_DESIGN = GirderSectionDesign()
```

在不修改这些 dataclass 默认值的前提下，模型将使用文中硬编码的参数进行截面与构件建模。

---

## 4. 节点生成函数

本节介绍所有生成节点的函数及其行为，调用顺序在后文“整体建模流程”中给出。

### 4.1 墩柱节点：`define_pier_nodes`

函数原型（简化）：

```python
def define_pier_nodes(num_spans: int,
                      span_length: float,
                      cols_per_pier: int,
                      nodes_per_col: int,
                      col_height: float,
                      deck_width: float,
                      edge_clear: float,
                      start_tag: int = 1):
    ...
    return {"pier_nodes": pier_nodes, "coords": coords, "next_tag": start_tag}
```

功能：

- 在当前 OpenSeesPy 模型中调用 `ops.node` 创建所有墩柱节点。

布置规则：

1. 桥墩沿 x 方向：
   - 一共 `num_spans - 1` 个桥墩。
   - 第 `s` 个桥墩中心的 x 坐标为 `x = (s+1)*span_length`，`s = 0, 1, ..., num_spans-2`。
2. 同一桥墩内多根墩柱沿 y 方向等距布置：
   - 有效桥面宽度 `We = deck_width - 2*edge_clear`。
   - 当 `cols_per_pier == 1` 时唯一一根柱截面中心在 `y = 0`。
   - 当 `cols_per_pier >= 2` 时，`y` 从 `-We/2` 到 `We/2` 等距布置 `cols_per_pier` 个截面中心。
3. 每根墩柱沿 z 方向等分：
   - 底部 z=0，顶部 z=col_height。
   - 共 `nodes_per_col` 个节点，z 坐标按 `k * col_height / (nodes_per_col - 1)` 线性插值。

节点创建：

- 对每个墩、每根柱、每个高度层调用

  ```python
  ops.node(tag, x, y, z)
  ```

  并记录到 `coords` 与嵌套列表 `pier_nodes` 中。

返回数据结构：

- `pier_nodes[pier_index][col_index][level_index] = nodeTag`。
- `coords[nodeTag] = (x, y, z)`。
- `next_tag`：当前使用的最后一个节点号 + 1，用于后续节点生成。

### 4.2 主梁（桥面）节点：`define_deck_nodes`

函数原型：

```python
def define_deck_nodes(num_spans: int,
                      span_length: float,
                      nodes_per_span: int,
                      col_height: float,
                      start_tag: int = 1000):
    ...
    return {"deck_nodes": deck_nodes, "coords": coords, "next_tag": start_tag}
```

功能：

- 沿桥轴线 `x` 方向生成桥面中心线上的节点，用作主梁单元的节点。

布置规则：

1. y 坐标固定为 `0.0`。
2. z 坐标固定为 `col_height`（即墩柱顶高度）。
3. 每跨生成 `nodes_per_span` 个节点，从左端到右端等距布置；为了避免跨间重复节点，从第 2 跨起不再生成左端点：

   - 第 1 跨：生成 `k = 0 .. nodes_per_span-1` 对应节点。
   - 第 s 跨（s > 0）：生成 `k = 1 .. nodes_per_span-1` 对应节点。

节点创建：

```python
ops.node(tag, x0 + k*dx, 0.0, col_height)
```

其中 `dx = span_length / (nodes_per_span - 1)`。

返回数据结构：

- `deck_nodes[span_index][local_index] = nodeTag`，跨间通过省略重复端点实现连续。
- `coords[nodeTag] = (x, y, z)`。
- `next_tag` 为下一个可用节点编号。

### 4.3 桥台节点：`define_abutment_nodes`

函数原型：

```python
def define_abutment_nodes(deck_res: list,
                          n: int,
                          total_y: float,
                          start_tag: int = 2000):
    ...
    return {"left": left_tags, "right": right_tags, "next_tag": start_tag}
```

功能：

- 在桥梁最左、最右端主梁节点处，沿 `y` 向总长 `total_y` 均匀生成 `n` 个桥台节点。

实现要点：

- 首先获取最左、最右主梁节点的 `(x,z)`：

  ```python
  left_node  = deck_res["deck_nodes"][0][0]
  right_node = deck_res["deck_nodes"][-1][-1]
  xL, _, zL = ops.nodeCoord(left_node)
  xR, _, zR = ops.nodeCoord(right_node)
  ```

- 计算 y 坐标：

  - 若 `n == 1`，则 `y = 0`。
  - 否则，`y` 从 `-total_y/2` 到 `+total_y/2` 等距布置。

- 对每个 y，在左端 `(xL, y, zL)` 和右端 `(xR, y, zR)` 处各生成一个节点。

返回：

- `"left"` 和 `"right"` 为两个列表，对应左右端桥台节点编号。

### 4.4 盖梁节点：`define_capbeam_nodes`

函数原型：

```python
def define_capbeam_nodes(pier_nodes,
                         design: CapBeamSectionDesign = CAPBEAM_DESIGN,
                         start_tag=3000):
    ...
    return {"capbeam_nodes": capbeam_nodes, "next_tag": tag}
```

功能：

- 在每个桥墩顶上方布置一条沿 `y` 向的盖梁节点链。

实现步骤：

1. 对于每个桥墩：
   - 从 `pier_nodes` 中提取每根墩柱顶节点坐标 `ops.nodeCoord(col[-1])`。
   - x 坐标取均值：`x_center = sum(x_i)/len`。
   - z 坐标取最大值并加上 `design.depth`：`z_cap = max(z_i) + design.depth`。
2. 盖梁横向布置：
   - 设 `span = design.span_width`。
   - 生成 `n_seg = design.num_elems` 个单元，则需要 `n_seg+1` 个节点。
   - y 坐标从 `-span/2` 到 `+span/2` 等距划分。
3. 对每个 y 调用：

   ```python
   ops.node(tag, x_center, y, z_cap)
   ```

返回：

- `capbeam_nodes[pier_index][i] = nodeTag` 表示第 pier 个桥墩对应盖梁上的第 i 个节点。

### 4.5 节点计数器：`init_node_counter`

```python
def init_node_counter(start_tag: int) -> Dict[str, int]:
    return {"value": int(start_tag)}
```

功能：

- 提供一个简单的可变字典 `{ "value": 当前可用节点号 }`，供后续函数统一分配新节点号。

---

## 5. 材料、截面与积分设置

### 5.1 全局标签计数器

```python
_material_counter = count(1)
_section_counter = count(1)
_integration_counter = count(1)

def next_material_tag() -> int: return next(_material_counter)
def next_section_tag() -> int: return next(_section_counter)
def next_integration_tag() -> int: return next(_integration_counter)
```

功能：

- 自动生成连续的材料号、截面号和积分号。从 1 开始递增。

### 5.2 墩柱截面：`define_pier_section`

函数负责创建墩柱纤维截面相关的材料与截面定义。

材料定义：

1. 根据 `PierSectionDesign` 计算单轴混凝土材料参数（强度、峰值应变、软化段等），分别得到：
   - 核心混凝土 `Concrete02`。
   - 保护层混凝土 `Concrete02`。
2. 钢筋材料：
   - 使用 `Hysteretic` 单轴滞回材料，定义正负向屈服与极限点。
3. 扭转刚度：
   - `Elastic` 单轴材料，用于截面 torsion。

截面定义：

- 令截面半径 `radius = 0.5 * diameter`，核心半径 `core_radius = radius - cover`。
- 计算单根钢筋面积 `bar_area = 0.25 * π * bar_diameter^2`。
- 调用：

  ```python
  ops.section('Fiber', sec_tag, '-torsion', mat_torsion)
  ops.patch('circ', mat_core,  nf_core_t,  nf_core_r,  0,0, 0,  core_radius, 0, 360)
  ops.patch('circ', mat_cover, nf_cover_t, nf_cover_r,  0,0, core_radius, radius, 0, 360)
  ops.layer('circ', mat_steel, num_bars, bar_area, 0,0, core_radius, 0, 360)
  ```

返回：

- `sec_tag`: 供后续梁单元使用。
- `mass_per_length`: 截面面积 × 单位体积重 / g。
- 混凝土与钢筋材料号等信息。

### 5.3 盖梁截面：`define_capbeam_section`

类似方式定义矩形盖梁截面：

- 根据 `CapBeamSectionDesign` 计算核心混凝土与保护层混凝土参数；
- 定义钢筋材料 `Steel02`；
- 使用 `ops.section('Fiber')` + 多个 `quad patch` 和 `layer('straight')` 进行二维纤维划分：
  - 核心混凝土 patch。
  - 上下、左右保护层 patch。
  - 上、下、中部钢筋直线分布。

返回：

- `sec_tag`、`mass_per_length`、钢筋材料号等。

### 5.4 其他材料：`define_misc_materials`

```python
def define_misc_materials() -> Dict[str, int]:
    soil = next_material_tag()
    deck_abut = next_material_tag()
    shear_key = next_material_tag()
    ops.uniaxialMaterial('ElasticPPGap', soil,      5.0e4, -5000.0, -0.03)
    ops.uniaxialMaterial('ElasticPPGap', deck_abut, 1.0e7, -1.0e8, -0.05)
    ops.uniaxialMaterial('ElasticPPGap', shear_key, 2.0e8,  6.0e5,  0.02)
    return {"soil": soil, "deck_abut": deck_abut, "shear_key": shear_key}
```

用途：

- 这些材料将用于零长度弹簧元素，模拟桥台-地基、桥梁-桥台之间的接触和剪力键。

---

## 6. 单元生成与连接函数

### 6.1 墩柱单元：`build_pier_elements_nonlin`

函数原型：

```python
def build_pier_elements_nonlin(pier_nodes: list,
                               secTag: int,
                               ele_tag_start: int = 1,
                               np: int = 5,
                               mass_per_length: float | None = None):
    ...
    return eTags
```

步骤：

1. 定义几何变换与积分：

   ```python
   trans_tag = 1
   ops.geomTransf('Linear', trans_tag, 0.0, 1.0, 0.0)
   integ_tag = next_integration_tag()
   ops.beamIntegration('Lobatto', integ_tag, secTag, np)
   ```

2. 循环遍历 `pier_nodes[pier][col]` 中相邻的节点对 `(ni, nj)`：
   - 构造参数列表 `['forceBeamColumn', eTag, ni, nj, trans_tag, integ_tag]`。
   - 若 `mass_per_length` 不为空，附加 `'-mass', mass_per_length`。
   - 调用 `ops.element(*args)` 创建单元。

3. 将所有生成的单元号收集到 `eTags` 列表返回。

### 6.2 主梁单元：`build_beam_elements_elastic`

函数原型：

```python
def build_beam_elements_elastic(deck_nodes: list,
                                A: float, E: float, G: float,
                                J: float, Iy: float, Iz: float,
                                ele_tag_start: int = 1000,
                                mass_per_length: float | None = None):
    ...
    return eTags
```

步骤：

1. 几何变换：

   ```python
   trans_tag = 3
   ops.geomTransf('Linear', trans_tag, 0.0, 0.0, 1.0)
   ```

2. 将所有跨的 `deck_nodes` 串接成一个节点链 `chain`。
3. 对 `chain[i], chain[i+1]` 构造 `elasticBeamColumn` 单元：

   ```python
   args = ['elasticBeamColumn', eTag, ni, nj, A, E, G, J, Iy, Iz, trans_tag]
   if mass_per_length is not None:
       args += ['-mass', mass_per_length]
   ops.element(*args)
   ```

4. 返回所有单元号。

### 6.3 盖梁单元：`build_capbeam_elements`

函数原型：

```python
def build_capbeam_elements(capbeam_nodes: List[List[int]],
                           secTag: int,
                           mass_per_length: float,
                           ele_tag_start: int = 4000,
                           np: int = 5):
    ...
    return eTags
```

步骤：

1. 定义变换和积分：

   ```python
   trans_tag = 4
   ops.geomTransf('Linear', trans_tag, 0.0, 0.0, 1.0)
   integ_tag = next_integration_tag()
   ops.beamIntegration('Lobatto', integ_tag, secTag, np)
   ```

2. 对每个 `pier` 的盖梁节点链 `pier_nodes`，遍历相邻节点对 `(ni, nj)`：

   ```python
   ops.element('forceBeamColumn', eTag, ni, nj, trans_tag, integ_tag,
               '-mass', mass_per_length)
   ```

3. 返回所有盖梁单元号。

### 6.4 墩顶与盖梁连接：`tie_piers_to_cap_nodes`

函数原型：

```python
def tie_piers_to_cap_nodes(pier_nodes: List[List[List[int]]],
                           capbeam_nodes: List[List[int]]):
    ...
```

步骤：

1. 对每个桥墩及其对应的盖梁节点列表 `cap_nodes`：
   - 使用 `cap_coords = {tag: ops.nodeCoord(tag)[1] for tag in cap_nodes}` 记录 y 坐标。
2. 对该墩的每根柱：
   - 取柱顶节点 `top_node = column[-1]`，得到 `y_top`。
   - 在 `cap_nodes` 中查找 y 坐标最接近 `y_top` 的盖梁节点 `cap_target`。
   - 调用

     ```python
     ops.equalDOF(cap_target, top_node, 1, 2, 3, 4, 5, 6)
     ```

   - 将墩顶所有自由度与盖梁对应节点约束相等。

### 6.5 基础弹簧材料：`create_foundation_materials`

```python
def create_foundation_materials(k_trans, k_rot) -> Tuple[int, ...]:
    mats = [next_material_tag() for _ in range(6)]
    ops.uniaxialMaterial('Elastic', mats[0], k_trans[0])
    ops.uniaxialMaterial('Elastic', mats[1], k_trans[1])
    ops.uniaxialMaterial('Elastic', mats[2], k_trans[2])
    ops.uniaxialMaterial('Elastic', mats[3], k_rot[0])
    ops.uniaxialMaterial('Elastic', mats[4], k_rot[1])
    ops.uniaxialMaterial('Elastic', mats[5], k_rot[2])
    return tuple(mats)
```

接收：

- `k_trans`：长度为 3 的平移刚度元组。
- `k_rot`：长度为 3 的转动刚度元组。

返回值为 6 个材料号，对应 6 个自由度的弹簧。

### 6.6 基础弹簧元素：`set_foundation_linear_springs_min`

函数原型：

```python
def set_foundation_linear_springs_min(
    pier_nodes,
    mat_tags: Tuple[int, ...],
    ele_tag_base: int,
    node_counter: Dict[str, int]
):
    ...
    return results
```

步骤：

1. 初始化 `ele_tag = ele_tag_base`。
2. 定义获取新节点的内部函数 `_next_node_tag()`，从 `node_counter["value"]` 中取号并自增。
3. 遍历所有墩、所有柱底节点 `base_node = col_nodes[0]`：
   - 获取底节点坐标 `(x, y, z) = ops.nodeCoord(base_node)`。
   - 新建弹簧节点 `spring_node`：

     ```python
     spring_node = _next_node_tag()
     ops.node(spring_node, x, y, z)
     ops.equalDOF(spring_node, base_node, 1, 2, 3, 4, 5, 6)
     ```

   - 新建地基刚结节点 `ground_node`：

     ```python
     ground_node = _next_node_tag()
     ops.node(ground_node, x, y, z)
     ops.fix(ground_node, 1, 1, 1, 1, 1, 1)
     ```

   - 在 `spring_node` 和 `ground_node` 之间创建零长度弹簧单元：

     ```python
     ops.element('zeroLength', ele_tag, spring_node, ground_node,
                 '-mat', *mat_tags,
                 '-dir', 1, 2, 3, 4, 5, 6)
     ```

4. 将 `spring_nodes`、`ground_nodes` 和 `elements` 收集到返回字典中。

### 6.7 支座材料：`define_bearing_materials`

```python
def define_bearing_materials(design: BearingDesign = BEARING_DESIGN) -> Tuple[int, int, int, int]:
    mat_fx = next_material_tag()
    mat_fy = next_material_tag()
    mat_fz = next_material_tag()
    mat_rot = next_material_tag()
    ops.uniaxialMaterial('Steel01', mat_fx, design.bfy, design.bkh1, 0.0)
    ops.uniaxialMaterial('Steel01', mat_fy, design.bfy, design.bkh2, 0.0)
    ops.uniaxialMaterial('Elastic', mat_fz, design.bkh3)
    ops.uniaxialMaterial('Elastic', mat_rot, design.rot_stiff)
    return mat_fx, mat_fy, mat_fz, mat_rot
```

解释：

- 给水平向、竖向和平面内转动方向定义单轴材料，作为支座 zeroLength 元素的基础。

### 6.8 支座元素：`build_bearings`

函数原型：

```python
def build_bearings(deck_nodes,
                   capbeam_nodes,
                   node_counter: Dict[str, int],
                   design: BearingDesign = BEARING_DESIGN,
                   ele_tag_start: int = 6000):
    ...
    return {
        "bearing_eles": bearing_elements,
        "pairs": bearing_pairs,
        "mat_tags": (mat_fx, mat_fy, mat_fz, mat_rot)
    }
```

步骤概要：

1. 调用 `define_bearing_materials` 获取 4 个材料号。
2. 展平所有主梁节点 `deck_tags`，记录其 x 坐标：

   ```python
   deck_x = {dn: ops.nodeCoord(dn)[0] for dn in deck_tags}
   ```

3. 定义 `_nearest_deck_node(x_target)`：在 `deck_tags` 中找 x 坐标最接近目标值的主梁节点。
4. 遍历每一个盖梁节点链 `pier_cap_nodes`：
   - 使用 `cap_coords = {tag: ops.nodeCoord(tag) for tag in pier_cap_nodes}` 记录盖梁节点的完整坐标 `(x,y,z)`。
   - 以该链第一个节点的 x 作为 `x_center`。
   - 查找最近的主梁节点 `deck_master = _nearest_deck_node(x_center)`。
5. 对每个支座横向位置 `y_offset`：
   - 使用 `_next_node_tag()` 从 `node_counter` 获取新的 `top_node` 标签。
   - 在盖梁节点中按照 y 坐标最接近原则确定 `cap_target`：

     ```python
     cap_target = min(pier_cap_nodes, key=lambda tag: abs(cap_coords[tag][1] - y_offset))
     _, _, z_cap = cap_coords[cap_target]
     ops.node(top_node, x_center, y_offset, z_cap)
     ```

   - 用刚性连接把主梁节点与支座上节点连接：

     ```python
     ops.rigidLink('beam', deck_master, top_node)
     ```

   - 在 `top_node` 与 `cap_target` 之间创建零长度支座元素：

     ```python
     ops.element(
         'zeroLength', ele, top_node, cap_target,
         '-mat', mat_fx, mat_fy, mat_fz, mat_rot, mat_rot, mat_rot,
         '-dir', 1, 2, 3, 4, 5, 6
     )
     ```

6. 所有支座单元号保存在 `bearing_eles` 中；每个支座一对节点 `(top_node, cap_target)` 记录在 `pairs` 中。

### 6.9 桥台与土弹簧/碰撞/剪力键：`set_abutment`

函数原型：

```python
def set_abutment(
    deck_nodes,
    start_node_tag,
    start_ele_tag,
    ssi_mat_tags, ssi_dirs,          # 桥台-地基：土弹簧
    bearing_mat_tags, bearing_dirs,  # 主梁-桥台：支座
    contact_mat_tags, contact_dirs,  # 主梁-桥台：碰撞/限位
    shearkey_mat_tags, shearkey_dirs,# 主梁-桥台：剪力键
    x_tol=1e-9
):
    ...
    return res
```

功能：

- 在主梁两端生成桥台与地基节点，并在其间、以及桥台与主梁之间布置一系列零长度元素模拟土弹簧、支座、碰撞与剪力键。

步骤概要：

1. 从 `deck_nodes` 展平所有主梁节点 `tags`，记录每个节点坐标 `xyz[n] = ops.nodeCoord(n)`。
2. 识别端部主梁节点：
   - 左端：x 最小，y 绝对值最小的节点。
   - 右端：x 最大，y 绝对值最小的节点。
3. 初始化节点号与单元号：
   - `tnode = start_node_tag`
   - `tele  = start_ele_tag`
4. 对左右两侧分别执行：
   - 读取端部节点坐标 `(x, y, z)`。
   - 创建桥台节点 `abut` 与地基节点 `base`：

     ```python
     ops.node(abut, x, y, z)
     ops.node(base, x, y, z)
     ops.fix(base, 1, 1, 1, 1, 1, 1)
     ```

   - 桥台-地基土弹簧：

     ```python
     ops.element('zeroLength', tele, abut, base,
                 '-mat', *ssi_mat_tags, '-dir', *ssi_dirs)
     ```

   - 主梁-桥台支座（多个方向）：

     ```python
     ops.element('zeroLength', tele, dn, abut,
                 '-mat', *bearing_mat_tags, '-dir', *bearing_dirs)
     ```

   - 主梁-桥台碰撞/限位：

     ```python
     ops.element('zeroLength', tele, dn, abut,
                 '-mat', *contact_mat_tags, '-dir', *contact_dirs)
     ```

   - 剪力键：

     ```python
     ops.element('zeroLength', tele, dn, abut,
                 '-mat', *shearkey_mat_tags, '-dir', *shearkey_dirs)
     ```

5. 记录桥台节点和地基节点到返回字典中。
6. 在外部会对桥台节点追加约束：

   ```python
   for abut_tag in abutment_res["abutment_nodes"].values():
       ops.fix(abut_tag, 0, 0, 0, 1, 1, 1)
   ```

   即桥台顶仅锁定 3 个转动，自由平动。

---

## 7. 重力分析与阻尼设置

### 7.1 重力荷载：`apply_uniform_gravity_loads`

函数原型：

```python
def apply_uniform_gravity_loads(pier_elements: List[int],
                                cap_elements: List[int],
                                girder_elements: List[int],
                                pier_weight: float,
                                cap_weight: float,
                                girder_weight: float,
                                ts_tag: int = 1,
                                pat_tag: int = 1):
    ...
    return status
```

步骤：

1. 先清理分析状态：

   ```python
   ops.wipeAnalysis()
   ops.timeSeries('Linear', ts_tag)
   ops.pattern('Plain', pat_tag, ts_tag)
   ```

2. 对传入的构件单元列表逐一调用 `eleLoad`：

   - 墩柱：

     ```python
     ops.eleLoad('-ele', e, '-type', '-beamUniform',
                 0.0, 0.0, -pier_weight)
     ```

   - 盖梁与主梁的方向类似，数值由调用方根据 `mass_per_length * G` 提供。

3. 设置静力分析：

   ```python
   ops.constraints("Transformation")
   ops.numberer("RCM")
   ops.system("BandGeneral")
   ops.test("NormDispIncr", 1.0e-6, 50)
   ops.algorithm("Newton")
   ops.integrator("LoadControl", 0.1)
   ops.analysis("Static")
   status = ops.analyze(10)
   ops.loadConst('-time', 0.0)
   ```

4. 返回 `status` 以供调用处检查是否收敛。

### 7.2 特征周期与 Rayleigh 阻尼

辅助函数：

```python
def get_periods(nMode=3):
    ops.wipeAnalysis()
    ops.system('BandGeneral')
    ops.numberer('RCM')
    ops.constraints('Transformation')
    lambdas = ops.eigen(nMode)
    ...
    return periods
```

和：

```python
def configure_default_rayleigh(xi=0.05, nMode=6):
    Ts = get_periods(nMode)
    valid_T = [T for T in Ts if (T is not None) and (T > 0.0)]
    T1, T2 = valid_T[0], valid_T[1]
    w1 = 2.0 * math.pi / T1
    w2 = 2.0 * math.pi / T2
    alphaM = 2.0 * xi * w1 * w2 / (w1 + w2)
    betaK  = 2.0 * xi / (w1 + w2)
    ops.rayleigh(alphaM, 0.0, betaK, 0.0)
    return {"periods": Ts, "alphaM": alphaM, "betaK": betaK}
```

说明：

- `get_periods` 获取前 `nMode` 个特征值并转换为圆频率，再计算周期，过滤掉无效项。
- `configure_default_rayleigh` 使用前两个有效周期 `T1, T2` 与目标阻尼比 `xi` 计算 Rayleigh 阻尼参数，并调用 `ops.rayleigh` 生效。

---

## 8. 模型整体重建函数：`rebuild_model_with_gravity`

函数原型：

```python
def rebuild_model_with_gravity():
    """重建整个桥梁模型并完成重力分析，返回关键节点/单元信息。"""
    ...
    return {...}
```

此函数负责在每次分析前重新构建模型并完成重力计算，其步骤如下：

1. 清空模型并重新建立域：

   ```python
   ops.wipe()
   ops.model('basic', '-ndm', 3, '-ndf', 6)
   units = {"length": "m", "force": "N", "mass": "kg"}
   ```

2. 调用节点生成函数：

   ```python
   pier_res = define_pier_nodes(num_spans, span_length,
                                cols_per_pier, nodes_per_col,
                                col_height, deck_width, edge_clear)

   deck_res = define_deck_nodes(num_spans, span_length,
                                nodes_per_span, col_height)

   capbeam_res = define_capbeam_nodes(pier_res["pier_nodes"])
   node_counter = init_node_counter(capbeam_res["next_tag"])
   ```

3. 定义截面与材料：

   ```python
   pier_section = define_pier_section()
   cap_section = define_capbeam_section()
   misc_mats = define_misc_materials()
   ```

4. 创建结构构件单元：

   - 墩柱单元：

     ```python
     pier_ele = build_pier_elements_nonlin(
         pier_nodes=pier_res["pier_nodes"],
         secTag=pier_section["sec_tag"],
         ele_tag_start=1,
         np=10,
         mass_per_length=pier_section["mass_per_length"]
     )
     ```

   - 主梁单元：

     ```python
     girder_G = GIRDER_DESIGN.E / (2.0 * (1.0 + GIRDER_DESIGN.nu))
     beam_ele = build_beam_elements_elastic(
         deck_nodes=deck_res["deck_nodes"],
         A=GIRDER_DESIGN.A,
         E=GIRDER_DESIGN.E,
         G=girder_G,
         J=GIRDER_DESIGN.J,
         Iy=GIRDER_DESIGN.Iy,
         Iz=GIRDER_DESIGN.Iz,
         ele_tag_start=1000,
         mass_per_length=GIRDER_DESIGN.mass_per_length
     )
     ```

   - 盖梁单元：

     ```python
     cap_ele = build_capbeam_elements(
         capbeam_nodes=capbeam_res["capbeam_nodes"],
         secTag=cap_section["sec_tag"],
         mass_per_length=cap_section["mass_per_length"],
         ele_tag_start=2000
     )
     ```

5. 连接墩顶与盖梁：

   ```python
   tie_piers_to_cap_nodes(pier_res["pier_nodes"], capbeam_res["capbeam_nodes"])
   ```

6. 设置基础弹簧：

   ```python
   k_trans = (4.21875e7, 2.109375e7, 7.5e9)
   k_rot   = (4.5e8,    2.25e8,    1.2e8)
   foundation_mats = create_foundation_materials(k_trans, k_rot)
   foundation_res = set_foundation_linear_springs_min(
       pier_nodes=pier_res["pier_nodes"],
       mat_tags=foundation_mats,
       ele_tag_base=1500,
       node_counter=node_counter
   )
   ```

7. 设置支座：

   ```python
   bear_res = build_bearings(
       deck_res["deck_nodes"],
       capbeam_res["capbeam_nodes"],
       node_counter
   )
   ```

8. 设置桥台及其弹簧/碰撞/剪力键：

   ```python
   abutment_res = set_abutment(
       deck_nodes=deck_res["deck_nodes"],
       start_node_tag=node_counter["value"],
       start_ele_tag=8000,
       ssi_mat_tags=(misc_mats["soil"],),        ssi_dirs=(1,),
       bearing_mat_tags=bear_res["mat_tags"][:3],bearing_dirs=(1, 2, 3),
       contact_mat_tags=(misc_mats["deck_abut"],), contact_dirs=(1,),
       shearkey_mat_tags=(misc_mats["shear_key"],),shearkey_dirs=(2,),
       x_tol=1e-9
   )

   for abut_tag in abutment_res["abutment_nodes"].values():
       ops.fix(abut_tag, 0, 0, 0, 1, 1, 1)
   ```

9. 计算各构件单位长度自重：

   ```python
   pier_weight   = pier_section["mass_per_length"] * G
   cap_weight    = cap_section["mass_per_length"] * G
   girder_weight = GIRDER_DESIGN.mass_per_length * G
   ```

10. 调用重力分析函数：

    ```python
    status = apply_uniform_gravity_loads(
        pier_ele, cap_ele, beam_ele,
        pier_weight, cap_weight, girder_weight
    )
    if status != 0:
        raise RuntimeError('重力分析失败')
    ```

11. 计算并施加 Rayleigh 阻尼：

    ```python
    damping_info = configure_default_rayleigh()
    ```

12. 返回各部分的构造结果：

    ```python
    return {
        "pier_res": pier_res,
        "deck_res": deck_res,
        "capbeam_res": capbeam_res,
        "bear_res": bear_res,
        "cap_ele": cap_ele,
        "foundation": foundation_res,
        "abutment_res": abutment_res,
        "pier_ele": pier_ele,
        "beam_ele": beam_ele,
        "units": units,
        "damping": damping_info
    }
    ```

---

## 9. 地震动输入与时程分析

### 9.1 地震动读取与加载：`apply_uniform_gm_from_txt`

函数原型：

```python
def apply_uniform_gm_from_txt(file_path, ts_tag=200, pattern_tag=200,
                              dof=1, factor=9.8):
    ...
    return {"time": t, "acc": acc, "tFinal": tFinal}
```

步骤：

1. 使用 `np.loadtxt(file_path)` 读取 TXT 文件，假定：
   - 第 1 列为时间 `t`（单位：秒）。
   - 第 2 列为加速度 `acc`（单位：g 或 m/s²，视数据而定）。
2. 将时间与加速度转为 `np.array` 并按 `factor` 放大加速度：

   ```python
   t = np.array(data[:, 0], dtype=float)
   acc = np.array(data[:, 1], dtype=float) * float(factor)
   ```

3. 将时间轴平移到从 0 开始：

   ```python
   if t[0] != 0.0:
       t = t - t[0]
   ```

4. 计算地震总时长 `tFinal = float(t[-1])`。
5. 创建时间序列与荷载模式：

   ```python
   ops.timeSeries('Path', ts_tag,
                  '-time', *t.tolist(),
                  '-values', *acc.tolist())
   ops.pattern('UniformExcitation', pattern_tag, dof,
               '-accel', ts_tag)
   ```

6. 返回时间向量、加速度向量和末端时间。

### 9.2 记录器布置：`setup_default_recorders`

函数原型：

```python
def setup_default_recorders(output_dir, pier_res, bear_res, abutment_res):
    ...
```

目标：

- 在指定输出目录 `output_dir` 下创建一批记录文件，记录关键位置的位移与支座变形。

步骤：

1. 创建输出目录：

   ```python
   output_dir = Path(output_dir)
   output_dir.mkdir(parents=True, exist_ok=True)
   ```

2. 选择需要记录的节点：

   - 墩顶节点：

     ```python
     pier_nodes_to_rec = [
         pier_res["pier_nodes"][i][j][-1]
         for i in range(len(pier_res["pier_nodes"]))
         for j in range(len(pier_res["pier_nodes"][i]))
     ]
     ```

   - 支座上下节点：

     ```python
     bearing_deck_nodes = [pair[0] for pair in bear_res["pairs"]]
     bearing_cap_nodes  = [pair[1] for pair in bear_res["pairs"]]
     ```

   - 桥台节点：

     ```python
     abutment_nodes_to_rec = [
         abutment_res["abutment_nodes"]["left"],
         abutment_res["abutment_nodes"]["right"]
     ]
     ```

3. 支座单元：

   ```python
   bearing_eles = bear_res["bearing_eles"]
   ```

4. 移除已有记录器并重新设置：

   ```python
   ops.remove('recorders')

   ops.recorder('Node',
                '-file', str(output_dir / 'rec_pier_top_disp.out'),
                '-time',
                '-node', *pier_nodes_to_rec,
                '-dof', 1, 2, 3,
                'disp')

   ops.recorder('Node',
                '-file', str(output_dir / 'rec_bearing_cap_disp.out'),
                '-time',
                '-node', *bearing_cap_nodes,
                '-dof', 1, 2, 3,
                'disp')

   ops.recorder('Node',
                '-file', str(output_dir / 'rec_bearing_deck_disp.out'),
                '-time',
                '-node', *bearing_deck_nodes,
                '-dof', 1, 2, 3,
                'disp')

   ops.recorder('Element',
                '-file', str(output_dir / 'rec_bearing_def.out'),
                '-time',
                '-ele', *bearing_eles,
                'deformations')

   ops.recorder('Node',
                '-file', str(output_dir / 'rec_abutment_disp.out'),
                '-time',
                '-node', *abutment_nodes_to_rec,
                '-dof', 1, 2, 3,
                'disp')
   ```

### 9.3 批量时程分析：`run_ground_motion_batch`

函数原型：

```python
def run_ground_motion_batch(gm_folder, results_root=Path('results'),
                            dof=1, factor=9.8):
    ...
    return summary
```

主要功能：

- 对 `gm_folder` 目录下所有 `.txt` 地震动文件逐一进行：
  1. 重建模型并完成重力分析。
  2. 加载地震动并设置记录器。
  3. 进行瞬态时程分析。
  4. 将各地震的结果和运行状态记录下来。

步骤概要：

1. 路径与结果目录准备：

   ```python
   gm_folder = Path(gm_folder)
   results_root = Path(results_root)

   # 清空结果目录
   for item in results_root.iterdir():
       if item.is_file():
           item.unlink()
       elif item.is_dir():
           shutil.rmtree(item)
   results_root.mkdir(parents=True, exist_ok=True)
   ```

2. 构建地震文件列表：

   ```python
   gm_files = sorted(gm_folder.glob('*.txt'))
   summary = []
   ```

3. 遍历每个地震文件：

   ```python
   for idx, gm_file in enumerate(gm_files, start=1):
       gm_tag = 2000 + idx
       run_info = {
           'gm_name': gm_file.name,
           'status': 'pending',
           'steps_completed': 0,
           'message': ''
       }
       try:
           model_ctx = rebuild_model_with_gravity()
           gm_info = apply_uniform_gm_from_txt(
               str(gm_file),
               ts_tag=gm_tag,
               pattern_tag=gm_tag,
               dof=dof,
               factor=factor
           )
           out_dir = results_root / gm_file.stem
           setup_default_recorders(
               out_dir,
               model_ctx['pier_res'],
               model_ctx['bear_res'],
               model_ctx['abutment_res']
           )
           ...
       except Exception as exc:
           run_info['status'] = 'error'
           run_info['message'] = str(exc)
       finally:
           try:
               ops.remove('recorders')
               ops.remove('loadPattern', gm_tag)
               ops.remove('timeSeries', gm_tag)
           except Exception:
               pass
       summary.append(run_info)
   ```

4. 瞬态分析设置：

   ```python
   ops.wipeAnalysis()
   ops.constraints('Transformation')
   ops.numberer('RCM')
   ops.system('BandGeneral')

   ops.test('NormDispIncr', 1.0e-4, 50)
   ops.algorithm('NewtonLineSearch', '-type', 'Bisection')
   ops.integrator('Newmark', 0.5, 0.25)
   ops.analysis('Transient')
   ```

5. 时间步控制：

   ```python
   tFinal = gm_info['tFinal']
   base_dt = 0.002
   dt_min  = 0.00025
   t_now   = 0.0
   step_ok = 0
   ok      = 0

   while t_now < tFinal:
       ok = ops.analyze(1, base_dt)
       if ok == 0:
           t_now += base_dt
           step_ok += 1
           continue

       dt_try = base_dt / 2.0
       retry_ok = 0
       while dt_try >= dt_min:
           retry_ok = ops.analyze(1, dt_try)
           if retry_ok == 0:
               t_now += dt_try
               step_ok += 1
               break
           dt_try /= 2.0

       if retry_ok != 0:
           ok = -3
           break
   ```

6. 分析结束后写出汇总文件：

   ```python
   summary_file = results_root / 'batch_summary.csv'
   with summary_file.open('w', newline='', encoding='utf-8') as f:
       writer = csv.DictWriter(
           f,
           fieldnames=['gm_name', 'status', 'steps_completed', 'message']
       )
       writer.writeheader()
       writer.writerows(summary)
   ```

7. 脚本底部直接给出默认调用方式：

   ```python
   GM_DIR = Path(r"../GM_process/ground_motions/scalared_data/test")
   RESULT_ROOT = Path('results')
   RESULT_ROOT.mkdir(exist_ok=True)
   batch_summary = run_ground_motion_batch(GM_DIR, RESULT_ROOT, dof=1, factor=9.8)
   print('Batch summary写入:', RESULT_ROOT / 'batch_summary.csv')
   ```

调用者可以根据需要修改 `GM_DIR` 与 `RESULT_ROOT` 的路径。

---

## 10. 复现本模型的步骤总览

在一个新环境中复现 `bridge_model_v1.ipynb` 的模型与分析，建议按照如下顺序执行代码单元或调用同名函数：

1. 导入依赖：`math`, `numpy`, `pathlib.Path`, `openseespy.opensees as ops` 等。
2. 设置全局几何参数及常数：跨数、跨长、桥面宽度、墩柱数量与高度等。
3. 定义 `dataclass` 参数类，并创建默认实例 `PIER_DESIGN`, `CAPBEAM_DESIGN`, `BEARING_DESIGN`, `GIRDER_DESIGN`。
4. 通过 `ops.wipe()` 和 `ops.model('basic', '-ndm', 3, '-ndf', 6)` 创建 3D、6 自由度模型域。
5. 定义所有节点生成函数：`define_pier_nodes`, `define_deck_nodes`, `define_abutment_nodes`, `define_capbeam_nodes`, `init_node_counter`。
6. 定义材料与截面函数：全局计数器、`define_pier_section`, `define_capbeam_section`, `define_misc_materials`。
7. 定义单元生成和连接函数：`build_pier_elements_nonlin`, `build_beam_elements_elastic`, `build_capbeam_elements`, `tie_piers_to_cap_nodes`, `create_foundation_materials`, `set_foundation_linear_springs_min`, `define_bearing_materials`, `build_bearings`, `set_abutment`。
8. 定义重力与阻尼函数：`apply_uniform_gravity_loads`, `get_periods`, `configure_default_rayleigh`。
9. 定义整体建模函数：`rebuild_model_with_gravity`。
10. 定义地震动输入与记录函数：`apply_uniform_gm_from_txt`, `setup_default_recorders`。
11. 定义批量分析函数：`run_ground_motion_batch`。
12. 准备地震动 TXT 文件目录，调用 `run_ground_motion_batch`，分析结束后在结果目录和 `batch_summary.csv` 中查看响应与状态。

按照上述顺序实现和调用，即可在任何配置了 OpenSeesPy 的 Python 环境中完整复现 `bridge_model_v1.ipynb` 的建模与分析流程。

