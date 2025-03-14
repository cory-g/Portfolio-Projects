'''
Fourleaf (Bethpage) Federal Credit Union runs a marketing campaign where people can vote for the "Best of Long Island"
in every industry imaginable. After checking the terms of service, there are no limits regarding the number of times a
person can vote. There are also no rules stating automation is against the rules. I wanted to give a little public
recognition to a local Doctor that goes above and beyond in every sense, and deserves to have her name among the
candidates for best Pediatrician on Long Island!
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

def vote_now():
    # Loading the website
    driver.get('https://app.smartsheet.com/b/form/c9a9908e311d4cfc88c95030f0e8a649')
    # Wait until element is clickable
    WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, '//div[@class="css-1i5h0xy-placeholder react-select__placeholder"]')))
    # Assigning the fields that need to be filled in
    site_category = driver.find_element(By.XPATH, '//div[@class="css-1i5h0xy-placeholder react-select__placeholder"]')
    site_name = driver.find_element(By.ID, 'text_box_Nominee')
    site_address = driver.find_element(By.ID, 'text_box_Nominee Address')
    site_city = driver.find_element(By.ID, 'text_box_Nominee City')
    site_phone = driver.find_element(By.ID, 'text_box_Nominee Phone Number')
    site_website = driver.find_element(By.ID, 'text_box_Nominee Website')
    site_notes = driver.find_element(By.ID, 'text_box_Notes')
    site_submit = driver.find_element(By.XPATH, '//button[@type="submit"]')

    # Not a normal dropdown box, this is my workaround
    # Click dropdown box
    site_category.click()
    # Assign keyboard actions to arrive at desired selection, in my case Pediatrician
    actions = ActionChains(driver)
    for n in range(18):
        actions.send_keys(Keys.PAGE_DOWN).perform()
        time.sleep(.1)
    actions.send_keys(Keys.ARROW_DOWN).perform()
    time.sleep(.01)
    actions.send_keys(Keys.RETURN).perform()

    time.sleep(.1)

    site_name.send_keys(f"{nom_name}")
    site_address.send_keys(f'{nom_street}')
    site_city.send_keys(f'{nom_city}')
    site_phone.send_keys(f'{nom_phone}')
    site_website.send_keys(f'{nom_website}')
    site_notes.send_keys(f'{nom_notes}')

    time.sleep(.5)
    # Submitting the entry
    nom_submit.click()

    time.sleep(3)


# Enter the Nominees information

# Enter the Doctors Name
nom_name = ''
# Enter the Address, Street Name
nom_street = ''
# Enter City
nom_city = ''
# Enter Phone number
nom_phone = ''
# Enter Website (if applicable)
nom_website = ''
# Enter Practice name
nom_notes = ''

# Set desired number of votes
votes = 100

while running < votes:
    vote_now()
    running += 1

driver.quit()
print(f'\nYou submited {running} votes!')