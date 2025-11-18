#--------------------------------------------------------------------------------------------------
# foundation 
#  基础  墩底固接 

set psshift 10000;
set KF1 2.68e9
set KF2 2.68e9
set KF3 1.07e10
set KF4 1.66e10
set KF5 1.66e10
set KF6 4.51e9
uniaxialMaterial Elastic [expr $psshift+1] [expr $KF1];   # 墩底水平1材料
uniaxialMaterial Elastic [expr $psshift+2] [expr $KF2];   # 墩底水平2材料
uniaxialMaterial Elastic [expr $psshift+3] [expr $KF3];    #  墩底水平3材料
uniaxialMaterial Elastic [expr $psshift+4] [expr $KF4];    # 墩底水平4材料
uniaxialMaterial Elastic [expr $psshift+5] [expr $KF5];    # 墩底水平5材料
uniaxialMaterial Elastic [expr $psshift+6] [expr $KF6];   # 墩底水平6材料  

#一号墩柱 
set sslefteleID1 [expr $psshift+500];
set ssleftnodeID1 [expr $psshift+500];
node $ssleftnodeID1 $kj1 -2.4 0;
node [expr $ssleftnodeID1+1] $kj1 -2.4 0;
equalDOF $ssleftnodeID1 $1leftnodeID1 1 2 3 4 5 6;

set ssrighteleID1 [expr $psshift+550];
set ssrightnodeID1 [expr $psshift+550];
node $ssrightnodeID1 $kj1 2.4 0;
node [expr $ssrightnodeID1+1] $kj1 2.4 0;
equalDOF $ssrightnodeID1 $1rightnodeID1 1 2 3 4 5 6;

element zeroLength $sslefteleID1  [expr $ssleftnodeID1]   [expr $ssleftnodeID1+1]	\
-mat [expr $psshift+1] [expr $psshift+2] [expr $psshift+3] [expr $psshift+4] [expr $psshift+5] [expr $psshift+6]  -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;

element zeroLength $ssrighteleID1  [expr $ssrightnodeID1]   [expr $ssrightnodeID1+1]	\
-mat [expr $psshift+1] [expr $psshift+2] [expr $psshift+3] [expr $psshift+4] [expr $psshift+5] [expr $psshift+6]  -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;

#2号墩柱
set sslefteleID2 [expr $psshift+600];
set ssleftnodeID2 [expr $psshift+600];
node $ssleftnodeID2 [expr $kj1+$kj2] -2.4 [expr -$dh];
node [expr $ssleftnodeID2+1] [expr $kj1+$kj2] -2.4 [expr -$dh];
equalDOF $ssleftnodeID2 $2leftnodeID2 1 2 3 4 5 6;

set ssrighteleID2 [expr $psshift+650];
set ssrightnodeID2 [expr $psshift+650];
node $ssrightnodeID2 [expr $kj1+$kj2] 2.4 [expr -$dh];
node [expr $ssrightnodeID2+1] [expr $kj1+$kj2] 2.4 [expr -$dh];
equalDOF $ssrightnodeID2 $2rightnodeID2 1 2 3 4 5 6;

element zeroLength $sslefteleID2  [expr $ssleftnodeID2]   [expr $ssleftnodeID2+1]	\
-mat [expr $psshift+1] [expr $psshift+2] [expr $psshift+3] [expr $psshift+4] [expr $psshift+5] [expr $psshift+6]  -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;

element zeroLength $ssrighteleID2  [expr $ssrightnodeID2]   [expr $ssrightnodeID2+1]	\
-mat [expr $psshift+1] [expr $psshift+2] [expr $psshift+3] [expr $psshift+4] [expr $psshift+5] [expr $psshift+6]  -dir 1 2 3 4 5 6 -orient  1 0 0  0 1 0;


fix [expr $ssleftnodeID1+1] 1 1 1 1 1 1 ;
fix [expr $ssrightnodeID1+1] 1 1 1 1 1 1 ;
fix [expr $ssleftnodeID2+1] 1 1 1 1 1 1 ;
fix [expr $ssrightnodeID2+1] 1 1 1 1 1 1 ;

puts "finish foundation"  
