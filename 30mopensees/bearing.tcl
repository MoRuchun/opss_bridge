#--------------------------------------------------------------------------------------------------
# bearing 
##支座弹性连接  

set beshift 4000;
set bnshift 4000;
set bmshift 400;

#需要设置的参数
#支座123方向的材料
# set GMbkh_sample [open GMdir/bkh.txt "r"];
# set GMbkh_data [read $GMbkh_sample];
# close $GMbkh_sample;
set bkh1  2.1e6;        #支座水平剪切刚度1方向

set bkh2 $bkh1;		#支座水平剪切刚度2方向

# set GMbfy_sample [open GMdir/bfy.txt "r"];
# set GMbfy_data [read $GMbfy_sample];
# close $GMbfy_sample;
set bfy 72000; #支座屈服水平力

# set GMbkh3_sample [open GMdir/bkh3.txt "r"];
# set GMbkh3_data [read $GMbkh3_sample];
# close $GMbkh3_sample;
set bkh3  7.85e8; #支座竖向变形刚度3方向


puts $NodeInfo "支座节点"
puts $eleInfo "支座单元(刚臂)"

##桥台支座

#桥台1
#节点建立
node 4701 $cbd  [expr -$czc/2+$czc/$celenum]  [expr $cdh1+$ph1+$CHSec] ;
puts $NodeInfo "4701 $cbd  [expr -$czc/2+$czc/$celenum]  [expr $cdh1+$ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4702 $cbd  [expr -$czc/2+2*$czc/$celenum]   [expr $cdh1+$ph1+$CHSec] ;
puts $NodeInfo "4702 $cbd  [expr -$czc/2+2*$czc/$celenum]   [expr $cdh1+$ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4703 $cbd  [expr $czc/2-2*$czc/$celenum]   [expr $cdh1+$ph1+$CHSec]  ;
puts $NodeInfo "4703 $cbd  [expr $czc/2-2*$czc/$celenum]   [expr $cdh1+$ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4704 $cbd  [expr $czc/2-$czc/$celenum]   [expr $cdh1+$ph1+$CHSec] ;
puts $NodeInfo "4704 $cbd  [expr $czc/2-$czc/$celenum]   [expr $cdh1+$ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node 4801 $cbd  [expr -$czc/2+$czc/$celenum]  [expr $cdh1+$ph1+$CHSec]  ;
puts $NodeInfo "4801 $cbd  [expr -$czc/2+$czc/$celenum]  [expr $cdh1+$ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4802 $cbd  [expr -$czc/2+2*$czc/$celenum]   [expr $cdh1+$ph1+$CHSec]  ;
puts $NodeInfo "4802 $cbd [expr -$czc/2+2*$czc/$celenum]   [expr $cdh1+$ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4803 $cbd  [expr $czc/2-2*$czc/$celenum]  [expr $cdh1+$ph1+$CHSec]  ;
puts $NodeInfo "4803 $cbd  [expr $czc/2-2*$czc/$celenum]   [expr $cdh1+$ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4804 $cbd  [expr $czc/2-$czc/$celenum]   [expr $cdh1+$ph1+$CHSec];
puts $NodeInfo "4804 $cbd  [expr $czc/2-$czc/$celenum]   [expr $cdh1+$ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

##桥台1建立线性梁柱刚臂
for {set i 0} {$i <= 3} {incr i 1} {
   rigidLink beam 3101 [expr 4701+$i];
   puts $eleInfo "rigidLink beam 3101 [expr 4701+$i]";
}
#桥台1支座建立

uniaxialMaterial Steel01 [expr $bmshift+1] $bfy $bkh1 0;    #纵向
uniaxialMaterial Steel01 [expr $bmshift+2] $bfy $bkh1 0;    #横向
uniaxialMaterial Elastic [expr $bmshift+3] $bkh3;       #竖向
uniaxialMaterial Elastic [expr $bmshift+4] $Ubig;

set ab1eleID [expr 1+$beshift+700];

for {set i 0} {$i <= 3} {incr i 1} { 
    element zeroLength $ab1eleID  [expr 4801+$i]   [expr 4701+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4]  -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;

    puts $eleInfo "$ab1eleID  [expr 4801+$i]   [expr 4701+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4] -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0"; ##往这个txt文件中写入节点信息

    incr ab1eleID 1 
}

