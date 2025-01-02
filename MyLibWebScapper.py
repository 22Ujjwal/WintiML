#make you have the below library installed
#pip install requests beautifulsoup4
#UG

import requests
from bs4 import BeautifulSoup

def scrape_documentation(url, outputFile):
    # Send a request to the URL & Check the request approval
    try:
        response = requests.get(url) 
    except requests.exceptions.RequestException as e:
        print(f"Error fetching the URL, Recheck! : {e}")
        return

    # Going through the HTML content
    soup = BeautifulSoup(response.content, 'html.parser')

    # Open the output file for writing
    with open(outputFile, 'w', encoding='utf-8') as file:
        # Extract and write the main title
        title = soup.find('h1')
        if title:
            file.write(f"# {title.text.strip()}\n\n")

# Making your guide and processing in structured format
        for section in soup.find_all(['h2', 'h3', 'p', 'pre']):
            if section.name == 'h2':
                file.write(f"## {section.text.strip()}\n\n")
            elif section.name == 'h3':
                file.write(f"### {section.text.strip()}\n\n")
            elif section.name == 'p':
                file.write(f"    {section.text.strip()}\n\n")
            elif section.name == 'pre':
                # For code snippets
                code = section.text.strip()
                file.write(f"    ```\n    {code}\n    ```\n\n")

if __name__ == "__main__":
    # Update the url to get the info
    url = 'https://pandas.pydata.org/docs/reference/index.html'
    
    # Your file will be here
    outputFile = 'MyLibraryGuide.md'
    
    scrape_documentation(url, outputFile)
    print(f"Documentation summary saved to {outputFile}")


#Thanks for reviewing!