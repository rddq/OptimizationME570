import selenium.webdriver as webdriver
import selenium.webdriver.support.ui as ui
from selenium.webdriver.common.keys import Keys
from time import sleep  
import pandas as pd
from copy import copy
import json 

data = pd.read_csv("Temple.txt", header=None,delimiter='\t')
all_names = data[0].values

browser = webdriver.Chrome()
browser.get('https://www.lds.org/temples/list?lang=eng')
sleep(0.2)
temple_links = browser.find_elements_by_class_name("filterResult-1Hx44")

# Save the window opener (current window, do not mistaken with tab... not the same)
main_window = browser.current_window_handle
all_dicts = []
for index, temple in enumerate(temple_links):
    if index > 172:
        link = temple.find_elements_by_css_selector('a')#.get_attribute('href')
        if len(link) == 0:
            pass
        else:
            link = link[0]
            temple_name = link.text
            if temple_name in all_names:
                link.send_keys(Keys.COMMAND + Keys.RETURN)
                sleep(2)
                browser.switch_to.window(window_name=browser.window_handles[-1])
                sleep(2)
                day_dict = {"Monday":[],"Tuesday":[],"Wednesday":[],"Thursday":[],"Friday":[],"Saturday":[]}
                expanded = False
                for key, value in day_dict.items():
                    # Open Calendar and find available days
                    sleep(2)
                    calendarButton = browser.find_element_by_id("secondSelect")
                    calendarButton.click()
                    sleep(2)
                    calendar = browser.find_element_by_class_name("calGrid-3UtQq")
                    available_days = calendar.find_elements_by_class_name("ordAvailable-2wfAJ")
                    # find the day for the current item in the dictionary                    
                    for day in available_days:
                        date = day.get_attribute("data-date")
                        if date is not "Thursday, 4 April 2019":
                            date = date.split(',')
                            day_of_week = date[0]
                            if day_of_week == key:
                                day.click()
                                sleep(2)
                                expanderbutton = browser.find_elements_by_class_name("expander-2gKrT")
                                if not expanded and len(expanderbutton) != 0:
                                    expanderbutton[0].click()
                                    sleep(2)
                                    expanded = True
                                endowment_times = browser.find_elements_by_class_name("scheduleItem-18mOd")
                                for time in endowment_times:
                                    timeinfo = time.text                            
                                    time_info = timeinfo.split('\n')
                                    value.append(time_info[0])
                                break
                    if len(value) == 0:
                        close_button = browser.find_element_by_class_name("closeButton-1O6Lj")
                        close_button.click()
                all_dicts.append(copy(day_dict))
                browser.close()
                sleep(2)
                browser.switch_to_window(main_window)
                       

with open('data.json', 'w') as outfile:
    json.dump(all_dicts, outfile)
browser.quit()
