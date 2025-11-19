# -*- coding: utf-8 -*-
"""
批量读取PEER地震波，并可以将地震波缩放至目标加速度,每个方向的地震波使用同一个缩放系数（缩放是可选的）。
本程序用来批量读取PEER地震波文件，批量读取的方法：事先将所有PEER地震波（三个方向）都解压到同一个文件夹内
（或者不同子文件夹内），本程序可自动对这些地震波(.AT2文件)进行读取，输出结果为一列表，列表的每个元素为一字典，
其中包含了三个方向的地震动时程(水平方向按PGA从大到小排列，第三列为竖向)，采样时间步，地震波的点数，RSN号等信息。
    GMdata           = BatchreadPEER(FileFolder, Scalsw = False);
    GMdata,Target_GM = ReadBatchPEER(FileFolder, Scalsw = True, TargetPGA = 0.5);     将所有水平1向地震波按PGA缩放至0.5g，其余方向与水平1方向保持比例不变
    输入：
        FileFolder------储存地震波文件的母文件夹，譬如  'E:\\GroundMotions' 。
        Scalsw ---------可选，False不缩放（默认），True为缩放，同时需输入目标 PGA(默认为0.5)。
        TargetPGA-------可选，默认为 0.5。
    输出：
        GMdata------储存原始（无缩放）地震波数据的列表，每一元素为一字典，包含如下键-值对；
        GMdata[i]['GMH1'] -------  水平1分量加速度时程，PGA最大的水平分量；   
        GMdata[i]['GMH2'] -------  水平2分量加速度时程； 
        GMdata[i]['GMV3'] -------  竖向分量加速度时程，如果原数据中没有竖向数据，则使用水平1方向时程×0.65后作为竖向时程； 
        GMdata[i]['time'] -------  时间序列；   
        GMdata[i]['dt']   -------  采样时间步；  
        GMdata[i]['npts'] -------  采样点数，即数据点数；  
        GMdata[i]['RSN']  -------  地震波的RSN编号；
        GMdata[i]['GMname'] -----  地震波的 三方向文件名,列表。
        Target_GM--------Scalsw = True 时才可输出，格式与GMdata相同，除了各方向时程为缩放后的时程。
@author: Yexiang Yan
"""
import numpy as np
from pathlib import Path
import copy
import re
import tkinter as tk
import numpy as np
from tkinter import filedialog
from pathlib import Path

def readPEER(*varargin):
    """
    This program is used to read ground motion data from PEER database

    @author: yexiang yan
    """
    if varargin == ():
        root = tk.Tk()
        root.withdraw()
        root.call('wm', 'attributes', '.', '-topmost', True)
        file_path = filedialog.askopenfilename(multiple=False)
        p = Path(file_path)
        file_name = p.name
    else:
        filefolder = varargin[0]
        file_name = varargin[1]
        file_path = Path(filefolder, file_name)

    with open(file_path, 'r') as f:
        content = f.read().splitlines()

    time_histories = []
    for line in content[4:]:
        currentLine = list(map(float, line.split()))
        time_histories.extend(currentLine)

    NPTS_DT = re.findall(r'-?\d*\.?\d+e?-?\d*', content[3])
    npts = int(NPTS_DT[0])
    dt = float(NPTS_DT[1])

    RSNlist = re.findall(r'\d+', file_name)
    RSN = int(RSNlist[0])

    time = np.arange(0, npts * dt, dt)

    # PEER_GM = {'time':time,'time_histories':time_histories,'dt':dt,'npts':npts,'RSN':RSN}
    tsg = np.array(time_histories)
    return tsg, time, dt, npts, RSN