fix 4801 1 1 1 1 1 1;
fix 4802 1 1 1 1 1 1;
fix 4803 1 1 1 1 1 1;
fix 4804 1 1 1 1 1 1;

#桥台3
#节点建立
node 4901 [expr 3*$kj1-$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec]  ;
puts $NodeInfo "4901 [expr 3*$kj1-$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4902 [expr 3*$kj1-$cbd]  [expr -$czc/2+2*$czc/$celenum] [expr $cdh2+$abdh+$ph1+$CHSec] ;
puts $NodeInfo "4902 [expr 3*$kj1-$cbd]  [expr -$czc/2+2*$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4903 [expr 3*$kj1-$cbd]  [expr $czc/2-2*$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec]   ;
puts $NodeInfo "4903 [expr 3*$kj1-$cbd]  [expr $czc/2-2*$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4904 [expr 3*$kj1-$cbd]  [expr $czc/2-$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec];
puts $NodeInfo "4904 [expr 3*$kj1-$cbd]  [expr $czc/2-$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec] "  ;   ##往这个txt文件中写入节点信息

node 4001 [expr 3*$kj1-$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec]   ;
puts $NodeInfo "4001 [expr 3*$kj1-$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4002 [expr 3*$kj1-$cbd]  [expr -$czc/2+2*$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec] ;
puts $NodeInfo "4002 [expr 3*$kj1-$cbd]  [expr -$czc/2+2*$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4003 [expr 3*$kj1-$cbd]  [expr $czc/2-2*$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec]   ;
puts $NodeInfo "4003 [expr 3*$kj1-$cbd]  [expr $czc/2-2*$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4004 [expr 3*$kj1-$cbd]  [expr $czc/2-$czc/$celenum]  [expr $cdh2+$abdh+$ph1+$CHSec] ;
puts $NodeInfo "4004 [expr 3*$kj1-$cbd]  [expr $czc/2-$czc/$celenum] [expr $cdh2+$abdh+$ph1+$CHSec] "  ;   ##往这个txt文件中写入节点信息

##桥台3建立线性梁柱刚臂
for {set i 0} {$i <= 3} {incr i 1} {
   rigidLink beam 3311 [expr 4901+$i];
   puts $eleInfo "rigidLink beam 3311 [expr 4901+$i]";
}
#桥台3支座建立
set ab2eleID [expr 1+$beshift+900];

for {set i 0} {$i <= 3} {incr i 1} { 
    element zeroLength $ab2eleID  [expr 4001+$i]   [expr 4901+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4]  -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;

    puts $eleInfo "$ab2eleID  [expr 4001+$i]   [expr 4901+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4] -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0"; ##往这个txt文件中写入节点信息

    incr ab2eleID 1 
}

fix 4001 1 1 1 1 1 1;
fix 4002 1 1 1 1 1 1;
fix 4003 1 1 1 1 1 1;
fix 4004 1 1 1 1 1 1;


##建立支座节点(与盖梁支座节点坐标相同)   支座与主梁截面中心线间的刚臂
#与盖梁1对应
node 4151 [expr $kj1-$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $ph1+$CHSec]  ;
puts $NodeInfo "4151 [expr $kj1-$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $ph1+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4152 [expr $kj1-$cbd]  [expr -$czc/2+3*$czc/$celenum]  [expr $ph1+$CHSec]  ;
puts $NodeInfo "4152 [expr $kj1-$cbd]  [expr -$czc/2+3*$czc/$celenum]  [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4153 [expr $kj1-$cbd]  [expr $czc/2-3*$czc/$celenum]  [expr $ph1+$CHSec]  ;
puts $NodeInfo "4153 [expr $kj1-$cbd]  [expr $czc/2-3*$czc/$celenum]  [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4154 [expr $kj1-$cbd]  [expr $czc/2-$czc/$celenum]  [expr $ph1+$CHSec]  ;
puts $NodeInfo "4154 [expr $kj1-$cbd]  [expr $czc/2-$czc/$celenum]  [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息

