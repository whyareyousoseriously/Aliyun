    select call_id  ,      
(case      when age_range ='16-20��' then 1
     when age_range ='21-25��' then 2
     when age_range ='26-35��' then 3
     when age_range ='36-45��' then 4
     when age_range ='46-55��' then 5
     else 0 end) as age_range,    
(case when gender='��' then 1 else 2 end) as gender,
brand,         
(case when  district='CF��˾' then 1
     when district='DF��˾' then 2
     when district='FF��˾' then 3
     when district='NF��˾' then 4
     when district='PF��˾' then 5
     when district='SF��˾' then 6
     when district='XF��˾' then 8
     when district='ZF��˾' then 7
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
			from  ${t1}; --�����
