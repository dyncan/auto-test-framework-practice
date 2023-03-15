import time
from cumulusci.robotframework.pageobjects import pageobject, ListingPage


@pageobject(page_type="Listing", object_name="Wallet_Adjustment__c")
class WalletListingPage(ListingPage):
    
    def click_on_the_row_with_name(self, name):
        xpath='xpath://a[@title="{}"]'.format(name)
        self._xpath_check(xpath)

    def populate_wallet_lookup(self, row, value):
        """populate the lookup field on bulk service delivery"""
        locator = "//lightning-input-field[@data-name='{}']//input".format(row)
        self.selenium.click_element(locator)
        self.selenium.get_webelement(locator).send_keys(value)
        locator_val = "//lightning-base-combobox-item/descendant::span[contains(@class,'slds-listbox__option-text')]/lightning-base-combobox-formatted-text[@class='slds-truncate' and @title='{}']".format(value)
        self.selenium.wait_until_page_contains_element(
            locator_val, error="value is not available"
        )
        time.sleep(1)
        self.salesforce._jsclick(locator_val)
        time.sleep(0.5)
    
    def populate_the_dropdown(self, value):
        value_loc = "//c-create-wallet-adjustment-l-w-c//span[@class='slds-media__body']/span[@class='slds-truncate' and contains(text(),'{}')]".format(value)
        element_click = self.selenium.driver.find_element_by_xpath(value_loc)
        self.selenium.driver.execute_script("arguments[0].click()", element_click)

    def _xpath_check(self, xpath):
        self.selenium.wait_until_page_contains_element(xpath)
        self.selenium.click_link(xpath)
        self.salesforce.wait_until_loading_is_complete()