node 4161 [expr $kj1+$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $ph1+$CHSec]  ;
puts $NodeInfo "4161 [expr $kj1+$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $ph1+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4162 [expr $kj1+$cbd]  [expr -$czc/2+3*$czc/$celenum] [expr $ph1+$CHSec]  ;
puts $NodeInfo "4162 [expr $kj1+$cbd]  [expr -$czc/2+3*$czc/$celenum]  [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4163 [expr $kj1+$cbd]  [expr $czc/2-3*$czc/$celenum]  [expr $ph1+$CHSec]  ;
puts $NodeInfo "4163 [expr $kj1+$cbd]  [expr $czc/2-3*$czc/$celenum]  [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息
node 4164 [expr $kj1+$cbd]  [expr $czc/2-$czc/$celenum]  [expr $ph1+$CHSec];
puts $NodeInfo "4164 [expr $kj1+$cbd]  [expr $czc/2-$czc/$celenum]  [expr $ph1+$CHSec]"  ;   ##往这个txt文件中写入节点信息


#建立线性梁柱刚臂  

for {set i 0} {$i <= 3} {incr i 1} {
   rigidLink beam 3111 [expr 4151+$i];
   puts $eleInfo "rigidLink beam 3111 [expr 4151+$i]";

}

for {set i 0} {$i <= 3} {incr i 1} {
   rigidLink beam 3201 [expr 4161+$i];
   puts $eleInfo "rigidLink beam 3201 [expr 4161+$i]";

}

#与盖梁2对应
node 4251 [expr $kj1+$kj2-$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $ph2-$dh+$CHSec]  ;
puts $NodeInfo "4251 [expr $kj1+$kj2-$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $ph2-$dh+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4252 [expr $kj1+$kj2-$cbd]  [expr -$czc/2+3*$czc/$celenum]  [expr $ph2-$dh+$CHSec]   ;
puts $NodeInfo "4252 [expr $kj1+$kj2-$cbd]  [expr -$czc/2+3*$czc/$celenum]  [expr $ph2-$dh+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4253 [expr $kj1+$kj2-$cbd]  [expr $czc/2-3*$czc/$celenum]  [expr $ph2-$dh+$CHSec]   ;
puts $NodeInfo "4253 [expr $kj1+$kj2-$cbd]  [expr $czc/2-3*$czc/$celenum]  [expr $ph2-$dh+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4254 [expr $kj1+$kj2-$cbd]  [expr $czc/2-$czc/$celenum]  [expr $ph2-$dh+$CHSec] ;
puts $NodeInfo "4254 [expr $kj1+$kj2-$cbd]  [expr $czc/2-$czc/$celenum]  [expr $ph2-$dh+$CHSec] "  ;   ##往这个txt文件中写入节点信息

node 4261 [expr $kj1+$kj2+$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $ph2-$dh+$CHSec] ;
puts $NodeInfo "4261 [expr $kj1+$kj2+$cbd]  [expr -$czc/2+$czc/$celenum]  [expr $ph2-$dh+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4262 [expr $kj1+$kj2+$cbd]  [expr -$czc/2+3*$czc/$celenum]  [expr $ph2-$dh+$CHSec] ;
puts $NodeInfo "4262 [expr $kj1+$kj2+$cbd]  [expr -$czc/2+3*$czc/$celenum]  [expr $ph2-$dh+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4263 [expr $kj1+$kj2+$cbd]  [expr $czc/2-3*$czc/$celenum]  [expr $ph2-$dh+$CHSec] ;
puts $NodeInfo "4263 [expr $kj1+$kj2+$cbd]  [expr $czc/2-3*$czc/$celenum]  [expr $ph2-$dh+$CHSec] "  ;   ##往这个txt文件中写入节点信息
node 4264 [expr $kj1+$kj2+$cbd]  [expr $czc/2-$czc/$celenum]  [expr $ph2-$dh+$CHSec] ;
puts $NodeInfo "4264 [expr $kj1+$kj2+$cbd]  [expr $czc/2-$czc/$celenum]  [expr $ph2-$dh+$CHSec] "  ;   ##往这个txt文件中写入节点信息


#建立线性梁柱刚臂!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

for {set i 0} {$i <= 3} {incr i 1} {
   rigidLink beam 3211 [expr 4251+$i];
   puts $eleInfo "rigidLink beam 3211 [expr 4251+$i]";

}

for {set i 0} {$i <= 3} {incr i 1} {
   rigidLink beam 3301 [expr 4261+$i];
   puts $eleInfo "rigidLink beam 3301 [expr 4261+$i]";

}

