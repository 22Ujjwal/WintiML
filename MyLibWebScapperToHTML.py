#make sure you have the below library installed, it will be quick
#pip install requests beautifulsoup4 or Run over Google Colab
#this creates a HTML and offers a great readility
#UG

import requests
from bs4 import BeautifulSoup

def scrape_documentation(url, outputFile):
    #Sends a request to the URL and request approval
    try:
        response = requests.get(url)
        response.raise_for_status()  #ensure successful request
    except requests.exceptions.RequestException as e:
        print(f"Error fetching the provided URL, Recheck: {e}")
        return

    #Parse the HTML content, love this part
    soup = BeautifulSoup(response.content, 'html.parser')

    #Ppen the output html file for writing
    with open(outputFile, 'w', encoding='utf-8') as file:
        #Writes HTML structure, to keep the data organised
        file.write("<html><head><style>")
        file.write("body { font-family: Calibri, sans-serif; margin: 20px; line-height: 1.6; }")
        file.write("h1 { color: darkblue; font-weight: bold; margin-bottom: 10px; }")
        file.write("h2 { color: blue; font-weight: bold; margin-top: 20px; margin-bottom: 10px; }")
        file.write("h3 { color: blue; font-weight: bold; margin-top: 15px; margin-bottom: 5px; }")
        file.write("p { text-align: justify; margin: 10px 0; }")
        file.write("pre { background-color: #f9f9f9; padding: 15px; border: 1px solid #ddd; border-radius: 5px; overflow-x: auto; margin: 15px 0; }")
        file.write("code { font-family: Consolas, monospace; font-size: 0.9em; }")
        file.write(".highlight { background-color: #e8f4ff; font-weight: bold; padding: 2px 4px; border-radius: 3px; }")
        file.write("</style></head><body>")

        #Write the extracted title
        title = soup.find('h1')
        if title:
            file.write(f"<h1>{title.text.strip()}</h1>")

        #Store data in structured and presentable format
        for section in soup.find_all(['h2', 'h3', 'p', 'pre']):
            if section.name == 'h2':
                file.write(f"<h2>{section.text.strip()}</h2>")
            elif section.name == 'h3':
                file.write(f"<h3>{section.text.strip()}</h3>")
            elif section.name == 'p':
                #Highlight specific keywords or headers in paragraphs
                text = section.text.strip()
                highlighted_text = text.replace(
                    text.split(' ')[0], f"<span class='highlight'>{text.split(' ')[0]}</span>", 1
                )
                file.write(f"<p>{highlighted_text}</p>")
            elif section.name == 'pre':
                #For code snippets
                code = section.text.strip()
                file.write(f"<pre><code>{code}</code></pre>")

        #Closing HTML struct
        file.write("</body></html>")

if __name__ == "__main__":
    #Here goes your URL
    url = 'https://pandas.pydata.org/docs/reference/frame.html'

    #Your file will be freshly ready[name it what you want to call it]
    outputFile = 'MyLibraryGuide.html'

    scrape_documentation(url, outputFile)
    print(f"Documentation summary saved to {outputFile}")

#I am glad this automation successfully creates an HTML file reading another HTML file

    #Thanks you for your feedback 