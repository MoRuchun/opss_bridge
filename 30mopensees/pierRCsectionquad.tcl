#--------------------------------------------------------------------------------------------------
#zhouqiluan 
#pierRCsectionquad
# build a section   墩柱纤维方截面   单位  m  Pa
wipe;
model BasicBuilder -ndm 3 -ndf 6;
# source LibUnits.tcl;			# define units


set psshift 1100;                 #墩柱截面转换号
set hntbh 		30;            #混凝土标号
set Ec 		3.0e10;	    #混凝土弹性模量 Concrete Elastic Modulus   
set fyh  2.35e8;                    #箍筋屈服强度
                      
# set GMps_sample [open GMdir/ps.txt "r"];
# set GMps_data [read $GMps_sample];
# close $GMps_sample;
set ps  0.001517;              #箍筋体积配箍率

# set GMDSec_sample [open GMdir/DSec.txt "r"];
# set GMDSec_data [read $GMDSec_sample];
# close $GMDSec_sample;
  
set D  1.5;  #墩柱边长 
set coverSec 0.06;	          #保护层厚度 Column cover to reinforcing steel NA.  

# set GMnumBarsSec_sample [open GMdir/numBarsSec.txt "r"];
# set GMnumBarsSec_data [read $GMnumBarsSec_sample];
# close $GMnumBarsSec_sample;
set num1Bar  26;  #单个截面1层钢筋数目 number of uniformly-distributed longitudinal-reinforcement bars 
# set num2Bar  6;  #单个截面2层钢筋数目

set gjzj 0.025;                   #纵向钢筋直径
set Fy  3.35e8;              #纵向钢筋强度标准值 STEEL yield stress     
set Es 2.0e11;            #纵向钢筋弹性模量 modulus of steel 

 # MATERIAL parameters -------------------------------------------------------------------
set IDconcCore 1; 				# material ID tag -- confined core concrete
set IDconcCover 2; 				# material ID tag -- unconfined cover concrete
set IDreinf 3; 				# material ID tag -- reinforcement
 # nominal concrete compressive strength

set fc 		[expr -0.85*$hntbh*1e6];		# CONCRETE Compressive Strength, ksi   (+Tension, -Compression)

# unconfined concrete
set fc1U 		$fc;			# UNCONFINED concrete (todeschini parabolic model), maximum stress
set eps1U	-0.002;			# strain at maximum strength of unconfined concrete
set fc2U 		[expr 0.2*$fc1U];		# ultimate stress
set eps2U	-0.005;			# strain at ultimate stress
set lambda 0.1;				# ratio between unloading slope at $eps2 and initial slope $Ec

# confined concrete

set Kfc   [expr 1+$ps*$fyh/(-$fc)];			# ratio of confined to unconfined concrete strength
set fc1C 		[expr $Kfc*$fc];		# CONFINED concrete (mander model), maximum stress
set eps1C	[expr -0.002*$Kfc];	# strain at maximum stress 
set fc2C 		[expr 0.2*$fc1C];		# ultimate stress
set eps2C 	[expr -(0.004+1.4*$ps*$fyh*0.15/(-$fc1C))];		# strain at ultimate stress 

# tensile-strength properties
set ftC [expr -0.07*$fc1C];			# tensile strength +tension
set ftU [expr -0.07  *$fc1U];			# tensile strength +tension
set Ets [expr $ftU/0.002];			# tension softening stiffness
# -----------
set Bs		0.01;			# strain-hardening ratio 
set R0 18;				# control the transition from elastic to plastic branches
set cR1 0.925;				# control the transition from elastic to plastic branches
set cR2 0.15;				# control the transition from elastic to plastic branches

uniaxialMaterial Concrete02 $IDconcCore $fc1C $eps1C $fc2C $eps2C $lambda $ftC $Ets;	# build core concrete (confined)
uniaxialMaterial Concrete02 $IDconcCover $fc1U $eps1U $fc2U $eps2U $lambda $ftU $Ets;	# build cover concrete (unconfined)
uniaxialMaterial Hysteretic $IDreinf $Fy 0.002 [expr 1.5*$Fy] 0.15 [expr -$Fy] -0.002 [expr -1.5*$Fy] -0.15 0.6 0.6 0 0;				# build reinforcement material

# section GEOMETRY -------------------------------------------------------------

set barAreaSec [expr $PI/4*$gjzj*$gjzj];	# area of longitudinal-reinforcement bars
set SecTag [expr 1+$psshift];			# set tag for symmetric section

set DC [expr $D-2*$coverSec]    
#set S 0.748
#set numCore 43;		#                        hexin混凝土截面划分网格数
#set numCoverUDH 45;		#                        baohuceng上下面H方向混凝土截面划分网格数
#set numCoverUDB 1;		#                        baohuceng上下面B方向混凝土截面划分网格数
#set numCoverLRH 1;		#                       baohuceng左右面H方向混凝土截面划分网格数
#set numCoverLRB 43;		#                       baohuceng左右面B方向混凝土截面划分网格数

