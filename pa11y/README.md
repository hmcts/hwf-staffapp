# Pa11y Accessibility Testing (Help with Fees - Staff App)

## Summary
Pa11y is an automated accessibility testing tool.
Pa11y accessibility tests are used to examine whether a site complies with Web Content Accessibility Guidelines (WCAG) 
2.1 standards. w3.org states:

"Following these guidelines will make content more accessible to a wider range of people 
with disabilities, including accommodations for blindness and low vision, deafness and hearing loss, limited movement, 
speech disabilities, photosensitivity, and combinations of these, and some accommodation for learning disabilities and 
cognitive limitations; but will not address every user need for people with these disabilities. These guidelines 
address accessibility of web content on desktops, laptops, tablets, and mobile devices. Following these guidelines will 
also often make Web content more usable to users in general."

The following shows how to implement Pa11y-CI, a variant of Pa11y which iterates over a list of
webpages and highlights accessibility issues.

### Using Pa11y

Install pa11y-ci using documentation at https://github.com/pa11y/pa11y-ci.

For the hwf-staffapp, tests may be carried out using Admin credentials or Manager credentials
(note: the webpages accessible to these accounts include the webpages accessible to User and Mi accounts).

First, open 2 terminal windows and cd into project directory, e.g. hwf-staffapp, in each. Next, in one terminal, 
launch the local web server using rails. 
Close down any localhost tabs you may have open in your browser.
Then, depending on the test you want to carry out, copy and execute the respective command(s) in your command line using
the other terminal window:

#### Admin account:

with screenshots:
```
mkdir -p pa11y/screenshots/admin     
pa11y-ci --config pa11y/tests/admin/.pa11yci_ss.json
```
without screenshots:
```
pa11y-ci --config pa11y/tests/admin/.pa11yci.json
```
(Screenshots can be useful to check whether the desired page is being tested. You may want to delete the screenshot 
directory after testing to avoid clutter).
#### Manager account:

###### Work in progress: Issues surrounding the randomness of "Waiting for Evidence" means that 2 user journeys have been omitted for now (08/10/20) to be addressed at a later date. At the moment, there is a long set of actions that are performed with the "url": "127.0.0.1:3000/?info=making_a_waiting_for_evidence_application" that should generate at least one Waiting for evidence application. 

with screenshots:
```
mkdir -p pa11y/screenshots/manager   
pa11y-ci --config pa11y/tests/manager/.pa11yci_ss.json
```
without screenshots:
```
pa11y-ci --config pa11y/tests/manager/.pa11yci.json
```

### Issues
The following field inputs will need refactoring so that they are within 3 months of the current date:
```
"set field #application_day_date_received to 01",
"set field #application_month_date_received to 10",
"set field #application_year_date_received to 2020",
```
This set of field inputs appear 7 times in both manager/.pa11yci_ss.json and manager/.pa11yci.json files.
(Daniel Bell Oct.2020)
### WCAG standards

In the default configuration, the compliance standard is WCAG2.1AA. To change this, go to the .pa11yci.json (or 
.pa11yci_ss.json) file and change the 'standard' attribute to either WCAG2.1A, WCAG2.1AA or WCAG2.1AAA.

### Official documentation

https://github.com/pa11y/pa11y-ci