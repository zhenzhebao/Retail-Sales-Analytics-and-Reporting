-- Based on the result of data audit report from report 9, 
-- implement a trigge to prevent people setting zero or negative unit price in product table

create trigger trg_product_positive_price_only_insert
before insert 
on product 
when New.unit_price<=0
begin
	select raise(abort,
	'Product Unit Price must be greater than zero');
end;

create trigger trg_product_positive_price_only_update
before update 
on product 
when New.unit_price<=0
begin
	select raise(abort,
	'Product Unit Price must be greater than zero');
end;

insert into product(stockcode,description,unit_price,category_id)
values('test1','invalid value',0,1);
update product
set unit_price=0
where stockcode='85123A';