use Placement_Project

-- 1. Creating the patient table
CREATE TABLE patient (
    PatientID NVARCHAR(10) PRIMARY KEY,
    Fname NVARCHAR(50),
    Lname NVARCHAR(50),
    Contact NVARCHAR(20),
    Age INT
);

INSERT INTO patient (PatientID, Fname, Lname, Contact, Age)
VALUES
('P0001', 'John', 'Doe', '123-456-7890', 35),
('P0002', 'Jane', 'Smith', '987-654-3210', 25),
('P0003', 'Michael', 'Johnson', '555-555-5555', 62),
('P0004', 'David', 'Lee', '111-222-3333', 33),
('P0005', 'Sarah', 'Brown', '444-555-6666', 21),
('P0006', 'John', 'Doe', '777-888-9999', 28),
('P0007', 'Jane', 'Smith', '333-222-1111', 30),
('P0008', 'Michael', 'Johnson', '666-777-8888', 41),
('P0009', 'David', 'Lee', '999-888-7777', 41),
('P0010', 'Sarah', 'Brown', '222-333-4444', 60);


-- 2. Creating the doctor table
CREATE TABLE doctor (
    DoctorID NVARCHAR(10) PRIMARY KEY,
    Fname NVARCHAR(50),
    Lname NVARCHAR(50),
    Speciality NVARCHAR(50),
    ContactEmail NVARCHAR(100)
);

INSERT INTO doctor (DoctorID, Fname, Lname, Speciality, ContactEmail)
VALUES
('D0001', 'Dr. John', 'Doe', 'General Physician', 'john.doe@example.com'),
('D0002', 'Dr. Jane', 'Smith', 'Pediatrician', 'jane.smith@example.com'),
('D0003', 'Dr. Michael', 'Johnson', 'Cardiologist', 'michael.j@example.com');


