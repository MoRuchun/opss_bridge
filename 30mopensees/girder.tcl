

#--------------------------------------------------------------------------------------------------
# girder 
###主梁 
set gmshift 300;
set geshift 3000;
set gnshift 3000;

##需要设置的参数
set ggd 0.04; 				#主梁与主梁之间的缝隙距离
set bh 0.1;					#支座厚度
set cdh1 -0.1773;       #0号桥台台帽顶面至一号墩台帽顶面高度差(0-1)
set cdh2 -0.3573;
set abdh -0.54;       #0号桥台台帽顶面至3号桥台台帽顶面高度差 (0-3)

# set GMgxingxinh_sample [open GMdir/gxingxinh.txt "r"];
# set GMgxingxinh_data [read $GMgxingxinh_sample];
# close $GMgxingxinh_sample;
set gxingxinh  1.24; #主梁形心高度（距主梁底端）

set gelenum 10;				#主梁划分单元数(不算支座对应点与主梁端点间的段)

# set GMgA_sample [open GMdir/gA.txt "r"];
# set GMgA_data [read $GMgA_sample];
# close $GMgA_sample;
set gA  3.536;  #主梁截面面积

set gE 3.25e10 ;	 			#主梁弹性模量
set gG [expr $gE/2/(1+0.25)] ;	#主梁剪切模量

# set GMgII_sample [open GMdir/gII.txt "r"];
# set GMgII_data [read $GMgII_sample];
# close $GMgII_sample;
set gJ  0.092155; #主梁转动惯量 ########

# set GMgIy_sample [open GMdir/gIy.txt "r"];
# set GMgIy_data [read $GMgIy_sample];
# close $GMgIy_sample;
set gIy  1.8964; #主梁饶y轴旋转的转动惯量########

# set GMgIz_sample [open GMdir/gIz.txt "r"];
# set GMgIz_data [read $GMgIz_sample];
# close $GMgIz_sample;
set gIz  18.9088;#主梁饶z轴旋转的转动惯量#########

# set GMgdg_sample [open GMdir/gdg.txt "r"];
# set GMgdg_data [read $GMgdg_sample];
# close $GMgdg_sample;
set gdg  9275.5102;  #主梁单位长度质量
#puts "盖梁gdg=$gdg"


##主梁1
puts $NodeInfo "主梁1节点"
puts $eleInfo "主梁1单元"


set g1nodeID [expr 1+$gnshift+100];
set g1nodeID1 $g1nodeID;

#主梁1节点
for {set i 0} {$i <= $gelenum} {incr i 1} { 
   set gx1 [expr $i*[expr $kj1-2*$cbd]/$gelenum] 

    node     $g1nodeID	[expr $cbd+$gx1]	0 [expr $cdh1+$ph1+$CHSec+$bh+$gxingxinh+$gx1*0.006];

    puts $NodeInfo "$g1nodeID	[expr $cbd+$gx1]	0 [expr $cdh1+$ph1+$CHSec+$bh+$gxingxinh+$gx1*0.006]";   ##往这个txt文件中写入节点信息

    incr g1nodeID 1 
}

#建立主梁单元（弹性梁单元）
set g1eleID [expr 1+$geshift+100];
set g1eleID1 $g1eleID;
geomTransf Linear [expr 1+$geshift]  0 0 1 ; 

for {set j 0} {$j <= [expr $gelenum-1]} {incr j 1} { 
    element elasticBeamColumn	$g1eleID	[expr $j+$g1nodeID1]	[expr $j+$g1nodeID1+1]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg;	
    puts $eleInfo "$g1eleID	[expr $j+$g1nodeID1]	[expr $j+$g1nodeID1+1]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg" ; ##往这个txt文件中写入单元信息
    incr g1eleID 1 
}

#主梁1外伸节点
#左端

node [expr 1+$gnshift+150] 0 0 [expr (-$kj1)*0.006++$ph1+$CHSec+$bh+$gxingxinh];
puts $NodeInfo "node [expr 1+$gnshift+150] 0 0 [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]";   ##往这个txt文件中写入节点信息
#右端
node [expr 2+$gnshift+150] $kj1 0 [expr $ph1+$CHSec+$bh+$gxingxinh];
puts $NodeInfo "node [expr 2+$gnshift+150] $kj1 0 [expr $ph1+$CHSec+$bh+$gxingxinh]";   ##往这个txt文件中写入节点信息

#主梁1外伸单元
element elasticBeamColumn [expr 1+$geshift+150] [expr 1+$gnshift+150] [expr 1+$gnshift+100] $gA $gE $gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg;	
puts $eleInfo "element elasticBeamColumn [expr 1+$geshift+150] [expr 1+$gnshift+150] [expr 1+$gnshift+100] $gA $gE	$gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg" ; ##往这个txt文件中写入单元信息

element elasticBeamColumn [expr 2+$geshift+150] [expr 11+$gnshift+100] [expr 2+$gnshift+150] $gA $gE $gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg;
puts $eleInfo "element elasticBeamColumn [expr 2+$geshift+150] [expr 11+$gnshift+100] [expr 2+$gnshift+150] $gA $gE $gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg" ; ##往这个txt文件中写入单元信息


