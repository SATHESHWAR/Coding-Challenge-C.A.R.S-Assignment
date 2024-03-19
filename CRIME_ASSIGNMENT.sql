-- Creation of Tables :

create table Crime(
CrimeId int primary key,
IncidentType varchar(255),
IncidentDate date,
Location varchar(255),
Description text,
Status Varchar(20)
);

create table Victim(
VictimID int primary key,
CrimeId int,
Name varchar(255),
ContactInfo varchar(255),
Injuries varchar(255),
Foreign key (CrimeId) references Crime(CrimeId)
);

create table Suspect(
SuspectId int primary key,
CrimeId int,
Name varchar(255),
Description text,
CriminalHistory text,
foreign key(CrimeId) references Crime(CrimeId)
);

-- Inserting Data

insert into Crime values (1,'Robbery','2023-09-15','123 Main St, Cityville','Armed Robbery at a convenience store','Open'),
(2,'Homicide','2023-09-20','456 Elm St, Townsville','Investigation into a murder case','Under Investigation'),
(3,'Theft','2023-09-10','789 Oak St, Villagetown','Shoplifting incident at a mall','Closed');


insert into Victim values (1,1,'John Doe','johndoe@example.com','Minor Injuries'),
(2,2,'Jane Smith','janesmith@example.com','Deceased'),
(3,3,'Alice Johnson','alicejohnson@example.com','None');

insert into Suspect values (1,1,'Robber 1','Armed and masked robber','Previous robbery convitions'),
(2,2,'Unknown','Investigation Ongoing',NULL),
(3,3,'Suspect 1','Shoplifting suspect','Prior shoplifting arrests');

-- Updating table [ As Data Insufficiency]
alter table Victim add (VictimAge int);
alter table Suspect add (SuspectAge int);

update Victim set VictimAge=42 where VictimId=1;
update Victim set VictimAge=32 where VictimId=2;
update Victim set VictimAge=35 where VictimId=3;

update Suspect set SuspectAge=27 where SuspectId=1;
update Suspect set SuspectAge=NULL where SuspectId=2;
update Suspect set SuspectAge=30 where SuspectId=3;

 -- Queries:
 
 -- Query 1: Select all open incidents
 
	Select * from  Crime where Status='Open';
 
 -- Query 2: Find the total number of incidents
 
	Select count(CrimeId) as Total_Incidents from Crime;
 
 -- Query 3: List all unique incident types
 
	Select distinct IncidentType from Crime;
 
 -- Query 4: Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'
 
	Select * from Crime where IncidentDate between '2023-09-01' and '2023-09-10';
 
 -- Query 5: List persons involved in incidents in descending order of age

	(Select C.CrimeID,V.Name as Name,V.VictimAge as Age from Crime C join Victim V 
	on C.CrimeId=V.CrimeId union select C.CrimeID,S.Name as Name,S.SuspectAge as Age from Crime C join Suspect S
	on C.CrimeId=S.SuspectID) order by Age desc;

 -- Query 6: Find the average age of persons involved in incidents
 
	Select avg(age) from(select V.VictimAge as age from Victim V union select S.SuspectAge as age from Suspect S) as AvgAge;

 -- Query 7: List incident types and their counts, only for open cases
 
	Select IncidentType, count(CrimeId) as Counts from Crime where Status='Open' group by(IncidentType);
 
 -- Query 8: Find persons with names containing 'Doe'
 
	Select * from Victim where Name Like '%Doe%' union select * from Suspect where Name Like '%Doe%';
 
 -- Query 9: Retrieve the names of persons involved in open cases and closed cases
 
	Select Name from Victim where  CrimeId in (Select CrimeId from Crime where Status='OPEN') UNION 
	Select Name from Victim where  CrimeId in (Select CrimeId from Crime where Status='CLOSED') UNION 
	Select Name from Suspect where  CrimeId in (Select CrimeId from Crime where Status='OPEN') UNION 
	Select Name from Suspect where  CrimeId in (Select CrimeId from Crime where Status='CLOSED');
 
 -- Query 10: List incident types where there are persons aged 30 or 35 involved
 
	Select distinct C.IncidentType from Crime C join(select CrimeId from Victim where VictimAge between 30 and 35
	union select CrimeId from Suspect where SuspectAge between 30 and 35 ) as PersonAge on C.CrimeId = PersonAge.CrimeId;
 
 -- Query 11: Find persons involved in incidents of the same type as 'Robbery'
 
	Select * from Victim where  CrimeId in (Select CrimeId from Crime where IncidentType='Robbery') UNION
	Select * from Suspect where  CrimeId in (Select CrimeId from Crime where IncidentType='Robbery');
 
 -- Query 12: List incident types with more than one open case
 
	Select IncidentType , Count(Status) Count from crime where Status= 'OPEN' group by(IncidentType) having count(Status)>1; 
 
 -- Query 13: List all incidents with suspects whose names also appear as victims in other incidents
	Select DISTINCT c.* FROM Crime c
	INNER JOIN Suspect s ON c.CrimeID = s.CrimeID
	INNER JOIN Victim v ON s.Name = v.Name AND s.CrimeID != v.CrimeID;
 
 -- Query 14: Retrieve all incidents along with victim and suspect details
 
	Select DISTINCT c.CrimeID,c.IncidentType,c.Location,c.IncidentDate, 
	v.name as Victim_Name, v.Injuries AS VictimInjuries, 
	s.name as Suspect_Name, s.Description AS SuspectDescription, s.CriminalHistory AS SuspectCriminalHistory, c.Description,Status from Crime c 
	INNER JOIN Victim v ON c.CrimeID = v.CrimeID
	INNER JOIN Suspect s ON c.CrimeID = s.CrimeID;
 
 -- Query 15: Find incidents where the suspect is older than any victim
 
	Select * from (select C.CrimeId,C.IncidentType,C.IncidentDate from Crime C join Victim V on C.CrimeId=V.CrimeId 
	join Suspect S on S.CrimeId=C.CrimeId where S.SuspectAge>V.VictimAge) as Age;
 
 
 -- Query 16: Find suspects involved in multiple incidents

	Select s.Name as SuspectName, COUNT(DISTINCT s.CrimeID) as IncidentCount FROM Suspect s GROUP BY s.Name HAVING IncidentCount >= 1;
 
 
 -- Query 17: List incidents with no suspects involved
 
	Select c.* FROM Crime c INNER JOIN Suspect s ON c.CrimeID = s.CrimeID WHERE s.CrimeID IS NULL;
 
 
 -- Query 18: . List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery'
	
    Select c.CrimeID, c.IncidentType, c.IncidentDate, c.Location, c.Description, c.Status FROM Crime c GROUP BY c.CrimeID 
	HAVING COUNT(DISTINCT CASE WHEN c.IncidentType = 'Homicide' THEN c.IncidentType END) >= 1 AND 
	COUNT(DISTINCT CASE WHEN c.IncidentType = 'Robbery' THEN c.IncidentType END) = COUNT(*);

-- Query 19: Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none

	Select C.CrimeId,C.IncidentType,C.IncidentType,C.Location,C.Description,S.SuspectId,
	if(S.Name!='Unknown',S.Name,'No Suspect') as SuspectName from Crime C left join Suspect S on C.CrimeId=S.CrimeId;



-- Query 20: List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault'
	Select s.SuspectID, s.Name , s.Description, s.CriminalHistory from Suspect s WHERE s.CrimeId IN (SELECT c.CrimeId FROM Crime c WHERE IncidentType IN ('Robbery', 'Assault'));
