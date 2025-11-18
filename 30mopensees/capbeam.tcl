#--------------------------------------------------------------------------------------------------
# capbeam 
#  盖梁   单位  m  Pa
source capbeamRCSectionRect.tcl;

set cnshift 2000;
set ceshift 2000;

#需要设置的参数
set cbd   0.45;                    #支座距离盖梁中心线的x方向长度
set czc 8;                       #盖梁总长 
set celenum 8;                     #盖梁划分单元数 
set cjfd  5;                       #盖梁积分点数

##建立盖梁
#盖梁1
puts $NodeInfo "盖梁1节点"
puts $eleInfo "盖梁1单元"
#建立节点
set C1nodeID [expr 1+$cnshift+100];
set C1nodeID1  $C1nodeID;

for {set i 0} {$i <= $celenum} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 

    node     $C1nodeID    $kj1  [expr -$czc/2+$cy]  [expr $ph1+$CHSec] ;
    puts $NodeInfo "$C1nodeID    $kj1  [expr -$czc/2+$cy]  [expr $ph1+$CHSec]" ;   ##往这个txt文件中写入节点信息


    incr C1nodeID 1 
}



#建立单元
set C1eleID [expr 1+$ceshift+100];
set C1eleID1 $C1eleID;
geomTransf Linear [expr 1+$ceshift]  0 0 1 ; 

for {set j 0} {$j <= [expr $celenum-1]} {incr j 1} { 
    element forceBeamColumn  $C1eleID [expr $j+$C1nodeID1]  [expr $j+$C1nodeID1+1]  $cjfd  $CSecTag3D  [expr 1+$ceshift] -mass [expr $CHSec*$CBSec*25*1000/$g];	
    puts $eleInfo "element forceBeamColumn $C1eleID	[expr $j+$C1nodeID1]	[expr $j+$C1nodeID1+1]	$cjfd	$CSecTag3D	[expr 1+$ceshift] -mass [expr $CHSec*$CBSec*25*1000/$g]"; ##往这个txt文件中写入单元信息
    incr C1eleID 1 ;
}

##建立支座与盖梁中心线的节点和刚臂
#左侧
set C1g1nodeID [expr 1+$cnshift+100+50];
set C1g1nodeID1  $C1g1nodeID;

node $C1g1nodeID [expr $kj1-$cbd] [expr -$czc/2+$czc/$celenum] [expr $ph1+$CHSec]  ;   
puts $NodeInfo "$C1g1nodeID [expr $kj1-$cbd] [expr -$czc/2+$czc/$celenum] [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 1+$C1g1nodeID] [expr $kj1-$cbd] [expr -$czc/2+3*$czc/$celenum] [expr $ph1+$CHSec]  ;
puts $NodeInfo "[expr 1+$C1g1nodeID] [expr $kj1-$cbd] [expr -$czc/2+2*$czc/$celenum] [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 2+$C1g1nodeID] [expr $kj1-$cbd] [expr $czc/2-3*$czc/$celenum] [expr $ph1+$CHSec]  ;
puts $NodeInfo "[expr 2+$C1g1nodeID] [expr $kj1-$cbd] [expr $czc/2-2*$czc/$celenum] [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 3+$C1g1nodeID] [expr $kj1-$cbd] [expr $czc/2-$czc/$celenum] [expr $ph1+$CHSec]  ;
puts $NodeInfo "[expr 3+$C1g1nodeID] [expr $kj1-$cbd] [expr $czc/2-$czc/$celenum] [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

#右侧
set C1g2nodeID [expr 1+$cnshift+100+60];
set C1g2nodeID2  $C1g2nodeID;

node $C1g2nodeID [expr $kj1+$cbd] [expr -$czc/2+$czc/$celenum] [expr $ph1+$CHSec]  ;
puts $NodeInfo "$C1g2nodeID [expr $kj1+$cbd] [expr -$czc/2+$czc/$celenum] [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 1+$C1g2nodeID] [expr $kj1+$cbd] [expr -$czc/2+3*$czc/$celenum] [expr $ph1+$CHSec]  ;
puts $NodeInfo "[expr 1+$C1g2nodeID] [expr $kj1+$cbd] [expr -$czc/2+2*$czc/$celenum] [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 2+$C1g2nodeID] [expr $kj1+$cbd] [expr $czc/2-3*$czc/$celenum] [expr $ph1+$CHSec]  ;
puts $NodeInfo "[expr 2+$C1g2nodeID] [expr $kj1+$cbd] [expr $czc/2-2*$czc/$celenum] [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 3+$C1g2nodeID] [expr $kj1+$cbd] [expr $czc/2-$czc/$celenum] [expr $ph1+$CHSec]  ;
puts $NodeInfo "[expr 3+$C1g2nodeID] [expr $kj1+$cbd] [expr $czc/2-$czc/$celenum] [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息



