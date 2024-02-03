with cte_customers as 
(
  select customer_id
    , case when family_size = 1 then 'Single'
           when family_size = 1 then 'Couple'
           when family_size in (3,4,5) then 'Family'
      else 'Large Family' end as customer_type
  from customers
)

select customer_type
  , year(checkouts.date) * 100 + month(checkouts.date) as year_month
  -- we can also take epoch month, but year month makes more sense here
  -- , year(checkouts.date)*12 + month(checkouts.date) as epoch_month
  , sum(checkout_items.quantity) as sale_quantity
  , sum(checkout_items.quantity * price_per_unit_cents)/ 100 as sale_value_dollars
from checkouts
left join checkout_items
  on checkouts.cartid = checkout_items.cartid
left join cte_customers
  on checkouts.customer_id = cte_customers.customer_id
group by 1,2
