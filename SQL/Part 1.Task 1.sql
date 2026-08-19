select c.first_name , c.last_name , age, c.country  
from customers c 
where c.country in ('USA') and c.age > 25; 