def BatchReadPEER(FileFolder, Scalsw=False, TargetPGA=0.5):
    """批量读取某文件夹下的PEER地震波，并可以将地震波缩放至目标加速度。每个方向的地震波使用同一个缩放系数。"""

    p = Path(FileFolder)
    GM = list(p.rglob('*.AT2'))  # 也可以打开该文件夹下所有子文件夹的其他文件
    n = len(GM)  # 所有的文件数
    acce = [None] * n  # 预分配加速度储存元胞数组
    time = [None] * n  # 预分配时间储存元胞数组
    dt = [None] * n  # 预分配采样时间步储存元胞数组
    npts = [None] * n  # 预分配采样点数储存元胞数组
    rsn = [None] * n  # 预分配RSN号储存元胞数组
    GMname = [None] * n  # 预分配文件名储存元胞数组

    for ii in range(n):
        p_i = Path(GM[ii])
        # print(GM[ii])
        # print(p_i.name)
        acce[ii], time[ii], dt[ii], npts[ii], rsn[ii] = readPEER(p_i.parent, p_i.name)
        GMname[ii] = p_i.stem
        # print(p_i.stem)

    # 将列表转换为nummpy数组,注意acc和time都是列表中嵌套了numpy数组
    acce = np.array(acce, dtype=object)
    time = np.array(time, dtype=object)
    dt = np.array(dt)
    npts = np.array(npts)
    rsn = np.array(rsn)
    GMname = np.array(GMname)

    # 根据RSN号识别出每一组地震波
    newRSN = np.unique(rsn)  # 提取出唯一的RNS号
    numRSN = len(newRSN)
    GMdata = [None] * numRSN  # 预分配列表保存每一个地震波，每个元素为一字典，包括该地震波的信息
    # fieldName = ['GMH1','GMH2','GMV3','time','dt','npts','RSN','GMname']; #每个字典的键

    for i in range(numRSN):
        idxRSN = np.nonzero(np.abs(rsn - newRSN[i]) <= 1E-8)  # 定位该RSN的逻辑向量
        # 提取出该属于RSN（同一地震）的地震波数据
        acceTemp = acce[idxRSN]
        timeTemp = time[idxRSN]
        rsnTemp = rsn[idxRSN]
        dtTemp = dt[idxRSN]
        GMnameTemp = GMname[idxRSN]
        # 使地震波各分量的长度相等,以最短的为准
        minLength = np.min([len(GMlength) for GMlength in acceTemp])

        for j in range(len(acceTemp)):
            acceTemp[j] = acceTemp[j][0:minLength]

        # 以下程序用来识别水平方向和竖直方向地震波
        acceTempCopy = np.copy(acceTemp)  # 复制加速度数组
        acceTempNew = np.copy(acceTemp)
        for k in range(len(acceTemp)):
            ver_sw = (GMnameTemp[k].upper().endswith('UP') | GMnameTemp[k].upper().endswith('DWN') |
                      GMnameTemp[k].upper().endswith('V') | GMnameTemp[k].upper().endswith('VER') |
                      GMnameTemp[k].upper().endswith('UD'))  # 为True说明是竖向地震动
            if ver_sw:
                if k != (len(acceTemp) - 1):
                    ver_acce = acceTemp[k]
                    acceTempCopy = np.delete(acceTempCopy, k, axis=0)
                    acceTempNew = np.array([*acceTempCopy, ver_acce])

        # 将PGA最大的水平分量 排在第一列
        if np.max(np.abs(acceTempNew[0])) < np.max(np.abs(acceTempNew[1])):
            acceTempNew[[0, 1]] = acceTempNew[[1, 0]]

        # 如果没有竖向地震动，则将PGA较大的水平分量乘以0.65当做竖向分量
        if len(acceTemp) == 2:
            acceTempNew = np.array([*acceTempCopy, acceTempNew[0] * 0.65])

        # 创建地震波的数据集，为一列表，列表的每个元素为一字典，包含各地震波的信息
        GMdata[i] = {'GMH1': acceTempNew[0], 'GMH2': acceTempNew[1], 'GMV3': acceTempNew[2],
                     'time': timeTemp[0][0:minLength], 'dt': dtTemp[0],
                     'npts': minLength, 'RSN': rsnTemp[0], 'GMname': GMnameTemp}

        print('RSN={0} 已读取和存储完成，序号: {1}，共 {2} 条'.format(rsnTemp[0], i + 1, numRSN))

    print('所有 {} 组地震波已读取和存储完成'.format(numRSN))

    # 缩放地震波加速度
    if Scalsw:
        print('现在进行地震波的缩放，目标 PGA = {}g'.format(TargetPGA))
        Target_GM = copy.deepcopy(GMdata)  # 复制GMdata数组
        scal1 = np.zeros(len(GMdata))
        scal2 = np.zeros(len(GMdata))
        for m in range(len(GMdata)):
            acce1 = GMdata[m]['GMH1']
            acce2 = GMdata[m]['GMH2']
            scal1[m] = TargetPGA / np.amax(np.abs(acce1))
            scal2[m] = TargetPGA / np.amax(np.abs(acce2))
            Target_GM[m]['GMH1'] = GMdata[m]['GMH1'] * scal1[m]
            Target_GM[m]['GMH2'] = GMdata[m]['GMH2'] * scal1[m]
            Target_GM[m]['GMV3'] = GMdata[m]['GMV3'] * scal1[m]

        print('所有 {} 组地震波已缩放完成'.format(numRSN))
        return GMdata, Target_GM
    else:
        return GMdata
