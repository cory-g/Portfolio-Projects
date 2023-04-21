'''
This Python script is a project written for anyone local to New York, specifically Long Island. Bethpage Federal Credit Union runs a marketing campaign where people can vote for the "Best of Long Island" in every industry imaginable.

After checking the terms of service, there are no limits regarding the number of times a person can vote. There are also no rules stating automation is against the rules.

I wanted to help give a little public recognition to a local Doctor that goes above and beyond in every sense and deserves to have her name among the candidates for best Pediatrician on Long Island! 

I wrote this web automation script to keep my hands from cramping while allowing my votes to be registered.

For my purposes the script is set to automatically begin voting once run 
'''


import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.action_chains import ActionChains

options = Options()
options.add_argument('--disable-dev-shm-usage')
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

running = 0
time_start = time.time()


def vote_now():
    # Loading the website
    driver.get('https://app.smartsheet.com/b/form/b47d3135966f4895ab2c5f5c1fd83e61')
    # Wait until element is clickable
    WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, '//div[@class="css-1i5h0xy-placeholder react-select__placeholder"]')))
    # Assigning the fields that need to be filled in
    nom_category = driver.find_element(By.XPATH, '//div[@class="css-1i5h0xy-placeholder react-select__placeholder"]')
    nom_name = driver.find_element(By.ID, 'text_box_Nominee')
    nom_address = driver.find_element(By.ID, 'text_box_Nominee Address')
    nom_city = driver.find_element(By.ID, 'text_box_Nominee City')
    nom_phone = driver.find_element(By.ID, 'text_box_Nominee Phone Number')
    nom_website = driver.find_element(By.ID, 'text_box_Nominee Website')
    nom_notes = driver.find_element(By.ID, 'text_box_Notes')
    nom_submit = driver.find_element(By.XPATH, '//button[@type="submit"]')

    # Not a normal dropdown box, this is my workaround
    # Click dropdown box
    nom_category.click()
    # Assign keyboard actions to arrive at desired selection, in my case Pediatrician
    actions = ActionChains(driver)
    for n in range(18):
        actions.send_keys(Keys.PAGE_DOWN).perform()
        time.sleep(.01)
    actions.send_keys(Keys.ARROW_UP).perform()
    time.sleep(.01)
    actions.send_keys(Keys.RETURN).perform()

    time.sleep(.1)

    # Entering the desired information
    # Enter the Doctors Name
    nom_name.send_keys("Name")
    # Enter the Doctors Address, Street
    nom_address.send_keys('Street Address')
    # Enter the Doctors Address, City
    nom_city.send_keys('City')
    # Enter the Doctors Phone Number
    nom_phone.send_keys('555-555-5555')
    # Enter the Doctors Website
    nom_website.send_keys('https://')
    # Enter the Doctors Practice Name
    nom_notes.send_keys('Practice Name')

    time.sleep(.5)
    # Submitting the entry
    nom_submit.click()

    time.sleep(3)


# Set for desired number of runs
while running <= 100:

    vote_now()
    running += 1

driver.quit()
time_final = time.time()-time_start

if time_final <= 60:
    print(f'\nYou submited {running-1} votes in {time_final} seconds!')
else:
    print(f'\nYou submited {running - 1} votes in {time_final/60} minutes!')