##主梁2
puts $NodeInfo "主梁2节点"
puts $eleInfo "主梁2单元"
#设置支座节点ID
set g2nodeID [expr 1+$gnshift+200];
set g2nodeID2 $g2nodeID;

for {set i 0} {$i <= $gelenum} {incr i 1} { 
   set gx2 [expr $i*($kj2-2*$cbd)/$gelenum] 

    node     $g2nodeID	[expr $kj1+$cbd+$gx2]	0 [expr $ph1+$CHSec+$bh+$gxingxinh+$gx2*0.006];
    puts $NodeInfo "$g2nodeID	[expr $kj1+$cbd+$gx2]	0	[expr $ph1+$CHSec+$bh+$gxingxinh+$gx2*0.006]";   ##往这个txt文件中写入节点信息

    incr g2nodeID 1 
}

#建立主梁单元（弹性梁单元）
set g2eleID [expr 1+$geshift+200];
set g2eleID2 $g2eleID;
for {set j 0} {$j <= [expr $gelenum-1]} {incr j 1} { 
    element elasticBeamColumn	$g2eleID	[expr $j+$g2nodeID2]	[expr $j+$g2nodeID2+1]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg;	
	puts $eleInfo "$g2eleID	[expr $j+$g2nodeID2]	[expr $j+$g2nodeID2+1]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg" ; ##往这个txt文件中写入单元信息
    incr g2eleID 1 
}


#主梁2外伸节点

node [expr 1+$gnshift+250] $kj1 0 [expr $ph1+$CHSec+$bh+$gxingxinh];
puts $NodeInfo "node [expr 1+$gnshift+250] $kj1 0 [expr $ph1+$CHSec+$bh+$gxingxinh]";   ##往这个txt文件中写入节点信息

node [expr 2+$gnshift+250] [expr $kj1+$kj2] 0 [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh];
puts $NodeInfo "node [expr 2+$gnshift+250] [expr $kj1+$kj2] 0 [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]";   ##往这个txt文件中写入节点信息

#主梁2外伸单元

element elasticBeamColumn [expr 1+$geshift+250] [expr 1+$gnshift+250] [expr 1+$gnshift+200] $gA $gE $gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg;	
puts $eleInfo "element elasticBeamColumn [expr 1+$geshift+250] [expr 1+$gnshift+250] [expr 1+$gnshift+200] $gA $gE	$gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg" ; ##往这个txt文件中写入单元信息

element elasticBeamColumn [expr 2+$geshift+250] [expr 11+$gnshift+200] [expr 2+$gnshift+250] $gA $gE $gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg;
puts $eleInfo "element elasticBeamColumn [expr 2+$geshift+250] [expr 11+$gnshift+200] [expr 2+$gnshift+250] $gA $gE $gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg" ; ##往这个txt文件中写入单元信息


##主梁3
puts $NodeInfo "主梁3节点"
puts $eleInfo "主梁3单元"
#设置支座节点ID
set g3nodeID [expr 1+$gnshift+300];
set g3nodeID3 $g3nodeID;

for {set i 0} {$i <= $gelenum} {incr i 1} { 
   set gx3 [expr $i*($kj3-2*$cbd)/$gelenum] 

    node     $g3nodeID	[expr $kj1+$kj2+$cbd+$gx3]	0 [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh+$gx3*0.006] ;
    puts $NodeInfo "$g3nodeID	[expr $kj1+$kj2+$cbd+$gx3]	0 [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh+$gx3*0.006]";   ##往这个txt文件中写入节点信息

    incr g3nodeID 1 
}

#建立主梁单元（弹性梁单元）
set g3eleID [expr 1+$geshift+300];
set g3eleID3 $g3eleID;
for {set j 0} {$j <= [expr $gelenum-1]} {incr j 1} { 
    element elasticBeamColumn	$g3eleID	[expr $j+$g3nodeID3]	[expr $j+$g3nodeID3+1]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg;	
    puts $eleInfo "$g3eleID	[expr $j+$g3nodeID3]	[expr $j+$g3nodeID3+1]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg" ; ##往这个txt文件中写入单元信息
    incr g3eleID 1 
}
#element elasticBeamColumn	$g3eleID	[expr $g1nodeID-1]	$g3nodeID3  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift];
#puts $eleInfo "$g3eleID	[expr $g1nodeID-1]	$g3nodeID3  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift]";##往这个txt文件中写入单元信息


#主梁3外伸节点

node [expr 1+$gnshift+350] [expr $kj1+$kj2] 0 [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh];
puts $NodeInfo "node [expr 1+$gnshift+350] [expr $kj1+$kj2] 0 [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]";   ##往这个txt文件中写入节点信息

node [expr 2+$gnshift+350] [expr $kj1+$kj2+$kj3] 0 [expr 2*$kj1*0.006+$ph1+$CHSec+$bh+$gxingxinh];
puts $NodeInfo "node [expr 2+$gnshift+350] [expr $kj1+$kj2+$kj3] 0 [expr 2*$kj1*0.006+$ph1+$CHSec+$bh+$gxingxinh]";   ##往这个txt文件中写入节点信息