#建立零长度单元
puts $eleInfo "支座单元"

#定义零长度单元
set b1eleID1 [expr 1+$beshift+100+50];
set b1eleID111 $b1eleID1;
set b1eleID2 [expr 1+$beshift+100+60];
set b1eleID212 $b1eleID2;			
set b2eleID1 [expr 1+$beshift+200+50];
set b2eleID121 $b2eleID1;
set b2eleID2 [expr 1+$beshift+200+60];
set b2eleID222 $b2eleID2;


for {set i 0} {$i <= 3} {incr i 1} { 
    element zeroLength $b1eleID1  [expr $C1g1nodeID1+$i]   [expr 4151+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4]  -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;

    puts $eleInfo "$b1eleID1  [expr $C1g1nodeID1+$i]   [expr 4151+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4] -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0"; ##往这个txt文件中写入节点信息

    incr b1eleID1 1 
}

for {set i 0} {$i <= 3} {incr i 1} { 
    element zeroLength $b1eleID2  [expr $C1g2nodeID2+$i]   [expr 4161+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4] -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;

    puts $eleInfo "$b1eleID2  [expr $C1g2nodeID2+$i]   [expr 4161+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4] -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0"; ##往这个txt文件中写入节点信息

    incr b1eleID2 1 
}



for {set i 0} {$i <= 3} {incr i 1} { 
    element zeroLength $b2eleID1  [expr $C2g1nodeID1+$i]   [expr 4251+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4] -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;

    puts $eleInfo "$b2eleID1  [expr $C2g1nodeID1+$i]   [expr 4251+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4] -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0"; ##往这个txt文件中写入节点信息

    incr b2eleID1 1 
}

for {set i 0} {$i <= 3} {incr i 1} { 
    element zeroLength $b2eleID2  [expr $C2g2nodeID2+$i]   [expr 4261+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4] -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;

    puts $eleInfo "$b2eleID2  [expr $C2g2nodeID2+$i]   [expr 4261+$i]	\
-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] [expr $bmshift+4] [expr $bmshift+4] [expr $bmshift+4] -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0"; ##往这个txt文件中写入节点信息

    incr b2eleID2 1 
}



##盖梁1上的支座节点参数
#set b1nodeID1  [expr ($C1nodeID-$cnshift-100)/2+$cnshift+100];
#set b1nodeID2  $g1nodeID1;
#
##盖梁2上的支座节点
#set b2nodeID1  [expr ($C2nodeID-$cnshift-200)/2+$cnshift+200];
#set b2nodeID2  [expr $g1nodeID-1];
#
#
#set bmat1 [expr 1+$bmshift];
#set bmat2 [expr 2+$bmshift];
#set bmat3 [expr 3+$bmshift];
#
#
#uniaxialMaterial Elastic [expr $bmshift+1] $bkh1;
#uniaxialMaterial Elastic [expr $bmshift+2] $bkh2;
#uniaxialMaterial Elastic [expr $bmshift+3] $bkh3;
#
##定义零长度单元
#set beleID1 [expr 1+$beshift+100];
#set beleID2 [expr 1+$beshift+200];
#
#
#element zeroLength $beleID1  $b1nodeID1   $b1nodeID2	\
#-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] -dir 1 2 3 -orient  1 0 0  0 1 0;
#
#element zeroLength $beleID2  $b2nodeID1   $b2nodeID2	\
#-mat [expr $bmshift+1] [expr $bmshift+2] [expr $bmshift+3] -dir 1 2 3 -orient  1 0 0  0 1 0;
#
#puts $eleInfo "$beleID1	$b1nodeID1	$b1nodeID2	\
#-mat	[expr $bmshift+1]	[expr $bmshift+2]	[expr $bmshift+3] -dir 1 2 3  -orient 1 0 0  0 1 0";  ##往这个txt文件中写入单元信息
#
#puts $eleInfo "$beleID2	$b2nodeID1	$b2nodeID2	\
#-mat	[expr $bmshift+1]	[expr $bmshift+2]	[expr $bmshift+3] -dir 1 2 3  -orient 1 0 0  0 1 0";  ##往这个txt文件中写入单元信息
#
#
#

puts "finish bearing 4000"