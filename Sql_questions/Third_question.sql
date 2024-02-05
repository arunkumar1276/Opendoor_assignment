with cte_checkouts as (
  select customer_id
    , cart_id
  from checkouts
  qualify row_number() over(partition by customer_id order by cart_id) <= 2
)

, base as (
  select cte_checkouts.customer_id
    , cart_id
    , sum(quantity * price_per_unit_cents)/ 100 sale_value_dollars
  from cte_checkouts
  left join checkut_items
    on cte_checkouts.cart_id = checkout_items.car_id
  group by 1,2
)

select customer_id
  , sale_value_dollars - lead(sale_value_dollars) over (partition by customer_id order by cart_id)
from base
qualify lead(sale_value_dollars) over (partition by customer_id order by cart_id) is not null