#主梁3外伸单元

element elasticBeamColumn [expr 1+$geshift+350] [expr 1+$gnshift+350] [expr 1+$gnshift+300] $gA $gE $gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg;	
puts $eleInfo "element elasticBeamColumn [expr 1+$geshift+350] [expr 1+$gnshift+350] [expr 1+$gnshift+300] $gA $gE	$gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg" ; ##往这个txt文件中写入单元信息

element elasticBeamColumn [expr 2+$geshift+350]  [expr 11+$gnshift+300] [expr 2+$gnshift+350] $gA $gE $gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg;
puts $eleInfo "element elasticBeamColumn [expr 2+$geshift+350] [expr 11+$gnshift+300] [expr 2+$gnshift+350] $gA $gE $gG $gJ $gIy $gIz [expr 1+$geshift] -mass $gdg" ; ##往这个txt文件中写入单元信息


##建立主梁端点到支座对应点
#puts $NodeInfo "建立主梁端点到支座对应点 节点"
#puts $eleInfo  "建立主梁端点到支座对应点 单元"
#节点
#node [expr 1+$gnshift+600] 0 0 [expr $ph1+$CHSec+$bh+$gxingxinh] ;
#node [expr 2+$gnshift+600] 0 0 [expr $ph1+$CHSec+$bh+$gxingxinh] ;

#node [expr 3+$gnshift+600] $kj1 0 [expr $ph1+$CHSec+$bh+$gxingxinh] ;
#node [expr 4+$gnshift+600] $kj1 0 [expr $ph1+$CHSec+$bh+$gxingxinh] ;

#puts $NodeInfo "[expr 1+$gnshift+600] 0 0 [expr $ph1+$CHSec+$bh+$gxingxinh]" ;##往这个txt文件中写入单元信息
#puts $NodeInfo "[expr 2+$gnshift+600] 0 0 [expr $ph1+$CHSec+$bh+$gxingxinh] ";##往这个txt文件中写入单元信息
#puts $NodeInfo "[expr 3+$gnshift+600] $kj1 0 [expr $ph1+$CHSec+$bh+$gxingxinh] ";##往这个txt文件中写入单元信息
#puts $NodeInfo "[expr 4+$gnshift+600] $kj1 0 [expr $ph1+$CHSec+$bh+$gxingxinh]";##往这个txt文件中写入单元信息

#单元
#element elasticBeamColumn	[expr 1+$gnshift+600]	[expr $g2nodeID-1]	[expr 1+$gnshift+600]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg;
#element elasticBeamColumn	[expr 2+$gnshift+600]	[expr $g1nodeID1]		[expr 2+$gnshift+600]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg;
#element elasticBeamColumn	[expr 3+$gnshift+600]	[expr $g1nodeID-1]	[expr 3+$gnshift+600]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg;
#element elasticBeamColumn	[expr 4+$gnshift+600]	[expr $g3nodeID3]		[expr 4+$gnshift+600]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg;

#puts $eleInfo "[expr 1+$gnshift+600]	[expr $g2nodeID-1]	[expr 1+$gnshift+600]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg"; ##往这个txt文件中写入单元信息
#puts $eleInfo "[expr 2+$gnshift+600]	[expr $g1nodeID1]	[expr 2+$gnshift+600]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg"; ##往这个txt文件中写入单元信息
#puts $eleInfo "[expr 3+$gnshift+600]	[expr $g1nodeID-1]	[expr 3+$gnshift+600]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg"; ##往这个txt文件中写入单元信息
#puts $eleInfo "[expr 4+$gnshift+600]	[expr $g3nodeID3]	[expr 4+$gnshift+600]  $gA	$gE	$gG	$gJ	$gIy	$gIz	[expr 1+$geshift] -mass $gdg"; ##往这个txt文件中写入单元信息

#桥跨刚臂
#node [expr 1+$gnshift+700] [expr -($halfg*tan($a))] [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];
#node [expr 2+$gnshift+700] [expr ($halfg*tan($a))] [expr $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];
#node [expr 3+$gnshift+700] [expr -($halfg*tan($a))] [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];
#node [expr 4+$gnshift+700] [expr ($halfg*tan($a))] [expr $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];
#node [expr 5+$gnshift+700] [expr $kj1-($halfg*tan($a))] [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];
#node [expr 6+$gnshift+700] [expr $kj1+($halfg*tan($a))] [expr $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];
#node [expr 7+$gnshift+700] [expr $kj1-($halfg*tan($a))] [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];
#node [expr 8+$gnshift+700] [expr $kj1+($halfg*tan($a))] [expr $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];

