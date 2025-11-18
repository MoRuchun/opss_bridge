## bridge 全桥运行
source LibUnits.tcl;          #设置单位变量
# set GMskew_sample [open GMdir/skew.txt "r"];
# set GMskew_data [read $GMskew_sample];
# close $GMskew_sample;

#set A [expr $PI/2-$a];        #斜度		
#set   halfg       4;                     #上部结构的一半宽度
				                                                      
source pier.tcl 		;	#转换号1000
source capbeam.tcl 	;	#转换号2000
source girder.tcl 	;	#转换号3000
source bearing.tcl 	;	#转换号4000
source Abutment.tcl	;	#转换号5000
source foundation.tcl 	;	 
#显示图形
#
#显示三维视图
#recorder display view 0 400 1000 1000 -wipe
#prp 50 -20 30
#vup 0 0 1
#display  1 2 10
#
#显示Model3D
source DisplayModel3D.tcl
source DisplayPlane.tcl
#DisplayModel3D DeformedShape
#
#图形停留时间
#
#after 20000