-- 3. Creating the appointment table
CREATE TABLE Appointment (
    AppointmentID NVARCHAR(10) PRIMARY KEY,
    PatientID NVARCHAR(10),
    DoctorID NVARCHAR(10),
    Date DATETIME,
    EndTime DATETIME,
    Status NVARCHAR(20),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

INSERT INTO Appointment (AppointmentID, PatientID, DoctorID, Date, EndTime, Status)
VALUES
('A0001', 'P0001', 'D0001', '2023-11-07 10:00', '2023-11-07 11:15', 'Scheduled'),
('A0002', 'P0002', 'D0002', '2023-11-08 11:00', '2023-11-08 12:06', 'Completed'),
('A0003', 'P0003', 'D0003', '2023-11-09 12:00', '2023-11-09 13:21', 'Cancelled'),
('A0004', 'P0002', 'D0001', '2023-11-10 13:00', '2023-11-10 14:17', 'Scheduled'),
('A0005', 'P0005', 'D0002', '2023-11-11 14:00', '2023-11-11 15:45', 'Completed'),
('A0006', 'P0006', 'D0003', '2023-11-12 15:00', '2023-11-12 16:15', 'Cancelled'),
('A0007', 'P0007', 'D0001', '2023-11-13 16:00', '2023-11-13 17:09', 'Scheduled'),
('A0008', 'P0008', 'D0002', '2023-11-14 17:00', '2023-11-14 18:29', 'Completed'),
('A0009', 'P0004', 'D0003', '2023-11-15 18:00', '2023-11-15 19:11', 'Cancelled'),
('A0010', 'P0010', 'D0001', '2023-11-16 19:00', '2023-11-16 20:05', 'Scheduled');



-- 4. Creating the PatientAppointment table
CREATE TABLE PatientAppointment (
    PatientID NVARCHAR(10),
    AppointmentID NVARCHAR(10),
    PRIMARY KEY (PatientID, AppointmentID),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

INSERT INTO PatientAppointment (PatientID, AppointmentID)
VALUES
('P0001', 'A0001'),
('P0002', 'A0002'),
('P0003', 'A0003'),
('P0004', 'A0004'),
('P0005', 'A0005'),
('P0006', 'A0006'),
('P0007', 'A0007'),
('P0008', 'A0008'),
('P0009', 'A0009'),
('P0010', 'A0010'),
('P0001', 'A0004'),
('P0002', 'A0005'),
('P0003', 'A0006');




-- 5. Creating the PatientHistory table
CREATE TABLE PatientHistory (
    HistoryID NVARCHAR(10) PRIMARY KEY,        -- Unique identifier for each history record
    PatientID NVARCHAR(10),                    -- References the PatientID from the Patient table
    [Date] DATETIME,                           -- Date of the record, use square brackets as 'Date' is a reserved keyword
    [Condition] NVARCHAR(50),                  -- Medical condition of the patient
    Surgeries NVARCHAR(50),                    -- Surgeries the patient had
    Medication NVARCHAR(50),                   -- Medication prescribed to the patient
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)  -- Establishing foreign key relationship with Patient table
);

INSERT INTO PatientHistory (HistoryID, PatientID, [Date], [Condition], Surgeries, Medication)
VALUES
('H0001', 'P0001', '2023-11-01 08:00', 'Hypertension', 'Appendectomy', 'Lisinopril'),
('H0002', 'P0002', '2023-11-02 09:00', 'Diabetes', 'None', 'Metformin'),
('H0003', 'P0003', '2023-11-03 10:00', 'Asthma', 'Tonsillectomy', 'Albuterol'),
('H0004', 'P0004', '2023-11-04 11:00', 'Migraine', 'Appendectomy', 'Ibuprofen'),
('H0005', 'P0005', '2023-11-05 12:00', 'Diabetes', 'None', 'Insulin'),
('H0006', 'P0006', '2023-11-06 13:00', 'Asthma', 'Tonsillectomy', 'Albuterol'),
('H0007', 'P0007', '2023-11-07 14:00', 'Hypertension', 'Appendectomy', 'Lisinopril'),
('H0008', 'P0008', '2023-11-08 15:00', 'Diabetes', 'None', 'Metformin'),
('H0009', 'P0009', '2023-11-09 16:00', 'Asthma', 'Tonsillectomy', 'Albuterol'),
('H0010', 'P0010', '2023-11-10 17:00', 'Migraine', 'Appendectomy', 'Ibuprofen');



-- 6. Creating the PatientFillHistory table
CREATE TABLE PatientFillHistory (
    PatientID NVARCHAR(10),        -- References the PatientID from the Patient table
    HistoryID NVARCHAR(10),        -- References the HistoryID from the PatientHistory table
    DateFilled DATETIME,           -- Date and time when the prescription was filled
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),   -- Establishing foreign key relationship with Patient table
    FOREIGN KEY (HistoryID) REFERENCES PatientHistory(HistoryID) -- Establishing foreign key relationship with PatientHistory table
);

INSERT INTO PatientFillHistory (PatientID, HistoryID, DateFilled)
VALUES
('P0001', 'H0001', '2023-11-04 08:30'),
('P0002', 'H0002', '2023-11-05 09:45'),
('P0003', 'H0003', '2023-11-06 10:30'),
('P0004', 'H0004', '2023-11-07 11:15'),
('P0005', 'H0005', '2023-11-08 12:45'),
('P0006', 'H0006', '2023-11-09 13:30'),
('P0007', 'H0007', '2023-11-10 14:15'),
('P0008', 'H0008', '2023-11-11 15:45'),
('P0009', 'H0009', '2023-11-12 16:30'),
('P0010', 'H0010', '2023-11-13 17:15');



-- 7. Creating the MediacationCost table
CREATE TABLE MedicationCost (
    Medication NVARCHAR(50) PRIMARY KEY,  -- The name of the medication, which is unique
    Cost_in$ DECIMAL(10, 2)               -- Cost of the medication in dollars
);

INSERT INTO MedicationCost (Medication, Cost_in$)
VALUES
('Lisinopril', 10.00),
('Metformin', 15.00),
('Albuterol', 12.00),
('Ibuprofen', 8.00),
('Insulin', 20.00);

-- tables
select * from patient
select * from doctor
select * from appointment
select * from PatientAppointment
select * from PatientHistory
select * from PatientFillHistory
select * from MedicationCost



/* 
Question: 1
Find the names of patients who have attended appointments scheduled by Dr. John Doe.
*/

