# 创建数据目录文件			                                                  
#if { [file exists Reaction] == 0 } {                                                                         

  #file mkdir Reaction
#} 
#节点位移文件夹
if { [file exists DF] == 0 } {                                                                         

  file mkdir DF
} 

#弯矩-曲率分析
if { [file exists MC] == 0 } {                                                                         

  file mkdir MC
} 

if { [file exists MCenvelope] == 0 } {                                                                         

  file mkdir MCenvelope
}

#单元内力提取文件夹
#if { [file exists ElementForce] == 0 } {                                                                         

  #file mkdir ElementForce
#}

#时程曲线文件夹
if { [file exists THResponse] == 0 } {                                                                         

  file mkdir THResponse
}

#振型分析文件夹
#if { [file exists Modal] == 0 } {                                                                         

  #file mkdir Modal
#}

 
#墩顶加速度时程曲线
#Pier 1
 recorder  Node -file THResponse/1111_acc_[expr $ii].txt -time -node 1111  -dof 1 accel;
 recorder  Node -file THResponse/1161_acc_[expr $ii].txt -time -node 1161  -dof 1 accel;
#pier 2
 recorder  Node -file THResponse/1211_acc_[expr $ii].txt -time -node 1211  -dof 1 accel;
 recorder  Node -file THResponse/1261_acc_[expr $ii].txt -time -node 1261  -dof 1 accel;

 

#墩顶位移时程曲线
 recorder Node -file THResponse/1111_deformation_[expr $ii].txt -time -node 1111 -dof 1 2 3 disp;
 recorder Node -file THResponse/1161_deformation_[expr $ii].txt -time -node 1161 -dof 1 2 3 disp;

 recorder Node -file THResponse/1211_deformation_[expr $ii].txt -time -node 1211 -dof 1 2 3 disp;
 recorder Node -file THResponse/1261_deformation_[expr $ii].txt -time -node 1261 -dof 1 2 3 disp;


#Moment-curvature(all)
  recorder Element -file MC/1101_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1101 section 1 force;
  recorder Element -file MC/1101_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1101 section 1 deformation;
  recorder Element -file MC/1111_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1111 section 1 force;
  recorder Element -file MC/1111_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1111 section 1 deformation;

  recorder Element -file MC/1151_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1151 section 1 force;
  recorder Element -file MC/1151_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1151 section 1 deformation;
  recorder Element -file MC/1161_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1161 section 1 force;
  recorder Element -file MC/1161_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1161 section 1 deformation;

  recorder Element -file MC/1201_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1201 section 1 force;
  recorder Element -file MC/1201_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1201 section 1 deformation;
  recorder Element -file MC/1211_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1211 section 1 force;
  recorder Element -file MC/1211_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1211 section 1 deformation;

  recorder Element -file MC/1251_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1251 section 1 force;
  recorder Element -file MC/1251_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1251 section 1 deformation;
  recorder Element -file MC/1261_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1261 section 1 force;
  recorder Element -file MC/1261_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1261 section 1 deformation;


#Moment-curvature(envelope)
  recorder EnvelopeElement -file MCenvelope/1101_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1101 section 1 force;
  recorder EnvelopeElement -file MCenvelope/1101_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1101 section 1 deformation;
  recorder EnvelopeElement -file MCenvelope/1111_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1111 section 1 force;
  recorder EnvelopeElement -file MCenvelope/1111_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1111 section 1 deformation;

  recorder EnvelopeElement -file MCenvelope/1151_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1151 section 1 force;
  recorder EnvelopeElement -file MCenvelope/1151_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1151 section 1 deformation;
  recorder EnvelopeElement -file MCenvelope/1161_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1161 section 1 force;
  recorder EnvelopeElement -file MCenvelope/1161_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1161 section 1 deformation;

  recorder EnvelopeElement -file MCenvelope/1201_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1201 section 1 force;
  recorder EnvelopeElement -file MCenvelope/1201_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1201 section 1 deformation;
  recorder EnvelopeElement -file MCenvelope/1211_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1211 section 1 force;
  recorder EnvelopeElement -file MCenvelope/1211_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1211 section 1 deformation;

  recorder EnvelopeElement -file MCenvelope/1251_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1251 section 1 force;
  recorder EnvelopeElement -file MCenvelope/1251_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1251 section 1 deformation;
  recorder EnvelopeElement -file MCenvelope/1261_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 1261 section 1 force;
  recorder EnvelopeElement -file MCenvelope/1261_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 1261 section 1 deformation;

