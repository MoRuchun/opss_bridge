# Abutment
# 桥台 单位 m Mpa

set   amshift     500;           #材料转换编号 
set   anshift     5000;          #节点转换编号
set   aeshift     5000;          #单元转换编号

# 参数设置


set akgap [expr 0.5*$gE*$gA/$kj1/11];
set agap  0.02;
set fygap 1.0e20;

# 桥台被土纵向刚度KL
#set KL  8.43897e7; #桥台端点纵向刚度
#set KL  4.49882e6; #桥台端点纵向刚度
set KL  3.693029e7; #桥台端点纵向刚度

# 桥台被土纵向屈服应变
set epsyP  0.068; 

# 桥台端点横向刚度
#set KT 22242500; #桥台端点横向刚度
set KT  4.00174e7
#set KT  6.0855e7

# 桥台端点横向屈服应变
set disPT  0.028313588; 



# 材料定义
uniaxialMaterial ElasticPPGap 501 $akgap   -$fygap    -$agap;    #GAP单元纵向7弹簧
#uniaxialMaterial ElasticPP    502 $KL      $epsyP;             #桥台被土纵向刚度
#uniaxialMaterial ElasticPP    513 $KT      $disPT;             #桥台端点横向刚度
#横向剪力键和桩基础的作用
uniaxialMaterial ElasticPP    513 $KT      1;             #桥台端点横向刚度
uniaxialMaterial Elastic      504 $Ubig;

#更新材料 
uniaxialMaterial HyperbolicGapMaterial 511 [expr $KL] [expr $KL] 0.7 [expr -3.26e6] [expr -$ggd]; #桥台被土纵向刚度
uniaxialMaterial Hysteretic 512 [expr 1.78e5] 0.3 [expr 2.1e5] 1 [expr -1.78e5] -0.3 [expr -2.1e5] -1 0.6 0.6 0 0;     #桩的作用
uniaxialMaterial Parallel  502 511 512 ;      #桥台纵向材料
uniaxialMaterial Parallel  503 513 512 ;      #桥台横向材料

# 0号桥台刚臂上节点

puts $NodeInfo "桥台1节点";     #在文件NodeInfo文件中写入“桥台1节点”
puts $eleInfo  "桥台1单元";     #在文件eleInfo文件中写入“桥台1单元”

