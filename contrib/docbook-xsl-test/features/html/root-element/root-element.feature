Feature: Get root element

	 Scenario: root element is article
	 	   Given I have the file 'lxml.xml'
		   When I parse this file
		   Then I see the root element 'article'