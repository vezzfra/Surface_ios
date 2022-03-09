# Surface

An iOS and Android management system for emergency first responders. 

As a volunteer first responder I experienced in firsthand the daily problems of Emergency associations. 
Because of this Surface was born, an app to help associations with the organisation of ambulances and cars.

The functioning is the following:

   - The login is integrated with User Authentication of Parse Platform;
   - Admins can use the website to login and define check-lists and properties for every ambulance and car;
   - Users log in and they have different sections to use: Ambulances check list, Training and exams, official operative instructions, shift management. 


#### Check lists

For every car or ambulance of the association is linked a check list. First responders at the beginning of the shift use the app to fill all the form and then to submit the finished document both to the admin and to the dispatcher console, where an operator receives it both via email and on the web portal.

#### Training and exams 

This section, present also on the online portal, is meant to be used by new First Responders to learn and practice after lessons. In it they can find slides, videos, manuals and advices from teachers.
There is also a section with past exams transformed into digital forms that they can try to solve. 

#### Official operative instructions 

In a world where the regional emergency service releases new protocols and operative operations every day, this section helps users to stay up to date. 
Data is downloaded from Parse Platform where they have been uploaded by the Administration. When a file is uploaded a Push notification is sento to every registered device. 

#### Shift management 

Managing shifts, turn exchangings and operative first responders can be a nightmare. Surface wants to help the association's Chief in this. When shifts are created at the beginning of the month everyone receives them on the app. 
Directly from that section every user can ask for shift exchanges to the chief or to other first responders, in case the request is approved the schedule for the month is automatically changed server-side. 

This code includes:

   - <img src="https://cdn-icons.flaticon.com/png/512/586/premium/586293.png?token=exp=1646816702~hmac=1aa8641ba216486043796ec8f171985b" width="15px"> Database access;
   - <img src="https://cdn-icons-png.flaticon.com/512/1182/1182769.png" width="15px"> Push notifications (<b>server to device</b>);
   - <img src="https://cdn-icons-png.flaticon.com/512/3143/3143460.png" width="15px"> Automatic PDF generation;
   - <img src="https://cdn-icons-png.flaticon.com/512/1060/1060387.png" width="15px"> User authentication;
   - <img src="https://cdn-icons.flaticon.com/png/512/3368/premium/3368235.png?token=exp=1646816975~hmac=8a05c9262761797b532a6f089c873567" width="15px"> UIKit with Interface Builder.
