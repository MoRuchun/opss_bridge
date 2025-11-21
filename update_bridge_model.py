import json
from pathlib import Path

notebook_path = r"c:\Users\Administrator\Nutstore\1\我的坚果云\代码\活动\OpenSeespy\bridges\bridge_model_v1.ipynb"

with open(notebook_path, 'r', encoding='utf-8') as f:
    nb = json.load(f)

# Find the cell with run_ground_motion_batch
target_cell = None
for cell in nb['cells']:
    if cell['cell_type'] == 'code' and 'def run_ground_motion_batch' in "".join(cell['source']):
        target_cell = cell
        break

if target_cell:
    new_source = r"""import csv
import shutil
def run_ground_motion_batch(gm_root, results_root=Path('results'), factor=9.8):
    gm_root = Path(gm_root)
    results_root = Path(results_root)

    # 清空结果目录
    if results_root.exists():
        for item in results_root.iterdir():
            if item.is_file():
                item.unlink()
            elif item.is_dir():
                shutil.rmtree(item)
    results_root.mkdir(parents=True, exist_ok=True)

    pga_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    summary = []

    for pga in pga_values:
        pga_folder_name = f"PGA_{pga:.2f}g"
        pga_path = gm_root / pga_folder_name
        if not pga_path.exists():
            print(f"警告: 找不到 {pga_folder_name} 文件夹，跳过。")
            continue
            
        h1_folder = pga_path / "H1"
        h2_folder = pga_path / "H2"
        
        h1_files = sorted(h1_folder.glob('*.txt'))
        h2_files = sorted(h2_folder.glob('*.txt'))
        
        if len(h1_files) != len(h2_files):
            print(f"警告: {pga_folder_name} 中 H1 和 H2 文件数量不匹配 ({len(h1_files)} vs {len(h2_files)})")
            
        # 创建 PGA 结果子目录
        pga_result_dir = results_root / pga_folder_name
        pga_result_dir.mkdir(parents=True, exist_ok=True)

        for idx, (h1_file, h2_file) in enumerate(zip(h1_files, h2_files), start=1):
            # 使用 H1 文件名作为记录名 (去除 .txt)
            record_name = h1_file.stem
            print(f"[{pga_folder_name}] [{idx}/{len(h1_files)}] 处理 {record_name}")
            
            gm_tag_h1 = 2000 + idx * 2
            gm_tag_h2 = 2000 + idx * 2 + 1
            
            run_info = {
                'pga': pga,
                'record_name': record_name,
                'status': 'pending',
                'steps_completed': 0,
                'message': ''
            }

            try:
                model_ctx = rebuild_model_with_gravity()
                
                # 应用 H1 到 DOF 1 (X方向)
                gm_info_h1 = apply_uniform_gm_from_txt(
                    str(h1_file),
                    ts_tag=gm_tag_h1,
                    pattern_tag=gm_tag_h1,
                    dof=1,
                    factor=factor
                )
                
                # 应用 H2 到 DOF 2 (Y方向)
                gm_info_h2 = apply_uniform_gm_from_txt(
                    str(h2_file),
                    ts_tag=gm_tag_h2,
                    pattern_tag=gm_tag_h2,
                    dof=2,
                    factor=factor
                )

                out_dir = pga_result_dir / record_name
                setup_default_recorders(
                    out_dir,
                    model_ctx['pier_res'],
                    model_ctx['bear_res'],
                    model_ctx['abutment_res']
                )

                ops.wipeAnalysis()
                ops.constraints('Transformation')
                ops.numberer('RCM')
                ops.system('BandGeneral')

                # 全局收敛标准稍微放宽一点，给非线性留点空间
                ops.test('NormDispIncr', 1.0e-4, 50)
                ops.algorithm('NewtonLineSearch', '-type', 'Bisection')
                ops.integrator('Newmark', 0.5, 0.25)
                ops.analysis('Transient')

                # 使用两个地震波中较长的时间
                tFinal = max(gm_info_h1['tFinal'], gm_info_h2['tFinal'])
                base_dt = 0.002      # 你原来的时间步
                dt_min  = 0.00025    # 最小允许时间步
                t_now   = 0.0
                step_ok = 0
                ok      = 0

                while t_now < tFinal:
                    ok = ops.analyze(1, base_dt)
                    if ok == 0:
                        # 正常通过这一小步
                        t_now += base_dt
                        step_ok += 1
                        continue

                    # 如果这一小步不收敛，自动把步长减半重试
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
                        # 缩到 dt_min 还是过不去，就认为在这一时刻结构已经
                        # 深入到求解器控制不了的状态，提前退出
                        ok = -3
                        break
                
                if ok == 0:
                    run_info['status'] = 'success'
                    run_info['steps_completed'] = step_ok
                else:
                    run_info['status'] = 'failed'
                    run_info['message'] = f'Analysis failed at t={t_now:.3f}'


            except Exception as exc:
                run_info['status'] = 'error'
                run_info['message'] = str(exc)

            finally:
                # 统一清理，不管成功还是异常
                try:
                    ops.remove('recorders')
                    ops.remove('loadPattern', gm_tag_h1)
                    ops.remove('timeSeries', gm_tag_h1)
                    ops.remove('loadPattern', gm_tag_h2)
                    ops.remove('timeSeries', gm_tag_h2)
                except Exception:
                    pass

            summary.append(run_info)

    summary_file = results_root / 'batch_summary.csv'
    with summary_file.open('w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(
            f,
            fieldnames=['pga', 'record_name', 'status', 'steps_completed', 'message']
        )
        writer.writeheader()
        writer.writerows(summary)

    return summary


GM_DIR = Path("GM/ground_motions/processed")
RESULT_ROOT = Path('results')
batch_summary = run_ground_motion_batch(GM_DIR, RESULT_ROOT, factor=9.8)
print('Batch summary写入:', RESULT_ROOT / 'batch_summary.csv')"""
    
    # Split into lines for JSON format
    target_cell['source'] = new_source.splitlines(keepends=True)
    
    with open(notebook_path, 'w', encoding='utf-8') as f:
        json.dump(nb, f, indent=1)
    print("Successfully updated the notebook.")
else:
    print("Could not find the target cell.")
