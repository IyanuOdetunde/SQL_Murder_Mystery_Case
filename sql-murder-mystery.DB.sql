--Step 1: Queried the Crime Scene Report table to reveal murders that occurred in SQL City and on the 15th January 2018
SELECT * 
FROM crime_scene_report 
WHERE type = "murder" AND city = "SQL City" AND date = 20180115;
-- Result = Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave”.

-- Step 2: Obtained more details of the witnesses provided in step 1 result above. 
--For the 1st Witness
SELECT * 
FROM person
WHERE address_street_name LIKE '%Northwestern%' 
ORDER BY address_number DESC;
--Result = 1ST Witness,Id = 14887, Name= Morty Schapiro, License_id = 118009, Address_number= 4919, address_street_name = Northwestern Dr, ssn = 111564949
-- For the 2nd Witness 
SELECT * 
FROM person 
WHERE address_street_name LIKE '%Franklin%' AND name LIKE '%Anna%';
-- Result = 2nd Witness, Id = 16371, Name= Annabel Miller, License_id = 490173, Address_number= 103, address_street_name = Franklin Ave, ssn = 318771143

-- Step 3: Obtained transcript of the interview statement of 1st Witness
SELECT * FROM interview WHERE person_id = 14887;
SELECT person.Name, interview.person_id, interview.transcript
FROM person
INNER JOIN interview
ON person.id = interview.person_id
WHERE person_id = 14887;
-- Result = I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".
-- To Obtain the interview statement from 2nd Witness
SELECT person.Name, interview.person_id, interview.transcript
FROM person
INNER JOIN interview
ON person.id = interview.person_id
WHERE person_id = 16371;
-- Result = I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.

-- Step 4: Obtained suspect details based on description provided by the witnesses.
SELECT * 
from get_fit_now_member 
WHERE membership_status = 'gold' and id LIKE '%48z%';
-- Result showed that there were two suspects. Their details include- Id= 48Z7A, Person_id= 28819, Name = Joe Germuska, Membership_start_date = 20160305,Membership_status = gold; Id= 48Z55, Person_id= 67318, Name = Jeremy Bowers, Membership_start_date = 20160101, Membership_status = gold
-- Obtained the car details provided by 1st Witness.
SELECT * 
from drivers_license 
WHERE plate_number LIKE '%H42W%' AND gender = 'male';
-- Results obtained from the query include- Id= 423327, Age= 30, Height= 70, Eye_color=brown, Hair color=brown, Gender= male, Plate number= 0H42W2, Car make= Chevrolet, Car model= Spark LS; Id= 664760, Age= 21, Height= 71, Eye_color=black, Hair color=black, Gender= male, Plate number= 4H42WR, Car make= Nissan, Car model= Altima
-- Based on details provided by 2nd witness and using membership details provided by 1st witness to filter the results
SELECT *
FROM get_fit_now_check_in 
where check_in_date = 20180109 AND membership_id LIKE '%48z%';
-- Results obtained from the query include- Membership_id = 48Z7A, Check in date = 20180109, Check in time = 1600, Check out time = 1730 ; Membership_id = 48Z55, Check in date = 20180109, Check in time = 1530, Check out time = 1700
--These results from the 2nd witness also match the results from the 1st witness.

-- Step 5:Based on the person id obtained from the two suspects, the interview table was queried to find out if there were any transcripts available
SELECT * 
FROM interview 
WHERE person_id IN (67318, 28819);
-- Only result displayed was for person_id 67318 (Jeremy Bowers), this also matches one of the car details obtained from 1st Witness with License ID 423327 driving a Chevrolet.
-- Result from transcript = I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017

-- Step 6: Queried the facebook event charity table with event details provided by Jeremy Bowers
SELECT person_id, COUNT(person_id) AS Event_attendance 
FROM facebook_event_checkin 
WHERE event_name LIKE '%SQL%' and date LIKE '%201712%' 
GROUP BY person_id
ORDER BY Event_attendance DESC;
--Result obtained showed two people attended three times in Dec and their Person IDs are 99716 and 24556. Furthermore, based on the car and person details provided by the Jeremy Bowers about who hired him, the results were filtered with code below
SELECT * 
FROM drivers_license
where gender = 'female' AND car_make = 'Tesla' AND car_model = 'Model S' AND hair_color = 'red';
-- Results obtained = Three females with License id = 202298, 291182, 918773

--Step 7: By Matching the above-named license ids with the Person IDs obtained from the Symphony concerts to narrow down the Murder Hirer
Select person.id, person.name, drivers_license.id, drivers_license.gender, drivers_license.car_make, drivers_license.car_model, drivers_license.hair_color
from person
INNER JOIN drivers_license
on person.license_id = drivers_license.id
WHERE person.id IN (24556, 99716) AND drivers_license.id IN (202298, 291182, 918773) AND drivers_license.gender = 'female';
-- Results obtained showed that the person that hired the Jeremy Bowers to perform the Murder is Miranda Priestly with Person ID= 99716 and License ID= 202298
