-- since we ony have date of checkout, i will assume acquistion date to be the first checkout date.

-- built a cte for checkouts to avoid multipel scans on the database for the same table
with cte_checkouts as (
  select *
  from checkouts
)

  -- Acquisition year of the customer
, cte_cust_acq as 
(
  select customer_id
    , min(year(date)) acquisition_year
  from cte_checkouts
  group by 1
)

-- calculating the cart value
, cte_sales as 
(
  select checkouts.customer_id
    , checkout_items.cart_id
    , sum(checkout_items.quantity * checkout_items.price_per_unit_cents)/ 100 as cart_sales_value_dollars
  from checkout_items
  left join cte_checkouts
    on cte_checkouts.cart_id = checkout_items.cart_id
  group by 1,2
)

select acquisition_year
  , avg(cart_sales_value_dollars) as avg_cart_value_dollars -- metric
from cte_cust_acq
left join cte_sales
  on cte_cust_acq.customer_id = cte_sales.customer_id
group by 1
