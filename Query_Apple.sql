
--Query optimization
 SET SHOWPLAN_TEXT ON;
 GO
Select  * from sales
where product_id='P-44'
 GO
SET SHOWPLAN_TEXT OFF;
GO

CREATE INDEX sales_product_id ON sales(product_id);

CREATE INDEX sales_store_id ON sales(store_id);

CREATE INDEX sales_sale_date ON sales(sale_date);

-------------------------
select top 5 * from sales;
--1.Find each country and number of stores

 select  count(*) as total_count, country
 from stores
 group by country
 ORDER BY count(*) DESC;

 ---2. What is the total number of units sold by each store?

 select    store_name,store_id  from  stores;
  select top 5 * from  sales;

  select store_name,stores. store_id ,sum(quantity)
FROM stores
join sales
on
stores.store_id=sales.store_id
group by store_name,stores.store_id
order by sum(quantity) desc

--3. How many sales occurred in December 2023?

select top 5 * from sales;

select top 5 format(sale_date,'MMMM-yyyy')
from sales;

select sum(quantity) as total_sale,format(sale_date,'MMMM-yyyy')
from
sales
where format(sale_date,'MMMM-yyyy') ='December-2023'
group by format(sale_date,'MMMM-yyyy')
order by sum(quantity) DESC

--4. How many stores have never had a warranty claim filed against any of their products?
SELECT COUNT(*) FROM stores
WHERE store_id NOT IN (
						SELECT 
							DISTINCT store_id
						FROM sales as s
						RIGHT JOIN warranty as w
						ON s.sale_id = w.sale_id
						);
--Using CTE


						with cte as (
select  distinct store_id
from sales
left join
warrantys
on sales.sale_id=warrantys.sale_id
where warrantys.sale_id is null)

select count(store_id)
from cte

--5. What percentage of warranty claims are marked as "Warranty Void"?

select  distinct repair_status  from warrantys

select  * from warrantys;

SELECT (COUNT(*)*1.0/30836)*100 as void_percentage
FROM warrantys
where repair_status='Warranty Void'

SELECT COUNT(*)
FROM warrantys
where repair_status is not null;

--6. Which store had the highest total units sold in the last year?

select  top 5 * from sales;

SELECT TOP 1
    s.store_id,
    st.store_name,
    SUM(s.quantity) AS total_units_sold
FROM sales AS s
JOIN stores AS st
ON s.store_id = st.store_id
WHERE sale_date >= DATEADD(YEAR, -1, GETDATE())
GROUP BY s.store_id, st.store_name
ORDER BY total_units_sold DESC;

--7. Count the number of unique products sold in the last year.
select distinct product_id  from sales;

select  count(distinct product_id) as product_sold
from sales
where sale_date >= DATEADD(YEAR,-1,GETDATE())


--8. What is the average price of products in each category?

--select  * from products;

select category_id,   avg(price)  as Average_price
from products
group by (category_id)
order by avg(price) DESC

--9. How many warranty claims were filed in 2020?

SELECT * FROM warrantys;

SELECT
	count(format(claim_date,'yyyy')) as total_count
FROM
	warrantys
WHERE 
	format(claim_date,'yyyy') = 2020;

--10. Identify each store and best selling day based on highest qty sold

select  top 2* from sales

WITH CTE 
	AS
		(
		SELECT 
			format(sale_date,'dddd') as day,
			store_id,sum(quantity) as total,
			RANK() OVER (PARTITION BY store_id ORDER BY sum(quantity) DESC) AS rank
		FROM sales
	GROUP BY format(sale_date,'dddd'),store_id
	)

	SELECT
		day,
		store_id,
		total
	FROM 
		CTE
	WHERE
		rank='1'


--11. Identify least selling product of each country for each year based on total unit sold

select  * from products
select  * from sales;
select  * from stores;


