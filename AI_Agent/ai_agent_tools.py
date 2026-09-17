from datetime import date

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