#--------------------------------------------------------------------------------------------------
# pier 
#  墩柱   单位  m  Pa
source pierRCsectionquad.tcl;			
set pnshift 1000;
set peshift 1000;
#设置参数

               
# set GMph_sample [open GMdir/ph.txt "r"];
# set GMph_data [read $GMph_sample];
# close $GMph_sample;

set ph1  10.5; #第一组墩柱的高度
set ph2 11;       #第二组墩柱的高度
set dh 0.32;   #1/2号墩底截面高度差（1-2）；以1号墩为起始高度0

# set GMkj_sample [open GMdir/kj.txt "r"];
# set GMkj_data [read $GMkj_sample];
# close $GMkj_sample;
set kj1 30; #跨径
set kj2 30;
set kj3 30;


# set GMpelenum_sample [open GMdir/pelenum.txt "r"];
# set GMpelenum_data [read $GMpelenum_sample];
# close $GMpelenum_sample;
set pelenum  10;  #墩柱划分单元段数

set pjfd 5;       #墩柱积分点数    


set NodeInfo [open nodeInfo.txt w];   ##建立一个txt文件记录节点信息
set eleInfo [open eleInfo.txt w] ;  ##建立一个txt文件记录单元信息
#puts $$NodeInfo "节点信息包括：节点号，x，y，z"
#puts $eleInfo "单元信息包括：单元号，节点1，节点2，积分点数，截面，质量"

#墩柱1（双柱式）
puts $NodeInfo "墩柱1节点"
puts $eleInfo "墩柱1单元"

#建立两侧节点
set 1leftnodeID [expr 1+$pnshift+100];          #left
set 1rightnodeID [expr 51+$pnshift+100];          #right
set 1leftnodeID1  $1leftnodeID;
set 1rightnodeID1 $1rightnodeID;

for {set i 0} {$i <= $pelenum} {incr i 1} { 
   set pzh [expr $i*$ph1/$pelenum] 
    node     $1leftnodeID    $kj1  -2.4  $pzh   
    puts $NodeInfo "$1leftnodeID    $kj1  -2.4  $pzh "	; ##往这个txt文件中写入节点信息
   
    incr 1leftnodeID 1    
}

for {set im 0} {$im <= $pelenum} {incr im 1} { 
   set pzh [expr $im*$ph1/$pelenum]   
    node     $1rightnodeID    $kj1  2.4  $pzh 
    puts $NodeInfo "$1rightnodeID    $kj1  2.4  $pzh "	; ##往这个txt文件中写入节点信息

    incr 1rightnodeID 1       
}


#建立单元
set 1lefteleID [expr 1+$peshift+100];
set 1righteleID [expr 51+$peshift+100];
set 1lefteleID1 $1lefteleID;
set 1righteleID1 $1righteleID;

geomTransf Linear [expr 1+$peshift]  0 1 0 ;      #转换局部坐标系

for {set j 0} {$j <= [expr $pelenum-1]} {incr j 1} { 
    element forceBeamColumn  $1lefteleID [expr $j+$1leftnodeID1]  [expr $j+$1leftnodeID1+1]  $pjfd   $SecTag3D [expr 1+$peshift] -mass [expr 3.14*$D*$D/4*25*1000/$g] ;	
    puts $eleInfo "$1lefteleID [expr $j+$1leftnodeID1]  [expr $j+$1leftnodeID1+1]  $pjfd   $SecTag3D [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g]" ; ##往这个txt文件中写入单元信息
   
    incr 1lefteleID 1
}

for {set jm 0} {$jm <= [expr $pelenum-1]} {incr jm 1} { 
    element forceBeamColumn  $1righteleID [expr $jm+$1rightnodeID1]  [expr $jm+$1rightnodeID1+1]  $pjfd   $SecTag3D [expr 1+$peshift] -mass [expr 3.14*$D*$D/4*25*1000/$g] ;	
    puts $eleInfo "$1righteleID [expr $jm+$1rightnodeID1]  [expr $jm+$1rightnodeID1+1]  $pjfd   $SecTag3D [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g]" ; ##往这个txt文件中写入单元信息
 
    incr 1righteleID 1
}



#墩柱2（双柱式）
puts $NodeInfo "墩柱2节点"
puts $eleInfo "墩柱2单元"

#建立两侧节点
set 2leftnodeID [expr 1+$pnshift+200];
set 2leftnodeID2  $2leftnodeID;
set 2rightnodeID [expr 51+$pnshift+200];
set 2rightnodeID2  $2rightnodeID;

######考虑一个问题，两边墩柱的单元长度不一致是否影响后面的分析结果？？？？
for {set i 0} {$i <= $pelenum} {incr i 1} { 
    set pzh [expr $i*$ph2/$pelenum] 
    node     $2leftnodeID   [expr $kj1+$kj2]  -2.4  [expr $pzh-$dh]
    puts $NodeInfo "$2leftnodeID   [expr $kj1+$kj2]  -2.4  [expr $pzh-$dh] "

    incr 2leftnodeID 1
}


for {set im 0} {$im <= $pelenum} {incr im 1} { 
    set pzh [expr $im*$ph2/$pelenum]  
    node     $2rightnodeID   [expr $kj1+$kj2]  2.4  [expr $pzh-$dh]
    puts $NodeInfo "$2rightnodeID   [expr $kj1+$kj2]  2.4  [expr $pzh-$dh] "
 
     incr 2rightnodeID 1
}


#建立单元
set 2lefteleID [expr 1+$peshift+200];
set 2lefteleID2 $2lefteleID;
set 2righteleID [expr 51+$peshift+200];
set 2righteleID2 $2righteleID;
for {set j 0} {$j <= [expr $pelenum-1]} {incr j 1} { 
     element forceBeamColumn  $2lefteleID [expr $j+$2leftnodeID2]  [expr $j+$2leftnodeID2+1]  $pjfd   $SecTag3D [expr 1+$peshift] -mass [expr 3.14*$D*$D/4*25*1000/$g];	
     puts $eleInfo "$2lefteleID [expr $j+$2leftnodeID2]  [expr $j+$2leftnodeID2+1]  $pjfd   $SecTag3D [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g]"
     
     incr 2lefteleID 1 
}

for {set jm 0} {$jm <= [expr $pelenum-1]} {incr jm 1} { 
     element forceBeamColumn  $2righteleID [expr $jm+$2rightnodeID2]  [expr $jm+$2rightnodeID2+1]  $pjfd   $SecTag3D [expr 1+$peshift] -mass [expr 3.14*$D*$D/4*25*1000/$g];
     puts $eleInfo "$2righteleID [expr $jm+$2rightnodeID2]  [expr $jm+$2rightnodeID2+1]  $pjfd   $SecTag3D [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g]"

     incr 2righteleID 1
}



puts "finish pier1000"