--least selling product for each country for each year
WITH
new_rank as
	(
	SELECT
		country,product_name,sum(quantity) as total_units_sold,format(sale_date,'yyyy') as year,
		RANK() OVER(PARTITION BY country,format(sale_date,'yyyy') order by SUM(quantity) ) AS t1
	FROM
			sales as s	
	 JOIN 
		products as p
	ON
		p.product_id=s.product_id
	JOIN 
		stores as st
	ON
		s.store_id=st.store_id
	GROUP BY 
		country,format(sale_date,'yyyy'),product_name
	--Order by country,sum(quantity)
	)

	SELECT 
		country,
		product_name,
		total_units_sold,
		year
	FROM
		new_rank
	where 
		t1='1'
			
	---least selling product for each country in general

	WITH
new_rank as
	(
	SELECT
		country,product_name,sum(quantity) as total_units_sold,
		RANK() OVER(PARTITION BY country order by SUM(quantity) ) AS t1
	FROM
			sales as s	
	 JOIN 
		products as p
	ON
		p.product_id=s.product_id
	JOIN 
		stores as st
	ON
		s.store_id=st.store_id
	GROUP BY 
		country,product_name
	--Order by country,sum(quantity)
	)

	SELECT 
		country,
		product_name,
		total_units_sold
	
	FROM
		new_rank
	where 
		t1='1'


--12. How many warranty claims were filed within 180 days of a product sale?

select * from sales;
select * from warrantys;


select product_id, sale_date,claim_date, datediff(day,sale_date,claim_date) as days_diff
from  warrantys as w
join sales as s
on w.sale_id=s.sale_id
where datediff(day,sale_date,claim_date) < 180;

--final query
SELECT
	count(datediff(day,sale_date,claim_date) )AS days_diff
	FROM
		warrantys as w
	JOIN
		sales as s
	ON
		w.sale_id=s.sale_id
	WHERE
		datediff(day,sale_date,claim_date) <= 180;

--13. How many warranty claims have been filed for products launched in the last two years?

select product_name,count(claim_id) as total_claims
from sales as s
join product as p
on s.product_id=p.product_id
  join warrantys as w
on s.sale_id=w.sale_id
where launch_date>= dateadd(year,-2,getdate())
group by product_name

select * from warrantys;
select  * from products;

select * from products
where product_name ='iPhone SE (3rd Gen)'

select  * from sales
where product_id ='P-51'

select  * from warrantys
where sale_id in ('OID-100194','OID-100195')











--14. List the months in the last 3 years where sales exceeded 5000 units from usa.

select top 2 * from sales;
select top 2 * from stores;

--last 3 years
--from USA
--sales>50000

SELECT
	country,
	format(sale_date,'MM-yy'),
	sum(quantity) as total_units
		FROM
			sales as s
		JOIN
			stores as st
		ON
			s.store_id=st.store_id
		WHERE
			sale_date >= dateadd(year,-3, getdate()) and country='USA'
		GROUP BY
			country,format(sale_date,'MM-yy')
		HAVING
			sum(quantity)>5000
		ORDER BY
			sum(quantity) DESC



--15. Which product category had the most warranty claims filed in the last 2 years?

--select top 2 *  from warrantys;
--select top 2 * from products;
--select top 2 * from sales;
--select top 2 * from category;


SELECT
	category_id ,
	COUNT(claim_id)
FROM
	sales AS s
RIGHT JOIN
	warrantys AS w
ON
	w.sale_id=s.sale_id
JOIN
	products AS p
ON
	s.product_id=p.product_id
Where
	claim_date >= DATEADD(year,-2,getdate()) 
GROUP BY
	 category_id 
ORDER BY
	COUNT(claim_id) DESC;

--16. Determine the percentage chance of receiving claims after each purchase for each country.


select top 2 * from sales;
select top 2 * from warrantys;
select top 2 * from stores;

select top 2 * from sales;

--each country
--total claims
--total sales
--total claims/total sales= % of claim

With CTE1 as (
select country,sum(quantity) as sum_quantities_per_country
from sales as s
left join stores as st
on s.store_id=st.store_id
group by country
--order by sum(quantity) 
),
CTE2 as
(
select country,count(claim_id) as total_claim_per_country
from sales 
join warrantys
on sales.sale_id=warrantys.sale_id
join stores
on sales.store_id=stores.store_id
group by country
)

