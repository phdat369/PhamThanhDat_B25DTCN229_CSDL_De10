-- Tạo cơ sở dữ liệu
create database final_subject;
use final_subject;
-- 1.1  Thiết kế bảng — DDL
-- Bảng 1 — Customers (Khách hàng)
create table customers (
   customer_id varchar(10) primary key,
   full_name varchar(100) not null,
   phone_number varchar(15) not null unique,
   email varchar(100) not null,
   join_date date default (current_date())
);
-- Bảng 2 — Insurance_Packages (Gói bảo hiểm)
drop table insurance_packages;
drop table policies;
drop table claims;
drop table claim_processing_log;
create table insurance_packages (
   package_id varchar(10) primary key,
   package_name varchar(50) not null ,
   max_limit decimal(12,2) not null check (max_limit > 0),
   base_premium decimal(10,2) not null check (base_premium > 0)
);
-- Bảng 3 — Policies (Hợp đồng bảo hiểm)
create table policies (
   policy_id varchar(10) primary key,
   customer_id varchar(10) not null,
   package_id varchar(10) not null,
   start_date date not null,
   end_date date not null,
   status varchar(50) not null check (status in ('Active', 'Expired', 'Cancelled')),
   check (end_date > start_date),
   foreign key (customer_id) references customers (customer_id) on update cascade on delete no action,
   foreign key (package_id) references insurance_packages (package_id) on update cascade on delete no action
);
-- Bảng 4 — Claims (Yêu cầu bồi thường)
create table claims (
   claim_id varchar(10) primary key,
   policy_id varchar(10) not null,
   claim_date date not null default (current_date()),
   claim_amount decimal(12,2) not null check (claim_amount > 0),
   status varchar(50) not null default 'Pending' check (status in ('Pending','Approved','Rejected')),
   foreign key (policy_id) references policies (policy_id)
);
-- Bảng 5 — Claim_Processing_Log (Nhật ký xử lý)
create table claim_processing_log (
   log_id varchar(10) primary key,
   claim_id varchar(10) not null,
   action_detail text not null,
   recorded_at datetime not null default current_timestamp,
   processor varchar(100) not null,
   foreign key (claim_id) references claims (claim_id)
);
-- 1.2  Chèn dữ liệu mẫu — DML 
insert into customers (customer_id,full_name,phone_number,email,join_date) 
values ('C001','Nguyen Hoang Long','0901112223','long.nh@gmail.com','2024-01-15'),
       ('C002','Tran Thi Kim Anh','0988877766','anh.tk@yahoo.com','2024-03-10'),
       ('C003','Le Hoang Nam','0903334445','nam.lh@outlook.com','2025-05-20'),
       ('C004','Pham Minh Duc','0355556667','duc.pm@gmail.com','2025-08-12'),
       ('C005','Hoang Thu Thao','0779998881','thao.ht@gmail.com','2026-01-01');
insert into insurance_packages (package_id,package_name,max_limit,base_premium) 
values ('PKG01','Bảo hiểm Sức khỏe Gold',500000000,5000000),
       ('PKG02','Bảo hiểm Ô tô Liberty',1000000000,15000000),
       ('PKG03','Bảo hiểm Nhân thọ An Bình',2000000000,25000000),
       ('PKG04','Bảo hiểm Du lịch Quốc tế',100000000,1000000),
       ('PKG05','Bảo hiểm Tai nạn 24/7',200000000,2500000);
insert into policies (policy_id,customer_id,package_id,start_date,end_date,status) 
values ('POL101','C001','PKG01','2024-01-15','2025-01-15','Expired'),
       ('POL102','C002','PKG02','2024-03-10','2026-03-10','Active'),
       ('POL103','C003','PKG03','2025-05-20','2035-05-20','Active'),
       ('POL104','C004','PKG04','2025-08-12','2025-09-12','Expired'),
       ('POL105','C005','PKG05','2026-01-01','2027-01-01','Active');
insert into claims (claim_id,policy_id,claim_date,claim_amount,status) 
values ('CLM901','POL102','2024-06-15',12000000,'Approved'),
       ('CLM902','POL103','2025-10-20',50000000,'Pending'),
       ('CLM903','POL101','2024-11-05',5500000,'Approved'),
       ('CLM904','POL105','2026-01-15',2000000,'Rejected'),
       ('CLM905','POL102','2025-02-10',120000000,'Approved');
insert into claim_processing_log (log_id,claim_id,action_detail,recorded_at,processor) 
values ('L001','CLM901','Đã nhận hồ sơ hiện trường','2024-06-15 09:00','Admin_01'),
       ('L002','CLM901','Chấp nhận bồi thường xe tai nạn','2024-06-20 14:30','Admin_01'),
       ('L003','CLM902','Đang thẩm định hồ sơ bệnh án','2025-10-21 10:00','Admin_02'),
       ('L004','CLM904','Từ chối do lỗi cố ý của khách hàng','2026-01-16 16:00','Admin_03'),
       ('L005','CLM905','Đã thanh toán qua chuyển khoản','2025-02-15 08:30','Accountant_01');
-- 1.3  Cập nhật & Xóa dữ liệu 
-- Câu 1: 
update insurance_packages 
set base_premium = base_premium * 1.15
where max_limit > 500000000;
set sql_safe_updates = 0;
-- Câu 2: 
delete
from claim_processing_log 
where recorded_at < '2025-06-20';