select 
	a.PatientID, a.Fname, a.Lname, d.DoctorID, d.Fname, d.Lname, c.AppointmentID
from 
	patient as a
join
	PatientAppointment as b -- linking patients to their appointments
on 
	a.PatientID = b.PatientID  
join
	appointment as c -- linking the appointment details 
on 
	b.AppointmentID = c.AppointmentID 
join
	doctor as d -- linking the doctor details 
on
	c.DoctorID = d.DoctorID 
where
	d.Fname like 'Dr. John'
and
	d.Lname like 'Doe'



/*
Question: 2
Calculate the average age of all patients.
*/

select 
	avg(Age) as average_age_of_all_patients
from 
	patient



/*
Question: 3
Create a stored procedure to get the total number of appointments for a given patient
*/

drop procedure if exists GetTotalAppointments

create procedure GetTotalAppointments
	@PatientID nvarchar(10) -- defining parameter
as
begin
	select
		count(AppointmentID) as total_appointment_count
	from 
		PatientAppointment
	where 
		PatientID = @PatientID
end

--declare @PatientID nvarchar(10) -- declare a variable
--set @PatientID = 'P0001' -- set the variable

exec GetTotalAppointments @PatientID = 'P0001' -- execute



/*
Question: 4
Create a trigger to update the appointment status to 'Completed' when the appointment date has passed.
*/

-- creating a staging appointment table for verification
select * into appointment_staging from appointment
drop table appointment_staging
select * from appointment_staging

--drop trigger if already exists
drop trigger if exists UpdateAppointmentStatus

create trigger UpdateAppointmentStatus
on appointment_staging
after insert, update -- the trigger will run after an insert or update operation
as 
begin
	-- Update the status of appointments where the appointment date has passed
	update a
	set a.Status = 'Completed'
	from 
		appointment_staging as a
	join 
		inserted as i on a.AppointmentID = i.AppointmentID -- inserted is a special table that holds data that has been added or changed, and the WHERE filter is applied only to this record (or records)
	where 
		a.Date < getdate() -- appointment date is less than the current date
	and
		a.Status != 'Completed' -- update only where status is not 'Completed'
end

-- verify if the trigger exists
select 
	*
from 
	sys.triggers
where 
	name = 'UpdateAppointmentStatus'

-- checking the trigger functionality
insert into appointment_staging(AppointmentID, PatientID, DoctorID, Date, EndTime, Status) -- inserting a new appointment with a past date
values('A0011', 'P0011', 'D0011', '2023-01-01 09:00:00', '2023-01-01 12:00:00', 'Scheduled')

-- verifying if the inserted row has fired the trigger
select * from appointment_staging 
where AppointmentID = 'A0011'



/*
Question: 5
Find the names of patients along with their appointment details and the corresponding doctor's name.
*/

select 
	a.PatientID,
	a.Fname,
	a.Lname,
	c.AppointmentID, 
	c.Date,
	c.EndTime,
	c.Status,
	d.DoctorID,
	d.Fname,
	d.Lname
from 
	patient as a
join 
	PatientAppointment as b -- linking patients to their appointments
on
	a.PatientID = b.PatientID
join
	appointment as c -- linking the appointment details 
on 
	b.AppointmentID = c.AppointmentID
join
	doctor as d -- linking the doctor details
on
	c.DoctorID = d.DoctorID

/*The Appointment table contains details about each appointment, like the appointment date, time, doctor, 
and status (e.g., scheduled, completed). It mainly focuses on the appointment itself. 
The PatientAppointment table, on the other hand, links patients to their appointments, 
especially when more complex relationships are needed — like if a patient has multiple appointments 
or if an appointment involves multiple patients. 
This table allows you to track each patient's involvement in appointments more easily 
and can store additional details about the patient's participation.
*/



/*
Question: 6
Find the patients who have a medical history of diabetes and their next appointment is scheduled within the next 7 days.
*/

select 
	a.PatientID,
	a.Fname,
	a.Lname,
	d.AppointmentID,
	d.Date,
	b.Condition
from 
	patient as a
join
	PatientHistory as b -- linking patients to their medical history
on
	a.PatientID = b.PatientID
join
	PatientAppointment as c -- linking patients to their appointments