#建立刚臂（equalDOF）

equalDOF 2102 2151 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2102 2151 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2104 2152 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2103 2152 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2106 2153 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2107 2153 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2108 2154 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2108 2154 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息


equalDOF 2102 2161 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2102 2161 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2104 2162 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2103 2162 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2106 2163 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2107 2163 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2108 2164 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2108 2164 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息


#盖梁2
puts $NodeInfo "盖梁2节点"
puts $eleInfo "盖梁2单元"
#建立节点
set C2nodeID [expr 1+$cnshift+200];
set C2nodeID2  $C2nodeID;

for {set i 0} {$i <= $celenum} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 

    node     $C2nodeID    [expr $kj1+$kj2]  [expr -$czc/2+$cy]  [expr -$dh+$ph2+$CHSec] ;
    puts $NodeInfo "$C2nodeID    [expr $kj1+$kj2]  [expr -$czc/2+$cy]  [expr -$dh+$ph2+$CHSec]" ;   ##往这个txt文件中写入节点信息

    incr C2nodeID 1 
}



#建立单元

set C2eleID [expr 1+$ceshift+200];
set C2eleID2 $C2eleID;
for {set j 0} {$j <= [expr $celenum-1]} {incr j 1} { 
    element forceBeamColumn  $C2eleID [expr $j+$C2nodeID2]  [expr $j+$C2nodeID2+1]  $cjfd  $CSecTag3D  [expr 1+$ceshift] -mass [expr $CHSec*$CBSec*25*1000/$g];	
    puts $eleInfo "element forceBeamColumn $C2eleID	[expr $j+$C2nodeID2]	[expr $j+$C2nodeID2+1]	$cjfd	$CSecTag3D	[expr 1+$ceshift] -mass [expr $CHSec*$CBSec*25*1000/$g]" ; ##往这个txt文件中写入单元信息
    incr C2eleID 1 ;
}


##建立支座与盖梁中心线的节点和刚臂
#左侧
set C2g1nodeID [expr 1+$cnshift+200+50];
set C2g1nodeID1  $C2g1nodeID;

node $C2g1nodeID [expr $kj1+$kj2-$cbd] [expr -$czc/2+$czc/$celenum] [expr -$dh+$ph2+$CHSec]  ;
puts $NodeInfo "$C2g1nodeID [expr $kj1+$kj2-$cbd] [expr -$czc/2+$czc/$celenum] [expr -$dh+$ph2+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 1+$C2g1nodeID] [expr $kj1+$kj2-$cbd] [expr -$czc/2+3*$czc/$celenum] [expr -$dh+$ph2+$CHSec]  ;
puts $NodeInfo "[expr 1+$C2g1nodeID] [expr $kj1+$kj2-$cbd] [expr -$czc/2+2*$czc/$celenum] [expr -$dh+$ph2+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 2+$C2g1nodeID] [expr $kj1+$kj2-$cbd] [expr $czc/2-3*$czc/$celenum] [expr -$dh+$ph2+$CHSec]  ;
puts $NodeInfo "[expr 2+$C2g1nodeID] [expr $kj1+$kj2-$cbd] [expr $czc/2-2*$czc/$celenum] [expr -$dh+$ph2+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 3+$C2g1nodeID] [expr $kj1+$kj2-$cbd] [expr $czc/2-$czc/$celenum] [expr -$dh+$ph2+$CHSec]  ;
puts $NodeInfo "[expr 3+$C2g1nodeID] [expr $kj1+$kj2-$cbd] [expr $czc/2-$czc/$celenum] [expr -$dh+$ph2+$CHSec]"  ;   ##往这个txt文件中写入节点信息

#右侧
set C2g2nodeID [expr 1+$cnshift+200+60];
set C2g2nodeID2  $C2g2nodeID;

node $C2g2nodeID [expr $kj1+$kj2+$cbd] [expr -$czc/2+$czc/$celenum] [expr -$dh+$ph2+$CHSec]  ;
puts $NodeInfo "$C2g2nodeID [expr $kj1+$kj2+$cbd] [expr -$czc/2+$czc/$celenum] [expr -$dh+$ph2+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 1+$C2g2nodeID] [expr $kj1+$kj2+$cbd] [expr -$czc/2+3*$czc/$celenum] [expr -$dh+$ph2+$CHSec]  ;
puts $NodeInfo "[expr 1+$C2g2nodeID] [expr $kj1+$kj2+$cbd] [expr -$czc/2+2*$czc/$celenum] [expr -$dh+$ph2+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 2+$C2g2nodeID] [expr $kj1+$kj2+$cbd] [expr $czc/2-3*$czc/$celenum] [expr -$dh+$ph2+$CHSec]  ;
puts $NodeInfo "[expr 2+$C2g2nodeID] [expr $kj1+$kj2+$cbd] [expr $czc/2-2*$czc/$celenum] [expr -$dh+$ph2+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node [expr 3+$C2g2nodeID] [expr $kj1+$kj2+$cbd] [expr $czc/2-$czc/$celenum] [expr -$dh+$ph2+$CHSec]  ;
puts $NodeInfo "[expr 3+$C2g2nodeID] [expr $kj1+$kj2+$cbd] [expr $czc/2-$czc/$celenum] [expr -$dh+$ph2+$CHSec]"  ;   ##往这个txt文件中写入节点信息


#建立刚臂（equalDOF）

equalDOF 2202 2251 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2202 2251 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2204 2252 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2203 2252 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2206 2253 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2207 2253 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2208 2254 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2208 2254 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息


equalDOF 2202 2261 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2202 2261 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2204 2262 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2203 2262 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2206 2263 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2207 2263 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

equalDOF 2208 2264 1 2 3 4 5 6;
puts $eleInfo "equalDOF 2208 2264 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息


#建立墩柱盖梁的连接
#因为双柱式桥墩与原盖梁结构体划分时偏离中心线，遂不采用共节点的方法，使用刚臂完成模拟

#equalDOF [expr $1leftnodeID-1] [expr $C1nodeID1+1] 1 2 3 4 5 6;
#puts $eleInfo "equalDOF [expr $1leftnodeID-1] [expr $C1nodeID1+1] 1 2 3 4 5 6"; ##往这个txt文件中写入节点信息

#equalDOF [expr $1rightnodeID-1] [expr $C1nodeID-2] 1 2 3 4 5 6;
#puts $eleInfo "equalDOF [expr $1rightnodeID-1] [expr $C1nodeID-2] 1 2 3 4 5 6";

#equalDOF [expr $2leftnodeID-1] [expr $C2nodeID2+1] 1 2 3 4 5 6;
#puts $eleInfo "equalDOF [expr $2leftnodeID-1] [expr $C2nodeID2+1] 1 2 3 4 5 6";

#equalDOF [expr $2rightnodeID-1] [expr $C2nodeID-2] 1 2 3 4 5 6;
#puts $eleInfo "equalDOF [expr $2rightnodeID-1] [expr $C2nodeID-2] 1 2 3 4 5 6";

element forceBeamColumn  [expr $ceshift+50+1] [expr $1leftnodeID-1] [expr $C1nodeID1+1] $cjfd  $SecTag3D  [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g];
element forceBeamColumn  [expr $ceshift+50+2] [expr $1rightnodeID-1] [expr $C1nodeID-2] $cjfd  $SecTag3D  [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g];
element forceBeamColumn  [expr $ceshift+50+3] [expr $2leftnodeID-1] [expr $C2nodeID2+1] $cjfd  $SecTag3D  [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g];
element forceBeamColumn  [expr $ceshift+50+4] [expr $2rightnodeID-1] [expr $C2nodeID-2] $cjfd  $SecTag3D  [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g];

#rigidlink beam [expr $1leftnodeID-1] [expr $C1nodeID1+1] [expr $C1nodeID1+2];         #left
#rigidlink beam [expr $1rightnodeID-1] [expr $C1nodeID-2] [expr $C1nodeID-3];           #right
#rigidlink beam [expr $2leftnodeID-1] [expr $C2nodeID1+1] [expr $C2nodeID1+2];          
#rigidlink beam [expr $2rightnodeID-1] [expr $C2nodeID-2] [expr $C21nodeID-3];


#set cp1nodeID11 [expr $1leftnodeID-1];               #建立共节点
#set cp1nodeID12 [expr $1rightnodeID-1];  
#set cp1nodeID21 [expr $C1nodeID1+4];
#set cp1nodeID22 [expr $C1nodeID1+4];
#set cp2nodeID1 [expr $2leftnodeID-1];
#set cp2nodeID2 [expr $C2nodeID2+4];

#element forceBeamColumn  [expr $ceshift+50+1] $cp1nodeID1 $cp1nodeID2 $cjfd  $SecTag3D  [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g];
#element forceBeamColumn  [expr $ceshift+50+2] $cp2nodeID1 $cp2nodeID2 $cjfd  $SecTag3D  [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g];

#puts $eleInfo "[expr $ceshift+50+1] $cp1nodeID1 $cp1nodeID2 $cjfd  $SecTag3D  [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g]" ;  ##往这个txt文件中写入单元信息 
#puts $eleInfo "[expr $ceshift+50+2] $cp2nodeID1 $cp2nodeID2 $cjfd  $SecTag3D  [expr 1+$peshift] -mass [expr $D*$D*25*1000/$g];" ;  ##往这个txt文件中写入单元信息


puts "finish capbeam2000"