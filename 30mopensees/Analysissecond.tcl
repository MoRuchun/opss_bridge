#############################################################################
set startT [clock seconds]; #定义时程分析起始时间

# -------------------------------------------------维持重力荷载、时间归零  maintain constant gravity loads and reset time to zero
loadConst -time 0.0

# （1）一致激励参数Uniform Earthquake ground motion (uniform acceleration input at all support nodes)
set 1GMdirection 1;				# 地震动加载方向ground-motion direction
set 2GMdirection 2;
set 3GMdirection 3;
#set GMfile "GM_1_E.g3" ;			# 定义地震动名称（在IDA中已经设置好）ground-motion filenames
set GMfact $GMScale ;	# 定义调幅系数ground-motion scaling factor

# （2）set up ground-motion-analysis parameters用于计算分析总步数
#set DtAnalysis	0.02;	# 分析步长time-step Dt for lateral analysis
set DtAnalysis [lindex $GMdt_data [expr $tt-1]];
#set TmaxAnalysis	[expr 1*11.60];	# 分析持时，输入地震波的时间长度maximum duration of ground-motion analysis -- should be 50*$sec
set TmaxAnalysis [lindex $GMTeff_data [expr $tt-1]];
# （3）动力分析参数DYNAMIC ANALYSIS PARAMETERS

constraints Transformation 
numberer RCM
system BandGeneral

# （4）分析收敛性检验：TEST: # convergence test to 
set Tol 1.e-5;                        # Convergence Test: tolerance
set maxNumIter 5000;                # Convergence Test: maximum number of iterations that will be performed before "failure to converge" is returned
set printFlag 0;                # Convergence Test: flag used to print information on convergence (optional)        # 1: print information on each step; 
set TestType EnergyIncr;	# Convergence-test type
test $TestType $Tol $maxNumIter $printFlag;

# （5）算法
set algorithmType Newton;  # 修正的牛顿法 
algorithm $algorithmType;        

set NewmarkGamma 0.5;	# Newmark-integrator gamma parameter (also HHT)
set NewmarkBeta  0.25;	# Newmark-integrator beta parameter
integrator Newmark $NewmarkGamma $NewmarkBeta 

# （6）瞬态动力分析ANALYSIS  -- defines what type of analysis is to be performed 
analysis Transient

puts "动力分析开始 "
#  ---------------------------------    perform Dynamic Ground-Motion Analysis
# （8）一致激励地震动文件输入 Uniform EXCITATION: acceleration input
set IDloadTag [expr $tt*10000+$jj*10];			# load tag
#set dt 0.005;			# 地震波步长time step for input ground motion
set dt [lindex $GMdt_data [expr $tt-1]];
set GMfatt  [expr $g*$GMfact]";			# data in input file is in g Unifts -- ACCELERATION TH
#set GMfatt  [expr $g*5];

set 1AccelSeries "Series -dt $dt -filePath $1GMfile -factor  $g";			# time series information
pattern UniformExcitation  [expr $IDloadTag+1]  $1GMdirection -accel  $1AccelSeries  ;		# create Unifform excitation

set 2AccelSeries "Series -dt $dt -filePath $2GMfile -factor  $g";			# time series information
pattern UniformExcitation  [expr $IDloadTag+2]  $2GMdirection -accel  $2AccelSeries  ;		# create Unifform excitation

set 3AccelSeries "Series -dt $dt -filePath $3GMfile -factor  [expr $g*$GMfact]";			# time series information   
pattern UniformExcitation  [expr $IDloadTag+3]  $3GMdirection -accel  $3AccelSeries  ;		# create Unifform excitation

puts "地震动输入完毕 "
set Nsteps [expr int($TmaxAnalysis/$DtAnalysis)];   # int表示取整，计算总步数，是否加1？？？？
set ok [analyze $Nsteps $DtAnalysis];			# actually perform analysis; returns ok=0 if analysis was successful

if {$ok != 0} {      ;					# if analysis was not successful.
	# change some analysis parameters to achieve convergence
	# performance is slower inside this loop
	#    Time-controlled analysis
	set ok 0;
	set controlTime [getTime];
	while {$controlTime < $TmaxAnalysis && $ok == 0} {
		set ok [analyze 1 $DtAnalysis]
		set controlTime [getTime]
		set ok [analyze 1 $DtAnalysis]
		if {$ok != 0} {
			puts "Trying Newton with Initial Tangent .."
			test NormDispIncr   $Tol 1000  0
			algorithm Newton -initial
			set ok [analyze 1 $DtAnalysis]
			test $TestType $Tol $maxNumIter  0
			algorithm $algorithmType
		}
		if {$ok != 0} {
			puts "Trying Broyden .."
			algorithm Broyden 8
			set ok [analyze 1 $DtAnalysis]
			algorithm $algorithmType
		}
		if {$ok != 0} {
			puts "Trying NewtonWithLineSearch .."
			algorithm NewtonLineSearch .8
			set ok [analyze 1 $DtAnalysis]
			algorithm $algorithmType
		}
	}
};      # end if ok !0

puts 地面运动分析完成..."
set endT [clock seconds]
puts "完成时间: [expr $endT-$startT] seconds."
puts "finish Analysissecond"