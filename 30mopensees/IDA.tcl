for { set ii  1 } { $ii <= 23} { incr ii} {
       for { set kk  1 } { $kk <= 1 } { incr kk} {
             for { set jj  1 } { $jj <= 1 } { incr jj} {
             wipe ;            
             source GenerateBridge.tcl;   #模型
             source gravity.tcl;
             source Analysisfirst.tcl;    #周期 频率 阻尼分析

#puts "DSec=$DSec $gA $gdg $gJ $gIy $gIz $gxingxinh $kj1  "
#读取地震波峰值PGA
#set GMScale_sample [open 0GMdir/PGA.txt "r"];
#set GMScale_data [read $GMScale_sample];
#close $GMScale_sample;

#读取地震波运行序号
set GMnum_sample [open GMdir/GM_num.txt "r"];
set GMnum_data [read $GMnum_sample];
close $GMnum_sample;
set GMnum [lindex $GMnum_data [expr $ii-1]];
set mm $GMnum;

#读取地震波间隔dt
set GMdt_sample [open GMdir/dt.txt "r"];
set GMdt_data [read $GMdt_sample];
close $GMdt_sample;

#读取地震波时长Tener
set GMTeff_sample [open GMdir/Teff.txt "r"];
set GMTeff_data [read $GMTeff_sample];
close $GMTeff_sample;

#读取地震波调幅系数
set GMsc_sample [open GMdir/scale.txt "r"];
set GMsc_data [read $GMsc_sample];
close $GMsc_sample;

#puts "GMScale_data=$GMScale_data"
#puts "GMdt_data_data=$GMdt_data"
#puts "GMTener_data=$GMTener_data"


          
#set 1GMfile "[format "GMdir/NGM_%i_E.txt" $ii]";  # 定义地震动名称ground-motion filenames
#set 2GMfile "[format "GMdir/NGM_%i_N.txt" $ii]";  # 定义地震动名称ground-motion filenames
#set 3GMfile "[format "GMdir/NGM_%i_UP.txt" $ii]";  # 定义地震动名称ground-motion filenames

set 1GMfile "[format "GMdir/GM_%tt_E.txt" $tt]";  # 定义地震动名称ground-motion filenames
set 2GMfile "[format "GMdir/GM_%tt_N.txt" $tt]";  # 定义地震动名称ground-motion filenames
set 3GMfile "[format "GMdir/GM_%tt_UP.txt" $tt]";  # 定义地震动名称ground-motion filenames


            
            #set iGMScale [lindex $GMScale_data [expr $ii-1]];
            #set GMScale [expr 0.1*$jj/$iGMScale];	               #定义调幅系数ground-motion scaling factor
            set GMScale [lindex $GMsc_data [expr $tt-1]];	         #读取调幅系数ground-motion scaling factor


             #set GMScale [expr $iGMScale];	               # 定义调幅系数ground-motion scaling factor

            
           #set GMScale=$iGMScale

            source  recorder-05.tcl
            puts "recorder.tcl"

            source  Analysissecond.tcl
            puts "finish motion $ii  $jj"

#puts "iGMScale=$iGMScale"
#puts "DtAnalysis=$DtAnalysis"
#puts "TmaxAnalysis=$TmaxAnalysis"
              
puts "内循环里面第$ii 条,第$kk 个角度,第$jj g=$ii $kk $jj"
              }
puts "内循环里面第$ii 条,第$kk 个角度,第$jj g=$ii $kk $jj"

        }
}
puts "finish IDA"


