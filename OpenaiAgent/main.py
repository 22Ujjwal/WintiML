import os  # to access the environment variable
import PyPDF2  # Processing the PDF file for this
import openai  
from dotenv import load_dotenv, find_dotenv
import prompts

# load .env file
_ = load_dotenv(find_dotenv())
openai.api_key = os.environ.get('OPENAI_API_KEY')  

model = 'gpt-4' 
temperature = 0.3
max_tokens = 400
job = "Machine learning Engineer"

# Reading Resume
Resume = ""
# file_path = "Resume_UjjwalGupta_Feb2025.pdf"


# prompts

system_message = prompts.system_message
prompt = prompts.generate_prompt(Resume, job)

messages = [
    {"role": "system", "content": "You are a smart assistant for interview prep"},
    {"role": "user", 'content': 'give 5 tips to succeed at a job interview'}
]

# Helper function
def get_Analysis():
    completion = client.chat.completions.create(  
        model=model,
        messages=messages,
        temperature=temperature, 
        max_tokens=max_tokens,
    )
    return completion.choices[0].message['content']  

print(get_Analysis())