#puts $NodeInfo "[expr 1+$gnshift+700] [expr -($halfg*tan($a))] [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";
#puts $NodeInfo "[expr 2+$gnshift+700] [expr ($halfg*tan($a))] [expr $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";
#puts $NodeInfo "[expr 3+$gnshift+700] [expr -($halfg*tan($a))] [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";
#puts $NodeInfo "[expr 4+$gnshift+700] [expr ($halfg*tan($a))] [expr $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";
#puts $NodeInfo "[expr 5+$gnshift+700] [expr $kj1-($halfg*tan($a))] [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";
#puts $NodeInfo "[expr 6+$gnshift+700] [expr $kj1+($halfg*tan($a))] [expr $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";
#puts $NodeInfo "[expr 7+$gnshift+700] [expr $kj1-($halfg*tan($a))] [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";
#puts $NodeInfo "[expr 8+$gnshift+700] [expr $kj1+($halfg*tan($a))] [expr $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";

#rigidLink beam [expr 1+$gnshift+600] [expr 1+$gnshift+700];
#rigidLink beam [expr 1+$gnshift+600] [expr 2+$gnshift+700];
#rigidLink beam [expr 2+$gnshift+600] [expr 3+$gnshift+700];
#rigidLink beam [expr 2+$gnshift+600] [expr 4+$gnshift+700];
#rigidLink beam [expr 3+$gnshift+600] [expr 5+$gnshift+700];
#rigidLink beam [expr 3+$gnshift+600] [expr 6+$gnshift+700];
#rigidLink beam [expr 4+$gnshift+600] [expr 7+$gnshift+700];
#rigidLink beam [expr 4+$gnshift+600] [expr 8+$gnshift+700];

#puts $eleInfo "rigidLink beam [expr 1+$gnshift+600] [expr 1+$gnshift+700]";
#puts $eleInfo "rigidLink beam [expr 1+$gnshift+600] [expr 2+$gnshift+700]";
#puts $eleInfo "rigidLink beam [expr 2+$gnshift+600] [expr 3+$gnshift+700]";
#puts $eleInfo "rigidLink beam [expr 2+$gnshift+600] [expr 4+$gnshift+700]";
#puts $eleInfo "rigidLink beam [expr 3+$gnshift+600] [expr 5+$gnshift+700]";
#puts $eleInfo "rigidLink beam [expr 3+$gnshift+600] [expr 6+$gnshift+700]";
#puts $eleInfo "rigidLink beam [expr 4+$gnshift+600] [expr 7+$gnshift+700]";
#puts $eleInfo "rigidLink beam [expr 4+$gnshift+600] [expr 8+$gnshift+700]";

# set GMhalfg_sample [open GMdir/halfg.txt "r"];
# set GMhalfg_data [read $GMhalfg_sample];
# close $GMhalfg_sample;
set halfg 4; #主梁宽度的一半


