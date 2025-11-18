#zhouqiluan--------------------------------------------------------------------------------------------------
# capbeamRCSectionRect
# build a section   盖梁纤维矩形截面   单位  m  Pa

source LibUnits.tcl;			# define units
set csshift 2100;                  #盖梁截面转换号
set Chntbh 		30;             #混凝土标号
set CEc 		3.0e10;	     #混凝土弹性模量 Concrete Elastic Modulus   
set Cfyh  2.35e8;                    #箍筋屈服强度
set Cps     0.005   ;              #箍筋体积配箍率
set CTgjzj 0.025;                  #纵向钢筋直径 顶部
set CBgjzj 0.025;                  #纵向钢筋直径 底部
set CIgjzj 0.012;                  #纵向钢筋直径 侧向
set CCgjzj 0.025;                  #纵向钢筋直径 中部
set CFy   3.35e8;              #纵向钢筋强度标准值 STEEL yield stress     
set CEs   2.0e11;            #纵向钢筋弹性模量 modulus of steel 
set CHSec 1.5; 			#盖梁截面高 Column Depth
set CBSec 1.7;			#盖梁截面宽 Column Width
set CcoverH 0.05;			#盖梁截面高度方向保护层厚度 Column cover to reinforcing steel NA, parallel to H
set CcoverB 0.058;			#盖梁截面宽度方向保护层厚度 Column cover to reinforcing steel NA, parallel to B



# set GMCnumBarsTop_sample [open GMdir/CnumBarsTop.txt "r"];
# set GMCnumBarsTop_data [read $GMCnumBarsTop_sample];
# close $GMCnumBarsTop_sample;
set CnumBarsTop  10; #盖梁截面顶部钢筋数 number of longitudinal-reinforcement bars in steel layer. -- top

set CnumBarsBot 10;		#盖梁截面底部钢筋数 number of longitudinal-reinforcement bars in steel layer. -- bot


# set GMCnumBarsIntTot_sample [open GMdir/CnumBarsIntTot.txt "r"];
# set GMCnumBarsIntTot_data [read $GMCnumBarsIntTot_sample];
# close $GMCnumBarsIntTot_sample;
set CnumBarsIntTot  18; #盖梁截面两侧总钢筋数number of longitudinal-reinforcement bars in steel layer. -- total intermediate skin reinforcement, symm about y-axis
set CnumBarsCenter 10;		#盖梁截面中底部钢筋数 number of longitudinal-reinforcement bars in steel layer. -- center




 # MATERIAL parameters -------------------------------------------------------------------
set CIDconcCore [expr 1+$csshift]; 				# material ID tag -- confined core concrete
set CIDconcCover [expr 2+$csshift]; 				# material ID tag -- unconfined cover concrete
set CIDreinf [expr 3+$csshift]; 				# material ID tag -- reinforcement
 # nominal concrete compressive strength

set Cfc 		[expr -0.85*$Chntbh*1e6];		# CONCRETE Compressive Strength, ksi   (+Tension, -Compression)

# unconfined concrete
set Cfc1U 		$Cfc;			# UNCONFINED concrete (todeschini parabolic model), maximum stress
set Ceps1U	-0.002;			# strain at maximum strength of unconfined concrete
set Cfc2U 		[expr 0.2*$Cfc1U];		# ultimate stress
set Ceps2U	-0.005;			# strain at ultimate stress
set Clambda 0.1;				# ratio between unloading slope at $eps2 and initial slope $Ec

# confined concrete

set CKfc   [expr 1+$Cps*$Cfyh/(-$Cfc)];			# ratio of confined to unconfined concrete strength
set Cfc1C 		[expr $CKfc*$Cfc];		# CONFINED concrete (mander model), maximum stress
set Ceps1C	[expr -0.002*$CKfc];	# strain at maximum stress 
set Cfc2C 		[expr 0.2*$Cfc1C];		# ultimate stress
set Ceps2C 	[expr -(0.004+1.4*$Cps*$Cfyh*0.15/(-$Cfc1C))];		# strain at ultimate stress 

# tensile-strength properties
set CftC [expr -0.07*$Cfc1C];			# tensile strength +tension
set CftU [expr -0.07  *$Cfc1U];			# tensile strength +tension
set CEts [expr $CftU/0.002];			# tension softening stiffness
# -----------
set CBs		0.01;			# strain-hardening ratio 
set CR0 18;				# control the transition from elastic to plastic branches
set CcR1 0.925;				# control the transition from elastic to plastic branches
set CcR2 0.15;				# control the transition from elastic to plastic branches

uniaxialMaterial Concrete02 $CIDconcCore $Cfc1C $Ceps1C $Cfc2C $Ceps2C $Clambda $CftC $CEts;	# build core concrete (confined)
uniaxialMaterial Concrete02 $CIDconcCover $Cfc1U $Ceps1U $Cfc2U $Ceps2U $Clambda $CftU $CEts;	# build cover concrete (unconfined)
uniaxialMaterial Steel02 $CIDreinf $CFy $CEs $CBs $CR0 $CcR1 $CcR2;				# build reinforcement material

# section GEOMETRY -------------------------------------------------------------

set CbarAreaTop [expr $PI/4*$CTgjzj*$CTgjzj];	# area of longitudinal-reinforcement bars -- top
set CbarAreaBot [expr $PI/4*$CBgjzj*$CBgjzj];	# area of longitudinal-reinforcement bars -- bot
set CbarAreaInt [expr $PI/4*$CIgjzj*$CIgjzj];	# area of longitudinal-reinforcement bars -- intermediate skin reinf
set CbarAreaCenter [expr $PI/4*$CCgjzj*$CCgjzj];	# area of longitudinal-reinforcement bars -- center


