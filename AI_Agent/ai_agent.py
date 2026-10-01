#from google.colab import userdata
#api_key=userdata.get('OPENAI_API_KEY')

#!pip install openai
from datetime import date
from openai import OpenAI
import json

"""## Python Functions"""

def generate_date_value(start_year,start_month,end_year,end_month,start_day=None,end_day=None):
    if start_year is None or start_month is None or end_year is None or end_month is None:
       raise Exception ('Incompleted LLM response')
    elif int(start_year) not in (2010,2011) or int(end_year) not in (2010,2011):
       raise Exception('Invalid Date Information')
    elif start_day is None and end_day is None:
       if int(start_month)<1 or int(start_month)>12 or int(end_month)<1 or int(end_month)>12:
          raise Exception('Invalid Month Information')
       elif int(start_year)<int(end_year) or (int(start_year)==int(end_year) and int(start_month)<=int(end_month)):
            start_month=str(start_year)+'-'+str(start_month)+'-'+'01'
            end_month=str(end_year)+'-'+str(end_month)+'-'+'01'
            return start_month,end_month
       else:
            raise Exception ('Invalid Date Range')
    elif start_day is not None and end_day is not None:
       try:
            if date(int(start_year),int(start_month),int(start_day))<=date(int(end_year),int(end_month),int(end_day)):
               start_month=str(start_year)+'-'+str(start_month)+'-'+str(start_day)
               end_month=str(end_year)+'-'+str(end_month)+'-'+str(end_day)
               return start_month,end_month
            else:
              raise Exception ('Invalid Date Range')
       except ValueError:
          raise Exception('Invalid Date Information')
    else:
        raise Exception ('Incompleted LLM response')

def get_monthly_return(start_month=None,end_month=None):
  if start_month is None and end_month is None:
    query='''select date(date_trunc('month',invoicedate))as month,abs(sum(quantity)) as total_return_quantity,
             abs(sum(quantity*product_unit_price)) as total_return_value
             from all_return_data
             group by date(date_trunc('month',invoicedate))
             order by month;'''
    return query
  else:
    query=f'''with t as (select date(date_trunc('month',invoicedate))as month,abs(sum(quantity)) as total_return_quantity,
             abs(sum(quantity*product_unit_price)) as total_return_value
             from all_return_data
             group by date(date_trunc('month',invoicedate)))
             select month,total_return_quantity,total_return_value
             from t
             where month>='{start_month}' and month<='{end_month}'
             order by month;'''
    return query

def get_product_return(metric=None,top_n=None):
  if metric is None:
     metric='both'
  if top_n is None:
     top_n=10
  product_return_quantity_query=None
  product_return_value_query=None
  product_return_quantity_columns='total_return_quantity,return_quantity_rank'
  product_return_value_columns='''total_return_value,return_value_rank'''
  try:
     int(top_n)
  except (ValueError,TypeError):
    raise Exception ('Incorrect top_n format')
  if metric not in ('return_value','return_quantity','both'):
     raise Exception('Invalid metric selection')
  elif type(top_n)==float or type(top_n)==bool or int(top_n)<=0:
     raise Exception('Invalid top_n value')
  elif metric=='both':
     product_return_quantity_query=f'''select stockcode,product_description,{product_return_quantity_columns}
                                      from product_return_summary
                                      where return_quantity_rank<={int(top_n)};'''
     product_return_value_query=f'''select stockcode,product_description,{product_return_value_columns}
                                    from product_return_summary
                                    where return_value_rank<={int(top_n)};'''
     return product_return_quantity_query,product_return_value_query
  elif metric=='return_quantity':
       product_return_quantity_query=f'''select stockcode,product_description,{product_return_quantity_columns}
                                      from product_return_summary
                                      where return_quantity_rank<={int(top_n)};'''
       return product_return_quantity_query,product_return_value_query
  elif metric=='return_value':
       product_return_value_query=f'''select stockcode,product_description,{product_return_value_columns}
                                    from product_return_summary
                                    where return_value_rank<={int(top_n)};'''
       return product_return_quantity_query,product_return_value_query