set ri 0.0;			# inner radius of the section, only for hollow sections
set ro [expr $D/2];	# overall (outer) radius of the section
set nfCoreR 12;		# number of radial divisions in the core (number of "rings")   核心混凝土截面径向划分网格数
set nfCoreT 26;		# number of theta divisions in the core (number of "wedges")   核心混凝土截面环向划分网格数
set nfCoverR 2;		# number of radial divisions in the cover                      保护层混凝土截面径向划分网格数
set nfCoverT 26;		# number of theta divisions in the cover

# Define the fiber section
section fiberSec $SecTag  {	
      set rc [expr $ro-$coverSec]
#	patch quad $IDconcCore $numCore $numCore [expr -$DC/2] [expr -$DC/2] [expr $DC/2] [expr -$DC/2] [expr $DC/2] [expr $DC/2] [expr -$DC/2] [expr $DC/2];		
#	patch quad $IDconcCover $numCoverUDH $numCoverUDB [expr -$D/2] [expr -$D/2] [expr $D/2] [expr -$D/2] [expr $D/2] [expr -$DC/2] [expr -$D/2] [expr -$DC/2];	
#	patch quad $IDconcCover $numCoverUDH $numCoverUDB [expr -$D/2] [expr $DC/2] [expr $D/2] [expr $DC/2] [expr $D/2] [expr $D/2] [expr -$D/2] [expr $D/2];
#	patch quad $IDconcCover $numCoverLRH $numCoverLRB [expr -$D/2] [expr -$DC/2] [expr -$DC/2] [expr -$DC/2] [expr -$DC/2] [expr $DC/2] [expr -$D/2] [expr $DC/2];
#	patch quad $IDconcCover $numCoverLRH $numCoverLRB [expr $DC/2] [expr -$DC/2] [expr $D/2] [expr -$DC/2] [expr $D/2] [expr $DC/2] [expr $DC/2] [expr $DC/2];
#	layer straight $IDreinf $num1Bar $barAreaSec -$S [expr -1*$DC/2] $S [expr -1*$DC/2];	# Define the reinforcing layer
#	layer straight $IDreinf $num1Bar $barAreaSec [expr $DC/2] -$S [expr $DC/2] $S;
#	layer straight $IDreinf $num1Bar $barAreaSec [expr -1*$DC/2] $S [expr $DC/2] $S;
#	layer straight $IDreinf $num1Bar $barAreaSec [expr -1*$DC/2] -$S [expr -1*$DC/2] $S;
#	layer straight $IDreinf $num2Bar $barAreaSec [expr -1*$DC/2] [expr -1*$DC/2+$gjzj] [expr $DC/2] [expr -1*$DC/2+$gjzj];
#	layer straight $IDreinf $num2Bar $barAreaSec [expr $DC/2-$gjzj] [expr -1*$DC/2] [expr $DC/2-$gjzj] [expr $DC/2];
#	layer straight $IDreinf $num2Bar $barAreaSec [expr -1*$DC/2] [expr $DC/2-$gjzj] [expr $DC/2] [expr $DC/2-$gjzj];
#	layer straight $IDreinf $num2Bar $barAreaSec [expr -1*$DC/2+$gjzj] [expr -1*$DC/2] [expr -1*$DC/2+$gjzj] [expr $DC/2];
	patch circ $IDconcCore $nfCoreT $nfCoreR 0 0 $ri $rc 0 360;		# Define the core patch
	patch circ $IDconcCover $nfCoverT $nfCoverR 0 0 $rc $ro 0 360;	# Define the cover patch
	set theta [expr 360.0/$num1Bar];		# Determine angle increment between bars
	layer circ $IDreinf $num1Bar $barAreaSec 0 0 $rc $theta 360
}

# assign torsional Stiffness for 3D Model
set SecTagTorsion [expr 2+$psshift];		# ID tag for torsional section behavior
set SecTag3D [expr 3+$psshift];			# ID tag for combined behavior for 3D model
uniaxialMaterial Elastic $SecTagTorsion $Ubig;	# define elastic torsional stiffness
section Aggregator $SecTag3D $SecTagTorsion T -section $SecTag;	# combine section properties
#验证参数结果
#puts   "unconfined" ;
#puts   "fc1U=$fc1U" ;
#puts   "eps1U=$eps1U" ;
#puts   "fc2U=$fc2U" ;
#puts   "eps2U=$eps2U" ;
#puts   "ftU =$ftU " ;
#
#
#puts   "confined" ;
#puts   "Kfc=$Kfc" ;
#puts   "fc1C=$fc1C" ;
#puts   "eps1C=$eps1C" ;
#puts   "fc2C=$fc2C" ;
#puts   "eps2C=$eps2C" ;
#puts   "ftC=$ftC" ;
#puts   "Ets=$Ets";
puts "finish pierRCsectionCir"
