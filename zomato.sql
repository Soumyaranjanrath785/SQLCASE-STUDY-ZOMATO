drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
            VALUES (1,'09-22-2017'),
                   (3,'04-21-2017');


drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
        (2,'2015-01-15'),
        (3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

what is the total amount each customer spend on zomato?

select s.userid,sum(p.price) as money from sales s inner join product p
on s.product_id=p.product_id
group by s.userid
order by money desc

how many days each customer visited zomato?

select userid, count( distinct created_date) from sales
group by userid

waht was the first product purchased by each customer?

select userid,created_date,product_id from sales
where created_date in (select min(created_date) from sales group by userid)

what is the most purchased item in menu and how many times it was purchased by all customres?

select userid,count(product_id) from sales
where product_id = (select product_id from (select product_id, count(product_id) as c from sales group by product_id order by c desc limit 1) as d) 
group by userid

which iteam was most popular for each customer

with rank_table as(
	select userid,product_id,count(product_id),dense_rank() over (partition by userid order by count(product_id) desc) as rnk from sales
    group by userid,product_id
    order by userid
)
select userid,product_id from rank_table
where rnk=1

which item was first purchased by customer after they became members

select * from sales 
select *  from product
select *  from users
select *  from goldusers_signup

select userid,product_id,date from (select s.userid,s.product_id,s.created_date as date,
									dense_rank() over(partition by s.userid order by s.created_date) as rn 
									from sales s join goldusers_signup u
                                    on s.userid=u.userid
                                    where s.created_date>=u.gold_signup_date) as dm
where rn=1

which item was  purchased before customer  became members

select s.userid,s.product_id,s.Date from(select s.userid,s.product_id,s.created_date as Date,
                                                  dense_rank() over(partition by s.userid order by s.created_date desc) as rnk 
                                                  from sales s join goldusers_signup u
                                                   on s.userid=u.userid
                                                    where s.created_date<=u.gold_signup_date) as s
where rnk=1

what is the total amount spent by each customers before they became a member

select s.userid,sum(p.price) as total from sales s join product p on s.product_id=p.product_id 
join goldusers_signup g on g.userid=s.userid
where s.created_date<g.gold_signup_date
group by s.userid


if buying each product generate points and each product have different purchasing points and 2p-rs5
p1-rs5-1p
p2-rs10-5p
p3-rs5-1p

calculate points collected by each customer and for which product most points have been given till now

with product_info as(
	select *,case when points>0 then (points/2)*5 else 0 end as reward from(select *, case when product_name='p1' then price/5 when product_name='p2' then price/2 when product_name='p3' then price/5 
    end as points from product) as d 
)
select s.userid,sum(p.points) as total_points,sum(reward) as total_rewards  from product_info p join sales s on p.product_id=s.product_id
group by s.userid
order by userid

with product_info as(
	select *,case when points>0 then (points/2)*5 else 0 end as reward from(select *, case when product_name='p1' then price/5 when product_name='p2' then price/2 when product_name='p3' then price/5 
    end as points from product) as d 
)
select s.product_id,sum(p.points) as total_points,sum(reward) as total_rewards  from product_info p join sales s on p.product_id=s.product_id
group by s.product_id
order by total_points desc
limit 1

In the first one year after a customer joins the gold program(including joining date) irrespective of 
what the customer has earned they earn 5 points for every 10rs spent who earned more 1 or 3 
and what was their points earnings in first year ?



select userid,sum(points) as total_points from (select s.userid,g.gold_signup_date,s.created_date,s.product_id,
												(s.created_date-g.gold_signup_date) 
								                as days,(p.price/10)*5  as points
                                                from sales s join goldusers_signup g on s.userid=g.userid 
                                                join product p on s.product_id=p.product_id
                                                where s.created_date>g.gold_signup_date) as f
where days<=365
group by f.userid


Rank_ all_ the transctions of_ customers

select *,dense_rank() over (partition by userid order by created_date) as rnk from sales

Rank_ all_ the transctions of_ customers when they are gold members if not mark na

select x.userid,x.created_date,x.product_id ,
       case when x.gold_signup_date is null then  'NA'
	        else cast (x.rnk  AS VARCHAR) 
       end as rnk 
from
    (select s.*,g.gold_signup_date, dense_rank() over (partition by s.userid order by s.created_date) as rnk 
      from sales s left join goldusers_signup g
      on s.userid=g.userid) AS x
	  

  
	  
	  

