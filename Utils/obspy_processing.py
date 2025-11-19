# -*- coding: utf-8 -*-
"""
使用 ObsPy 进行地震波预处理
包括：基线校正、滤波去噪、重采样、反应谱计算、波形绘制等功能

@author: Enhanced with ObsPy
"""
import numpy as np
import matplotlib.pyplot as plt
from obspy.core.trace import Trace
from obspy.core.stream import Stream
from scipy.integrate import cumulative_trapezoid
from scipy.interpolate import interp1d


def create_trace_from_array(acce, dt, station='STA', channel='HHZ'):
    """
    从加速度数组创建 ObsPy Trace 对象
    
    参数:
        acce: 加速度时程数组 (单位: g)
        dt: 采样时间步 (秒)
        station: 台站名称
        channel: 通道名称 (HHZ=竖向, HHN=北向, HHE=东向)
    
    返回:
        trace: ObsPy Trace 对象
    """
    trace = Trace(data=acce)
    trace.stats.delta = dt
    trace.stats.station = station
    trace.stats.channel = channel
    trace.stats.sampling_rate = 1.0 / dt
    return trace


def baseline_correction(trace, method='linear'):
    """
    基线校正
    
    参数:
        trace: ObsPy Trace 对象
        method: 校正方法
            - 'demean': 去均值
            - 'linear': 线性去趋势
            - 'polynomial': 多项式去趋势
    
    返回:
        trace: 校正后的 Trace 对象
    """
    trace_corrected = trace.copy()
    
    if method == 'demean':
        trace_corrected.detrend('demean')
    elif method == 'linear':
        trace_corrected.detrend('linear')
    elif method == 'polynomial':
        trace_corrected.detrend('polynomial', order=3)
    else:
        trace_corrected.detrend('demean')
        trace_corrected.detrend('linear')
    
    return trace_corrected


def filter_signal(trace, freqmin=0.1, freqmax=25.0, corners=4, zerophase=True):
    """
    带通滤波去噪
    
    参数:
        trace: ObsPy Trace 对象
        freqmin: 最低频率 (Hz)
        freqmax: 最高频率 (Hz)
        corners: 滤波器阶数
        zerophase: 是否使用零相位滤波
    
    返回:
        trace: 滤波后的 Trace 对象
    """
    trace_filtered = trace.copy()
    trace_filtered.filter('bandpass', freqmin=freqmin, freqmax=freqmax, 
                         corners=corners, zerophase=zerophase)
    return trace_filtered


def resample_trace(trace, sampling_rate=100.0):
    """
    重采样
    
    参数:
        trace: ObsPy Trace 对象
        sampling_rate: 目标采样率 (Hz)
    
    返回:
        trace: 重采样后的 Trace 对象
    """
    trace_resampled = trace.copy()
    trace_resampled.resample(sampling_rate)
    return trace_resampled


def calculate_response_spectrum(acce, dt, periods, damping=0.05):
    """
    计算加速度反应谱
    
    参数:
        acce: 加速度时程 (单位: g)
        dt: 时间步长 (秒)
        periods: 周期数组 (秒)
        damping: 阻尼比 (默认 5%)
    
    返回:
        Sa: 加速度反应谱 (g)
        Sv: 速度反应谱 (cm/s)
        Sd: 位移反应谱 (cm)
    """
    g = 9.81  # 重力加速度 m/s^2
    acce_ms2 = acce * g  # 转换为 m/s^2
    
    npts = len(acce)
    n_periods = len(periods)
    
    Sa = np.zeros(n_periods)
    Sv = np.zeros(n_periods)
    Sd = np.zeros(n_periods)
    
    for i, T in enumerate(periods):
        omega = 2 * np.pi / T  # 圆频率
        omega_d = omega * np.sqrt(1 - damping**2)  # 阻尼圆频率
        
        # 初始化位移和速度
        u = np.zeros(npts)
        v = np.zeros(npts)
        a = np.zeros(npts)
        
        # Newmark-β 方法求解运动方程
        beta = 0.25
        gamma = 0.5
        
        # 系数
        a0 = 1.0 / (beta * dt**2)
        a1 = gamma / (beta * dt)
        a2 = 1.0 / (beta * dt)
        a3 = 1.0 / (2 * beta) - 1.0
        a4 = gamma / beta - 1.0
        a5 = dt / 2.0 * (gamma / beta - 2.0)
        
        k_eff = omega**2 + a0 + 2 * damping * omega * a1
        
        for j in range(npts - 1):
            dp = -acce_ms2[j+1] + acce_ms2[j]
            dp_eff = dp + a0 * u[j] + a2 * v[j] + a3 * a[j]
            dp_eff += 2 * damping * omega * (a1 * u[j] + a4 * v[j] + a5 * a[j])
            
            u[j+1] = dp_eff / k_eff
            v[j+1] = a1 * (u[j+1] - u[j]) - a4 * v[j] - a5 * a[j]
            a[j+1] = -acce_ms2[j+1] - 2 * damping * omega * v[j+1] - omega**2 * u[j+1]
        
        # 计算反应谱值
        Sd[i] = np.max(np.abs(u)) * 100  # 转换为 cm
        Sv[i] = np.max(np.abs(v)) * 100  # 转换为 cm/s
        Sa[i] = np.max(np.abs(a)) / g  # 转换为 g
    
    return Sa, Sv, Sd


