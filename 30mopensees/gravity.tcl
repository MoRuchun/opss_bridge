source GenerateBridge.tcl

pattern Plain 24 Linear {
     puts $eleInfo "墩柱重力"
     #墩柱1重力
     set 1leftelegravity1 $1lefteleID1;
     for {set j 0} {$j <= [expr $pelenum-1]} {incr j 1} { 
    eleLoad -ele $1leftelegravity1 -type -beamUniform 0 0 -[expr 3.14*$D*$D/4*25*1000] ;	
    puts $eleInfo "eleLoad -ele $1leftelegravity1 -type -beamUniform 0 0 -[expr 3.14*$D*$D/4*25*1000]" ; ##往这个txt文件中写入单元信息
    incr 1leftelegravity1 1 
    }

     set 1rightelegravity1 $1righteleID1;
     for {set j 0} {$j <= [expr $pelenum-1]} {incr j 1} { 
    eleLoad -ele $1rightelegravity1 -type -beamUniform 0 0 -[expr 3.14*$D*$D/4*25*1000] ;	
    puts $eleInfo "eleLoad -ele $1rightelegravity1 -type -beamUniform 0 0 -[expr 3.14*$D*$D/4*25*1000]" ; ##往这个txt文件中写入单元信息
    incr 1rightelegravity1 1 
    }

#    puts "1elegravity1=$1elegravity1"

     #墩柱2重力
     set 2leftelegravity2 $2lefteleID2;
     for {set j 0} {$j <= [expr $pelenum-1]} {incr j 1} { 
    eleLoad -ele $2leftelegravity2 -type -beamUniform 0 0 -[expr 3.14*$D*$D/4*25*1000] ;	
    puts $eleInfo "eleLoad -ele $2leftelegravity2 -type -beamUniform 0 0 -[expr 3.14*$D*$D/4*25*1000]" ; ##往这个txt文件中写入单元信息
    incr 2leftelegravity2 1 
    }

set 2rightelegravity2 $2righteleID2;
     for {set j 0} {$j <= [expr $pelenum-1]} {incr j 1} { 
    eleLoad -ele $2rightelegravity2 -type -beamUniform 0 0 -[expr 3.14*$D*$D/4*25*1000] ;	
    puts $eleInfo "eleLoad -ele $2rightelegravity2 -type -beamUniform 0 0 -[expr 3.14*$D*$D/4*25*1000]" ; ##往这个txt文件中写入单元信息
    incr 2rightelegravity2 1 
    }
#    puts "2elegravity2=$2elegravity2"


    puts $eleInfo "盖梁重力"
    #盖梁1重力
    set C1gravity1 $C1eleID1;
    for {set j 0} {$j <= [expr $celenum-1]} {incr j 1} { 
    eleLoad -ele $C1gravity1 -type -beamUniform 0 -[expr $CHSec*$CBSec*25*1000] 0;	
    puts $eleInfo "eleLoad -ele $C1gravity1 -type -beamUniform 0 -[expr $CHSec*$CBSec*25*1000] 0"; ##往这个txt文件中写入单元信息
    incr C1gravity1 1 ;
    }

   #盖梁2重力
    set C2gravity2 $C2eleID2;
    for {set j 0} {$j <= [expr $celenum-1]} {incr j 1} { 
    eleLoad -ele $C2gravity2   -type -beamUniform 0 -[expr $CHSec*$CBSec*25*1000] 0;	
    puts $eleInfo "eleLoad -ele $C2gravity2   -type -beamUniform 0 -[expr $CHSec*$CBSec*25*1000] 0" ; ##往这个txt文件中写入单元信息
    incr C2gravity2 1 ;
    }


    puts $eleInfo "主梁重力"
    #主梁1重力
    set g1gravity1 $g1eleID1;
    for {set j 0} {$j <= [expr $gelenum-1]} {incr j 1} { 
    eleLoad -ele	$g1gravity1	 -type -beamUniform 0 -[expr $gdg*$g] 0;	
    puts $eleInfo "eleLoad -ele	$g1gravity1	 -type -beamUniform 0 -[expr $gdg*$g] 0" ; ##往这个txt文件中写入单元信息
    incr g1gravity1 1 
    }
#    puts "g1gravity1=$g1gravity1"

    #主梁2重力
    set g2gravity2 $g2eleID2;
    for {set j 0} {$j <= [expr $gelenum-1]} {incr j 1} { 
    eleLoad -ele $g2gravity2 -type -beamUniform 0 -[expr $gdg*$g] 0;	
    puts $eleInfo "eleLoad -ele $g2gravity2 -type -beamUniform 0 -[expr $gdg*$g] 0" ; ##往这个txt文件中写入单元信息
    incr g2gravity2 1 
    }
#    puts "g2gravity2=$g2gravity2"

    #主梁3重力
    set g3gravity3 $g3eleID3;
    for {set j 0} {$j <= [expr $gelenum-1]} {incr j 1} { 
    eleLoad -ele $g3gravity3 -type -beamUniform 0 -[expr $gdg*$g] 0;	
    puts $eleInfo "eleLoad -ele $g3gravity3 -type -beamUniform 0 -[expr $gdg*$g] 0" ; ##往这个txt文件中写入单元信息
    incr g3gravity3 1 
    }

}
#    puts "g3gravity3=$g3gravity3"





#puts "gravity recorder"


system        BandGeneral
constraints   Transformation
numberer      RCM
test          NormDispIncr 1.0e-12 10 3
algorithm     Newton
integrator    LoadControl 0.1
analysis      Static
initialize
#loadConst -time 0.0


#重力下的受力分析
# 创建数据目录文件			                                                  
if { [file exists Gravity] == 0 } {                                                                         

  file mkdir Gravity
} 

#recorder Element -file Gravity/4151_BearingElementForce.txt -time -ele 4151 localforce;
recorder Node -file Gravity/1111_BearingNodetReaction.txt -time -node 1111 -dof 1 2 3 reaction;
recorder Node -file Gravity/1161_BearingNodetReaction.txt -time -node 1161 -dof 1 2 3 reaction;
recorder Node -file Gravity/4153_BearingNodetReaction.txt -time -node 4153 -dof 1 2 3 reaction;

recorder Node -file Gravity/2151_BearingNodetReaction.txt -time -node 2151 -dof 1 2 3 reaction;
recorder Node -file Gravity/2152_BearingNodetReaction.txt -time -node 2152 -dof 1 2 3 reaction;
recorder Node -file Gravity/2153_BearingNodetReaction.txt -time -node 2153 -dof 1 2 3 reaction;

recorder Node -file Gravity/1109_BearingNodetReaction.txt -time -node 1109 -dof 1 2 3 reaction;
recorder Node -file Gravity/1101_BearingNodetReaction.txt -time -node 1101 -dof 1 2 3 reaction;

puts "finish recorder"

analyze       10
puts "finish gravity"