# 与主梁相连节点
set a1nodeupID1 [expr 2+$anshift+100];
for {set i 0} {$i <= [expr $celenum/2-1]} {incr i 1} { 
   set ay [expr $i*($czc/$celenum)] 
    node     $a1nodeupID1    0  [expr -$czc/2+$ay]  [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$a1nodeupID1    0  [expr -$czc/2+$ay]  [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr a1nodeupID1 1 
}
set a1nodeupID2 [expr 7+$anshift+100];
for {set i 1} {$i <= [expr $celenum/2]} {incr i 1} { 
   set ay [expr $i*($czc/$celenum)] 
    node     $a1nodeupID2    0  $ay  [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$a1nodeupID2    0  $ay  [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr a1nodeupID2 1 
}
node 5101 0 [expr -$halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 5101 0 [expr -$halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 5111 0 [expr  $halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   5111 0 [expr  $halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息

# 0号桥台刚臂下节点

set a1nodedownID [expr 2+$anshift+200];
for {set i 0} {$i <= $celenum} {incr i 1} { 
   set ay [expr $i*($czc/$celenum)] 
    node     $a1nodedownID    0  [expr -$czc/2+$ay]  [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$a1nodedownID    0  [expr -$czc/2+$ay]  [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr a1nodedownID 1 
}

node 5201 0 [expr -$halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 5201 0 [expr -$halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 5211 0 [expr  $halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   5211 0 [expr  $halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息

# 0号桥台下固定节点

set a1nodeID [expr 2+$anshift+300];
for {set i 0} {$i <= $celenum} {incr i 1} { 
   set ay [expr $i*($czc/$celenum)] 
    node     $a1nodeID    0  [expr -$czc/2+$ay]  [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$a1nodeID    0  [expr -$czc/2+$ay]  [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr a1nodeID 1 
}

node 5301 0 [expr -$halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 5301 0 [expr -$halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 5311 0 [expr  $halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   5311 0 [expr  $halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息

#横桥向
node 5701 0 [expr -$halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 5701 0 [expr -$halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 5711 0 [expr  $halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   5711 0 [expr  $halfg] [expr (-$kj1)*0.006+$ph1+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息

# 桥台0刚臂建立

rigidLink beam 3151 5105;      #3151为主梁外伸节点
rigidLink beam 5105 5104;
rigidLink beam 5104 5103;
rigidLink beam 5103 5102;
rigidLink beam 5102 5101;
rigidLink beam 3151 5107;
rigidLink beam 5107 5108;
rigidLink beam 5108 5109;
rigidLink beam 5109 5110;
rigidLink beam 5110 5111;

puts $eleInfo "rigidLink beam 3151 5105";
puts $eleInfo "rigidLink beam 5105 5104";
puts $eleInfo "rigidLink beam 5104 5103";
puts $eleInfo "rigidLink beam 5103 5102";
puts $eleInfo "rigidLink beam 5102 5101";
puts $eleInfo "rigidLink beam 3151 5107";
puts $eleInfo "rigidLink beam 5107 5108";
puts $eleInfo "rigidLink beam 5108 5109";
puts $eleInfo "rigidLink beam 5109 5110";
puts $eleInfo "rigidLink beam 5110 5111";

rigidLink beam 5206 5205;
rigidLink beam 5205 5204;
rigidLink beam 5204 5203;
rigidLink beam 5203 5202;
rigidLink beam 5202 5201;
rigidLink beam 5206 5207;
rigidLink beam 5207 5208;
rigidLink beam 5208 5209;
rigidLink beam 5209 5210;
rigidLink beam 5210 5211;

puts $eleInfo "rigidLink beam 5206 5205";
puts $eleInfo "rigidLink beam 5205 5204";
puts $eleInfo "rigidLink beam 5204 5203";
puts $eleInfo "rigidLink beam 5203 5202";
puts $eleInfo "rigidLink beam 5202 5201";
puts $eleInfo "rigidLink beam 5206 5207";
puts $eleInfo "rigidLink beam 5207 5208";
puts $eleInfo "rigidLink beam 5208 5209";
puts $eleInfo "rigidLink beam 5209 5210";
puts $eleInfo "rigidLink beam 5210 5211";

# 桥台1边界条件——零长度Gap单元

element zeroLength 5101 5201 5101 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5102 5202 5102 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5103 5203 5103 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5104 5204 5104 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5105 5205 5105 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5106 5206 3151 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5107 5207 5107 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5108 5208 5108 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5109 5209 5109 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5110 5210 5110 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5111 5211 5111 -mat 501 -dir 1 -orient 1 0 0 0 1 0;

puts $eleInfo "element zeroLength 5101 5201 5101 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5102 5202 5102 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5103 5203 5103 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5104 5204 5104 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5105 5205 5105 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5106 5206 3151 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5107 5207 5107 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5108 5208 5108 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5109 5209 5109 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5110 5210 5110 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5111 5211 5111 -mat 501 -dir 1 -orient 1 0 0 0 1 0";

# 桥台1边界条件——零长度桥台被土单元

element zeroLength 5701 5701 5101 -mat 503 -dir 2;
element zeroLength 5711 5711 5111 -mat 503 -dir 2;

puts $eleInfo "element zeroLength 5701 5701 5101 -mat 503 -dir 2";
puts $eleInfo "element zeroLength 5711 5711 5111 -mat 503 -dir 2"

element zeroLength 5201 5301 5201 -mat 502 504 504 504 504 504 -dir 1 2 3 4 5 6 -orient 1 0 0 0 1 0;
element zeroLength 5211 5311 5211 -mat 502 504 504 504 504 504 -dir 1 2 3 4 5 6 -orient 1 0 0 0 1 0;

puts $eleInfo "element zeroLength 5201 5301 5201 -mat 502 503 504 504 504 504 -dir 1 2 3 4 5 6 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5211 5311 5211 -mat 502 503 504 504 504 504 -dir 1 2 3 4 5 6 -orient 1 0 0 0 1 0";

element zeroLength 5202 5302 5202 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5203 5303 5203 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5204 5304 5204 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5205 5305 5205 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5206 5306 5206 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5207 5307 5207 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5208 5308 5208 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5209 5309 5209 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5210 5310 5210 -mat 502 -dir 1 -orient 1 0 0 0 1 0;

puts $eleInfo "element zeroLength 5202 5302 5202 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5203 5303 5203 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5204 5304 5204 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5205 5305 5205 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5206 5306 5206 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5207 5307 5207 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5208 5308 5208 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5209 5309 5209 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5210 5310 5210 -mat 502 -dir 1 -orient 1 0 0 0 1 0";


fix 5701 1 1 1 1 1 1;
fix 5711 1 1 1 1 1 1;

fix 5301 1 1 1 1 1 1;
fix 5302 1 1 1 1 1 1;
fix 5303 1 1 1 1 1 1;
fix 5304 1 1 1 1 1 1;
fix 5305 1 1 1 1 1 1;
fix 5306 1 1 1 1 1 1;
fix 5307 1 1 1 1 1 1;
fix 5308 1 1 1 1 1 1;
fix 5309 1 1 1 1 1 1;
fix 5310 1 1 1 1 1 1;
fix 5311 1 1 1 1 1 1;

# 3号桥台刚臂上节点

puts $NodeInfo "桥台3节点";     #在文件NodeInfo文件中写入“桥台2节点”
puts $eleInfo  "桥台3单元";     #在文件eleInfo文件中写入“桥台2单元”

# 与主梁相连节点
set a2nodeupID1 [expr 2+$anshift+400];
for {set i 0} {$i <= [expr $celenum/2-1]} {incr i 1} { 
   set ay [expr $i*($czc/$celenum)] 
    node     $a2nodeupID1    [expr 3*$kj1]  [expr -$czc/2+$ay]  [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$a2nodeupID1    [expr 3*$kj1]  [expr -$czc/2+$ay]  [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr a2nodeupID1 1 
}
set a2nodeupID2 [expr 7+$anshift+400];
for {set i 1} {$i <= [expr $celenum/2]} {incr i 1} { 
   set ay [expr $i*($czc/$celenum)] 
    node     $a2nodeupID2    [expr 3*$kj1]  $ay  [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$a2nodeupID2    [expr 3*$kj1]  $ay  [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr a2nodeupID2 1 
}
node 5401 [expr 3*$kj1] [expr -$halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 5401 [expr 3*$kj1] [expr -$halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 5411 [expr 3*$kj1] [expr  $halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   5411 [expr 3*$kj1] [expr  $halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息

# 1号桥台刚臂下节点

set a2nodedownID [expr 2+$anshift+500];
for {set i 0} {$i <= $celenum} {incr i 1} { 
   set ay [expr $i*($czc/$celenum)] 
    node     $a2nodedownID    [expr 3*$kj1]  [expr -$czc/2+$ay]  [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$a2nodedownID    [expr 3*$kj1]  [expr -$czc/2+$ay]  [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr a2nodedownID 1 
}

node 5501 [expr 3*$kj1] [expr -$halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 5501 [expr 3*$kj1] [expr -$halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 5511 [expr 3*$kj1] [expr  $halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   5511 [expr 3*$kj1] [expr  $halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息

# 1号桥台下固定节点

set a2nodeID [expr 2+$anshift+600];
for {set i 0} {$i <= $celenum} {incr i 1} { 
   set ay [expr $i*($czc/$celenum)] 
    node     $a2nodeID    [expr 3*$kj1]  [expr -$czc/2+$ay]  [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]  ;
    puts $NodeInfo "$a2nodeID    [expr 3*$kj1]  [expr -$czc/2+$ay]  [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]"  ;   ##往这个txt文件中写入节点信息

    incr a2nodeID 1 
}

node 5601 [expr 3*$kj1] [expr -$halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 5601 [expr 3*$kj1] [expr -$halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 5611 [expr 3*$kj1] [expr  $halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   5611 [expr 3*$kj1] [expr  $halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息


node 5801 [expr 3*$kj1] [expr -$halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh];                              
puts $NodeInfo "node 5801 [expr 3*$kj1] [expr -$halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]";             #往NodeInfo文件中写入引号内信息
node 5811 [expr 3*$kj1] [expr  $halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh];                             
puts $NodeInfo "node   5811 [expr 3*$kj1] [expr  $halfg] [expr $kj1*2*0.006+$ph1+$CHSec+$bh+$gxingxinh]";    #往NodeInfo文件中写入引号内信息

# 桥台1刚臂建立

rigidLink beam 3352 5405;
rigidLink beam 5405 5404;
rigidLink beam 5404 5403;
rigidLink beam 5403 5402;
rigidLink beam 5402 5401;
rigidLink beam 3352 5407;
rigidLink beam 5407 5408;
rigidLink beam 5408 5409;
rigidLink beam 5409 5410;
rigidLink beam 5410 5411;

puts $eleInfo "rigidLink beam 3352 5405";
puts $eleInfo "rigidLink beam 5405 5404";
puts $eleInfo "rigidLink beam 5404 5403";
puts $eleInfo "rigidLink beam 5403 5402";
puts $eleInfo "rigidLink beam 5402 5401";
puts $eleInfo "rigidLink beam 3451 5407";
puts $eleInfo "rigidLink beam 5407 5408";
puts $eleInfo "rigidLink beam 5408 5409";
puts $eleInfo "rigidLink beam 5409 5410";
puts $eleInfo "rigidLink beam 5410 5411";

rigidLink beam 5506 5505;
rigidLink beam 5505 5504;
rigidLink beam 5504 5503;
rigidLink beam 5503 5502;
rigidLink beam 5502 5501;
rigidLink beam 5506 5507;
rigidLink beam 5507 5508;
rigidLink beam 5508 5509;
rigidLink beam 5509 5510;
rigidLink beam 5510 5511;

puts $eleInfo "rigidLink beam 5506 5505";
puts $eleInfo "rigidLink beam 5505 5504";
puts $eleInfo "rigidLink beam 5504 5503";
puts $eleInfo "rigidLink beam 5503 5502";
puts $eleInfo "rigidLink beam 5502 5501";
puts $eleInfo "rigidLink beam 5506 5507";
puts $eleInfo "rigidLink beam 5507 5508";
puts $eleInfo "rigidLink beam 5508 5509";
puts $eleInfo "rigidLink beam 5509 5510";
puts $eleInfo "rigidLink beam 5510 5511";

# 桥台1边界条件——零长度Gap单元

element zeroLength 5401 5501 5401 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5402 5502 5402 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5403 5503 5403 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5404 5504 5404 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5405 5505 5405 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5406 5506 3352 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5407 5507 5407 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5408 5508 5408 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5409 5509 5409 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5410 5510 5410 -mat 501 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5411 5511 5411 -mat 501 -dir 1 -orient 1 0 0 0 1 0;

puts $eleInfo "element zeroLength 5401 5501 5401 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5402 5502 5402 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5403 5503 5403 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5404 5504 5404 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5405 5505 5405 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5406 5506 3352 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5407 5507 5407 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5408 5508 5408 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5409 5509 5409 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5410 5510 5410 -mat 501 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5411 5511 5411 -mat 501 -dir 1 -orient 1 0 0 0 1 0";

# 桥台1边界条件——零长度桥台被土单元

element zeroLength 5801 5801 5401 -mat 503 -dir 2;
element zeroLength 5811 5811 5411 -mat 503 -dir 2;

puts $eleInfo "element zeroLength 5801 5801 5401 -mat 503 -dir 2";
puts $eleInfo "element zeroLength 5811 5811 5411 -mat 503 -dir 2"

element zeroLength 5501 5601 5501 -mat 502 504 504 504 504 504 -dir 1 2 3 4 5 6 -orient 1 0 0 0 1 0;
element zeroLength 5511 5611 5511 -mat 502 504 504 504 504 504 -dir 1 2 3 4 5 6 -orient 1 0 0 0 1 0;

puts $eleInfo "element zeroLength 5501 5601 5501 -mat 502 503 504 504 504 504 -dir 1 2 3 4 5 6 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5511 5611 5511 -mat 502 503 504 504 504 504 -dir 1 2 3 4 5 6 -orient 1 0 0 0 1 0";

element zeroLength 5502 5602 5502 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5503 5603 5503 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5504 5604 5504 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5505 5605 5505 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5506 5606 5506 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5507 5607 5507 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5508 5608 5508 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5509 5609 5509 -mat 502 -dir 1 -orient 1 0 0 0 1 0;
element zeroLength 5510 5610 5510 -mat 502 -dir 1 -orient 1 0 0 0 1 0;

puts $eleInfo "element zeroLength 5502 5602 5502 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5503 5603 5503 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5504 5604 5504 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5505 5605 5505 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5506 5606 5506 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5507 5607 5507 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5508 5608 5508 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5509 5609 5509 -mat 502 -dir 1 -orient 1 0 0 0 1 0";
puts $eleInfo "element zeroLength 5510 5610 5510 -mat 502 -dir 1 -orient 1 0 0 0 1 0";


fix 5801 1 1 1 1 1 1;
fix 5811 1 1 1 1 1 1;

fix 5601 1 1 1 1 1 1;
fix 5602 1 1 1 1 1 1;
fix 5603 1 1 1 1 1 1;
fix 5604 1 1 1 1 1 1;
fix 5605 1 1 1 1 1 1;
fix 5606 1 1 1 1 1 1;
fix 5607 1 1 1 1 1 1;
fix 5608 1 1 1 1 1 1;
fix 5609 1 1 1 1 1 1;
fix 5610 1 1 1 1 1 1;
fix 5611 1 1 1 1 1 1;


puts "abutment 5000"
