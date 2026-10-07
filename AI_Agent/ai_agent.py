"""from google.colab import userdata
api_key=userdata.get('OPENAI_API_KEY')
!pip install openai
client=OpenAI(api_key=api_key)"""

import datetime
from datetime import date
from decimal import Decimal
import openai
from openai import OpenAI
import json
import os
import psycopg
from psycopg.rows import dict_row

client=OpenAI()

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
  query={}
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
     query.update({"product_return_quantity_query":product_return_quantity_query})
     query.update({"product_return_value_query":product_return_value_query})
  elif metric=='return_quantity':
       product_return_quantity_query=f'''select stockcode,product_description,{product_return_quantity_columns}
                                      from product_return_summary
                                      where return_quantity_rank<={int(top_n)};'''
       query.update({"product_return_quantity_query":product_return_quantity_query})
       query.update({"product_return_value_query":None})
  elif metric=='return_value':
       product_return_value_query=f'''select stockcode,product_description,{product_return_value_columns}
                                    from product_return_summary
                                    where return_value_rank<={int(top_n)};'''
       query.update({"product_return_quantity_query":None})
       query.update({"product_return_value_query":product_return_value_query})
  return query

def product_category_return(metric=None):
  query={}
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
        query.update({"product_category_return_quantity_query":product_category_return_quantity_query})
        query.update({"product_category_return_value_query":product_category_return_value_query})
     elif metric=='return_quantity':
          product_category_return_quantity_query=f'''select product_category,{product_category_return_quantity_columns}
                                                     from product_category_return_summary;'''
          query.update({"product_category_return_quantity_query":product_category_return_quantity_query})
          query.update({"product_category_return_value_query":None})
     elif metric=='return_value':
          product_category_return_value_query=f'''select product_category,{product_category_return_value_columns}
                                                from product_category_return_summary;'''
          query.update({"product_category_return_quantity_query":None})
          query.update({"product_category_return_value_query":product_category_return_value_query})
  return query

def product_department_return(metric=None):
  query={}
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
        query.update({"product_department_return_quantity_query":product_department_return_quantity_query})
        query.update({"product_department_return_value_query":product_department_return_value_query})
     elif metric=='return_quantity':
          product_department_return_quantity_query=f'''select product_department,{product_department_return_quantity_columns}
                                                   from product_department_return_summary;'''
          query.update({"product_department_return_quantity_query":product_department_return_quantity_query})
          query.update({"product_department_return_value_query":None})
     elif metric=='return_value':
          product_department_return_value_query=f'''select product_department,{product_department_return_value_columns}
                                                from product_department_return_summary;'''
          query.update({"product_department_return_quantity_query":None})
          query.update({"product_department_return_value_query":product_department_return_value_query})
  return query

def customer_return_value(top_n=None):
  if top_n is None:
     top_n=10
  else:
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

def country_return_value(top_n=None):
  if top_n is None:
     top_n=10
  else:
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

def customized_tool_call(query):
    return query

"""## Tool Definitions and System Prompt"""