def plot_waveform(trace, title='地震波时程', save_path=None):
    """
    绘制波形图
    
    参数:
        trace: ObsPy Trace 对象或加速度数组
        title: 图标题
        save_path: 保存路径 (可选)
    """
    plt.figure(figsize=(12, 4))
    
    if isinstance(trace, Trace):
        time = trace.times()
        acce = trace.data
        dt = trace.stats.delta
    else:
        acce = trace
        dt = 0.01  # 默认值
        time = np.arange(len(acce)) * dt
    
    plt.plot(time, acce, 'b-', linewidth=0.8)
    plt.xlabel('时间 (s)', fontsize=12)
    plt.ylabel('加速度 (g)', fontsize=12)
    plt.title(title, fontsize=14)
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_response_spectrum(periods, Sa, Sv=None, Sd=None, title='反应谱', save_path=None):
    """
    绘制反应谱
    
    参数:
        periods: 周期数组 (秒)
        Sa: 加速度反应谱 (g)
        Sv: 速度反应谱 (cm/s, 可选)
        Sd: 位移反应谱 (cm, 可选)
        title: 图标题
        save_path: 保存路径 (可选)
    """
    n_plots = 1 + (Sv is not None) + (Sd is not None)
    fig, axes = plt.subplots(1, n_plots, figsize=(6*n_plots, 4))
    
    if n_plots == 1:
        axes = [axes]
    
    plot_idx = 0
    
    # 加速度反应谱
    axes[plot_idx].plot(periods, Sa, 'r-', linewidth=2)
    axes[plot_idx].set_xlabel('周期 (s)', fontsize=12)
    axes[plot_idx].set_ylabel('Sa (g)', fontsize=12)
    axes[plot_idx].set_title('加速度反应谱', fontsize=13)
    axes[plot_idx].grid(True, alpha=0.3)
    axes[plot_idx].set_xlim([0, max(periods)])
    plot_idx += 1
    
    # 速度反应谱
    if Sv is not None:
        axes[plot_idx].plot(periods, Sv, 'g-', linewidth=2)
        axes[plot_idx].set_xlabel('周期 (s)', fontsize=12)
        axes[plot_idx].set_ylabel('Sv (cm/s)', fontsize=12)
        axes[plot_idx].set_title('速度反应谱', fontsize=13)
        axes[plot_idx].grid(True, alpha=0.3)
        axes[plot_idx].set_xlim([0, max(periods)])
        plot_idx += 1
    
    # 位移反应谱
    if Sd is not None:
        axes[plot_idx].plot(periods, Sd, 'b-', linewidth=2)
        axes[plot_idx].set_xlabel('周期 (s)', fontsize=12)
        axes[plot_idx].set_ylabel('Sd (cm)', fontsize=12)
        axes[plot_idx].set_title('位移反应谱', fontsize=13)
        axes[plot_idx].grid(True, alpha=0.3)
        axes[plot_idx].set_xlim([0, max(periods)])
    
    plt.suptitle(title, fontsize=14, y=1.02)
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_comparison(trace_original, trace_processed, title='处理前后对比'):
    """
    对比处理前后的波形
    
    参数:
        trace_original: 原始 Trace 对象
        trace_processed: 处理后的 Trace 对象
        title: 图标题
    """
    fig, axes = plt.subplots(2, 1, figsize=(12, 6), sharex=True)
    
    # 原始波形
    time_orig = trace_original.times()
    axes[0].plot(time_orig, trace_original.data, 'b-', linewidth=0.8)
    axes[0].set_ylabel('加速度 (g)', fontsize=12)
    axes[0].set_title('原始波形', fontsize=13)
    axes[0].grid(True, alpha=0.3)
    
    # 处理后波形
    time_proc = trace_processed.times()
    axes[1].plot(time_proc, trace_processed.data, 'r-', linewidth=0.8)
    axes[1].set_xlabel('时间 (s)', fontsize=12)
    axes[1].set_ylabel('加速度 (g)', fontsize=12)
    axes[1].set_title('处理后波形', fontsize=13)
    axes[1].grid(True, alpha=0.3)
    
    plt.suptitle(title, fontsize=14, y=0.995)
    plt.tight_layout()
    plt.show()


