system_message = """
You are an AI interview assistant specializing in generating highly effective interview questions tailored to a candidate's resume and target job profile. Your goal is to create:
1. **Technical Interview Questions** - Directly relevant to the candidate's skills, experience, and the job role, categorized by difficulty level (Beginner, Intermediate, Advanced).
2. **Behavioral Interview Questions** - Following the STAR method, focusing on past experiences, leadership, problem-solving, and collaboration.
3. **Degree of Expectancy** - Rate the likelihood of each question being asked in a real interview (Low, Medium, High).
4. **Professional "Tell me about yourself" Response** - A refined, standout answer that makes the candidate memorable, aligned with their strengths and job expectations.

Follow a structured and detailed approach for each section, ensuring the candidate is well-prepared for their interview.
"""


def generate_prompt(Resume, job):
    prompt = f"""
Given the following **Resume** and **Target Job Profile**, generate:
1. **Technical Interview Questions**:
    - Extract relevant technical concepts from the resume.
    - Create questions in three difficulty levels: **Beginner, Intermediate, Advanced**.
    - Ensure alignment with the job role and industry standards.

2. **Behavioral Interview Questions**:
    - Formulate questions using the **STAR (Situation, Task, Action, Result)** method.
    - Cover areas such as teamwork, leadership, problem-solving, and challenges faced.

3. **Degree of Expectancy**:
    - Assign a probability label (**Low, Medium, High**) to each question based on how commonly it appears in real interviews.

4. **Professional "Tell me about yourself" Response**:
    - Structure: **Hook → Experience Summary → Key Strengths → Passion → Why This Role**.
    - Ensure it is compelling, concise, and differentiates the candidate from others.

---
**Resume:**  
{Resume}

**Target Job Profile:**  
{job}

---
**Output Format Example:**  

### **Technical Questions**  
**1. Beginner:**  
**Q:** Explain the difference between an array and a linked list.  
**Expectancy:** High

**2. Intermediate:**  
**Q:** How does a database index work, and when should you use it?  
**Expectancy:** Medium  

**3. Advanced:**  
**Q:** Design a scalable microservices architecture for a real-time analytics platform.  
**Expectancy:** Low  

### **Behavioral Questions**  
**Q:** Tell me about a time you resolved a major conflict within a team.  
**Expectancy:** High  

### **Tell Me About Yourself (Optimized Response)**  
"I’m a results-driven software engineer with a passion for building scalable and efficient systems. In my previous role, I optimized an API that reduced response time by 40%, directly improving user engagement. My expertise lies in backend development, cloud computing, and performance optimization. Beyond technical skills, I thrive in collaborative environments, mentoring junior engineers, and tackling complex challenges. What excites me about this role is the opportunity to work on innovative AI-driven solutions that make a real-world impact."  

Ensure all responses are tailored to the provided resume and job profile.
"""
    return prompt