get_monthly_return_tool={
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

get_product_return_tool={
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


product_category_return_tool={
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

product_department_return_tool={
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

customer_return_value_tool={
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

country_return_value_tool={
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

customized_tool_call_tool={
"type":"function",
"name":"customized_tool_call",
"description":"Execute a custom SQL query when the available analytical tools cannot provide the required information.",
"parameters":{
    "type":"object",
    "description":"Provide the customized SQL query",
    "properties":{
        "query":{
            "type":"string",
            "description":"The customized SQL query you proposed."
        }
    },
    "required":["query"]
}
}

tools=[get_monthly_return_tool,get_product_return_tool,product_category_return_tool,
       product_department_return_tool,customer_return_value_tool,country_return_value_tool,customized_tool_call_tool]

system_prompt="""
Database Description:
The database contains records from December 2010 through December 2011. Each row represents a customer's purchase of a product with a specific quantity. A negative quantity represents a return.
You only have access to the all_return_data view, which contains all return records from the same period.
The view contains no duplicate records, and product_unit_price contains no missing or negative values.
Product_unit_price and all monetary values derived from it are denominated in pound sterling (GBP, £).

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
When constructing custom SQL that filters by a user-provided value, preserve enough information in the query result to distinguish no matching records from a valid zero-valued result.
Do not list known facts from the provided information as assumptions. Do not make assumptions about unavailable information, unclear definitions, or undefined metrics.

In every text response, use the analysis_status field to indicate the purpose of the response:
- Use "processing_request" when the analysis is not complete, including when presenting an analysis plan, requesting human approval, asking the user a question, or providing any other intermediate response.
- Use "final_report" only when the requested analysis has been successfully completed and you are providing the final report.
- Use "cancel_analysis" when the requested analysis cannot be completed with the available data or information, when the user rejects the proposed analysis and does not want to revise it, or when the user explicitly asks to stop/cancel the current analysis.
Use the text_response field for your response to the user, including the final report or the reason the analysis cannot be completed.
Do not include these fields when making tool calls.

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

normal_text_response_format={
"format":{
    "type":"json_schema",
    "name":"text_response_format",
    "strict":True,
    "schema":{
        "type":"object",
        "properties":{
            "analysis_status":{
                "type":"string",
                "description": "Indicates the current outcome of the analysis. Use processing_request when the analysis is still in progress or requires user input, final_report only when the requested analysis has been successfully completed, and cancel_analysis when the analysis cannot be completed with the available information or when the user cancels it.",
                "enum":["processing_request","final_report","cancel_analysis"]
            },
            "text_response":{
              "type":"string",
              "description": "A natural-language response written for the user. Do not return JSON, dictionaries, or other structured data inside this field. Include the final report here when the analysis is complete."
            }   
        },
        "required":["analysis_status","text_response"],
        "additionalProperties":False
}
}    
}

"""## Function to process user questions and clean return query data"""

# classify user question to ensure it is irrelevant
def question_classifcation(user_question):
    try:
        response=client.responses.create(
                model="gpt-6-luna",
                instructions=question_classifier_prompt,
                text=question_classifer_answer_format,
                input=user_question)
    except openai.AuthenticationError:
           raise Exception ("Invalid API key")
    except openai.APIConnectionError:
           raise Exception ("Network connection issue")
    except openai.APIStatusError:
           raise Exception ("API Error")
    # determine if the response is completed
    if response.status!='completed':
           raise Exception ("Incomplete LLM Response")
    elif response.status=='completed':
         # check to ensure the response contain an item with type message
         has_message=False
         for item in response.output:
             if item.type=='message':
                has_message=True
         if has_message==False:
             raise Exception ("Incomplete LLM Response") 
         for item in response.output:
              # only process the actual message and skip other content in response.output
              if item.type=='message':
                llm_output=item.model_dump()
                llm_response=json.loads(response.output_text)
                #llm_output contains more information than the final answer, llm_response is the actual output
                if 'status' not in llm_output.keys() or llm_output['status']!='completed':
                    raise Exception ("Incomplete LLM Response")
                elif 'answer' not in llm_response.keys() or str.lower(llm_response['answer']) not in ('yes','no'):
                    raise Exception ("Incorrect Format.")
                question_classification_result=str.lower(llm_response['answer'])
                #print(question_classification_result)
                return question_classification_result

# Process the question for the first time, take user question and return message_id, actual_text_response and status of a request (processing_request,final_report,cancel_analysis)
def first_time_question_process(user_question):
    try:
        response=client.responses.create(
            model="gpt-5.6-luna",
            instructions=system_prompt,
            input=user_question,
            text=normal_text_response_format,
            tools=tools)
    except openai.AuthenticationError:
          raise Exception ("Invalid API key")
    except openai.APIConnectionError:
          raise Exception ("Network connection issue")
    except openai.APIStatusError:
          raise Exception ("API Error")
    #print('-------------------=====================================')
    #print(response)
    
    if response.status!='completed':
        raise Exception ("Incompleted LLM Response from API")
    else:
        if response.status=='completed':
           has_message=False
           for item in response.output:
                 if item.type=='message':
                    has_message=True
        if has_message==False:
             raise Exception ("Incomplete LLM Response, no message content is found.") 
        for item in response.output:
            if item.type=='message':
                # llm_output contain more than the final text response and response status, comeplete or not from the API
                llm_output=item.model_dump()
                llm_response=json.loads(response.output_text) 
                #llm_response is the text output, it is a dinctionary that contain the status and text response 
                if 'status' not in llm_output.keys() or llm_output['status']!='completed':
                       raise Exception ("Incompleted LLM Response")
                elif 'analysis_status' not in llm_response.keys() or 'text_response' not in llm_response.keys():
                       raise Exception ("Incompleted LLM Response")
                else:
                     analysis_status=llm_response['analysis_status']
                     if analysis_status not in ("processing_request","final_report","cancel_analysis"):
                        raise Exception ("Incorrect format")
                     else: 
                          llm_text_response=llm_response['text_response']
                          message_id=response.id
                          #print(llm_text_response)
                          #print(type(llm_text_response))
                          #print('-----------------------------')
                          #print(message_id)
                          #print('LLM Response')
                          #print(response)
                          return analysis_status,llm_text_response,message_id   

"""## Function to process user response and clean return query data"""
# Process follow up response or tool calls
def user_question_processing(user_response,previous_message_id):      
      function_call_for_python=[]
      analysis_status=None
      llm_text_response=None
      has_message=False
      has_function_call=False
      try:
          response=client.responses.create(
            model="gpt-5.6-luna",
            previous_response_id=previous_message_id,
            instructions=system_prompt,
            input=user_response,
            text=normal_text_response_format,
            tools=tools)
      except openai.AuthenticationError:
            raise Exception ("Invalid API key")
      except openai.APIConnectionError:
            raise Exception ("Network connection issue")
      except openai.APIStatusError:
            raise Exception ("API Error")
      #print('==============------------------------++++++++++++++++++++')
      #print(response)
      if response.status!='completed':
         raise Exception ("Incomplete LLM Response")
      elif response.status=='completed':
           for item in response.output:
                if item.type=='message':
                   has_message=True
                elif item.type=='function_call':
                   has_function_call=True
      if has_message is False and has_function_call is False:
         raise Exception ("Incomplete LLM Response")     
      
      message_id=response.id
      for item in response.output:
              if item.type=='message':
                     llm_output=item.model_dump()
                     llm_response=json.loads(response.output_text) 
                     if 'status' not in llm_output.keys() or llm_output['status']!='completed':
                            raise Exception ("Incompleted LLM Response")
                     elif 'analysis_status' not in llm_response.keys() or 'text_response' not in llm_response.keys():
                            raise Exception ("Incompleted LLM Response")
                     analysis_status=llm_response['analysis_status']
                     if analysis_status not in ("processing_request","final_report","cancel_analysis"):
                            raise Exception ("Incorrect format")
                     else:
                         llm_text_response=llm_response['text_response']
              elif item.type=='function_call':
                      # proposed function call contain additional information besides name, function, call id
                      proposed_function_call=item.model_dump()
                      if 'status' not in proposed_function_call.keys() or proposed_function_call['status']!='completed':
                          raise Exception ("Incompleted LLM Response")
                      if 'name' not in proposed_function_call.keys() or 'arguments' not in proposed_function_call.keys() or 'call_id' not in proposed_function_call.keys():
                          raise Exception ("Incompleted LLM Response")
                      else:
                          function_call={}
                          for key in proposed_function_call.keys(): 
                              #print(key)
                              if key=='arguments':
                                #print(key)
                                #print(proposed_function_call[key])
                                arguments=json.loads(proposed_function_call[key])
                                if len(arguments)==0:
                                    function_call.update({key:None})
                                else:
                                    function_call.update({key:arguments})
                              elif key=='call_id' or key=='name': 
                                function_call.update({key:proposed_function_call[key]})
                          function_call_for_python.append(function_call)
                          #print('========================================================')
                          #print(function_call)
                          #print(function_call_for_python)
      #print(function_call_for_python)
      if len(function_call_for_python)==0:
          function_call_for_python=None
      #print(response)
      return analysis_status,llm_text_response,function_call_for_python,message_id

# Process the return data from PostgreSQL server
def clean_query_data(query_data):
    clean_data=[]
    for item in query_data:
        if type(item)==dict:
            #print(item)
            #print(clean_data)
            #print(row)
            row={}
            for key in item.keys():
                #print(key,item[key])
                if type(item[key])==Decimal:
                  #print(key,float(item[key]))
                  row.update({key:float(item[key])})
                elif type(item[key])==datetime.date:
                    #print(key,str(item[key]))
                    row.update({key:str(item[key])})
                else:
                    #print(key,item[key])
                    row.update({key:item[key]})
            #print(row)
            clean_data.append(row)
            #print("================================")
            #print(clean_data)
        else:
          raise Exception("Unexcpeted return Data Structure")
    return clean_data

# format the tool results as proper LLM input 
def prepare_return_tool_results(call_ids,tool_results):
    input=[]
    for call_id in call_ids:
      #print(call_id)
      #print(tool_results['query_result'][call_id])
      result={
          "type":"function_call_output",
          "call_id":call_id,
          "output":json.dumps(tool_results['query_result'][call_id])
          }
      #print(result)
      input.append(result)
    return input

"======================================================================================================================="
"""## AI Agent"""

first_run=True
program_status=True
max_attempt=3
processing_request=False
previous_message_id=None
try:
    conn=psycopg.connect(host=os.environ["DB_HOST"],
                        dbname=os.environ["DB_NAME"],
                        user=os.environ["DB_USER"],
                        password=os.environ["DB_PASSWORD"],
                        row_factory=dict_row,
                        connect_timeout=5)
except psycopg.Error:
       raise Exception("Database related error, unable to connect to Database.")

while program_status is True:
  user_question=None
  user_response=None
  if max_attempt==0:
     print("Too many irrelevant questions. The program has been stopped.")
     break
  else:
     if first_run is True:
        print("Type exit to exit the program, reset to start a new conversation or help for more information.")
        first_run=False
     if processing_request is False:
           user_question=input("What kind of analysis do you want to perform:")
           if type(user_question)==str and len(user_question)==0:
                   print("We didn’t receive a question. Please enter a question and try again.")
                   print()
                   continue
     elif processing_request is True:
           user_response=input("\nWhat's your response:")
           if type(user_response)==str and len(user_response)==0:
                   print("We didn’t receive a response. Please enter a response and try again.")
                   print()
                   continue
     #print(question)
     # verify if the user input is exit or help before continue
     if user_question is not None and user_response is None:
        user_input=user_question
     elif user_question is None and user_response is not None:
        user_input=user_response
     if str.lower(user_input)=='exit':
            print("The program has been stopped.")
            break
     elif str.lower(user_input)=='help':
            print("Type exit to exit the program, reset to start a new conversation or ask a question to perform data analysis.")
            continue
     elif str.lower(user_input)=='reset':
            processing_request=False
            print("This Conversation is ended by user, you will start a new conversation.")
            print("==============================================================")
     else:
          if processing_request is False:
              print("============================================================================")
              print("\nQuestion Classification")
              question_classifcation_result=None
              question_classifcation_result=question_classifcation(user_question)
              #print(question_classifcation_result)
              if question_classifcation_result=='yes':
                  print('This is a relevant question.')
                  processing_request=True
                  analysis_status,llm_text_response,previous_message_id=first_time_question_process(user_question)
                  print(f"\nUser question: {user_question}")
                  print('LLM Response:\n')
                  if analysis_status=='cancel_analysis':
                       print(llm_text_response)
                       print("========================================================================")
                       processing_request=False
                       previous_message_id=None
                       continue
                  else:
                       print(analysis_status)
                       print(llm_text_response)
                       #print(previous_message_id)
              elif question_classifcation_result=='no':
                    max_attempt=max_attempt-1
                    if max_attempt==0:
                      continue
                    else:
                        print(f"This question is not relevant to Data Analysis, please try it again. You have {max_attempt} chances to retry.")
          else:
                print("============================================================================")
                print("\nLLM Starts to process requests.")
                print("Your response:",user_response)
                analysis_status,llm_text_response,function_calls,previous_message_id=user_question_processing(user_response,previous_message_id)
                #print('++++++++++++++++++++++++++++++++++++++++++')
                #print(analysis_status)
                #print(llm_text_response)
                # if this is a text response from LLM print out the result
                if analysis_status is not None and llm_text_response is not None and function_calls is None:
                    if analysis_status=='cancel_analysis':
                         print(llm_text_response)
                         processing_request=False
                         print("==============================================================")
                         continue
                    elif analysis_status=="processing_request":
                         print(llm_text_response)
                         continue
                elif analysis_status is None and llm_text_response is None and function_calls is not None:
                        #print('=================================')
                        #print(function_calls)
                        #print(previous_message_id)
                    performing_tool_call=True
                    while performing_tool_call is True:
                        tool_results={}
                        query_result={}
                        call_ids=[]
                        for item in function_calls:
                            #print(item)
                            function_name=item['name']
                            call_id=item['call_id']
                            arguments=item['arguments']
                            #print(function_name)
                            if function_name in ("get_monthly_return","customer_return_value",'country_return_value','customized_tool_call'):
                                #print('++++++++++++++++++++++++++')
                                #print(function_name)
                                #print(call_id)
                                query=None
                                data=None
                                if function_name=="get_monthly_return":
                                    if arguments is None or (arguments['start_year'] is None and arguments['start_month'] is None and arguments['end_year'] is None and arguments['end_month'] is None):
                                            query=get_monthly_return()
                                    elif arguments['start_year'] is not None and arguments['start_month'] is not None and arguments['end_year'] is not None and arguments['end_month'] is not None:
                                            start_month,end_month=generate_date_value(arguments['start_year'],arguments['start_month'],arguments['end_year'],arguments['end_month'])
                                            #print("start_month:", start_month,"end_month:", end_month)
                                            query=get_monthly_return(start_month,end_month)
                                elif function_name=="customer_return_value":
                                    if arguments is None or "top_n" not in arguments.keys():
                                            query=customer_return_value()
                                    else:
                                            query=customer_return_value(top_n=arguments["top_n"])
                                elif function_name=='country_return_value':
                                    if arguments is None or "top_n" not in arguments.keys():
                                            query=country_return_value()
                                    else:
                                            query=country_return_value(top_n=arguments['top_n'])
                                elif function_name=="customized_tool_call":
                                    if arguments is None or 'query' not in arguments.keys():
                                        raise Exception ("Incomplete LLM response")
                                    else:
                                        query=customized_tool_call(query=arguments["query"])
                                #print(query)
                                if query is None:
                                        raise Exception ("SQL query does not exist.")
                                else:
                                        try:
                                                with conn.cursor() as cur:
                                                    cur.execute(query)
                                                    data=cur.fetchall()
                                                    #print(data)
                                        except psycopg.Error:
                                                raise Exception("Database related error")
                                        clean_data=clean_query_data(data)
                                        call_ids.append(call_id)
                                        query_result.update({call_id:clean_data})
                                        #print('===========================================')
                                        #print(clean_data)
                                        #print(len(clean_data))
                                        #print(query_result)
                            elif function_name in ("get_product_return","product_category_return","product_department_return"):
                                #print('+++++++++++++++++++++++++++++++++')
                                #print(function_name)
                                query=None
                                data={}
                                if function_name=="get_product_return":
                                    metric=None
                                    top_n=None
                                    if arguments is None:
                                        query=get_product_return(metric=metric,top_n=top_n)
                                    else:
                                        if "metric" in arguments.keys():
                                            metric=arguments["metric"]
                                        if "top_n" in arguments.keys():
                                            top_n=arguments["top_n"]
                                        query=get_product_return(metric=metric,top_n=top_n)
                                elif function_name =='product_category_return':
                                    if arguments is None or "metric" not in arguments.keys():
                                            query=product_category_return()
                                    else:
                                            query=product_category_return(metric=arguments["metric"])
                                elif function_name=='product_department_return':
                                    if arguments is None or "metric" not in arguments.keys():
                                            query=product_department_return()
                                    else:
                                            query=product_department_return(metric=arguments["metric"])
                                #print(query)
                                for key in query.keys():
                                    query_data=None
                                    if query[key] is not None:
                                        query_name=key+'_data'
                                        #print(query_name)
                                        #print(query[key])
                                        try:
                                            with conn.cursor() as cur:
                                                cur.execute(query[key])
                                                query_data=cur.fetchall()
                                        except psycopg.Error:
                                                raise Exception("Database related error")
                                        clean_data=clean_query_data(query_data)
                                        #print('+++++++++++++++++++++++++++++++++')
                                        #print(clean_data)
                                        #print(len(clean_data))
                                        #print('+++++++++++++++++++++++++++++++++')
                                        data.update({query_name:clean_data})
                                call_ids.append(call_id)
                                query_result.update({call_id:data})
                                #print(query_result)
                        tool_results.update({"previous_message_id":previous_message_id})
                        tool_results.update({"query_result":query_result})
                        #print('=============================================')
                        #print('Call ID')
                        #print(call_ids)
                        #print("Tool results")
                        print("\nTool results are ready")
                        print("\nSend Tool results back to LLM")
                        #print(tool_results)
                        previous_message_id=tool_results['previous_message_id']
                        return_results=prepare_return_tool_results(call_ids,tool_results)
                        analysis_status,llm_text_response,function_calls,previous_message_id=user_question_processing(return_results,previous_message_id)
                        #print('===============================================')
                        if analysis_status is not None and llm_text_response is not None and function_calls is None:
                               if analysis_status=="final_report":
                                        print("==============================================================")
                                        print("\nFinal Report")
                                        print()
                                        print()
                                        print(llm_text_response)
                                        print()
                                        print()
                                        print("Analysis is completed, you can start a new analysis now by press enter, or ask follow up questions.")
                                        user_question=(input("What questions do you have?"))
                                        if len(user_question)==0 or str.lower(user_question)=='reset':
                                            processing_request=False
                                            print("This Conversation is ended by user, you will start a new conversation.")
                                            print("==============================================================")
                                            break
                                        elif str.lower(user_question)=='exit':
                                             program_status=False
                                             break
                                        else:
                                            analysis_status,llm_text_response,function_calls,previous_message_id=user_question_processing(user_question,previous_message_id)
                                            if analysis_status is not None and llm_text_response is not None and function_calls is None:
                                                    if analysis_status=='cancel_analysis':
                                                       #print(analysis_status)
                                                        print(llm_text_response)
                                                        processing_request=False
                                                        print("This Conversation is ended by user, you will start a new conversation.")
                                                        print("==============================================================")
                                                        break
                                                    else:
                                                         print(llm_text_response)
                                                         break
                                            elif analysis_status is None and llm_text_response is None and function_calls is not None:
                                                    print("Perform another tool call based on response from LLM")
                                                    #print(function_calls)
                                                    continue
                               elif analysis_status=="processing_request":
                                        print(llm_text_response)
                                        break
                        elif analysis_status is None and llm_text_response is None and function_calls is not None:
                               print("Perform another tool call based on response from LLM")
                               #print(function_calls)
                               continue
                    continue
if program_status is False:
   print("The program has been stopped.")