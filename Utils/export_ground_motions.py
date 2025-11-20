import os
import numpy as np

def export_ground_motions(GMdata, Target_GM=None, TargetPGA=None, base_dir="ground_motions"):
    """
    导出原始和缩放后的地震动数据为 TXT 文件。
    
    参数:
    - GMdata: 原始地震动数据列表（每个元素为字典）
    - Target_GM: 缩放后的地震动数据列表（可选）
    - TargetPGA: 目标 PGA（用于创建子文件夹名，可选）
    - base_dir: 基础输出目录名（默认 "ground_motions"）
    """
    # 创建原始数据文件夹
    original_dir = os.path.join(base_dir, "original_data")
    os.makedirs(original_dir, exist_ok=True)
    
    # 导出原始数据
    for record in GMdata:
        rsn = record['RSN']
        time = record['time']
        components = {
            'H1': record['GMH1'],
            'H2': record['GMH2'],
            'V3': record['GMV3']
        }
        gmnames = record['GMname']  # array of 3 filenames
        
        # 确保有三个分量名称
        if len(gmnames) < 3:
            # 如果名称不足，用默认名
            default_names = [f"RSN{rsn}_H1", f"RSN{rsn}_H2", f"RSN{rsn}_V3"]
            gmnames = (list(gmnames) + default_names[len(gmnames):])[:3]
        
        for i, (comp_key, comp_data) in enumerate(components.items()):
            # 使用 GMname 中的名称（去掉路径，只保留文件名主体）
            fname_base = gmnames[i].split('/')[-1].split('\\')[-1]  # 兼容不同系统
            # 确保文件名不包含 .AT2 等扩展名
            if fname_base.endswith('.AT2'):
                fname_base = fname_base[:-4]
            output_path = os.path.join(original_dir, f"{fname_base}.txt")
            
            # 合并时间和加速度
            data_to_save = np.column_stack((time, comp_data))
            np.savetxt(output_path, data_to_save, fmt="%.8e", delimiter="\t")
    
    print(f"原始数据已导出至: {os.path.abspath(original_dir)}")
    
    # 导出缩放数据（如果提供）
    if Target_GM is not None:
        if TargetPGA is None:
            TargetPGA = 0.5  # 默认值
        scaled_dir = os.path.join(base_dir, "scalared_data", f"PGA={TargetPGA:.3f}")
        os.makedirs(scaled_dir, exist_ok=True)
        
        for record in Target_GM:
            rsn = record['RSN']
            time = record['time']
            components = {
                'H1': record['GMH1'],
                'H2': record['GMH2'],
                'V3': record['GMV3']
            }
            gmnames = record['GMname']
            
            if len(gmnames) < 3:
                default_names = [f"RSN{rsn}_H1", f"RSN{rsn}_H2", f"RSN{rsn}_V3"]
                gmnames = (list(gmnames) + default_names[len(gmnames):])[:3]
            
            for i, (comp_key, comp_data) in enumerate(components.items()):
                fname_base = gmnames[i].split('/')[-1].split('\\')[-1]
                if fname_base.endswith('.AT2'):
                    fname_base = fname_base[:-4]
                component_dir = os.path.join(scaled_dir, comp_key)
                os.makedirs(component_dir, exist_ok=True)
                output_path = os.path.join(component_dir, f"{fname_base}.txt")
                
                data_to_save = np.column_stack((time, comp_data))
                np.savetxt(output_path, data_to_save, fmt="%.8e", delimiter="\t")
        
        print(f"缩放数据已导出至: {os.path.abspath(scaled_dir)}")