set CSecTag [expr 1+$csshift]; 	# set tag for symmetric section		
# FIBER SECTION properties -------------------------------------------------------------
#
#                        y
#                        ^
#                        |     
#             -----------------------   --
#             |   o     o     o    |     |    -- coverH
#             |                    |     |
#             |   o            o   |     |
#    z <---   |          +         |     Hsec
#             |   o            o   |     |
#             |                    |     |
#             |   o o o o o o      |     |    -- coverH
#             -----------------------   --
#             |-------Bsec------|
#             |---| coverB  |---|
#
#                       z
#                       ^
#                       |    
#             ---------------------
#             |\      cover      /|
#             | \------Top------/ |
#             |c|               |c|
#             |o|               |o|
#   y <-----  |v|       core    |v|  Hsec   
#             |e|               |e|
#             |r|               |r|
#             | /-------Bot-----\ |
#             |/      cover      \|
#             ---------------------
#                       Bsec
#
# Notes
#    The core concrete ends at the NA of the reinforcement
#    The center of the section is at (0,0) in the local axis system

set CcoverY [expr $CBSec/2.0];	# The distance from the section z-axis to the edge of the cover concrete -- outer edge of cover concrete
set CcoverZ [expr $CHSec/2.0];	# The distance from the section y-axis to the edge of the cover concrete -- outer edge of cover concrete
set CcoreY [expr $CcoverY-$CcoverB];	# The distance from the section z-axis to the edge of the core concrete --  edge of the core concrete/inner edge of cover concrete
set CcoreZ [expr $CcoverZ-$CcoverH];	# The distance from the section y-axis to the edge of the core concrete --  edge of the core concrete/inner edge of cover concreteset nfY 16;			# number of fibers for concrete in y-direction
set CnfY 120;			# 核心混凝土Y向划分段数 number of fibers for concrete in y-direction
set CnfZ 25;			# 核心混凝土Z向划分段数 number of fibers for concrete in z-direction
set CnfYU 2;			# 保护层混凝土Y向划分段数 
set CnfZU 2;		# 保护层混凝土Z向划分段数
set CnumBarsInt [expr $CnumBarsIntTot/2];	# number of intermediate bars per side
section fiberSec $CSecTag {;	# Define the fiber section
	patch quadr $CIDconcCore $CnfY $CnfZ -$CcoreY -$CcoreZ $CcoreY -$CcoreZ $CcoreY $CcoreZ -$CcoreY $CcoreZ; 	# Define the core patch
	patch quadr $CIDconcCover [expr $CnfY+2*$CnfYU] $CnfZU -$CcoverY -$CcoverZ $CcoverY -$CcoverZ $CcoverY -$CcoreZ -$CcoverY -$CcoreZ;	# Define the four cover patches
	patch quadr $CIDconcCover [expr $CnfY+2*$CnfYU] $CnfZU -$CcoverY $CcoreZ $CcoverY $CcoreZ $CcoverY $CcoverZ -$CcoverY $CcoverZ
	patch quadr $CIDconcCover $CnfYU $CnfZ -$CcoverY -$CcoreZ -$CcoreY -$CcoreZ -$CcoreY $CcoreZ -$CcoverY $CcoreZ  
	patch quadr $CIDconcCover $CnfYU $CnfZ $CcoreY -$CcoreZ $CcoverY -$CcoreZ $CcoverY $CcoreZ $CcoreY $CcoreZ
	layer straight $CIDreinf $CnumBarsInt $CbarAreaInt  $CcoreY [expr -$CcoreZ+0.14] $CcoreY [expr $CcoreZ-0.14];	# intermediate skin reinf. +y
	layer straight $CIDreinf $CnumBarsInt $CbarAreaInt  -$CcoreY [expr -$CcoreZ+0.14] -$CcoreY [expr $CcoreZ-0.14];	# intermediate skin reinf. -y
	layer straight $CIDreinf $CnumBarsTop $CbarAreaTop -$CcoreY $CcoreZ $CcoreY $CcoreZ;	# top layer reinfocement
	layer straight $CIDreinf $CnumBarsBot $CbarAreaBot  -$CcoreY -$CcoreZ $CcoreY -$CcoreZ;	# bottom layer reinforcement
	layer straight $CIDreinf $CnumBarsCenter $CbarAreaCenter  -$CcoreY [expr -$CcoreZ+0.039] $CcoreY [expr -$CcoreZ+0.039];	# center layer reinforcement
};	# end of fibersection definition


# assign torsional Stiffness for 3D Model
set CSecTagTorsion [expr 12+$csshift];		# ID tag for torsional section behavior
set CSecTag3D [expr 3+$csshift];			# ID tag for combined behavior for 3D model
uniaxialMaterial Elastic $CSecTagTorsion $Ubig;	# define elastic torsional stiffness
section Aggregator $CSecTag3D $CSecTagTorsion T -section $CSecTag;	# combine section properties

#puts   "unconfined" ;
#puts   "Cfc1U=$Cfc1U" ;
#puts   "Ceps1U=$Ceps1U" ;
#puts   "Cfc2U=$Cfc2U" ;
#puts   "Ceps2U=$Ceps2U" ;
#puts   "CftU =$CftU " ;
#
#
#puts   "confined" ;
#puts   "CKfc=$CKfc" ;
#puts   "Cfc1C=$Cfc1C" ;
#puts   "Ceps1C=$Ceps1C" ;
#puts   "Cfc2C=$Cfc2C" ;
#puts   "Ceps2C=$Ceps2C" ;
#puts   "CftC=$CftC" ;

puts "finish capbeamRCSectionRect"
 