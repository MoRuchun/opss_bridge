# 创建数据目录文件			                                                  
if { [file exists DF] == 0 } {                                                                         

  file mkdir DF
} 
if { [file exists CM] == 0 } {                                                                         

  file mkdir CM
} 
if { [file exists dataoutputSSS] == 0 } {                                                                         

  file mkdir dataoutputSSS
} 

 
#实际用到的数据

 #recorder EnvelopeElement -file dataoutputSSS/SSSEnvelopeColumnbottom_Deformation_IDA_[expr $ii]_skew_[expr $kk]_[expr $jj]g.txt  -time 	-ele $1eleID1  deformation;
 #recorder EnvelopeElement -xml dataoutputSSS/SSSEnvelopeColumnbottom_Force_IDA_[expr $ii]_skew_[expr $kk]_[expr $jj]g.txt  -time 	-ele $1nodeID1 $3nodeID3 $2nodeID2 $4nodeID4 section 1 Force;
 # recorder EnvelopeElement -file abutmentSSS/abutmentL_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5202 5203 5204 5205 5206 5207 5208 5209 5210 deformation;
  #recorder EnvelopeElement -file abutmentSSS/abutmentL_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5202 5203 5204 5205 5206 5207 5208 5209 5210 force;

#  recorder EnvelopeElement -file abutmentSSS/abutmentR_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5502 5503 5504 5505 5506 5507 5508 5509 5510 deformation;
 # recorder EnvelopeElement -file abutmentSSS/abutmentR_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5502 5503 5504 5505 5506 5507 5508 5509 5510 force;

  #recorder EnvelopeElement -file bearingSSS/bearing1_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4701 4702 4703 4704 force;
 # recorder EnvelopeElement -file bearingSSS/bearing1_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4701 4702 4703 4704 deformation;
#  recorder EnvelopeElement -file bearingSSS/bearing2_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4151 4152 4153 4154 4161 4162 4163 4164 force;
 # recorder EnvelopeElement -file bearingSSS/bearing2_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4151 4152 4153 4154 4161 4162 4163 4164 deformation;
  #recorder EnvelopeElement -file bearingSSS/bearing3_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4251 4252 4253 4254 4261 4262 4263 4264 force;
 # recorder EnvelopeElement -file bearingSSS/bearing3_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4251 4252 4253 4254 4261 4262 4263 4264 deformation;
 # recorder EnvelopeElement -file bearingSSS/bearing4_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4351 4352 4353 4354 4361 4362 4363 4364 force;
 # recorder EnvelopeElement -file bearingSSS/bearing4_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4351 4352 4353 4354 4361 4362 4363 4364 deformation;
 # recorder EnvelopeElement -file bearingSSS/bearing5_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4901 4902 4903 4904 force;
 # recorder EnvelopeElement -file bearingSSS/bearing5_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4901 4902 4903 4904 deformation;

 recorder  EnvelopeNode -file dataoutputSSS/1109_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-node 1109  -dof 1 2 3 disp;
 recorder  EnvelopeNode -file dataoutputSSS/1209_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-node 1209  -dof 1 2 3 disp;
 recorder  EnvelopeNode -file dataoutputSSS/1309_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-node 1309  -dof 1 2 3 disp;

#  recorder EnvelopeElement -file dataoutputSSS/1101_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $1eleID1 section 1 force;
#left 
 recorder EnvelopeElement -file dataoutputSSS/1101_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $1lefteleID1 section 1 deformation;

#right
recorder EnvelopeElement -file dataoutputSSS/1151_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $1righteleID1 section 1 deformation;

 # recorder EnvelopeElement -file dataoutputSSS/1201_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $2eleID2 section 1 force;
  recorder EnvelopeElement -file dataoutputSSS/1201_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $2lefteleID2 section 1 deformation;

 recorder EnvelopeElement -file dataoutputSSS/1251_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $2righteleID2 section 1 deformation;


  #recorder EnvelopeElement -file dataoutputSSS/1301_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $3eleID3 section 1 force;
  #recorder EnvelopeElement -file dataoutputSSS/1301_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $3eleID3 section 1 deformation;
 #recorder  EnvelopeNode -xml dataoutputSSS/SSSEnvelopeTOPDIS_Force_IDA_[expr $ii]_skew_[expr $kk]_[expr $jj]g.txt 	-time 	-node [expr $1nodeID1+$pelenum] [expr $2nodeID2+$pelenum] [expr $3nodeID3+$pelenum] [expr $4nodeID4+$pelenum] -dof 1 2 3 reaction;



