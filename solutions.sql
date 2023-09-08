---Stamp Registration
/*How does the revenue generated from document registration vary across districts in Telangana?  
List down the top 5 districts that showed the highest document registration revenue growth between FY 2019
and 2022.  */
select top 5 
	s.dis_code ,d.district ,
	sum(s.documents_registered_cnt)  as total_count
from stamps s  join districts d 
on s.dis_code=d.dist_code
where s.month between '2019-04-01' and '2022-03-01'
group by s. dis_code ,d.district
order by 3 desc

---How does the revenue generated from document registration compare to the revenue generated from e-stamp challans across districts?

select 
	s.dis_code ,d.district ,
	sum(s.documents_registered_rev)  as rev_by_documents,
	sum (s.estamps_challans_rev) as rev_by_echallans ,
	((sum(s.estamps_challans_rev))- (sum(s.documents_registered_rev) ))*100/(sum(s.documents_registered_rev)) as differenence
from stamps s  join districts d 
on s.dis_code=d.dist_code
where s.month >='2020-12-01'
group by s. dis_code ,d.district
order by 5 desc

---List down the top 5 districts where e-stamps revenue contributes significantly more to the revenue than the documents in FY 2022?
select top 5
	s.dis_code ,d.district ,
	sum(s.documents_registered_rev)  as rev_by_documents,
	sum (s.estamps_challans_rev) as rev_by_echallans 
from stamps s  join districts d 
on s.dis_code=d.dist_code
where s.month  between '2022-04-01' and '2023-03-01'
group by s. dis_code ,d.district
having 	sum(s.documents_registered_rev) <  sum (s.estamps_challans_rev) 
order by   4 desc

/*
Is there any alteration of e-Stamp challan count and document registration count pattern since the implementation of e-Stamp challan? 
If so, what suggestions would you propose to the government?   */
select 
	s.dis_code ,d.district ,
	sum(s.documents_registered_cnt)  as rev_by_documents,
	sum (s.estamps_challans_cnt) as rev_by_echallans ,
	cast(1.0*(sum(s.estamps_challans_cnt)- 
	(sum(s.documents_registered_cnt) ))*100/(sum(s.documents_registered_cnt)) as decimal (10,2)) as differenence_in_percent
from stamps s  join districts d 
on s.dis_code=d.dist_code
where s.month >='2020-12-01'
group by s. dis_code ,d.district
order by 5 desc


---Categorize districts into three segments based on their stamp registration revenue generation during the fiscal year 2021 to 2022
with registration as (
select
	dis_code,
	sum(documents_registered_cnt + estamps_challans_cnt)  as total_reg
from stamps
where month between '2021-04-01' and '2022-03-01'
group by dis_code)
select
	r.dis_code,
	d.district,
	case when total_reg >100000 then 'High'
		when total_reg>50000 then 'Medium'
		else 'Low' end as Segments
from registration r join districts d
on d.dist_code=r.dis_code
order by 3

----Transportation
/** Investigate whether there is any correlation between vehicle sales and specific months or seasons in different districts. Are there any months
or seasons that consistently show higher or lower sales rate, and if yes, what could be the driving factors? (Consider Fuel-Type category only) */
select * from transport
alter table transport
alter column [fuel_type_diesel] int
SELECT
    datename(month, [month]) AS monthnames,
    SUM(fuel_type_diesel) AS total_diesel_consumption
FROM
    transport
GROUP BY  DATENAME(month, [month])
order by SUM(fuel_type_diesel) desc

/*How does the distribution of vehicles vary by vehicle class (MotorCycle, MotorCar, AutoRickshaw, Agriculture) across different
 districts? Are there any districts with a predominant preference for a
specific vehicle class? Consider FY 2022 for analysis. */

SELECT
    dist_code,
    sum([vehicleClass_MotorCycle]) as motot_cycle ,
	sum([vehicleClass_MotorCar])  as motor_car,
	sum([vehicleClass_AutoRickshaw]) as auto_richsaw,
	sum([vehicleClass_Agriculture]) as agri
FROM
    transport
where month between '2022-04-01' and '2023-04-01'
GROUP BY  dist_code

/*  List down the top 3 and bottom 3 districts that have shown the highest and lowest vehicle sales growth during FY 2022 compared to FY
2021? (Consider and compare categories: Petrol, Diesel and Electric)  */
----top 3 highest distict
select  top 3
	t1.dist_code,
	(SUM(t2.[fuel_type_petrol])-SUM(t1.[fuel_type_petrol]))  * 100   /SUM(t1.[fuel_type_petrol]) as petrol_growth
from transport t1 join transport t2
on t1.dist_code=t2.dist_code and  year(t1.month)=year(t2.month)-1 
where YEAR(t1.month)=2021
group by t1.dist_code 
order by 2 desc
---- bottom 3 
select  top 3
	t1.dist_code,
	(SUM(t2.[fuel_type_petrol])-SUM(t1.[fuel_type_petrol]))  * 100   /SUM(t1.[fuel_type_petrol]) as petrol_growth
from transport t1 join transport t2
on t1.dist_code=t2.dist_code and  year(t1.month)=year(t2.month)-1 
where YEAR(t1.month)=2021
group by t1.dist_code 
order by 2 

---Ts- i pass
---List down the top 5 sectors that have witnessed the most significant investments in FY 2022.
select top 5
	sector,
	sum(investment_in_cr)
from ipass
group by sector
order by 2 desc

----List down the top 3 districts that have attracted the most significant sector investments during FY 2019 to 2022? 
select top 3
	d.district,
	sum(investment_in_cr)
from ipass i join districts d  on i.dist_code=d.dist_code
join dates t on i.month=t.month
where t.fiscal_year >=2019 and t.fiscal_year <=2022
group by d.district
order by 2 desc

----Is there any relationship between district investments, vehicles
---sales and stamps revenue within the same district between FY 2021 and 2022?

with cte1 as( 
select  
	s.dis_code,
	sum(s.documents_registered_rev  + s.estamps_challans_rev) as total_count
	,row_number() over (order by sum(s.documents_registered_rev  + s.estamps_challans_rev) desc)  as rank
from 
stamps s join  dates d on s.month=d.month
where d.fiscal_year=2021
group by dis_code),
cte2 as(
select 
	i.dist_code,
	sum(i.investment_in_cr) as investments,
	row_number() over (order by sum(i.investment_in_cr) desc) as rank
from ipass i join dates t on i.month=t.month
where t.fiscal_year =2021
group by i.dist_code)
,cte3 as(
SELECT
    t.dist_code,
    sum(t.fuel_type_petrol + t.fuel_type_diesel +t.fuel_type_electric+t.fuel_type_others) as vehicel_sold,
	ROW_NUMBER() over(order by sum(t.fuel_type_petrol + t.fuel_type_diesel +t.fuel_type_electric+t.fuel_type_others)  desc) as rank
FROM
    transport t join dates d on t.month=d.month
where d.fiscal_year =2021
GROUP BY  t.dist_code)

select 
	d.district
	,c1.total_count,c1.rank,
	c2.investments,c2.rank,
	c3.vehicel_sold,c3.rank from 
districts d 
left join cte1 c1 on d.dist_code=c1.dis_code
join cte2 c2 on c1.dis_code=c2.dist_code
join cte3 c3 on c3.dist_code=c1.dis_code
order by c1.rank,c2.rank,c3.rank




