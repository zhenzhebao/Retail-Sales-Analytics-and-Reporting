Present various questions to the AI Agent, observe how the Agent provides responses and executes Python logic, and verify that the responses and execution logic are correct. Analyze the final report to ensure the reported data and calculations are accurate and the interpretation is supported by the data.
Come up with 30 test questions first and save these questions into the existing test_question.txt file.
You are only allowed to modify test_question.txt and test_log.txt. You are prohibited from modifying any other files or the PostgreSQL database. 
For each question:
- Run the question once.
- If the AI Agent passes the test, move to the next question.
- If the first attempt fails, test the same question with the same user responses two more times.
- If either retry passes, move to the next question.
- Only classify a question as a failure if it fails all three attempts.
For every question that fails all three attempts, save a concise diagnostic record in test_log.txt. For each failure, only include:
- Test question
- The step where the failure occurred
- Relevant LLM response or tool call associated with the failure
- Actual SQL query, if the SQL is relevant to the failure
- Relevant tool result sent back to the LLM, if the tool result is relevant to the failure
- Complete Python traceback or error message, if a Python/database error occurred
In the final report, provide:
- Number of questions tested
- Number of questions that passed on the first attempt
- Number of questions that failed initially but passed on a subsequent retry
- Number of questions that failed all three attempts
For each question that failed all three attempts, provide the question and briefly explain the type of the failure. 