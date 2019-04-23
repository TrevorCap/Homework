use sakila;

select first_name as 'First Name', last_name as 'Last Name' 
from actor ;

select concat(first_name, ' ', last_name) as 'Actor Name'
from actor;

select * from actor
where first_name = 'JOE';

select * from actor
where last_name Like '%GEN%';

select * from actor
where last_name Like '%LI%'
order by last_name asc, first_name asc;

select country_id as 'Country ID', country as 'Country'
from country
where country IN ('Afghanistan', 'Bangladesh', 'China');

alter table actor
add column description blob;

alter table actor
drop column description;

select last_name as 'Last Name', count(last_name) as '# of Occurences'
from actor
group by last_name 
order by last_name asc;

select last_name as 'Last Name', count(last_name) as '# of Occurences'
from actor
group by last_name
having count(last_name) >1;


/* Determines actor id to replace*/
select actor_id from actor
where first_name = 'GROUCHO' AND last_name = 'williams';

update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO' AND last_name = 'williams';

update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO' AND last_name = 'williams';

describe address;

describe staff;

select s.first_name as 'First', s.last_name as 'Last', a.address as 'Address'
from staff s
left join address a on (s.address_id = a.address_id);