-- Câu 1: Liệt kê thông tin các hợp đồng có trạng thái 'Active' và có ngày kết thúc (end_date) trong năm 2026.
select policy_id,customer_id,package_id,start_date,end_date,status
from policies 
where status = 'Active'and (year(end_date) = '2026');
-- Câu 2: Lấy thông tin khách hàng (họ tên, email) có tên chứa chữ 'Hoang' và tham gia bảo hiểm từ năm 2025 trở lại đây. 
select full_name,email
from customers 
where full_name like ('%Hoang%') and (join_date between '2025-01-1' and current_date()); 
-- Câu 3: Sắp xếp claim_amount giảm dần, bỏ qua bản ghi đầu tiên, lấy 3 bản ghi tiếp theo.
select claim_id,policy_id,claim_date,claim_amount,status 
from claims 
order by claim_amount desc 
limit 3 
offset 1;
-- Câu 1: (7đ)  Sử dụng LEFT JOIN để hiển thị cả hợp đồng chưa có yêu cầu bồi thường. Kết quả gồm: Tên khách hàng, Tên gói bảo hiểm, Ngày bắt đầu hợp đồng, Số tiền bồi thường (NULL nếu chưa có) 
select c.full_name,i.package_name,p.start_date,cl.claim_amount 
from policies p 
left join customers c 
on c.customer_id = p.customer_id 
left join claims cl
on cl.policy_id = p.policy_id 
left join insurance_packages i 
on i.package_id = p.package_id;
-- Câu 2: (7đ)  Thống kê tổng số tiền bồi thường đã chi trả (status = 'Approved') cho từng khách hàng. Chỉ hiển thị những người có tổng chi trả > 50.000.000 VNĐ
select c.full_name , sum(cl.claim_amount) as total
from customers c 
inner join policies p 
on p.customer_id = c.customer_id 
inner join claims cl 
on cl.policy_id = p.policy_id 
where cl.status = 'Approved' 
group by c.customer_id
having sum(cl.claim_amount) > 50000000;
-- Câu 3: (6đ)  Tìm gói bảo hiểm có số lượng khách hàng đăng ký nhiều nhất 
select i.package_name, count(p.package_id) as quantity_buy 
from policies p 
inner join insurance_packages i 
on i.package_id = p.package_id
group by p.package_id 
order by count(p.package_id) desc 
limit 1;

-- Câu 1: (4đ)  Tạo Composite Index tên idx_policy_status_date trên bảng Policies cho hai cột: status và start_date
create index idx_policy_status_date 
on policies(status,start_date);
-- Câu 2: (6đ)  Tạo View tên vw_customer_summary hiển thị: Tên khách hàng, Số lượng hợp đồng đang sở hữu, Tổng phí bảo hiểm định kỳ phải trả
create view vw_customer_summary 
as select c.full_name,count(p.policy_id) as quantity_polices, sum(i.base_premium) as total_return
from customers c 
inner join policies p 
on p.customer_id = c.customer_id 
inner join insurance_packages i 
on i.package_id = p.package_id
group by c.full_name;
select * from vw_customer_summary;
-- Câu 1: (5đ)  Viết Trigger tên trg_after_claim_approved.
-- Yêu cầu: Khi một yêu cầu bồi thường chuyển trạng thái sang 'Approved', tự động thêm một dòng vào Claim_Processing_Log với nội dung:
-- 'Payment processed to customer'
delimiter // 
create trigger trg_after_claim_approved
after update on claims
for each row
begin
   if new.status = 'Approved' then insert into claim_processing_log (action_detail) values ('Payment processed to customer');
   end if;
end // 
delimiter ;
-- Câu 2: (5đ)  Viết Trigger ngăn chặn việc xóa hợp đồng nếu trạng thái của hợp đồng đó đang là 'Active' 
delimiter // 
create trigger trg_check_delete 
after delete on policies 
for each row
begin
   if old.status = 'Active' then signal sqlstate '45000' set message_text = 'Không thể xóa';
   end if;
end // 
delimiter ;

-- Câu 1: (8đ)  Viết Stored Procedure sp_check_claim_limit
delimiter // 
create procedure sp_check_claim_limit (
   in p_claim_id varchar(10),
   out message varchar(50)
)
begin 
   declare p_claim_amount decimal(12,2);
   declare p_max_limit decimal(12,2);
   
   select claim_amount into p_claim_amount 
   from claims 
   where claim_id = p_claim_id;
   
   select i.max_limit into p_max_limit 
   from insurance_packages i 
   inner join policies p 
   on p.package_id = i.package_id 
   inner join claims cl 
   on cl.policy_id = p.policy_id 
   where cl.claim_id = p_claim_id ;
   
   if p_claim_amount > p_max_limit then set message = 'Exceeded';
   elseif p_claim_amount <= p_max_limit then set message = 'Valid';
   end if;
end // 
delimiter ;
call sp_check_claim_limit ('CLM901',@mes);

-- Câu 2: (12đ)  Viết Stored Procedure sp_cancel_policy để hủy một hợp đồng bảo hiểm
delimiter // 
create procedure sp_cancel_policy (
   in p_policy_id varchar(10),
   in p_claim_id varchar(10),
   out message varchar(50)
)
begin
start transaction;
   if p_policy_id not in (select policy_id 
					  from policies
					  where policy_id = p_policy_id) then set message = 'Policy not found';
					rollback;
	elseif p_claim_id not in (select claim_id
                              from claims
                              where policy_id = p_policy_id) then set message = 'Invalid claim for policy';
                              rollback;
	end if;
	update policies 
    set status = 'Cancelled'
    where policy_id = p_policy_id;
    
    update claim_processing_log 
    set action_detail = 'Customer requested cancellation'
    where claim_id = p_claim_id;
    
    set message = 'Cancelled successfully';
    commit;
end // 
delimiter ;