def product_category_return(metric=None):
  product_category_return_quantity_columns='total_return_quantity,return_quantity_rank'
  product_category_return_value_columns='total_return_value,return_value_rank'
  product_category_return_quantity_query=None
  product_category_return_value_query=None
  if metric is None:
     metric='both'
  if metric not in ('return_quantity','return_value','both'):
     raise Exception ("Invalid metric selection")
  else:
     if metric=='both':
        product_category_return_quantity_query=f'''select product_category,{product_category_return_quantity_columns}
                                                  from product_category_return_summary;'''
        product_category_return_value_query=f'''select product_category, {product_category_return_value_columns}
                                                from product_category_return_summary;'''
     elif metric=='return_quantity':
          product_category_return_quantity_query=f'''select product_category,{product_category_return_quantity_columns}
                                                     from product_category_return_summary;'''
     elif metric=='return_value':
          product_category_return_value_query=f'''select product_category,{product_category_return_value_columns}
                                                from product_category_return_summary;'''
  return product_category_return_quantity_query,product_category_return_value_query

def product_department_return(metric=None):
  product_department_return_quantity_columns='total_return_quantity,return_quantity_rank'
  product_department_return_value_columns='total_return_value,return_value_rank'
  product_department_return_quantity_query=None
  product_department_return_value_query=None
  if metric is None:
     metric='both'
  if metric not in ('return_quantity','return_value','both'):
     raise Exception ("Invalid metric selection")
  else:
     if metric=='both':
        product_department_return_quantity_query=f'''select product_department,{product_department_return_quantity_columns}
                                                   from product_department_return_summary;'''
        product_department_return_value_query=f'''select product_department,{product_department_return_value_columns}
                                                from product_department_return_summary;'''
     elif metric=='return_quantity':
          product_department_return_quantity_query=f'''select product_department,{product_department_return_quantity_columns}
                                                   from product_department_return_summary;'''
     elif metric=='return_value':
          product_department_return_value_query=f'''select product_department,{product_department_return_value_columns}
                                                from product_department_return_summary;'''
  return product_department_return_quantity_query,product_department_return_value_query

def customer_return_value(top_n=10):
  try:
    int(top_n)
  except (ValueError,TypeError):
    raise Exception ("Invalid top_n value")
  if type(top_n)==float or type(top_n)==bool or int(top_n)<=0:
     raise Exception('Invalid top_n value')
  else: query=f'''select customer_id,total_return_value,return_value_rank
                  from customer_return_summary
                  where return_value_rank<={int(top_n)};'''
  return query

def country_return_value(top_n=10):
  try:
    int(top_n)
  except (ValueError,TypeError):
    raise Exception ("Invalid top_n value")
  if type(top_n)==float or type(top_n)==bool or int(top_n)<=0:
     raise Exception('Invalid top_n value')
  else: query=f'''select country,total_return_value,return_value_rank
                  from country_return_summary
                  where return_value_rank<={int(top_n)};'''
  return query

"""## Tool Definitions and System Prompt"""

get_monthly_return={
"type":"function",
"name":"get_monthly_return",
"description":"Returns monthly return information, including month, total return quantity, and total return value in one dataset.",
"parameters":{
    "type":"object",
    "description":"For a specific time period, provide all four date parameters. For the entire available period, omit all four.",
    "properties":{
    "start_year":
        {
            "type":"integer",
            "description":"The start year of analysis.",
            "enum":[2010,2011]
        },
    "start_month":
        {
            "type":"integer",
            "description":"The start month of analysis.",
            "minimum":1,
            "maximum":12
        },
    "end_year":
        {
            "type":"integer",
            "description":"The end year of analysis.",
            "enum":[2010,2011]
        },
    "end_month":
        {
            "type":"integer",
            "description":"The end month of analysis.",
            "minimum":1,
            "maximum":12
        }
    }
}
}

get_product_return={
  "type": "function",
    "name": "get_product_return",
    "description": "Returns a product level summary of return quantity, return value, or both, with respective rankings. Each product includes its stock code and product description.",
    "parameters": {
      "type": "object",
      "description": "Both parameters are optional. The default metric is both, and the default top_n is 10.",
      "properties": {
        "metric": {
          "type": "string",
          "description": "The metric to use for the product level return summary.",
          "enum": ["both", "return_quantity", "return_value"]
        },
        "top_n": {
          "type": "integer",
          "description": "The number of top products to return.",
          "minimum": 1
        }
      }
    }
  }


product_category_return={
"type":"function",
"name":"product_category_return",
"description":"Returns a summary of returns by product category based on return quantity, return value, or both, with respective rankings.",
"parameters":{
"type":"object",
 "description":"The metric parameter is optional. The default metric is both.",
 "properties":{
  "metric":{
      "type":"string",
      "description":"The metric to use for the product category level return summary.",
      "enum":["both","return_quantity","return_value"]
  }
 }
}
}