on
	b.PatientID = c.PatientID 
join
	appointment as d -- linking patients to their apointment details
on
	c.AppointmentID = d.AppointmentID
where 
	b.Condition like 'Diabetes'
and
	d.Date >= '2023-11-07' -- ensuring the appointment is on or after this day
and
	d.Date <= dateadd(day, 7, '2023-11-07') -- ensuring the appointment is within the next 7 days of the given date



/*
Question: 7
Find patients who have multiple appointments scheduled
*/

select 
	a.PatientID,
	a.Fname,
	a.Lname,
	count(b.AppointmentID) as number_of_appointments
from 
	patient as a
join
	PatientAppointment as b
on
	a.PatientID = b.PatientID
join
	appointment as c
on 
	b.AppointmentID = c.AppointmentID
group by
	a.PatientID,
	a.Fname,
	a.Lname
having 
	count(b.AppointmentID) > 1



/*
Question: 8
Calculate the average duration of appointments for each doctor
*/

select 
	b.DoctorID,
	b.Fname,
	b.Lname,
	avg(datediff(minute, a.Date, a.EndTime)) as avg_duration
from 
	appointment as a
join 
	doctor as b
on
	a.DoctorID = b.DoctorID
group by 
	b.DoctorID,
	b.Fname,
	b.Lname
order by
	avg_duration desc



/*
Question: 9
Find Patients with Most Appointments
*/

select 
	a.PatientID,
	a.Fname,
	a.Lname,
	count(b.AppointmentID) as number_of_appointments
from 
	patient as a
join
	PatientAppointment as b -- linking patients to their appointments
on
	a.PatientID = b.PatientID
join
	appointment as c -- linking patients to their appointment details
on
	b.AppointmentID = c.AppointmentID
group by 
	a.PatientID,
	a.Fname,
	a.Lname
order by
	number_of_appointments desc



/*
Question: 10
Calculate the total cost of medication for each patient
*/

select 
	a.PatientID,
	a.Fname,
	a.Lname,
	sum(c.Cost_in$) as medication_cost
from 
	patient as a
join
	PatientHistory as b -- linking patients to their medical history
on
	a.PatientID = b.PatientID
join
	MedicationCost as c -- linking patients to their medication costs
on
	b.Medication = c.Medication
group by
	a.PatientID,
	a.Fname,
	a.Lname	
order by
	medication_cost desc



/*
Question: 11
Create a stored procedure named CalculatePatientBill that calculates the total bill for a patient based on their medical history 
and medication costs. The procedure should take the PatientID as a parameter and calculate the total cost by summing up the medication costs
and applying a charge of $50 for each surgery in the patient's medical history. 
If the patient has no medical history, the procedure should still return a basic charge of $50.
*/

-- creating a staging table
select *
into PatientHistory_staging
from PatientHistory

drop table PatientHistory_staging

select * from PatientHistory_staging

-- updating the 'None' values to NULL for better processing
update PatientHistory_staging
set Surgeries = NULL
where Surgeries = 'None'



drop procedure if exists CalculatePatientBill

create procedure CalculatePatientBill
	@PatientID nvarchar(10)
as 
begin
	with total_medication_costs as -- calculates the total medication cost for the patient
	(
	select 
		sum(b.Cost_in$) as total_medication_cost
	from 
		PatientHistory_staging as a
	join
		MedicationCost as b
-- medication costs are essential for bill calculation, it is advisable to only include rows where there is a matching cost in 'MedicationCost'
	on 
		a.Medication = b.Medication
	where 
		a.PatientID = @PatientID
	),
	surgery_charges as -- counts the number of surgeries for the patient
	(
	select count(Surgeries) as number_of_surgeries
	from 
		PatientHistory_staging
	where
		PatientID = @PatientID and Surgeries is not null
	)
	-- calculating total bill
	select 
		case	
		when d.number_of_surgeries = 0 and c.total_medication_cost > 0
		then c.total_medication_cost + 50
		else c.total_medication_cost + (d.number_of_surgeries * 50)
		end as total_bill
	from 
		total_medication_costs as c
	cross join
		surgery_charges as d
end

exec CalculatePatientBill @PatientID = 'P0002'