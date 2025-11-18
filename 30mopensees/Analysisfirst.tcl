#############################################################################
# ------  计算结构的自振频率，按照阻尼比计算Rayleigh常数--------------
#set pi [expr 2.0*asin(1.0)];  # 定义pi，asin是反正弦函数 
set nEigenI 1; #主振型1为第一振型
set nEigenJ 2; #主振型2为第二振型
set nEigenK 3; #主振型3为第二振型
set lambdaN [eigen [expr $nEigenK]]; # 求三阶振型 eigenvalue analysis for nEigenJ modes
set lambdaI [lindex $lambdaN [expr $nEigenI-1]]; # 提取第一阶特征值 eigenvalue mode j = 1 
set lambdaJ [lindex $lambdaN [expr $nEigenJ-1]]; # 提取第二阶特征值 eigenvalue mode j = 2
set lambdaK [lindex $lambdaN [expr $nEigenK-1]]; # 提取第三阶特征值 eigenvalue mode k = 3
set w1 [expr pow($lambdaI,0.5)]; # 第一阶频率的特征周期 (1st mode circular frequency)
set w2 [expr pow($lambdaJ,0.5)]; # 第二阶频率的特征周期 (2nd mode circular frequency)
set w3 [expr pow($lambdaK,0.5)]; # 第三阶频率的特征周期 (3nd mode circular frequency)
set T1 [expr 2.0*$PI/$w1]; #第一阶频率的特征周期 1st mode period of the structure
set T2 [expr 2.0*$PI/$w2]; #第二阶频率的特征周期 2nd mode period of the structure
set T3 [expr 2.0*$PI/$w3]; #第三阶频率的特征周期 3nd mode period of the structure
set F1 [expr 1.0/$T1]; # 1st mode frequency of the structure
set F2 [expr 1.0/$T2]; # 2nd mode frequency of the structure
set F3 [expr 1.0/$T3]; # 3nd mode frequency of the structure
puts "前三阶周期"
puts "T1 = $T1 s"; #第一阶频率的特征周期 display the first mode period in the command window
puts "T2 = $T2 s"; # 第二阶频率的特征周期display the second mode period in the command window
puts "T3 = $T3 s"; # 第三阶频率的特征周期display the third mode period in the command window
puts "前三阶频率"
puts "f1 = $F1 Hz"; # display the first mode period in the command window
puts "f2 = $F2 Hz"; # display the second mode period in the command window
puts "f3 = $F3 Hz"; # display the third mode period in the command window


# （7）Rayleigh阻尼定义define DAMPING--------------------------------------------------------------------------------------
# apply Rayleigh DAMPING from $xDamp
# D=$alphaM*M + $betaKcurr*Kcurrent + $betaKcomm*KlastCommit + $beatKinit*$Kinitial
set zeta 0.05; #设置阻尼比为0.05
set a0 [expr $zeta*2.0*$w1*$w2/($w1 + $w2)]; #质量相关系数a0 （mass damping coefficient based on first and second modes）
set a1 [expr $zeta*2.0/($w1 + $w2)]; # 刚度相关系数a1(stiffness damping coefficient based on first and second modes)
#----定义阻尼  质量矩阵系数  当前刚度  初始刚度    上一时步刚度系数   
 rayleigh      $a0             0        0            $a1 ;  #定义瑞利阻尼
puts "Rayleigh阻尼系数:"
puts "a0 = $a0 "
puts "a1 = $a1 "

puts "finish Analysisfirst"