def calculate_significant_duration(acce, dt, energy_threshold=(0.05, 0.95)):
    """
    计算地震波的有效持时（基于能量）
    
    参数:
        acce: 加速度时程 (g)
        dt: 时间步长 (秒)
        energy_threshold: 能量阈值元组 (start_ratio, end_ratio)
                         默认 (0.05, 0.95) 表示 5%-95% 能量持时
    
    返回:
        t_start: 起始时间索引
        t_end: 结束时间索引
        duration: 有效持时 (秒)
    """
    # 计算累积能量
    energy = acce ** 2
    cumulative_energy = np.cumsum(energy)
    total_energy = cumulative_energy[-1]
    
    # 归一化累积能量
    normalized_energy = cumulative_energy / total_energy
    
    # 找到能量阈值对应的时间点
    t_start = np.argmax(normalized_energy >= energy_threshold[0])
    t_end = np.argmax(normalized_energy >= energy_threshold[1])
    
    duration = (t_end - t_start) * dt
    
    return t_start, t_end, duration


def truncate_ground_motion(trace, energy_threshold=(0.05, 0.95)):
    """
    截断地震波（保留主要能量部分）
    
    参数:
        trace: ObsPy Trace 对象
        energy_threshold: 能量阈值 (start_ratio, end_ratio)
    
    返回:
        trace_truncated: 截断后的 Trace 对象
        t_start: 起始时间索引
        t_end: 结束时间索引
    """
    acce = trace.data
    dt = trace.stats.delta
    
    t_start, t_end, duration = calculate_significant_duration(acce, dt, energy_threshold)
    
    # 截断数据
    trace_truncated = trace.copy()
    trace_truncated.data = trace.data[t_start:t_end+1]
    
    return trace_truncated, t_start, t_end


def scale_to_pga(acce, target_pga):
    """
    将加速度时程缩放到目标 PGA
    
    参数:
        acce: 加速度时程 (g)
        target_pga: 目标 PGA (g)
    
    返回:
        acce_scaled: 缩放后的加速度时程
        scale_factor: 缩放系数
    """
    current_pga = np.max(np.abs(acce))
    scale_factor = target_pga / current_pga
    acce_scaled = acce * scale_factor
    
    return acce_scaled, scale_factor


def process_ground_motion(acce, dt, baseline_method='linear', 
                         filter_freq=(0.1, 25.0), truncate=True,
                         energy_threshold=(0.05, 0.95), resample_rate=None):
    """
    完整的地震波预处理流程
    
    参数:
        acce: 加速度时程 (g)
        dt: 时间步长 (秒)
        baseline_method: 基线校正方法
        filter_freq: 滤波频率范围 (freqmin, freqmax)
        truncate: 是否截断地震波
        energy_threshold: 能量阈值 (用于截断)
        resample_rate: 重采样率 (Hz, None表示不重采样)
    
    返回:
        trace_processed: 处理后的 Trace 对象
        trace_original: 原始 Trace 对象
        processing_info: 处理信息字典
    """
    # 创建 Trace 对象
    trace_original = create_trace_from_array(acce, dt)
    trace_processed = trace_original.copy()
    
    processing_info = {}
    
    # 基线校正
    trace_processed = baseline_correction(trace_processed, method=baseline_method)
    
    # 滤波
    if filter_freq is not None:
        trace_processed = filter_signal(trace_processed, 
                                       freqmin=filter_freq[0], 
                                       freqmax=filter_freq[1])
    
    # 截断
    if truncate:
        trace_truncated, t_start, t_end = truncate_ground_motion(
            trace_processed, energy_threshold
        )
        processing_info['truncated'] = True
        processing_info['t_start'] = t_start
        processing_info['t_end'] = t_end
        processing_info['duration'] = (t_end - t_start) * trace_processed.stats.delta
        trace_processed = trace_truncated
    else:
        processing_info['truncated'] = False
    
    # 重采样
    if resample_rate is not None:
        trace_processed = resample_trace(trace_processed, sampling_rate=resample_rate)
        processing_info['resampled'] = True
        processing_info['new_sampling_rate'] = resample_rate
    else:
        processing_info['resampled'] = False
    
    return trace_processed, trace_original, processing_info



