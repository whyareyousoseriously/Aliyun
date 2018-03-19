    select call_id  ,      
(case      when age_range ='16-20岁' then 1
     when age_range ='21-25岁' then 2
     when age_range ='26-35岁' then 3
     when age_range ='36-45岁' then 4
     when age_range ='46-55岁' then 5
     else 0 end) as age_range,    
(case when gender='男' then 1 else 2 end) as gender,
brand,         
(case when  district='CF公司' then 1
     when district='DF公司' then 2
     when district='FF公司' then 3
     when district='NF公司' then 4
     when district='PF公司' then 5
     when district='SF公司' then 6
     when district='XF公司' then 8
     when district='ZF公司' then 7
     else 0 end) as district,       
					open_date    ,  
					join_month   ,  
					arpu_jan     ,  
					arpu_feb     ,  
					arpu_mar     ,  
					arpu_apr     ,  
					arpu_may     ,  
					arpu_jun     ,  
					arpu_jul     ,  
					arpu_aug     ,  
					apru_sep     ,  
					arpu_num     ,  
					total_arpu   ,  
					total_mou    ,  
					total_data 
			from  ${t1}; --输入表