select CTE1.country, (((sum_quantities_per_country *1.0)/(total_claim_per_country *1.0))*100) as result
from CTE1
left join CTE2
on CTE1.country=CTE2.country
order by (((sum_quantities_per_country *1.0)/(total_claim_per_country *1.0))*100) DESC



WITH CTE1 AS (
    SELECT country, SUM(quantity) AS sum_quantities_per_country
    FROM sales AS s
    LEFT JOIN stores AS st
    ON s.store_id = st.store_id
    GROUP BY country
),
CTE2 AS (
    SELECT country, COUNT(claim_id) AS total_claim_per_country
    FROM sales 
    JOIN warrantys
    ON sales.sale_id = warrantys.sale_id
    JOIN stores
    ON sales.store_id = stores.store_id
    GROUP BY country
)

SELECT CTE1.country, 
       (((sum_quantities_per_country * 1.0) / (total_claim_per_country*1.0))*100) AS result
FROM CTE1
LEFT JOIN CTE2
ON CTE1.country = CTE2.country
order by  (sum_quantities_per_country * 0.01) / NULLIF(total_claim_per_country, 0) DESC;


SELECT
		country,
		total_units_sold,
		total_claim,
		( total_claim*1.0 /(total_units_sold*1.0 ) *100) as risk
	FROM (
		 SELECT country,
		 SUM(quantity) as total_units_sold,
		 COUNT(claim_id) AS total_claim
			FROM sales 
			left JOIN warrantys
			ON sales.sale_id = warrantys.sale_id
			JOIN stores
			ON sales.store_id = stores.store_id
			GROUP BY country
			)t1
	--where ( total_claim /NULLIF(total_units_sold *100,0))< 0
	order by 4 DESC

--	17. Analyze each stores year by year growth ratio
	
select top 2 *  from stores;
select top 2 * from sales;
select top 2 * from products;



WITH yearly_sales 
as
(
	select st.store_id,store_name, format(sale_date,'yyyy') as year , sum(s.quantity * p.price) as total_revenue
from sales as s
join products as p
on
	s.product_id=p.product_id
join stores as st
on s.store_id=st.store_id
	group by  st.store_id,store_name, format(sale_date,'yyyy')
	--order by  st.store_id, store_name,format(sale_date,'yyyy') 
),

growth_ratio as (
select 
	store_name,
		year,
			lag(total_revenue, 1) OVER(PARTITION BY store_name ORDER BY year ) as last_year_sale,
		total_revenue as current_year_sale
	
	from yearly_sales
	--order by store_name,year  
	)

	select 
		store_name,
		year,
		last_year_sale,
		current_year_sale,
		(current_year_sale  - last_year_sale) / last_year_sale*100

		from growth_ratio

--18. What is the correlation between product price and warranty claims for products sold in the last five years?

select top 2 * from warrantys;
select top 2 * from products;
select top 2 * from sales;

select count(claim_id)as total_claim,
CASE
WHEN
p.price<500
THEN 'Less Expensive Product'
WHEN
p.price between 500 and 1000 THEN 'More EXpensive Product'
ELSE 'Expensive Product'
END as seggeration
from warrantys as w
left join
sales as s
on
w.sale_id=s.sale_id
join products as p
on p.product_id=s.product_id
where format(claim_date,'yyyy') < dateadd(year,-5, GETDATE()) 
group by 
CASE
WHEN
p.price<500
THEN 'Less Expensive Product'
WHEN
p.price between 500 and 1000 THEN 'More EXpensive Product'
ELSE 'Expensive Product'
END

-- 19. Identify the store with the highest percentage of "Paid Repaired" claims in relation to total claims filed.


select top 2 * from warrantys;
select top 2 * from products;
select top 2 * from sales;


with  T1 AS (
select store_id,count(claim_id) as total_claims
from warrantys as w
left join
sales as s
on w.sale_id=s.sale_id
join
products as p
on p.product_id=s.product_id
group by store_id

),

T2 as (
select store_id,count(claim_id) as paid_repair
from warrantys as w
left join
sales as s
on w.sale_id=s.sale_id
join
products as p
on p.product_id=s.product_id
where repair_status='Paid Repaired'
group by store_id
)

