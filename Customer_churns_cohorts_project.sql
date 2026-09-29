select * from customers_details;

select * from order_items;

select * from orders;
----------------------------------------------------------------------------------------------------------------------------------
/* Query used to join the order_items with order id*/

select 
order_items.category,
order_items.quantity,
order_items.unit_price,
orders.order_status,
orders.total_amount,
orders.discount_amount,
orders.shipping_fee
from orders
inner join order_items on orders.order_id = order_items.order_id
ORDER BY order_items.category;
----------------------------------------------------------------------------------------------------------------------------------
/* Query to find is there any duplicates */

select customer_id,
count(*) as is_any_duplicates
from customers_details
group by customer_id
having count(*)>1;

----------------------------------------------------------------------------------------------------------------------------------
/* Query to find the counts of disticnt country*/

select 
country,
count(*) as total_counts
from customers_details
group by country
order by total_counts;
----------------------------------------------------------------------------------------------------------------------------------

/*Finding the orders which are all completed and save it in a new table*/

create or replace view clean_sales as
select 
    customer_id,
    order_id,
    order_status,
    cast(order_date as date) as order_date,
    cast((date_format(order_date, '%Y-%m-01')) as date) as order_month,
    total_amount
    from orders
    where total_amount > 0
    and order_status not in ('Cancelled', 'Returned','Refunded')
    and customer_id is not null;
    
    select * from clean_sales;
 
----------------------------------------------------------------------------------------------------------------------------------
/* Find the customers cohorts month*/

create or replace view customers_cohorts as
select customer_id,
cast(min(order_month) as date) as cohorts_month,
min(order_date) as first_order_date
from clean_sales
group by customer_id;

select * from customers_cohorts;
----------------------------------------------------------------------------------------------------------------------------------
/* Finding the activity of the customers*/

create view cohort_activity as
select
clean_sales.customer_id,
customers_cohorts.cohorts_month,
clean_sales.order_month,
period_diff(
date_format(clean_sales.order_month, '%Y%m'),
date_format(customers_cohorts.cohorts_month, '%Y%m')
) as month_number,
clean_sales.total_amount
from clean_sales 
join customers_cohorts on clean_sales.customer_id = clean_sales.customer_id;

select * from cohort_activity;
----------------------------------------------------------------------------------------------------------------------------------
/* Finding the cohorts size, active users and the retenation rate in percentage*/

with cohortSize as (
select 
cohorts_month,
count(distinct customer_id) as total_cohort_users
from customers_cohorts
group by cohorts_month
),

RetentionCounts as (
select 
cohorts_month,
month_number,
count(distinct customer_id) as active_users
from cohort_activity
group by cohorts_month, month_number
)

select 
r.cohorts_month,
s.total_cohort_users as cohorts_size,
r.month_number,
r.active_users,
ROUND((r.active_users * 100.0 / s.total_cohort_users), 2) AS retention_rate_pct
from RetentionCounts r
inner join cohortSize as s on r.cohorts_month = s.cohorts_month
order by r.cohorts_month, r.month_number;

----------------------------------------------------------------------------------------------------------------------------------
/* Finding the customers who are all churned*/

with CustomerRecency as (
select 
customer_id,
max(order_date) as last_order_date,
datediff((select max(order_date) from clean_sales), max(order_date)) as days_since_last_order
from clean_sales
group by customer_id
)
select
customer_id,
last_order_date,
days_since_last_order,
case 
 when days_since_last_order > 90 then 'churned'
 else 'Active'
end as customer_status
from CustomerRecency 
order by days_since_last_order asc ;
----------------------------------------------------------------------------------------------------------------------------------
/* Finding the distinct order, historical of customer lifetime value and average*/

select
c.customer_id,
c.cohorts_month,
count(distinct s.order_id)	as total_orders,
round(sum(s.total_amount),2) as historical_clv,
round(avg(s.total_amount),2) as avg_order_value
from customers_cohorts c
join clean_sales s on c.customer_id = s.customer_id
group by c.customer_id, c.cohorts_month;

----------------------------------------------------------------------------------------------------------------------------------
/* Finding the monthly revenue for the months*/

select 
cohorts_month,
month_number,
round(sum(total_amount), 2) as monthly_revenue,
round(sum(sum(total_amount)) over (partition by cohorts_month order by month_number), 2) as cumulative_clv_revenue
from cohort_activity
group by cohorts_month, month_number
order by cohorts_month, month_number;