#墩顶位移
 recorder Node -file DF/1111_DISP_[expr $ii].txt -time -node 1108 -dof 1 2 3 disp;    #水平两个方向的位移
 recorder Node -file DF/1161_DISP_[expr $ii].txt -time -node 1154 -dof 1 2 3 disp;

 recorder Node -file DF/1211_DISP_[expr $ii].txt -time -node 1210 -dof 1 2 3 disp;
 recorder Node -file DF/1261_DISP_[expr $ii].txt -time -node 1256 -dof 1 2 3 disp;


#墩顶反力
 #recorder Node -file Reaction/1111_reaction_[expr $ii].txt -time -node 1111 -dof 1 2 3 4 5 6 reaction;
 #recorder Node -file Reaction/1161_reaction_[expr $ii].txt -time -node 1161 -dof 1 2 3 4 5 6 reaction;
 #recorder Node -file Reaction/1211_reaction_[expr $ii].txt -time -node 1211 -dof 1 2 3 4 5 6 reaction;
 #recorder Node -file Reaction/1261_reaction_[expr $ii].txt -time -node 1261 -dof 1 2 3 4 5 6 reaction;

#墩底内力
 #recorder Element -file ElementForce/1101_force_[expr $ii].txt -time -ele 1101 globalForce; 
 #recorder Element -file ElementForce/1151_force_[expr $ii].txt -time -ele 1151 globalForce; 
 #recorder Element -file ElementForce/1201_force_[expr $ii].txt -time -ele 1201 globalForce; 
 #recorder Element -file ElementForce/1251_force_[expr $ii].txt -time -ele 1251 globalForce; 



#墩柱位移曲线
 #recorder EnvelopeNode -file DF/p1left_bottom2top_disp_[expr $ii].txt -time -nodeRange 1101 1111 -dof 1 2 disp; 
 #recorder EnvelopeNode -file DF/p1right_bottom2top_disp_[expr $ii].txt -time -nodeRange 1151 1161 -dof 1 2 disp; 

 #recorder EnvelopeNode -file DF/p2left_bottom2top_disp_[expr $ii].txt -time -nodeRange 1201 1211 -dof 1 2 disp; 
 #recorder EnvelopeNode -file DF/p2right_bottom2top_disp_[expr $ii].txt -time -nodeRange 1251 1261 -dof 1 2 disp;

#墩柱力曲线
 #recorder EnvelopeElement -file ElementForce/p1left_b2t_globalforce_[expr $ii].txt -time -eleRange 1101 1110 globalForce;
 #recorder EnvelopeElement -file ElementForce/p1right_b2t_globalforce_[expr $ii].txt -time -eleRange 1151 1160 globalForce;

 #recorder EnvelopeElement -file ElementForce/p2left_b2t_globalforce_[expr $ii].txt -time -eleRange 1201 1210 globalForce;
 #recorder EnvelopeElement -file ElementForce/p2right_b2t_globalforce_[expr $ii].txt -time -eleRange 1251 1260 globalForce;


#振型
 #recorder Node -file Modal/1eigen1_lefpier.txt -time -nodeRange 1101 1111 -dof 1 2 3 "eigen 1"      #一阶振型
 #recorder Node -file Modal/1eigen1_rigpier.txt -time -nodeRange 1151 1161 -dof 1 2 3 "eigen 1"
 #recorder Node -file Modal/1eigen2_lefpier.txt -time -nodeRange 1201 1211 -dof 1 2 3 "eigen 1"      
 #recorder Node -file Modal/1eigen2_rigpier.txt -time -nodeRange 1251 1261 -dof 1 2 3 "eigen 1"

 #recorder Node -file Modal/2eigen1_lefpier.out -time -nodeRange 1101 1111 -dof 1 2 3 "eigen 2"      #二阶振型
 #recorder Node -file Modal/2eigen1_rigpier.out -time -nodeRange 1151 1161 -dof 1 2 3 "eigen 2"
 #recorder Node -file Modal/2eigen2_lefpier.out -time -nodeRange 1201 1211 -dof 1 2 3 "eigen 2"      
 #recorder Node -file Modal/2eigen2_rigpier.out -time -nodeRange 1251 1261 -dof 1 2 3 "eigen 2"

 #recorder Node -file Modal/3eigen1_lefpier.out -time -nodeRange 1101 1111 -dof 1 2 3 "eigen 3"      #三阶振型
 #recorder Node -file Modal/3eigen1_rigpier.out -time -nodeRange 1151 1161 -dof 1 2 3 "eigen 3"
 #recorder Node -file Modal/3eigen2_lefpier.out -time -nodeRange 1201 1211 -dof 1 2 3 "eigen 3"      
 #recorder Node -file Modal/3eigen2_rigpier.out -time -nodeRange 1251 1261 -dof 1 2 3 "eigen 3"


puts "finish recorder"