select T1.store_id,total_claims,paid_repair,
(paid_repair*1.0/total_claims )*100 as percentage_paid_repair
from T1
right join T2
on T1.store_id=T2.store_id
order by  percentage_paid_repair DESC


--20.Write SQL query to calculate the monthly running total of sales for each store over the past four years and compare the trends across this period?

select  * from stores;
select top 2 * from sales;
select top 2 * from products;


select format(sale_date,'MM') from sales;

WITH T1 AS (
    SELECT 
        st.store_name, 
        s.quantity * p.price AS revenue, 
        FORMAT(s.sale_date, 'MM') AS month, 
        FORMAT(s.sale_date, 'yyyy') AS year
    FROM 
        sales s
    LEFT JOIN 
        stores st 
        ON s.store_id = st.store_id
    JOIN 
        products p 
        ON p.product_id = s.product_id
),
T2 AS (
    SELECT 
        store_name, 
        SUM(revenue) AS rolling, 
        month, 
        year
    FROM 
        T1
    WHERE 
        TRY_CAST(year AS INT) < YEAR(DATEADD(YEAR, -4, GETDATE())) -- Filter for data older than 4 years
    GROUP BY 
        store_name, 
        month, 
        year
)
SELECT 
    store_name, 
    month, 
    year, 
    rolling,
    SUM(rolling) OVER (PARTITION BY store_name ORDER BY year, month) AS month_running_total
FROM 
    T2
ORDER BY 
    store_name, 
    year, 
    month;

--20.Analyze sales trends of product over time, segmented into key time periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months?

select top 2 * from sales
select  top 2 * from products

with T1 as
(
select  product_name, (s.quantity * p.price ) as revenue ,format(launch_date,'MM') as month,format(launch_date,'yyyy') as year
from sales as s 
left join products as p
on s.product_id=p.product_id
)



WITH T1 AS (
    SELECT 
        p.product_name, 
        s.quantity AS revenue, 
        s.sale_date, 
        p.launch_date,
        CASE
            WHEN s.sale_date = p.launch_date THEN 'Introduction Phase'
            WHEN s.sale_date <= DATEADD(MONTH, 6, p.launch_date) THEN 'Introduction Phase'
            WHEN s.sale_date <= DATEADD(MONTH, 12, p.launch_date) THEN 'Growth Phase'
            WHEN s.sale_date <= DATEADD(MONTH, 18, p.launch_date) THEN 'Maturity Phase'
            ELSE 'Legacy Phase'
        END AS segmentation
    FROM 
        sales s
    LEFT JOIN 
        products p 
        ON s.product_id = p.product_id
)
SELECT 
    product_name, 
    segmentation, 
    SUM(revenue) AS total_sales
FROM 
    T1
GROUP BY 
    product_name, 
    segmentation
ORDER BY 
    product_name, 
    segmentation;


--USING CASE ON THE 2ND HALF

	WITH T1 AS (
    SELECT 
        p.product_name, 
        s.quantity AS revenue, 
        s.sale_date, 
        p.launch_date
    FROM 
        sales s
    LEFT JOIN 
        products p 
        ON s.product_id = p.product_id
)
SELECT 
    product_name, 
    CASE
        WHEN sale_date = launch_date THEN 'Introduction Phase'
        WHEN sale_date <= DATEADD(MONTH, 6, launch_date) THEN 'Introduction Phase'
        WHEN sale_date <= DATEADD(MONTH, 12, launch_date) THEN 'Growth Phase'
        WHEN sale_date <= DATEADD(MONTH, 18, launch_date) THEN 'Maturity Phase'
        ELSE 'Legacy Phase'
    END AS segmentation,
    SUM(revenue) AS total_sales
FROM 
    T1
GROUP BY 
    product_name, 
    CASE
        WHEN sale_date = launch_date THEN 'Introduction Phase'
        WHEN sale_date <= DATEADD(MONTH, 6, launch_date) THEN 'Introduction Phase'
        WHEN sale_date <= DATEADD(MONTH, 12, launch_date) THEN 'Growth Phase'
        WHEN sale_date <= DATEADD(MONTH, 18, launch_date) THEN 'Maturity Phase'
        ELSE 'Legacy Phase'
    END
ORDER BY 
    product_name, 
    segmentation;