##桥跨刚臂？？？？？？？？？？？？？？？？？
#间隙1左边
set gap11nodeID1 [expr 2+$gnshift+500];
for {set i 0} {$i <= [expr $celenum/2-1]} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 
    node     $gap11nodeID1    $kj1  [expr -$czc/2+$cy]  [expr $ph1+$CHSec+$bh+$gxingxinh];
    puts $NodeInfo "$gap11nodeID1    $kj1 [expr -$czc/2+$cy]  [expr $ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr gap11nodeID1 1 
}
set gap11nodeID2 [expr 7+$gnshift+500];
for {set i 1} {$i <= [expr $celenum/2]} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 
    node     $gap11nodeID2    $kj1  $cy  [expr $ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$gap11nodeID2    $kj1  $cy  [expr $ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr gap11nodeID2 1 
}
node 3501 $kj1 [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 3501 $kj1 [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 3511 $kj1 [expr  $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   3511 $kj1 [expr  $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息
#间隙1右边
set gap12nodeID1 [expr 2+$gnshift+600];
for {set i 0} {$i <= [expr $celenum/2-1]} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 
    node     $gap12nodeID1    $kj1  [expr -$czc/2+$cy]  [expr $ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$gap12nodeID1    $kj1  [expr -$czc/2+$cy]  [expr $ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr gap12nodeID1 1 
}
set gap12nodeID2 [expr 7+$gnshift+600];
for {set i 1} {$i <= [expr $celenum/2]} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 
    node     $gap12nodeID2     $kj1  $cy  [expr $ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$gap12nodeID2     $kj1  $cy  [expr $ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr gap12nodeID2 1 
}
node   3601    $kj1 [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node   3601    $kj1 [expr -$halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node   3611    $kj1 [expr  $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh];                                     
puts $NodeInfo "node   3607    $kj1 [expr  $halfg] [expr $ph1+$CHSec+$bh+$gxingxinh]";                    #往NodeInfo文件中写入引号内信息


#间隙2左边
set gap21nodeID1 [expr 2+$gnshift+700];
for {set i 0} {$i <= [expr $celenum/2-1]} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 
    node     $gap21nodeID1    [expr $kj1+$kj2]  [expr -$czc/2+$cy]  [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$gap21nodeID1    [expr $kj1+$kj2]  [expr -$czc/2+$cy]  [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr gap21nodeID1 1 
}
set gap21nodeID2 [expr 7+$gnshift+700];
for {set i 1} {$i <= [expr $celenum/2]} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 
    node     $gap21nodeID2    [expr $kj1+$kj2]  $cy  [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$gap21nodeID2    [expr $kj1+$kj2]  $cy  [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr gap21nodeID2 1 
}
node 3701 [expr $kj1+$kj2] [expr -$halfg] [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 3701 [expr $kj1+$kj2] [expr -$halfg] [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 3711 [expr $kj1+$kj2] [expr  $halfg] [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   3711 [expr $kj1+$kj2] [expr  $halfg] [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息
#间隙2右边
set gap22nodeID1 [expr 2+$gnshift+800];
for {set i 0} {$i <= [expr $celenum/2-1]} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 
    node     $gap22nodeID1    [expr $kj1+$kj2]  [expr -$czc/2+$cy]  [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$gap22nodeID1    [expr $kj1+$kj2]  [expr -$czc/2+$cy]  [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr gap22nodeID1 1 
}
set gap22nodeID2 [expr 7+$gnshift+800];
for {set i 1} {$i <= [expr $celenum/2]} {incr i 1} { 
   set cy [expr $i*($czc/$celenum)] 
    node     $gap22nodeID2    [expr $kj1+$kj2]  $cy  [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$gap22nodeID2    [expr $kj1+$kj2]  $cy  [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr gap22nodeID2 1 
}
node   3801   [expr $kj1+$kj2] [expr -$halfg] [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node   3801   [expr $kj1+$kj2] [expr -$halfg] [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node   3811  [expr $kj1+$kj2] [expr  $halfg] [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh];                                     
puts $NodeInfo "node   3807 [expr $kj1+$kj2] [expr  $halfg] [expr -$dh+$ph2+$CHSec+$bh+$gxingxinh]";                    #往NodeInfo文件中写入引号内信息



##刚臂连接
# 1左
rigidLink beam [expr 2+$gnshift+150] [expr 7+$gnshift+500];
rigidLink beam [expr 7+$gnshift+500] [expr 8+$gnshift+500];
rigidLink beam [expr 8+$gnshift+500] [expr 9+$gnshift+500];
rigidLink beam [expr 9+$gnshift+500] [expr 10+$gnshift+500];
rigidLink beam [expr 10+$gnshift+500] [expr 11+$gnshift+500];
rigidLink beam [expr 2+$gnshift+150] [expr 5+$gnshift+500];
rigidLink beam [expr 5+$gnshift+500] [expr 4+$gnshift+500];
rigidLink beam [expr 4+$gnshift+500] [expr 3+$gnshift+500];
rigidLink beam [expr 3+$gnshift+500] [expr 2+$gnshift+500];
rigidLink beam [expr 2+$gnshift+500] [expr 1+$gnshift+500];
puts $eleInfo "rigidLink beam [expr 2+$gnshift+150] [expr 7+$gnshift+500]";
puts $eleInfo "rigidLink beam [expr 7+$gnshift+500] [expr 8+$gnshift+500]";
puts $eleInfo "rigidLink beam [expr 8+$gnshift+500] [expr 9+$gnshift+500]";
puts $eleInfo "rigidLink beam [expr 9+$gnshift+500] [expr 10+$gnshift+500]";
puts $eleInfo "rigidLink beam [expr 10+$gnshift+500] [expr 11+$gnshift+500]";
puts $eleInfo "rigidLink beam [expr 2+$gnshift+150] [expr 5+$gnshift+500]";
puts $eleInfo "rigidLink beam [expr 5+$gnshift+500] [expr 4+$gnshift+500]";
puts $eleInfo "rigidLink beam [expr 4+$gnshift+500] [expr 3+$gnshift+500]";
puts $eleInfo "rigidLink beam [expr 3+$gnshift+500] [expr 2+$gnshift+500]";
puts $eleInfo "rigidLink beam [expr 2+$gnshift+500] [expr 1+$gnshift+500]";
# 1右
rigidLink beam [expr 1+$gnshift+250] [expr 7+$gnshift+600];
rigidLink beam [expr 7+$gnshift+600] [expr 8+$gnshift+600];
rigidLink beam [expr 8+$gnshift+600] [expr 9+$gnshift+600];
rigidLink beam [expr 9+$gnshift+600] [expr 10+$gnshift+600];
rigidLink beam [expr 10+$gnshift+600] [expr 11+$gnshift+600];
rigidLink beam [expr 1+$gnshift+250] [expr 5+$gnshift+600];
rigidLink beam [expr 5+$gnshift+600] [expr 4+$gnshift+600];
rigidLink beam [expr 4+$gnshift+600] [expr 3+$gnshift+600];
rigidLink beam [expr 3+$gnshift+600] [expr 2+$gnshift+600];
rigidLink beam [expr 2+$gnshift+600] [expr 1+$gnshift+600];
puts $eleInfo "rigidLink beam [expr 1+$gnshift+250] [expr 7+$gnshift+600]";
puts $eleInfo "rigidLink beam [expr 7+$gnshift+600] [expr 8+$gnshift+600]";
puts $eleInfo "rigidLink beam [expr 8+$gnshift+600] [expr 9+$gnshift+600]";
puts $eleInfo "rigidLink beam [expr 9+$gnshift+600] [expr 10+$gnshift+600]";
puts $eleInfo "rigidLink beam [expr 10+$gnshift+600] [expr 11+$gnshift+600]";
puts $eleInfo "rigidLink beam [expr 1+$gnshift+250] [expr 5+$gnshift+600]";
puts $eleInfo "rigidLink beam [expr 5+$gnshift+600] [expr 4+$gnshift+600]";
puts $eleInfo "rigidLink beam [expr 4+$gnshift+600] [expr 3+$gnshift+600]";
puts $eleInfo "rigidLink beam [expr 3+$gnshift+600] [expr 2+$gnshift+600]";
puts $eleInfo "rigidLink beam [expr 2+$gnshift+600] [expr 1+$gnshift+600]";

# 2左
rigidLink beam [expr 2+$gnshift+250] [expr 7+$gnshift+700];
rigidLink beam [expr 7+$gnshift+700] [expr 8+$gnshift+700];
rigidLink beam [expr 8+$gnshift+700] [expr 9+$gnshift+700];
rigidLink beam [expr 9+$gnshift+700] [expr 10+$gnshift+700];
rigidLink beam [expr 10+$gnshift+700] [expr 11+$gnshift+700];
rigidLink beam [expr 2+$gnshift+250] [expr 5+$gnshift+700];
rigidLink beam [expr 5+$gnshift+700] [expr 4+$gnshift+700];
rigidLink beam [expr 4+$gnshift+700] [expr 3+$gnshift+700];
rigidLink beam [expr 3+$gnshift+700] [expr 2+$gnshift+700];
rigidLink beam [expr 2+$gnshift+700] [expr 1+$gnshift+700];
puts $eleInfo "rigidLink beam [expr 2+$gnshift+250] [expr 7+$gnshift+700]";
puts $eleInfo "rigidLink beam [expr 7+$gnshift+700] [expr 8+$gnshift+700]";
puts $eleInfo "rigidLink beam [expr 8+$gnshift+700] [expr 9+$gnshift+700]";
puts $eleInfo "rigidLink beam [expr 9+$gnshift+700] [expr 10+$gnshift+700]";
puts $eleInfo "rigidLink beam [expr 10+$gnshift+700] [expr 11+$gnshift+700]";
puts $eleInfo "rigidLink beam [expr 2+$gnshift+250] [expr 5+$gnshift+700]";
puts $eleInfo "rigidLink beam [expr 5+$gnshift+700] [expr 4+$gnshift+700]";
puts $eleInfo "rigidLink beam [expr 4+$gnshift+700] [expr 3+$gnshift+700]";
puts $eleInfo "rigidLink beam [expr 3+$gnshift+700] [expr 2+$gnshift+700]";
puts $eleInfo "rigidLink beam [expr 2+$gnshift+700] [expr 1+$gnshift+700]";
# 2右
rigidLink beam [expr 1+$gnshift+350] [expr 7+$gnshift+800];
rigidLink beam [expr 7+$gnshift+800] [expr 8+$gnshift+800];
rigidLink beam [expr 8+$gnshift+800] [expr 9+$gnshift+800];
rigidLink beam [expr 9+$gnshift+800] [expr 10+$gnshift+800];
rigidLink beam [expr 10+$gnshift+800] [expr 11+$gnshift+800];
rigidLink beam [expr 1+$gnshift+350] [expr 5+$gnshift+800];
rigidLink beam [expr 5+$gnshift+800] [expr 4+$gnshift+800];
rigidLink beam [expr 4+$gnshift+800] [expr 3+$gnshift+800];
rigidLink beam [expr 3+$gnshift+800] [expr 2+$gnshift+800];
rigidLink beam [expr 2+$gnshift+800] [expr 1+$gnshift+800];
puts $eleInfo "rigidLink beam [expr 1+$gnshift+350] [expr 7+$gnshift+800]";
puts $eleInfo "rigidLink beam [expr 7+$gnshift+800] [expr 8+$gnshift+800]";
puts $eleInfo "rigidLink beam [expr 8+$gnshift+800] [expr 9+$gnshift+800]";
puts $eleInfo "rigidLink beam [expr 9+$gnshift+800] [expr 10+$gnshift+800]";
puts $eleInfo "rigidLink beam [expr 10+$gnshift+800] [expr 11+$gnshift+800]";
puts $eleInfo "rigidLink beam [expr 1+$gnshift+350] [expr 5+$gnshift+800]";
puts $eleInfo "rigidLink beam [expr 5+$gnshift+800] [expr 4+$gnshift+800]";
puts $eleInfo "rigidLink beam [expr 4+$gnshift+800] [expr 3+$gnshift+800]";
puts $eleInfo "rigidLink beam [expr 3+$gnshift+800] [expr 2+$gnshift+800]";
puts $eleInfo "rigidLink beam [expr 2+$gnshift+800] [expr 1+$gnshift+800]";

# 3左
#rigidLink beam [expr 2+$gnshift+350] [expr 7+$gnshift+900];
#rigidLink beam [expr 7+$gnshift+900] [expr 8+$gnshift+900];
#rigidLink beam [expr 8+$gnshift+900] [expr 9+$gnshift+900];
#rigidLink beam [expr 9+$gnshift+900] [expr 10+$gnshift+900];
#rigidLink beam [expr 10+$gnshift+900] [expr 11+$gnshift+900];
#rigidLink beam [expr 2+$gnshift+350] [expr 5+$gnshift+900];
#rigidLink beam [expr 5+$gnshift+900] [expr 4+$gnshift+900];
#rigidLink beam [expr 4+$gnshift+900] [expr 3+$gnshift+900];
#rigidLink beam [expr 3+$gnshift+900] [expr 2+$gnshift+900];
#rigidLink beam [expr 2+$gnshift+900] [expr 1+$gnshift+900];
#puts $eleInfo "rigidLink beam [expr 2+$gnshift+350] [expr 7+$gnshift+900]";
#puts $eleInfo "rigidLink beam [expr 7+$gnshift+900] [expr 8+$gnshift+900]";
#puts $eleInfo "rigidLink beam [expr 8+$gnshift+900] [expr 9+$gnshift+900]";
#puts $eleInfo "rigidLink beam [expr 9+$gnshift+900] [expr 10+$gnshift+900]";
#puts $eleInfo "rigidLink beam [expr 10+$gnshift+900] [expr 11+$gnshift+900]";
#puts $eleInfo "rigidLink beam [expr 2+$gnshift+350] [expr 5+$gnshift+900]";
#puts $eleInfo "rigidLink beam [expr 5+$gnshift+900] [expr 4+$gnshift+900]";
#puts $eleInfo "rigidLink beam [expr 4+$gnshift+900] [expr 3+$gnshift+900]";
#puts $eleInfo "rigidLink beam [expr 3+$gnshift+900] [expr 2+$gnshift+900]";
#puts $eleInfo "rigidLink beam [expr 2+$gnshift+900] [expr 1+$gnshift+900]";
# 3右
#rigidLink beam [expr 1+$gnshift+450] [expr 7+$gnshift];
#rigidLink beam [expr 7+$gnshift] [expr 8+$gnshift];
#rigidLink beam [expr 8+$gnshift] [expr 9+$gnshift];
#rigidLink beam [expr 9+$gnshift] [expr 10+$gnshift];
#rigidLink beam [expr 10+$gnshift] [expr 11+$gnshift];
#rigidLink beam [expr 1+$gnshift+450] [expr 5+$gnshift];
#rigidLink beam [expr 5+$gnshift] [expr 4+$gnshift];
#rigidLink beam [expr 4+$gnshift] [expr 3+$gnshift];
#rigidLink beam [expr 3+$gnshift] [expr 2+$gnshift];
#rigidLink beam [expr 2+$gnshift] [expr 1+$gnshift];
#puts $eleInfo "rigidLink beam [expr 1+$gnshift+450] [expr 7+$gnshift]";
#puts $eleInfo "rigidLink beam [expr 7+$gnshift] [expr 8+$gnshift]";
#puts $eleInfo "rigidLink beam [expr 8+$gnshift] [expr 9+$gnshift]";
#puts $eleInfo "rigidLink beam [expr 9+$gnshift] [expr 10+$gnshift]";
#puts $eleInfo "rigidLink beam [expr 10+$gnshift] [expr 11+$gnshift]";
#puts $eleInfo "rigidLink beam [expr 1+$gnshift+450] [expr 5+$gnshift]";
#puts $eleInfo "rigidLink beam [expr 5+$gnshift] [expr 4+$gnshift]";
#puts $eleInfo "rigidLink beam [expr 4+$gnshift] [expr 3+$gnshift]";
#puts $eleInfo "rigidLink beam [expr 3+$gnshift] [expr 2+$gnshift]";
#puts $eleInfo "rigidLink beam [expr 2+$gnshift] [expr 1+$gnshift]";

#间隙单元
set matIDgirdergap [expr 1+$gmshift];
set ggap 0.04;
set kgap [expr 0.5*$gE*$gA/$kj1/11];
set fygap 1.0e20;
uniaxialMaterial ElasticPPGap $matIDgirdergap $kgap -$fygap -$ggap;

element zeroLength [expr 1+$geshift+500] [expr 1+$gnshift+500] [expr 1+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 2+$geshift+500] [expr 2+$gnshift+500] [expr 2+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 3+$geshift+500] [expr 3+$gnshift+500] [expr 3+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 4+$geshift+500] [expr 4+$gnshift+500] [expr 4+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 5+$geshift+500] [expr 5+$gnshift+500] [expr 5+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 6+$geshift+500] [expr 2+$gnshift+150] [expr 1+$gnshift+250] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 7+$geshift+500] [expr 7+$gnshift+500] [expr 7+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 8+$geshift+500] [expr 8+$gnshift+500] [expr 8+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 9+$geshift+500] [expr 9+$gnshift+500] [expr 9+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 10+$geshift+500] [expr 10+$gnshift+500] [expr 10+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 11+$geshift+500] [expr 11+$gnshift+500] [expr 11+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;

puts $eleInfo "element zeroLength [expr 1+$geshift+500] [expr 1+$gnshift+500] [expr 1+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 2+$geshift+500] [expr 2+$gnshift+500] [expr 2+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 3+$geshift+500] [expr 3+$gnshift+500] [expr 3+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 4+$geshift+500] [expr 4+$gnshift+500] [expr 4+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 5+$geshift+500] [expr 5+$gnshift+500] [expr 5+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 6+$geshift+500] [expr 2+$gnshift+150] [expr 1+$gnshift+250] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 7+$geshift+500] [expr 7+$gnshift+500] [expr 7+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 8+$geshift+500] [expr 8+$gnshift+500] [expr 8+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 9+$geshift+500] [expr 9+$gnshift+500] [expr 9+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 10+$geshift+500] [expr 10+$gnshift+500] [expr 10+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 11+$geshift+500] [expr 11+$gnshift+500] [expr 11+$gnshift+600] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";

element zeroLength [expr 1+$geshift+700] [expr 1+$gnshift+700] [expr 1+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 2+$geshift+700] [expr 2+$gnshift+700] [expr 2+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 3+$geshift+700] [expr 3+$gnshift+700] [expr 3+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 4+$geshift+700] [expr 4+$gnshift+700] [expr 4+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 5+$geshift+700] [expr 5+$gnshift+700] [expr 5+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 6+$geshift+700] [expr 2+$gnshift+250] [expr 1+$gnshift+350] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 7+$geshift+700] [expr 7+$gnshift+700] [expr 7+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 8+$geshift+700] [expr 8+$gnshift+700] [expr 8+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 9+$geshift+700] [expr 9+$gnshift+700] [expr 9+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 10+$geshift+700] [expr 10+$gnshift+700] [expr 10+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
element zeroLength [expr 11+$geshift+700] [expr 11+$gnshift+700] [expr 11+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;

puts $eleInfo "element zeroLength [expr 1+$geshift+700] [expr 1+$gnshift+700] [expr 1+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 2+$geshift+700] [expr 2+$gnshift+700] [expr 2+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 3+$geshift+700] [expr 3+$gnshift+700] [expr 3+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 4+$geshift+700] [expr 4+$gnshift+700] [expr 4+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 5+$geshift+700] [expr 5+$gnshift+700] [expr 5+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 6+$geshift+700] [expr 2+$gnshift+250] [expr 1+$gnshift+350] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 7+$geshift+700] [expr 7+$gnshift+700] [expr 7+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 8+$geshift+700] [expr 8+$gnshift+700] [expr 8+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 9+$geshift+700] [expr 9+$gnshift+700] [expr 9+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 10+$geshift+700] [expr 10+$gnshift+700] [expr 10+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength [expr 11+$geshift+700] [expr 11+$gnshift+700] [expr 11+$gnshift+800] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";

#element zeroLength [expr 1+$geshift+900] [expr 1+$gnshift+900] [expr 1+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 2+$geshift+900] [expr 2+$gnshift+900] [expr 2+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 3+$geshift+900] [expr 3+$gnshift+900] [expr 3+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 4+$geshift+900] [expr 4+$gnshift+900] [expr 4+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 5+$geshift+900] [expr 5+$gnshift+900] [expr 5+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 6+$geshift+900] [expr 2+$gnshift+350] [expr 1+$gnshift+450] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 7+$geshift+900] [expr 7+$gnshift+900] [expr 7+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 8+$geshift+900] [expr 8+$gnshift+900] [expr 8+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 9+$geshift+900] [expr 9+$gnshift+900] [expr 9+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 10+$geshift+900] [expr 10+$gnshift+900] [expr 10+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;
#element zeroLength [expr 11+$geshift+900] [expr 11+$gnshift+900] [expr 11+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0;

#puts $eleInfo "element zeroLength [expr 1+$geshift+900] [expr 1+$gnshift+900] [expr 1+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 2+$geshift+900] [expr 2+$gnshift+900] [expr 2+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 3+$geshift+900] [expr 3+$gnshift+900] [expr 3+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 4+$geshift+900] [expr 4+$gnshift+900] [expr 4+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 5+$geshift+900] [expr 5+$gnshift+900] [expr 5+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 6+$geshift+900] [expr 2+$gnshift+350] [expr 1+$gnshift+450] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 7+$geshift+900] [expr 7+$gnshift+900] [expr 7+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 8+$geshift+900] [expr 8+$gnshift+900] [expr 8+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 9+$geshift+900] [expr 9+$gnshift+900] [expr 9+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 10+$geshift+900] [expr 10+$gnshift+900] [expr 10+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts $eleInfo "element zeroLength [expr 11+$geshift+900] [expr 11+$gnshift+900] [expr 11+$gnshift] -mat $matIDgirdergap -dir 1 -orient 1 0 0 0 1 0";
#puts "g1nodeID=$g1nodeID";
#puts "g2nodeID=$g2nodeID";
#puts "g3nodeID=$g3nodeID";
#puts "g1nodeID1=$g1nodeID1";
#puts "g2nodeID2=$g2nodeID2";
#puts "g3nodeID3=$g3nodeID3";

puts "finish girder" 

