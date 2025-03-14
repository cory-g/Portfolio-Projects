'''
Fourleaf (Bethpage) Federal Credit Union runs a marketing campaign where people can vote for the "Best of Long Island"
in every industry imaginable. After checking the terms of service, there are no limits regarding the number of times a
person can vote. There are also no rules stating automation is against the rules. I wanted to give a little public
recognition to a local Doctor that goes above and beyond in every sense, and deserves to have her name among the
candidates for best Pediatrician on Long Island!
'''

import time
import json
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.action_chains import ActionChains
from gooey import Gooey, GooeyParser


options = Options()
options.add_argument("--disable-dev-shm-usage")
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
running = 0

@Gooey(advanced=True, program_name="Fourleaf (Bethpage) 'Best of Long Island' Nominator")
def parse_args():
    # stored arguments
    stored_args = {}
    script_name = os.path.splitext(os.path.basename(__file__))[0]
    args_file = "{}-args.json".format(script_name)
    # Read in the prior arguments as a dictionary
    if os.path.isfile(args_file):
        with open(args_file) as data_file:
            stored_args = json.load(data_file)
    parser = GooeyParser(description="Nomination Assistant")
    parser.add_argument("candidate_category",
                        choices=["Doctor", "Pediatrician"],
                        action="store",
                        default=stored_args.get("candidate_category"),
                        metavar="Candidate's Professional Category",
                        help="Choose the Candidate's Profession")
    parser.add_argument("candidate_name",
                        action="store",
                        default=stored_args.get("candidate_name"),
                        metavar="Candidate's Name",
                        help="ex: Dr. Jane Doe")
    parser.add_argument("candidate_address",
                        action="store",
                        default=stored_args.get("candidate_address"),
                        metavar="Candidate's Address",
                        help="ex: 123 Medical Park Rd")
    parser.add_argument("candidate_city",
                        action="store",
                        default=stored_args.get("candidate_city"),
                        metavar="Candidate's City",
                        help='ex: Stony Brook, NY')
    parser.add_argument("candidate_number",
                        action="store",
                        default=stored_args.get("candidate_number"),
                        metavar="Candidate's Phone Number",
                        help="ex: 555-555-5555")
    parser.add_argument("candidate_website",
                        action="store",
                        default=stored_args.get("candidate_website"),
                        metavar="Candidate's Website",
                        help="ex: www.medical-practice-website.com")
    parser.add_argument("candidate_practice",
                        action="store",
                        default=stored_args.get("candidate_practice"),
                        metavar="Name of Medical Practice",
                        help="ex: Amazing Medical Group")
    parser.add_argument("num_votes",
                        type=int,
                        action="store",
                        default=stored_args.get("num_votes"),
                        metavar="Number of Votes to Cast",
                        help="ex: 100")
    args = parser.parse_args()
    # Store the values of the arguments
    with open(args_file, 'w') as data_file:
        # vars(args) returns the data as a dictionary
        json.dump(vars(args), data_file)
    return args


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

    # Setting the Nominees information
    site_name.send_keys(args.candidate_name)
    site_address.send_keys(args.candidate_address)
    site_city.send_keys(args.candidate_city)
    site_phone.send_keys(args.candidate_number)
    site_website.send_keys(args.candidate_website)
    site_notes.send_keys(args.candidate_practice)

    time.sleep(.5)
    # Submitting the entry
    site_submit.click()
    print(f'Vote {running + 1} successfully cast!')
    time.sleep(3)


if __name__ == "__main__":

    args = parse_args()
    while running < args.num_votes:
        vote_now()
        running += 1
    driver.quit()
    print(f"\nCongratulations, You successfully cast {args.num_votes} votes!")