product_department_return={
 "type":"function",
  "name":"product_department_return",
  "description":"Returns a summary of returns by product department based on return quantity, return value, or both, with respective rankings.",
  "parameters":{
  "type":"object",
  "description":"The metric parameter is optional. The default metric is both.",
  "properties":{
      "metric":{
      "type":"string",
      "description":"The metric to use for the product department level return summary.",
      "enum":["both","return_quantity","return_value"]
  }
  }
  }
 }

customer_return_value={
"type":"function",
"name":"customer_return_value",
"description":"Returns customer-level return values and their rankings. Each customer is identified by customer_id.",
"parameters":{
"type":"object",
"description":"The top_n parameter is optional. The default top_n is 10.",
"properties":{
"top_n":{
    "type":"integer",
    "description":"The number of top customers to return.",
    "minimum":1
}
}
}
}

country_return_value={
"type":"function",
"name":"country_return_value",
"description":"Returns a summary of total return value by country with respective rankings.",
"parameters":{
"type":"object",
"description":"The top_n parameter is optional. The default top_n is 10.",
"properties":{
"top_n":{
"type":"integer",
"description":"The number of top countries to return.",
"minimum":1
}
}
}
}

tools=[get_monthly_return,get_product_return,product_category_return,product_department_return,customer_return_value,country_return_value]

system_prompt="""
Database Description:
The database contains records from December 2010 through December 2011. Each row represents a customer's purchase of a product with a specific quantity. A negative quantity represents a return.
You only have access to the all_return_data view, which contains all return records from the same period.
The view contains no duplicate records, and product_unit_price contains no missing or negative values.

The all_return_data view contains the following columns:
customer_id, customer_name, customer_country, membership_type,invoiceno, invoicedate, quantity,
stockcode, product_description,product_unit_price, product_category, product_department

Metric Definitions:
Return quantity and return value must be reported as positive numbers.
Ranking metrics are sorted in descending order.

Available Tools:
Return quantity and return value are presented as positive numbers in tool results. Unless otherwise specified, tools that return both metrics provide return quantity and return value results separately.

Goal:
You are an analyst responsible for analyzing sales return patterns from different perspectives using the available tools and data. Once the investigation is complete, provide a concise report summarizing your findings.

Instructions:
For analysis, you may use the available tools or construct SQL queries. Only construct a SQL query when the available tools do not provide the information required for the analysis. Do not write SQL queries solely to verify results returned by the available tools.
Do not list known facts from the provided information as assumptions. Do not make assumptions about unavailable information, unclear definitions, or undefined metrics.

Before conducting the analysis, present the following for human approval:
- The proposed analysis plan.
- The tools you plan to use.
- The parameter values for each proposed tool call.
- The complete SQL code for any proposed custom SQL query.
- The metric definitions relevant to the analysis.

List any important assumptions requiring human approval in a separate section. If no assumptions are required, explicitly state that no assumptions are being made.
After approval, you may change the analytical approach if newly available information indicates that the original plan is insufficient or inappropriate.
In the final report, include any assumptions made during the analysis and definitions of the metrics used. If an analysis does not reveal a meaningful pattern, it does not need to be included in the final report.
You are prohibited from modifying or deleting data in the database.

"""

"""## Question classification prompt and response format"""

question_classifier_prompt="""You are a classification assistant responsible for determining whether a user's request is asking for data analysis. Respond only with "yes" or "no".
                      Respond "yes" if the user's request asks to analyze, investigate, compare, summarize, identify patterns or trends, calculate metrics, or answer questions using data.

                      Respond "no" if the request:
                      - Is unrelated to data analysis.
                      - Only asks for an explanation of a data analysis, database, statistical, or programming concept.
                      - Is unclear or cannot be understood.
                      - Contains programming or SQL code.
                      - Asks you to write, generate, modify, debug, or execute programming or SQL code."""

question_classifer_answer_format={
"format":{
"type":"json_schema",
"name":"question_classifier",
"strict":True,
"schema":{
    "type":"object",
    "properties":{
        "answer":{
            "type":"string",
            "enum":["yes","no"]
        }
    },
    "required":["answer"],
    "additionalProperties":False
}
}
}

"""## Function to process user questions"""