#位移
#recorder Element -file dataoutput/Columnbottom_Deformation_IDA_[expr $ii]_skew_[expr $kk]_[expr $jj]g.txt            -time  -ele $1nodeID1 section 1 deformation;
recorder  Node -file DF/1109_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-node 1109  -dof 1 2 3 disp;
recorder Element -file DF/1101_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $1lefteleID1  force;

recorder  Node -file DF/1109_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-node 1109  -dof 1 2 3 disp;
recorder Element -file DF/1101_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $1righteleID1  force;


recorder  Node -file DF/1209_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-node 1209  -dof 1 2 3 disp;
recorder Element -file DF/1201_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $2lefteleID2  force;

recorder  Node -file DF/1209_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-node 1209  -dof 1 2 3 disp;
recorder Element -file DF/1201_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $2righteleID2  force;


#recorder  Node -file DF/1309_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-node 1309  -dof 1 2 3 disp;
#recorder Element -file DF/1301_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $3eleID3  force;



# Column Moment-Curvature  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #left
  recorder Element -file CM/1101_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $1lefteleID1 section 1 force;
  recorder Element -file CM/1101_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $1lefteleID1 section 1 deformation;
  #right
  recorder Element -file CM/1151_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $1righteleID1 section 1 force;
  recorder Element -file CM/1151_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $1righteleID1 section 1 deformation;


  recorder Element -file CM/1201_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $2lefteleID2 section 1 force;
  recorder Element -file CM/1201_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $2lefteleID2 section 1 deformation;

  recorder Element -file CM/1251_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $2righteleID2 section 1 force;
  recorder Element -file CM/1251_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $2righteleID2 section 1 deformation;


  #recorder Element -file CM/1301_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $3eleID3 section 1 force;
  #recorder Element -file CM/1301_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $3eleID3 section 1 deformation;
  
  #recorder Element -file CM/1301_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele $3eleID3 section 1 force;
  #recorder Element -file CM/1301_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele $3eleID3 section 1 deformation;
  
  #recorder Element -xml dataoutput/Columntop_Force_IDA_[expr $ii]_[expr $jj]g.txt			 -time 	-ele [expr $1nodeID1+$pelenum-1] [expr $2nodeID2+$pelenum-1] [expr $3nodeID3+$pelenum-1] [expr $4nodeID4+$pelenum-1] 	section $pjfd force;
  #recorder Element -xml dataoutput/Columntop_Deformation_IDA_[expr $ii]_[expr $jj]g.txt 	-time -ele [expr $1nodeID1+$pelenum-1] [expr $2nodeID2+$pelenum-1] [expr $3nodeID3+$pelenum-1] [expr $4nodeID4+$pelenum-1] 	section $pjfd deformation;
#桥台
  #recorder Element -file abutmentL/5202_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5202 force;
  #recorder Element -file abutmentL/5202_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5202 deformation;

#  recorder Element -file abutmentR/5502_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5502 force;
 # recorder Element -file abutmentR/5502_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5502 deformation;

  #recorder Element -file abutmentL/5203_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5203 force;
  #recorder Element -file abutmentL/5203_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5203 deformation;

  #recorder Element -file abutmentR/5503_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5503 force;
  #recorder Element -file abutmentR/5503_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5503 deformation;

 # recorder Element -file abutmentL/5204_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5204 force;
#  recorder Element -file abutmentL/5204_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5204 deformation;

  #recorder Element -file abutmentR/5504_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5504 force;
  #recorder Element -file abutmentR/5504_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5504 deformation;

  #recorder Element -file abutmentL/5205_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5205 force;
  #recorder Element -file abutmentL/5205_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5205 deformation;

  #recorder Element -file abutmentR/5505_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5505 force;
  #recorder Element -file abutmentR/5505_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5505 deformation;

  #recorder Element -file abutmentL/5206_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5206 force;
 # recorder Element -file abutmentL/5206_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5206 deformation;

  #recorder Element -file abutmentR/5506_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5506 force;
  #recorder Element -file abutmentR/5506_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5506 deformation;

  #recorder Element -file abutmentL/5207_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5207 force;
  #recorder Element -file abutmentL/5207_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5207 deformation;

  #recorder Element -file abutmentR/5507_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5507 force;
  #recorder Element -file abutmentR/5507_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5507 deformation;

  #recorder Element -file abutmentL/5208_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5208 force;
  #recorder Element -file abutmentL/5208_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5208 deformation;

  #recorder Element -file abutmentR/5508_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5508 force;
  #recorder Element -file abutmentR/5508_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5508 deformation;

  #recorder Element -file abutmentL/5209_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5209 force;
  #recorder Element -file abutmentL/5209_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5209 deformation;

  #recorder Element -file abutmentR/5509_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5509 force;
  #recorder Element -file abutmentR/5509_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5509 deformation;

  #recorder Element -file abutmentL/5210_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5210 force;
  #recorder Element -file abutmentL/5210_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5210 deformation;

  #recorder Element -file abutmentR/5510_Force_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5510 force;
  #recorder Element -file abutmentR/5510_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 5510 deformation;
