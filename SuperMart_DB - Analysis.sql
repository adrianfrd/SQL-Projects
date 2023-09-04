--IN THIS PROJECT SQL I USED A DATA SET FROM KAGGLE, UNZIPPED THE FILE, AND IMPORTED THE DATA TO POSTGRESQL
--I'm querying a database with multiple tables in it to quantify statistics about product and customer data sales. 
CREATE EXTENSION IF NOT EXISTS tablefunc;
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;
SELECT * FROM CUSTOMER;
SELECT * FROM PRODUCT;
SELECT * FROM SALES;

	
/* 1. Sales Revenue */
select 
	extract(year from order_date) as year_n,
	sum(sales) as total_sales,
	count(order_id) as total_order
from sales
group by year_n
order by year_n;

/* 2. Sales by Product Category */

select
	distinct p.category,
	sum(sales) as total_sales,
	extract(year from order_date) as year_n
from sales
	join product as p on 
	(sales.product_id = p.product_id)
where extract(year from order_date) in ('2014', '2015','2016','2017')
group by p.category, year_n
order by year_n;


select 	
	p.category,
	sum(sales)
from  sales
join product as p on (sales.product_id = p.product_id)
group by p.category;


/* 3. Top Selling Sub-Category */

select 	p.sub_category,
		sum(sales) as total_sales
from sales as s
	join product as p
	on (s.product_id = p.product_id)
group by p.sub_category
order by total_sales desc;

/* 4.  5 Top Selling Product */

select 	p.product_name,
		round(sum(sales)) as total_sales
from sales as s
	join product as p
	on (s.product_id = p.product_id)
group by p.product_name
order by total_sales desc
limit 5;

/* 5.  5 Slow Moving Selling Product */

select 	p.product_name,
		round(sum(sales)) as total_sales
from sales as s
	join product as p
	on (s.product_id = p.product_id)
group by p.product_name
order by total_sales asc
limit 5;


/* 6. Consumer Segment Sales */

select * from customer;
select distinct
	c.segment,
	round(sum(s.sales)) as total_sales
from sales as s
	join customer as c
		on (s.customer_id = c.customer_id)
group by c.segment
order by total_sales desc;


/* 7. Sales by Ship Mode */

select * from sales;
select distinct
	ship_mode,
	round(sum(sales)) as total_sales
from sales
group by ship_mode
order by total_sales desc;

/* 8. Most Sales by Region */

select * from customer;
select distinct
	c.region,
	round(sum(s.sales)) as total_sales
from sales as s
	join customer as c
		on (s.customer_id = c.customer_id)
group by c.region
order by total_sales desc;

/* 9. Top 10 Highest and Lowest Sales by City */

select * from customer;
select distinct
	c.city,
	round(sum(s.sales)) as total_sales
from sales as s
	join customer as c
		on (s.customer_id = c.customer_id)
group by c.city
order by total_sales desc
limit 10;


select distinct
	c.city,
	round(sum(s.sales)) as total_sales
from sales as s
	join customer as c
		on (s.customer_id = c.customer_id)
group by c.city
order by total_sales asc
limit 10;

select sum(sales)
	from sales;
select * from product;

/* 10. 3 Top Customer Contribution on Sales based on Segment */
select * 
from (
	select
		c.customer_name,
		c.segment,
		c.age,
		c.state,
		round(s.sales) as total_sales,
		rank() over(partition by c.segment order by s.sales desc) as rank,
		round(max(s.sales) over (partition by c.segment)) as max_sales
		from sales as s
			join customer as c
				on (s.customer_id = c.customer_id)
		group by c.segment, s.sales, c.customer_name, c.age, c.state
		order by c.segment, s.sales
	) x
where x.rank <= 3
order by x.segment, x.rank;  

/* 11. Top 5 Selling Product in each Category */
select * from(
	select
		p.product_name,
		p.category,
		SUM(s.sales),
		rank() over (partition by p.category order by s.sales desc) as rnk
	from sales as s
		 join product as p
			on (s.product_id = p.product_id)
	group by p.category, s.sales, p.product_name
	order by p.category, s.sales) x
where x.rnk <= 5
order by category, x.rnk;

/* SALES by Category each Year Trends */
SELECT * FROM CROSSTAB($$
	SELECT
		COALESCE(p.category,'All Categories') as Category,
		EXTRACT(YEAR FROM s.order_date) as Year,
		ROUND(SUM(s.sales)) as Sales
	FROM sales as s
	JOIN product as p
	USING (product_id)
	GROUP BY ROLLUP(p.category), year
	ORDER BY p.category, year;
$$) AS ct (Category VARCHAR,
		  "2014" double precision,
		  "2015" double precision,
		  "2016" double precision,
		  "2017" double precision)
ORDER BY Category Desc;

/* SALES by Category each Month Trends */
SELECT * FROM CROSSTAB($$
	SELECT
		COALESCE(p.category,'All Categories') as Category,
		EXTRACT(MONTH FROM s.order_date) as MONTH,
		ROUND(SUM(s.sales)) as Sales
	FROM sales as s
	JOIN product as p
	USING (product_id)
	GROUP BY ROLLUP(p.category), MONTH
	ORDER BY p.category, MONTH;
$$) AS ct (Category VARCHAR,
		  "January" double precision,
		  "February" double precision,
		  "March" double precision,
		  "April" double precision,
		  "May" double precision,
		  "June" double precision,
		  "July" double precision,
		  "August" double precision,
		  "September" double precision,
		  "October" double precision,
		  "November" double precision,
		  "December" double precision
		  )
ORDER BY Category Desc;

/* SALES by Category each Quarter Trends */
SELECT * FROM CROSSTAB($$
	SELECT
		COALESCE(p.category,'All Categories') as Category,
		EXTRACT(QUARTER FROM s.order_date) as Quarter,
		ROUND(SUM(s.sales)) as Sales
	FROM sales as s
	JOIN product as p
	USING (product_id)
	WHERE EXTRACT(YEAR FROM s.order_date) = 2014 -- Can Change to 2014 - 2017
	GROUP BY ROLLUP(p.category), Quarter
	ORDER BY p.category, Quarter;
$$) AS ct (Category VARCHAR,
		  "Q1" double precision,
		  "Q2" double precision,
		  "Q3" double precision,
		  "Q4" double precision)
ORDER BY Category Desc;

/* Check IF Value its TRUE or FALSE in previous Code */
SELECT ROUND(SUM(sales))
FROM SALES
JOIN PRODUCT
USING(product_id)
WHERE product.category = 'Office Supplies' 
	AND EXTRACT(QUARTER FROM SALES.order_date) = '3'
	AND EXTRACT(YEAR FROM SALES.order_date) = 2015
	