# classify user question to ensure it is irrelevant
def question_classifcation(question):
    try:
        response=client.responses.create(
                model="gpt-6-luna",
                instructions=question_classifier_prompt,
                text=question_classifer_answer_format,
                input=question)
    except openai.AuthenticationError:
           raise Exception ("Invalid API key")
    except openai.APIConnectionError:
           raise Exception ("Network connection issue")
    except openai.APIStatusError:
           raise Exception ("API Error")
    if response.status=='completed':
        for item in response.output:
            if item.type=='message':
              result=item.model_dump()
              if 'status' in result.keys():
                  if result['status']=='completed':
                      result=json.loads(response.output_text)
                      if 'answer' not in result.keys():
                          raise Exception ("Incorrect Format.")
                      elif str.lower(result['answer']) not in ('yes','no'):
                          raise Exception ("Incorrect Format.")
                      result=str.lower(result['answer'])
                      #print(result)
                      return result
                  else:
                      raise Exception ("Incomplete LLM Response")
              else:
                  raise Exception ("Incomplete LLM Response")
    else:
          raise Exception ("Incomplete LLM Response")

# Process the question for the first time
def first_time_question_process(question):
    try:
        response=client.responses.create(
            model="gpt-5.6-luna",
            instructions=system_prompt,
            input=question,
            tools=tools)
    except openai.AuthenticationError:
          raise Exception ("Invalid API key")
    except openai.APIConnectionError:
          raise Exception ("Network connection issue")
    except openai.APIStatusError:
          raise Exception ("API Error")
    if response.status=='completed':
        for item in response.output:
            if item.type=='message':
                result=item.model_dump()
                if 'status' in result.keys():
                    if result['status']=='completed':
                          #print('Response is good')
                          result=response.output_text
                          message_id=response.id
                          #print(result)
                          #print(message_id)
                          return result,message_id
                    else:
                        raise Exception ("Incompleted LLM Response")
                else:
                    raise Exception ("Incompleted LLM Response")
            else:
              continue
    else:
       raise Exception ("Incompleted LLM Response")

# Process follow up response or tool calls
def user_question_processing(question,previous_message_id):
      function_calls=[]
      try:
          response=client.responses.create(
            model="gpt-5.6-luna",
            previous_response_id=previous_message_id,
            instructions=system_prompt,
            input=question,
            tools=tools)
      except openai.AuthenticationError:
            raise Exception ("Invalid API key")
      except openai.APIConnectionError:
            raise Exception ("Network connection issue")
      except openai.APIStatusError:
            raise Exception ("API Error")

      message_id=response.id
      if response.status=='completed':
          for item in response.output:
              if item.type=='function_call':
                  result=item.model_dump()
                  if 'status' in result.keys():
                      if result['status']=='completed':
                            #print(result)
                            function_call={}
                            for key in result.keys():
                                if key=='arguments':
                                  #print(key)
                                  #print(result[key])
                                  function_call.update({key:result[key]})
                                elif key=='call_id':
                                  #print(key)
                                  #print(result[key])
                                  function_call.update({key:result[key]})
                                elif key=='name':
                                  #print(key)
                                  #print(result[key])
                                  function_call.update({key:result[key]})
                            function_calls.append(function_call)
                            #print(function_call)
                            #print(function_calls)
                      else:
                            raise Exception ("Incomplete LLM Response")
                  else:
                        raise Exception ("Incomplete LLM Response")
      else:
           raise Exception ("Incomplete LLM Response")
      return function_calls,message_id

"""## AI Agent"""

first_run=True
program_status=True
max_attempt=3
processing_request=False
previous_message_id=None

client=OpenAI(api_key=api_key)

while program_status is True:
  question=None
  if max_attempt==0:
     print("Too many irrelevant questions. The program has been stopped.")
     break
  else:
     if first_run is True:
        print("Type exit to exit the program or help for more information.")
        first_run=False
     if processing_request is False:
           question=input("What kind of analysis do you want to perform:")
     elif processing_request is True:
           question=input("\nWhat's your response:")
     #print(question)
     if str.lower(question)=='exit':
      print("The program has been stopped.")
      break
     elif str.lower(question)=='help':
      print("Type exit to exit the program or ask a question to perform data analysis.")
      continue
     else:
          if processing_request is False:
              print("\nQuestion Classification")
              result=question_classifcation(question)
              #print(result)
              if result=='yes':
                  print('This is a relevant question.')
                  processing_request=True
                  result,previous_message_id=first_time_question_process(question)
                  print(f"\nUser question: {question}")
                  print('LLM Response:\n')
                  print(result)
                  #print(previous_message_id)
              elif result=='no':
                    max_attempt=max_attempt-1
                    if max_attempt==0:
                      continue
                    else:
                        print(f"This question is not relevant to Data Analysis, please try it again. You have {max_attempt} chances to rety.")
          else:
                print("\nLLM Starts to process requests.")
                llm_response,previous_message_id=user_question_processing(question,previous_message_id)
                print(llm_response)
                print(previous_message_id)