#bearing
  #recorder Element -file bearing1/4701_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4701 force;
  #recorder Element -file bearing1/4701_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4701 deformation;
  #recorder Element -file bearing1/4702_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4702 force;
  #recorder Element -file bearing1/4702_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4702 deformation;
  #recorder Element -file bearing1/4703_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4703 force;
  #recorder Element -file bearing1/4703_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4703 deformation;
  #recorder Element -file bearing1/4704_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4704 force;
  #recorder Element -file bearing1/4704_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4704 deformation;

 # recorder Element -file bearing2/4151_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4151 force;
 # recorder Element -file bearing2/4151_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4151 deformation;
 # recorder Element -file bearing2/4152_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4152 force;
  #recorder Element -file bearing2/4152_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4152 deformation;
  #recorder Element -file bearing2/4153_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4153 force;
  #recorder Element -file bearing2/4153_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4153 deformation;
  #recorder Element -file bearing2/4154_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4154 force;
  #recorder Element -file bearing2/4154_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4154 deformation;
  #recorder Element -file bearing2/4161_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4161 force;
  #recorder Element -file bearing2/4161_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4161 deformation;
  #recorder Element -file bearing2/4162_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4162 force;
  #recorder Element -file bearing2/4162_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4162 deformation;
  #recorder Element -file bearing2/4163_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4163 force;
  #recorder Element -file bearing2/4163_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4163 deformation;
  #recorder Element -file bearing2/4164_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4164 force;
  #recorder Element -file bearing2/4164_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4164 deformation;

 # recorder Element -file bearing3/4251_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4251 force;
 # recorder Element -file bearing3/4251_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4251 deformation;
 # recorder Element -file bearing3/4252_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4252 force;
 # recorder Element -file bearing3/4252_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4252 deformation;
 # recorder Element -file bearing3/4253_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4253 force;
 # recorder Element -file bearing3/4253_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4253 deformation;
 # recorder Element -file bearing3/4254_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4254 force;
 # recorder Element -file bearing3/4254_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4254 deformation;
 # recorder Element -file bearing3/4261_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4261 force;
 # recorder Element -file bearing3/4261_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4261 deformation;
 # recorder Element -file bearing3/4262_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4262 force;
 # recorder Element -file bearing3/4262_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4262 deformation;
 # recorder Element -file bearing3/4263_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4263 force;
 # recorder Element -file bearing3/4263_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4263 deformation;
 # recorder Element -file bearing3/4264_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4264 force;
 # recorder Element -file bearing3/4264_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4264 deformation;

 # recorder Element -file bearing4/4351_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4351 force;
 # recorder Element -file bearing4/4351_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4351 deformation;
 # recorder Element -file bearing4/4352_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4352 force;
 # recorder Element -file bearing4/4352_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4352 deformation;
 # recorder Element -file bearing4/4353_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4353 force;
 # recorder Element -file bearing4/4353_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4353 deformation;
  #recorder Element -file bearing4/4354_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4354 force;
  #recorder Element -file bearing4/4354_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4354 deformation;
  #recorder Element -file bearing4/4361_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4361 force;
  #recorder Element -file bearing4/4361_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4361 deformation;
  #recorder Element -file bearing4/4362_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4362 force;
  #recorder Element -file bearing4/4362_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4362 deformation;
  #recorder Element -file bearing4/4363_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4363 force;
  #recorder Element -file bearing4/4363_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4363 deformation;
  #recorder Element -file bearing4/4364_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4364 force;
  #recorder Element -file bearing4/4364_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4364 deformation;


 # recorder Element -file bearing5/4901_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4901 force;
 # recorder Element -file bearing5/4901_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4901 deformation;
 # recorder Element -file bearing5/4902_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4902 force;
 # recorder Element -file bearing5/4902_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4902 deformation;
 # recorder Element -file bearing5/4903_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4903 force;
 # recorder Element -file bearing5/4903_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4903 deformation;
 # recorder Element -file bearing5/4904_Force_IDA_[expr $ii]_[expr $jj]g.txt 	-time 	-ele 4904 force;
 # recorder Element -file bearing5/4904_Deformation_IDA_[expr $ii]_[expr $jj]g.txt -time 	-ele 4904 deformation;

puts "finish recorder"