def export_processed_ground_motions(GMdata_list, pga_values, base_dir="ground_motions/processed"):
    """
    导出处理后并缩放到不同 PGA 的地震动数据
    
    参数:
        GMdata_list: 处理后的地震动数据列表，每个元素为字典，包含:
            - 'RSN': 地震波编号
            - 'GMH1': 水平1分量 Trace 对象
            - 'GMH2': 水平2分量 Trace 对象
            - 'GMV3': 竖向分量 Trace 对象
            - 'GMname': 文件名列表
        pga_values: PGA 值列表 (如 [0.1, 0.2, 0.3, ...])
        base_dir: 基础输出目录
    """
    import os
    
    for pga in pga_values:
        # 为每个 PGA 创建子目录
        pga_dir = os.path.join(base_dir, f"PGA_{pga:.2f}g")
        os.makedirs(pga_dir, exist_ok=True)
        
        for gm in GMdata_list:
            rsn = gm['RSN']
            gmnames = gm['GMname']
            
            # 处理三个分量
            components = {
                'H1': gm['GMH1'],
                'H2': gm['GMH2'],
                'V3': gm['GMV3']
            }
            
            for i, (comp_key, trace) in enumerate(components.items()):
                # 缩放到目标 PGA
                acce_scaled, scale_factor = scale_to_pga(trace.data, pga)
                time = trace.times()
                
                # 生成文件名
                if i < len(gmnames):
                    fname_base = gmnames[i].split('/')[-1].split('\\')[-1]
                    if fname_base.endswith('.AT2'):
                        fname_base = fname_base[:-4]
                else:
                    fname_base = f"RSN{rsn}_{comp_key}"
                
                output_path = os.path.join(pga_dir, f"{fname_base}.txt")
                
                # 保存数据
                data_to_save = np.column_stack((time, acce_scaled))
                np.savetxt(output_path, data_to_save, fmt="%.8e", delimiter="\t",
                          header=f"Time(s)\tAcceleration(g)\tPGA={pga:.2f}g\tScale_Factor={scale_factor:.6f}")
        
        print(f"PGA = {pga:.2f}g 的数据已导出至: {os.path.abspath(pga_dir)}")


def plot_all_waveforms_comparison(traces_original_list, traces_processed_list, 
                                  rsn_list, save_path=None):
    """
    绘制所有地震波处理前后的对比图（每条地震波一个子图）
    
    参数:
        traces_original_list: 原始 Trace 对象列表
        traces_processed_list: 处理后 Trace 对象列表
        rsn_list: RSN 编号列表
        save_path: 保存路径 (可选)
    """
    n_gm = len(traces_original_list)
    n_cols = 3
    n_rows = int(np.ceil(n_gm / n_cols))
    
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(15, 3*n_rows))
    axes = axes.flatten() if n_gm > 1 else [axes]
    
    for i in range(n_gm):
        ax = axes[i]
        
        # 原始波形
        time_orig = traces_original_list[i].times()
        ax.plot(time_orig, traces_original_list[i].data, 'b-', 
                linewidth=0.8, alpha=0.6, label='原始')
        
        # 处理后波形
        time_proc = traces_processed_list[i].times()
        ax.plot(time_proc, traces_processed_list[i].data, 'r-', 
                linewidth=0.8, label='处理后')
        
        ax.set_title(f'RSN={rsn_list[i]}', fontsize=10)
        ax.set_xlabel('时间 (s)', fontsize=9)
        ax.set_ylabel('加速度 (g)', fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=8, loc='upper right')
        ax.tick_params(labelsize=8)
    
    # 隐藏多余的子图
    for i in range(n_gm, len(axes)):
        axes[i].axis('off')
    
    plt.suptitle('所有地震波处理前后对比', fontsize=14, y=0.995)
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_all_response_spectra(Sa_list, periods, rsn_list, pga_value=None, save_path=None):
    """
    绘制所有地震波的反应谱（每条地震波一个子图）
    
    参数:
        Sa_list: 加速度反应谱列表
        periods: 周期数组
        rsn_list: RSN 编号列表
        pga_value: PGA 值 (用于标题)
        save_path: 保存路径 (可选)
    """
    n_gm = len(Sa_list)
    n_cols = 3
    n_rows = int(np.ceil(n_gm / n_cols))
    
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(15, 3*n_rows))
    axes = axes.flatten() if n_gm > 1 else [axes]
    
    for i in range(n_gm):
        ax = axes[i]
        
        ax.plot(periods, Sa_list[i], 'r-', linewidth=1.5)
        
        title = f'RSN={rsn_list[i]}'
        if pga_value is not None:
            title += f' (PGA={pga_value:.2f}g)'
        ax.set_title(title, fontsize=10)
        ax.set_xlabel('周期 (s)', fontsize=9)
        ax.set_ylabel('Sa (g)', fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.set_xlim([0, max(periods)])
        ax.tick_params(labelsize=8)
    
    # 隐藏多余的子图
    for i in range(n_gm, len(axes)):
        axes[i].axis('off')
    
    title = '所有地震波的加速度反应谱'
    if pga_value is not None:
        title += f' (PGA={pga_value:.2f}g)'
    plt.suptitle(title, fontsize=14, y=0.995)
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
    
    plt.show()
