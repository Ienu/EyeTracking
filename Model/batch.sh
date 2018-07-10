#!/bin/bash
for i in 2000 4000 6000 8000 10000
do
	data=$(printf '../data/data_clm_2m_hh_%d.mat' $i)
	i2g_res=$(printf '../result/i2g_data_clm_hh_2m_%d.txt' $i)
	f2g_res=$(printf '../result/f2g_data_clm_hh_2m_%d.txt' $i)
	m2g_res=$(printf '../result/m2g_data_clm_hh_2m_%d.txt' $i)
	
	python ../src/i2g_g_v1.0.py $data > $i2g_res
	python ../src/f2g_g_v1.0.py $data > $f2g_res
	python ../src/m2g_g_v1.0.py $data > $m2g_res
done
